# User Flow: Organization Admin (org_admin)

## Who They Are

The org admin is the primary administrator for a single client organization — a school bursar, a church treasurer, a business finance manager. They manage their own organization's settings, view their transactions and reports, and have the option to manage their connected project via the API key given to them by the super admin.

Their JWT contains `role: "org_admin"` and `organizationId: "<their_org_id>"`. They can only ever see and edit their own organization's data.

---

## Flow 1 — Initial Login & Account Setup

**Trigger:** Super admin provisions the org and hands over login credentials.

```
1. Sign in
   POST /api/auth/login
   Body: { email: "bursar@xyzschool.edu.gh", password: "..." }
   →  JWT token (12h expiry)

2. Check own profile
   GET /api/auth/me
   →  { id, firstName, role: "org_admin", organizationId: "..." }

3. View their organization record
   GET /api/orgs
   →  returns only their own org (scoped automatically)

4. Update contact details if needed
   PATCH /api/orgs/:id
   Body: { phone: "...", email: "...", settings: { sendReceiptSMS: true } }
```

---

## Flow 2 — Managing Payment Types

**Trigger:** School wants to add a new fee category for a new term.

```
1. View current payment types
   GET /api/orgs/:id/payment-types
   →  [ { id: "school_fees", name: "School Fees", enabled: true, minAmount: 100 }, ... ]

2. Add a new type
   POST /api/orgs/:id/payment-types
   Body: {
     typeId: "excursion_fee",
     name: "Excursion Fee",
     description: "Year 3 Accra Zoo trip",
     minAmount: 50,
     maxAmount: 200,
     enabled: true
   }

3. Temporarily disable a type (e.g. school is on break)
   PATCH /api/orgs/:id/payment-types/school_fees
   Body: { enabled: false }

4. Re-enable
   PATCH /api/orgs/:id/payment-types/school_fees
   Body: { enabled: true }

5. Adjust amount limits
   PATCH /api/orgs/:id/payment-types/pta_dues
   Body: { minAmount: 20, maxAmount: 80 }
```

---

## Flow 3 — Viewing Transactions & Reports

**Trigger:** End of term — bursar needs to reconcile payments received.

```
1. View all transactions for the term
   GET /api/reports/transactions
   Params: {
     organizationId: "<own_org_id>",
     startDate: "2026-01-01",
     endDate: "2026-03-31",
     status: "completed"
   }
   →  paginated list of completed payments
   →  Subscription payments (PayHub platform fees) are never shown here —
      they are internal billing records visible to super admin only

2. Filter by payment type
   GET /api/reports/transactions
   Params: { organizationId: "...", status: "completed" }
   →  filter further by paymentType field in results (all types except "subscription")

3. Get a monthly summary
   GET /api/reports/orgs/:id/summary
   Params: { startDate: "2026-02-01", endDate: "2026-02-28" }
   →  { totalVolume: 71750, totalNetVolume: 69597.50, completedTransactions: 287 }
   →  totalVolume and completedTransactions reflect your collected payments only —
      subscription payments to PayHub are excluded from these figures

4. Check subscription expiry
   GET /api/subscriptions/:id/status
   →  { subscription: { endDate: "2026-03-28" }, ussdEnabled: true }
   →  If approaching expiry, initiate a renewal payment (see Flow 5)

5. Check available USSD numbers (if not yet assigned one)
   GET /api/ussd/free-codes
   →  { total: 994, codes: [1, 2, 3, 4, 6, 7, ...] }
   →  Share a preferred number with the super admin — they will assign it via PATCH /api/orgs/:id
```

---

## Flow 4 — Managing API Keys & Developer Dashboard

**Trigger:** Org admin needs to integrate their web portal with PayHub, or wants to review transaction analytics.

```
1. Self-provision an API key (no longer requires super admin)
   POST /api/v1/keys
   Headers: { Authorization: "Bearer <JWT>" }
   Body: {
     projectName: "XYZ School Portal",
     environment: "live",
     scopes: ["payments:write", "payments:read", "ussd:write"],
     webhookUrl: "https://xyzschool.edu.gh/webhooks/payhub",
     webhookSecret: "<generated>"
   }
   →  secretKey returned ONCE — store it immediately as an environment variable
   →  organizationId is automatically set to your own org (cannot be overridden)
   →  Elevated scopes (keys:manage, payments:split_override) require super admin — request if needed

2. List your org's keys
   GET /api/v1/keys
   →  Only keys for your org are returned

3. Update a key's webhook URL
   PATCH /api/v1/keys/:id
   Body: { webhookUrl: "https://new.xyzschool.edu.gh/webhooks/payhub" }

4. Revoke a key (soft delete — preserves audit trail)
   DELETE /api/v1/keys/:id

5. View usage analytics (Developer Dashboard)
   GET /api/orgs/:id/usage?from=<iso>&to=<iso>
   Headers: { Authorization: "Bearer <JWT>" }
   →  Aggregated transaction counts, volumes, success rates, daily breakdown
   →  Includes summary of the org's most recently active API key
   →  Also available via GET /api/v1/keys/:keyId/usage for a single key

6. View webhook delivery history
   GET /api/orgs/:id/webhook-deliveries?page=1&limit=20
   →  All delivery attempts for all of your org's API keys
   →  Filter: ?transactionRef=TXN-... or ?status=permanently_failed
```

