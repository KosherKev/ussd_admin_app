# User Flow: Connected Project Developer

## Who They Are

The connected project developer works for an organization that uses PayHub as their payment backbone. They are building or maintaining a web portal, mobile app, or back-office system that initiates payments, generates USSD codes, and listens for webhooks. They authenticate exclusively with an **API key** — never a JWT. They never touch the admin routes.

They have received from the super admin:
- A `sk_live_...` key for production
- A `sk_test_...` key for development and CI

---

## Flow 1 — Development & Test Setup

```
1. Store keys in environment variables
   PAYHUB_API_KEY_LIVE=sk_live_...
   PAYHUB_API_KEY_TEST=sk_test_...
   PAYHUB_BASE_URL=https://api.payhub.com

2. Verify test key works
   GET /api/v1/payments/FAKE-REF/status
   Headers: { Authorization: "Bearer sk_test_..." }
   →  404 NOT_FOUND (expected — key auth succeeded, transaction doesn't exist)
   →  Check response headers: x-ratelimit-limit: 60

3. Simulate a normal mobile money payment (push prompt)
   POST /api/v1/payments/initiate
   Body: { amount: 100.00, customer: { phone: "0244111111", network: "MTN" },
           paymentType: "school_fees" }
   →  202: { status: "processing", otpRequired: false, environment: "test" }
   →  amount ending in .00 → simulates push prompt accepted (no OTP)

4. Simulate an OTP-required payment
   POST /api/v1/payments/initiate
   Body: { amount: 100.01, ... }
   →  202: { status: "processing", otpRequired: true,
             _links: { submitOtp: "/api/v1/payments/TXN-.../submit-otp" } }
   →  amount ending in .01 → simulates networks that require OTP

   Then submit the OTP:
   POST /api/v1/payments/TXN-.../submit-otp
   Body: { otp: "123456" }
   →  { status: "completed" }
   →  Any OTP except "000000" succeeds in test mode
   →  otp "000000" → { error: "OTP_REJECTED", status: "failed" }

5. Simulate a decline
   POST /api/v1/payments/initiate
   Body: { amount: 100.99, ... }
   →  { success: false, error: "GATEWAY_ERROR" }
   →  amount ending in .99 always declines in test mode

6. Test card checkout
   POST /api/v1/payments/checkout
   Body: { amount: 150, customer: { email: "test@school.edu.gh" }, paymentType: "school_fees" }
   →  { checkoutUrl: "http://localhost:3001/api/v1/test/checkout-simulator?ref=TXN-..." }
   →  Open checkoutUrl in browser — auto-completes after 2 seconds
```

---

## Flow 2 — Mobile Money Payment (Headless) — Normal Push

**Use case:** Customer is on the school portal. They choose "Pay via Mobile Money", enter their number and network. Their network supports MoMo push prompts directly — no OTP required.

```
1. Your server calls PayHub
   POST /api/v1/payments/initiate
   Headers: { Authorization: "Bearer sk_live_...", x-idempotency-key: "<uuid>" }
   Body: {
     amount: 250,
     customer: { phone: "0244111111", network: "MTN", name: "Kofi Mensah" },
     paymentType: "school_fees",
     metadata: { studentId: "STU-2024-001", term: "Term 2" }
   }
   →  202: {
        transactionRef: "TXN-...",
        status: "processing",
        otpRequired: false,
        message: "Payment prompt sent to the subscriber...",
        _links: { status: "/api/v1/payments/TXN-.../status" }
      }

2. Your UI shows "Waiting for customer approval" with a spinner
   →  A push prompt appears on the customer's phone
   →  Customer enters their MoMo PIN to approve

3. Poll for result (if not using webhooks)
   GET /api/v1/payments/TXN-.../status
   →  Poll every 5s, exponential backoff, max 30s interval
   →  { status: "completed" | "failed" | "processing" }

4. On webhook (preferred):
   PayHub POSTs to your webhookUrl:
   {
     "event": "payment.completed",
     "transactionRef": "TXN-...",
     "amount": 250,
     "customer": { "phone": "233244111111", "network": "MTN" },
     "metadata": { "studentId": "STU-2024-001" }
   }

5. Verify the webhook signature before trusting it
   const expected = 'sha256=' + hmac(webhookSecret, rawBody)
   if (expected !== req.headers['x-payhub-signature']) reject()

6. Mark student's account as paid in your database
```

