# App Pages & Routes

## Auth
- Page: `Splash`
  - Route: `/splash`
  - Features: token check, `GET /api/auth/me` (`api/INTEGRATION_GUIDE.md:10–12`)
- Page: `Login`
  - Route: `/login`
  - Features: email/password login `POST /api/auth/login` (`api/INTEGRATION_GUIDE.md:6–9`)
  - Headers: `Content-Type: application/json`; `x-correlation-id` sent (`api/INTEGRATION_GUIDE.md:15–17`)

## Home
- Page: `Home`
  - Route: `/home`
  - Tabs: Dashboard, Organizations, Payments, Reports, Admin (role-based)

## Dashboard
- Page: `Dashboard`
  - Route: `/dashboard`
  - Features: summary stats and weekly chart from Reports endpoints (`api/INTEGRATION_GUIDE.md:68–76`)

## Organizations
- Page: `Organizations List`
  - Route: `/orgs`
  - Features: list/search/paginate (`GET /api/orgs`, `page`, `limit`, `q`) (`api/INTEGRATION_GUIDE.md:28–36`, `api/INTEGRATION_GUIDE.md:23–26`)
- Page: `Organization Detail`
  - Route: `/orgs/detail`
  - Features: overview, links to Subscription status and Payment Types
- Page: `Create/Edit Organization`
  - Routes: handled in Detail via actions
  - Features: `POST /api/orgs`, `PATCH /api/orgs/:id` restricted to `super_admin` (`api/INTEGRATION_GUIDE.md:31–36`)

## Payment Types
- Page: `Payment Types List`
  - Route: `/orgs/payment-types`
  - Features: list organization-scoped payment types (`GET /api/orgs/:id/payment-types`) (`api/INTEGRATION_GUIDE.md:39–41`)
- Page: `Payment Type Editor`
  - Route: `/orgs/payment-types/edit`
  - Features: add/update/toggle enabled; min/max amounts (`POST`/`PATCH`) (`api/INTEGRATION_GUIDE.md:41–47`)

## Subscriptions
- Page: `Subscription Status`
  - Route: `/subscriptions/status`
  - Features: `GET /api/subscriptions/:id/status` shows `subscription` and `ussdEnabled` (`api/INTEGRRATION_GUIDE.md:50–52`)
- Page: `Manage Subscription`
  - Route: `/subscriptions/manage`
  - Features: Activate/Cancel `POST /api/subscriptions/:id/activate|cancel` (`api/INTEGRATION_GUIDE.md:53–56`)

## Payouts (Admin)
- Page: `Schedule Payouts`
  - Route: `/payouts/schedule`
  - Features: `POST /api/payouts/schedule` (`api/INTEGRATION_GUIDE.md:59–61`)
- Page: `Pending Payouts`
  - Route: `/payouts/pending`
  - Features: `GET /api/payouts/pending` and `POST /api/payouts/:id/process` (`api/INTEGRATION_GUIDE.md:62–65`)

## Reports
- Page: `Transactions`
  - Route: `/reports/transactions`
  - Features: filters and pagination (`GET /api/reports/transactions`) (`api/INTEGRATION_GUIDE.md:68–70`)
- Page: `Org Summary`
  - Route: `/reports/org-summary`
  - Features: grouped totals by payment type (`GET /api/reports/orgs/:id/summary`) (`api/INTEGRATION_GUIDE.md:71–73`)
- Page: `USSD Sessions`
  - Route: `/reports/ussd-sessions`
  - Features: admin-only stats (`GET /api/reports/ussd/sessions`) (`api/INTEGRATION_GUIDE.md:74–76`)

## Settings/Profile
- Page: `Profile`
  - Route: `/settings/profile`
  - Features: user info, sign out

## Notes
- Error shape: `{ success: false, message, errors? }` used across pages (`api/INTEGRATION_GUIDE.md:19–21`)
- Pagination payload shape reused in list pages (`api/INTEGRATION_GUIDE.md:23–26`)