**Using the key to integrate your portal:**

```
Initiate a mobile money payment:
   POST /api/v1/payments/initiate
   Headers: { Authorization: "Bearer sk_live_..." }
   Body: { amount: 250, customer: { phone: "0244111111", network: "MTN" }, paymentType: "school_fees" }
   →  202: { transactionRef: "TXN-...", status: "processing", otpRequired: false | true }

   If otpRequired is true (network requires OTP instead of push prompt):
   →  Show an OTP input field to the customer
   →  POST /api/v1/payments/TXN-.../submit-otp   Body: { otp: "847291" }
   →  On success: { status: "completed" }
   →  On failure: { error: "OTP_REJECTED" } — show failure, let customer re-initiate

Generate a USSD code for walk-in customers:
   POST /api/v1/payments/ussd-code
   Body: { amount: 75, paymentType: "pta_dues" }
   →  { code: "3924", dialString: "*920*123#", expiresAt: "..." }

Check payment status:
   GET /api/v1/payments/TXN-.../status

Receive webhook notifications:
   →  PayHub POSTs to webhookUrl when payment.completed / payment.failed fires
   →  Portal marks student's account as paid

If a webhook was missed:
   GET /api/orgs/:id/webhook-deliveries?transactionRef=TXN-...
   →  View all delivery attempts and response codes (Bearer JWT auth)
```

**Note on split codes:** The org admin never needs to think about split codes or subaccounts. If the super admin has configured a split code for this organization, PayHub applies it automatically to every transaction. No change is needed in the portal's integration code.

---

## Flow 5 — Renewing a Subscription

**Trigger:** Subscription is approaching its end date, or status has flipped to `expired`.

```
1. Check current status
   GET /api/subscriptions/:id/status
   →  { subscription: { status: "expired" | "active", endDate: "..." }, ussdEnabled: false | true }

2. Initiate a subscription payment (headless mobile money charge — no redirect)
   POST /api/subscriptions/:id/pay
   Headers: { Authorization: "Bearer <JWT>" }
   Body: {
     phone:        "0244111111",          ← local (0XXXXXXXXX) or international (233XXXXXXXXX) format
     network:      "MTN",                 ← MTN | VODAFONE | AIRTELTIGO
     billingModel: "monthly"              ← monthly | annual_prepaid | annual_monthly
   }
   →  Phone number is normalized to 233XXXXXXXXX automatically before being sent to Paystack
   →  201: {
        transactionRef: "TXN-XYZSCH-...",
        amount:         100,
        currency:       "GHS",
        billingModel:   "monthly",
        billingPeriod:  "monthly",
        commitment:     "monthly",
        status:         "pending" | "send_otp",
        requiresOtp:    false | true,
        _links: {
          status:    "/api/v1/payments/TXN-.../status",
          submitOtp: "/api/v1/subscriptions/:id/pay/otp"   ← only present when requiresOtp: true
        }
      }

3a. If requiresOtp is false (push prompt sent to phone)
   →  Approve the debit on your phone when the MoMo prompt appears
   →  PayHub's Paystack webhook fires automatically → subscription is activated without any
      further action from you or the super admin
   →  If the PIN prompt never appeared on your phone:
      →  Contact the super admin — they can run a force-verify to check if the charge went
         through on Paystack's side, or mark it failed so you can retry

3b. If requiresOtp is true (network requires OTP instead of push)
   →  An OTP is sent to the phone number
   →  Submit it:
      POST /api/subscriptions/:id/pay/otp
      Body: { transactionRef: "TXN-XYZSCH-...", otp: "847291" }
      →  200: { success: true, transactionRef: "...", status: "pending" | "success" }
   →  Subscription activates automatically once Paystack confirms the charge

4. Confirm subscription is active
   GET /api/subscriptions/:id/status
   →  { subscription: { status: "active", endDate: "2026-04-28" }, ussdEnabled: true }
```

**Billing models explained:**

| `billingModel` | What is charged | Period added |
|----------------|-----------------|--------------|
| `monthly` | `monthlyFee` (default GHS 100) | 1 month |
| `annual_prepaid` | `annualFee` (default 12 × monthly) | 12 months |
| `annual_monthly` | `monthlyFee` | 1 month (annual commitment tracked) |

---

## Flow 6 — Resolving a Disputed Payment

**Trigger:** A parent claims they paid but their account is still showing as outstanding.

```
1. Locate the transaction
   GET /api/reports/transactions
   Params: { organizationId: "...", startDate: "...", status: "completed" }
   →  Search by parent's phone or reference number

2. If transaction is stuck in "processing"
   POST /api/v1/payments/:ref/verify   (force re-query Paystack)
   →  { status: "completed", changed: true }

3. If still not found
   →  Provide the transactionRef to the super admin
   →  Super admin checks reconciliation job logs and gateway records
```