**Retry safety:** Always include `x-idempotency-key: <uuid>` on initiate calls. If your request times out and you retry, PayHub returns the original response — no duplicate charge.

---

## Flow 3 — Mobile Money Payment (Headless) — OTP Required

**Use case:** Same setup as Flow 2, but Paystack returns `send_otp` instead of firing a push prompt. This happens for certain networks or account configurations where Paystack requires the subscriber to verify via a one-time password. The response from `/initiate` signals this with `otpRequired: true`.

Your server must detect this flag and collect the OTP from the subscriber before calling `/submit-otp` to complete the charge.

```
1. Initiate the payment (same as Flow 2, Step 1)
   POST /api/v1/payments/initiate
   Headers: { Authorization: "Bearer sk_live_...", x-idempotency-key: "<uuid>" }
   Body: {
     amount: 250,
     customer: { phone: "0244111111", network: "MTN", name: "Kofi Mensah" },
     paymentType: "school_fees",
     metadata: { studentId: "STU-2024-001" }
   }
   →  202: {
        transactionRef: "TXN-...",
        status: "processing",
        otpRequired: true,
        message: "An OTP has been sent to the subscriber's phone. Collect it and POST to /submit-otp.",
        _links: {
          submitOtp: "/api/v1/payments/TXN-.../submit-otp",
          status:    "/api/v1/payments/TXN-.../status"
        }
      }

2. Your UI detects otpRequired: true
   →  Show an OTP input field to the customer:
      "A code has been sent to your phone. Enter it below to complete payment."
   →  Subscriber checks their SMS and enters the OTP

3. Your server submits the OTP to PayHub
   POST /api/v1/payments/TXN-.../submit-otp
   Headers: { Authorization: "Bearer sk_live_...", x-idempotency-key: "<uuid>" }
   Body: { otp: "847291" }

   Success response:
   →  200: {
        transactionRef: "TXN-...",
        status: "completed",          ← or "processing" if gateway needs more time
        gatewayStatus: "success",
        message: "Payment completed successfully.",
        _links: { status: "/api/v1/payments/TXN-.../status" }
      }

   OTP rejected response:
   →  400: {
        error: "OTP_REJECTED",
        status: "failed",
        message: "The OTP was not accepted by the payment gateway. The transaction has been marked as failed."
      }
      →  Transaction is now permanently failed — do not retry /submit-otp
      →  If the customer wants to try again, call POST /initiate again (new transaction)

4. Webhook fires on terminal status
   PayHub POSTs payment.completed or payment.failed to your webhookUrl
   →  Same shape as Flow 2, Step 4

5. Mark student's account as paid (or show failure message)
```

**Error states you must handle on `submit-otp`:**

| Error code | Meaning | What to do |
|---|---|---|
| `OTP_REJECTED` (400) | Gateway declined the OTP | Show failure, let customer retry from scratch via new `/initiate` |
| `OTP_NOT_EXPECTED` (400) | Transaction didn't need an OTP | Bug in your code — check `otpRequired` flag before calling |
| `INVALID_TRANSACTION_STATE` (400) | Transaction already completed or failed | Do not retry — show current status |
| `NOT_FOUND` (404) | Invalid `transactionRef` | |
| `FORBIDDEN` (403) | This transaction belongs to a different API key | |

**OTP expiry:** Paystack OTPs have a short validity window (typically a few minutes). If the subscriber takes too long, the `/submit-otp` call will return `OTP_REJECTED`. Start a visible countdown timer in your UI and prompt the customer to act quickly. If the OTP expires, the customer must initiate a fresh payment.

---

## Flow 4 — Hosted Card Checkout

**Use case:** Customer wants to pay by card. You redirect them to a Paystack-hosted page.

```
1. Create checkout session
   POST /api/v1/payments/checkout
   Body: {
     amount: 150,
     customer: { email: "ama@gmail.com", name: "Ama Boateng" },
     paymentType: "pta_dues",
     redirectUrl: "https://xyzschool.edu.gh/payment/result"
   }
   →  201: { checkoutUrl: "https://checkout.paystack.com/czs11slwz9qyfmo", expiresAt: "..." }

   ⚠ redirectUrl must be at the TOP LEVEL of the request body.
     Do NOT nest it inside customer: { redirectUrl: "..." } — it will be silently ignored
     and the customer will land on PayHub's fallback HTML page instead of your app.

2. Redirect customer's browser to checkoutUrl

3. Customer pays on Paystack (card entry, 3DS)

4. Paystack → PayHub return handler → PayHub fires webhook → PayHub redirects customer
   Customer lands on: https://xyzschool.edu.gh/payment/result?ref=TXN-...&status=completed

5. Your result page reads ?status= and shows the outcome

6. Your webhook endpoint also receives payment.completed / payment.failed

7. If webhook missed (e.g. customer closed browser early):
   POST /api/v1/payments/TXN-.../verify
   →  { status: "completed", changed: true }
```

**If redirectUrl is not set:** The return handler renders a plain HTML status page instead of bouncing the customer back to your app. This is acceptable in development but always supply `redirectUrl` in production.

**In test mode:** `checkoutUrl` points to PayHub's built-in checkout simulator — no card entry required. The simulator auto-completes after 2 seconds and redirects to your `redirectUrl` (or the HTML fallback page if none was set).

---

## Flow 5 — USSD Code Bridge

**Use case:** A school staff member is signing in a student who has no smartphone. The cashier's portal generates a code, prints it or reads it out, and the student/parent pays by dialling in.

```
1. Generate a 4-digit code
   POST /api/v1/payments/ussd-code
   Headers: { Authorization: "Bearer sk_live_..." }
   Body: {
     amount: 75,
     paymentType: "pta_dues",
     description: "Term 2 PTA Dues — STU-2024-042",
     metadata: { studentId: "STU-2024-042" }
   }
   →  201: {
         code: "3924",
         transactionRef: "TXN-...",
         expiresAt: "...",
         expiresInSeconds: 300,
         dialString: "*920*123#",
         instructions: "Dial *920*123#, select \"Pay with Code\", enter 3924"
      }

2. Display on cashier's screen (and optionally print / SMS to parent):
   ┌────────────────────────────────────┐
   │  Dial *920*123# on your phone      │
   │  Select "Pay with Code"            │
   │  Enter code: 3924                  │
   │  Code expires in 5 minutes         │
   └────────────────────────────────────┘

3. Parent dials *920*123# on their MoMo phone
   → Selects "Make Payment" → selects "Pay with Code" → enters 3924 → approves

4. PayHub fires webhook to your webhookUrl:
   { event: "payment.completed", transactionRef: "TXN-...", metadata: { studentId: "..." } }

5. Your portal marks the student paid

6. If code expires before customer dials:
   Generate a new code (POST /ussd-code again)
   The old code is automatically discarded
```

---

## Flow 6 — Signing Requests (Optional Extra Security)

**Use case:** Developer wants to protect their API calls with an HMAC signature in addition to the Bearer key.

```javascript
function signRequest(body, secret) {
  const timestamp = Math.floor(Date.now() / 1000).toString();
  const rawBody   = JSON.stringify(body);
  const sig = crypto.createHmac('sha256', secret)
    .update(`${timestamp}.${rawBody}`).digest('hex');
  return { 'x-timestamp': timestamp, 'x-signature': sig };
}

const sigHeaders = signRequest(payload, process.env.PAYHUB_SIGNING_SECRET);

await fetch('https://api.payhub.com/api/v1/payments/initiate', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${apiKey}`,
    'Content-Type': 'application/json',
    ...sigHeaders
  },
  body: JSON.stringify(payload)
});
```

PayHub verifies the signature server-side. Requests older than 5 minutes are rejected (replay protection).

---

## Flow 7 — Developer Dashboard (API Key Stats & Usage)

**Who this is for:** The org admin viewing the Developer tab of their PayHub dashboard. The dashboard calls these endpoints using the **same JWT Bearer token** from the admin session — no API key required.

**How the dashboard resolves the correct org:**

```
1. GET /api/auth/me
   → { user: { organizationId: "69a1ef...", apiKeyId: "69a27c...", ... } }
   → Store organizationId — used for all org-scoped dashboard calls
   → apiKeyId is informational only (most recently active key); not used as a URL param
```

**Loading the usage overview:**

```
2. GET /api/orgs/:organizationId/usage?from=<iso>&to=<iso>
   Headers: { Authorization: "Bearer <session_token>" }
   →  {
        success: true,
        data: {
          key: {
            id: "69a27c...",
            projectName: "HostelConnect Live",
            environment: "live",
            keyPrefix: "sk_live_34ac****",
            isActive: true,
            lastUsedAt: "2026-03-04T11:32:00.000Z",
            lifetimeUsage: { totalRequests: 1200, totalPayments: 920, totalVolume: 18400.0 }
          },
          period: { from: "...", to: "...", days: 30 },
          transactions: {
            total: 920, completed: 884, failed: 36, processing: 0,
            successRate: 96.1,
            totalVolume: 18400.0, totalNetVolume: 17840.0, totalCommission: 560.0,
            byChannel: { mobileMoney: 680, card: 205, ussdBridge: 35 }
          },
          webhooks: { total: 920, delivered: 901, failed: 12, retrying: 7, successRate: 97.9 },
          daily: [ { date: "2026-03-01", total: 45, completed: 43, volume: 900.0 }, ... ]
        }
      }
   →  If the org has no active API key yet, data.key is null
   →  Transactions aggregate ALL sources (API, USSD, web) for the org
```

**Loading the Webhooks tab:**

```
3. GET /api/orgs/:organizationId/webhook-deliveries?page=1&limit=20
   Headers: { Authorization: "Bearer <session_token>" }
   →  { success: true, page: 1, total: 143, items: [
         { transactionRef: "TXN-...", event: "payment.completed",
           status: "delivered", attemptCount: 1,
           attempts: [ { attemptedAt: "...", responseStatus: 200, durationMs: 142 } ] }
      ] }

   Filter to a specific transaction:
   GET /api/orgs/:organizationId/webhook-deliveries?transactionRef=TXN-...

   Filter by status:
   GET /api/orgs/:organizationId/webhook-deliveries?status=permanently_failed
```

**Managing API keys (org admin self-service):**

```
4. List my org's keys
   GET /api/v1/keys
   Headers: { Authorization: "Bearer <session_token>" }
   →  Only keys for this org are returned (scoped automatically by role)

5. Provision a new key
   POST /api/v1/keys
   Body: { projectName: "HostelConnect Staging", environment: "test",
           scopes: ["payments:write", "payments:read"],
           webhookUrl: "https://staging.hostelconnect.app/webhooks/payhub" }
   →  { secretKey: "sk_test_...", keyPrefix: "sk_test_xxxx****", ... }
   →  Store secretKey immediately — shown only once

6. Revoke a key
   DELETE /api/v1/keys/:id
   →  { message: "Key for 'HostelConnect Staging' has been revoked." }

   Note: org_admin cannot grant keys:manage or payments:split_override.
   If those scopes are needed, request them from the super admin.
```

---

## Flow 8 — Debugging Webhook Deliveries

**Use case:** Developer notices a payment completed but their server didn't receive the webhook.

```
1. List recent delivery records for the transaction (Bearer auth)
   GET /api/orgs/:organizationId/webhook-deliveries?transactionRef=TXN-...
   Headers: { Authorization: "Bearer <session_token>" }
   →  [ { status: "permanently_failed", attemptCount: 7,
           attempts: [ { responseStatus: 503, durationMs: 9800 }, ... ] } ]

2. Common issues:
   - responseStatus 404 → webhook URL path changed
     → update via: PATCH /api/v1/keys/:id  Body: { webhookUrl: "..." }
   - responseStatus 401 → your server is rejecting PayHub's requests
     → check your signature verification logic (see Flow 6)
   - timeout (durationMs > 10000) → your handler is too slow
     → acknowledge with 200 immediately, process async

3. Once fixed, the next real payment will trigger a fresh delivery
   (Failed deliveries are not re-triggered manually — wait for the next event)
```

> The `/api/orgs/:id/webhook-deliveries` endpoint uses Bearer JWT auth. The older `/v1/webhooks/deliveries` endpoint requires an `x-api-key` header and is for server-to-server use. Use the org endpoint from the dashboard.

---

## Flow 9 — Split Code Override (External Platforms)

**Who this is for:** Developers building platforms where each merchant has their own Paystack subaccount — for example, a rental platform where each property manager receives their share of rent directly, or a marketplace where each seller gets paid out independently.

**Prerequisites:** Your API key must have the `payments:split_override` scope, granted by the PayHub super admin. Without it, the `splitCode` field in your request body is silently ignored.

---

**Use case:** Tenant pays rent. The rental platform has pre-created a Paystack split code for the property manager. The platform passes the manager's split code on each charge so Paystack automatically splits the funds between the manager and the platform in real time — no manual payout run needed.

```
1. Your platform has already created the Paystack split for this manager
   →  You have: splitCode = "SPL_mgr_abc123"
   →  This lives in your own database against the manager's property

2. Tenant initiates a rent payment on your platform

3. Your server calls PayHub with the manager's split code
   POST /api/v1/payments/initiate
   Headers: { Authorization: "Bearer sk_live_...", x-idempotency-key: "<uuid>" }
   Body: {
     amount: 1200,
     paymentType: "rent",
     splitCode: "SPL_mgr_abc123",
     customer: { phone: "0244111111", network: "MTN", name: "Tenant Name" },
     metadata: { propertyId: "PROP-007", managerId: "MGR-042" }
   }
   →  202: { transactionRef: "TXN-...", status: "processing", ... }

4. Paystack receives the charge with SPL_mgr_abc123
   →  Paystack splits automatically:
      e.g. 85% → manager's settlement account
           15% → platform's main Paystack account
   →  No manual payout job required for this manager

5. Webhook fires when tenant approves the MoMo prompt
   PayHub POSTs to your webhookUrl:
   {
     "event": "payment.completed",
     "transactionRef": "TXN-...",
     "amount": 1200,
     "metadata": { "propertyId": "PROP-007", "managerId": "MGR-042" }
   }

6. Your platform marks the tenancy as paid for this period
```

**For card checkout (same pattern):**
```
POST /api/v1/payments/checkout
Body: {
  amount: 1200,
  paymentType: "rent",
  splitCode: "SPL_mgr_abc123",
  redirectUrl: "https://yourplatform.com/payment/complete",
  customer: { email: "tenant@email.com" }
}
```

**What happens if the split code is wrong or expired:**
- Paystack rejects the charge
- PayHub returns `502 GATEWAY_ERROR`
- Your platform should catch this and surface the error — the manager's Paystack subaccount or split code may need to be re-created

**What happens if your key lacks `payments:split_override`:**
- `splitCode` field is ignored silently — no error returned
- The transaction proceeds without any split (or uses the org-level split if one is configured)
- Contact the PayHub super admin to have the scope added to your key

**Split code lifecycle (your responsibility):**
```
Manager signs up on your platform
  → Your backend creates Paystack subaccount (POST https://api.paystack.co/subaccount)
  → Your backend creates split code (POST https://api.paystack.co/split)
  → Store split_code in your DB against the manager

Manager is verified / activated
  → Begin passing their splitCode on each payment

Manager account suspended
  → Stop passing their splitCode
  → New transactions go without a split (or use a default platform split)

Manager account closed
  → Archive their split_code in your DB
  → Optionally deactivate subaccount in Paystack
```

PayHub has no visibility into your managers' subaccounts. You own the full merchant lifecycle.

---

## Rate Limit Handling

```javascript
async function callPayHub(url, options, retries = 3) {
  const res = await fetch(url, options);

  if (res.status === 429) {
    const retryAfter = parseInt(res.headers.get('retry-after') || '10', 10);
    if (retries > 0) {
      await new Promise(r => setTimeout(r, retryAfter * 1000));
      return callPayHub(url, options, retries - 1);
    }
  }

  return res;
}
```

The `x-ratelimit-remaining` header is present on every response. Build dashboards to alert when it consistently reaches 0.

---

## Test Simulator Reference

| Amount ending | Gateway result | `otpRequired` | Next step |
|---|---|---|---|
| `.00` | Push prompt sent (success) | `false` | Poll or await webhook |
| `.01` | OTP required | `true` | Collect OTP → POST `/submit-otp` |
| `.99` | Declined | — | `GATEWAY_ERROR` returned immediately |
| anything else | Push prompt sent (processing) | `false` | Poll or await webhook |

| OTP value (test mode) | Result |
|---|---|
| Any value except `000000` | OTP accepted → `completed` |
| `000000` | OTP rejected → `OTP_REJECTED` → transaction `failed` |
