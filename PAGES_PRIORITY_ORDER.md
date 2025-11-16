# 📋 Remaining Pages - Implementation Priority Order

## ✅ Completed (3 pages)
1. ✅ **SplashPage** - Auto-login with beautiful branding
2. ✅ **LoginPage** - Enhanced with validation, theme, error handling
3. ✅ **HomeShell** - Updated with theme, role management, sign out

---

## 🎯 Implementation Order (Remaining 12 Pages)

### **PHASE 1: Core Organization Management (Week 1 - 22 hours)**

#### Priority 1: OrgListPage Enhancement (2 hours) ⭐⭐⭐
**File:** `lib/features/orgs/org_list_page.dart`  
**Status:** Partially complete - needs enhancements  
**Why First:** Already working, just needs polish

**Add:**
- ✅ Tap on org card to navigate to detail
- ✅ FloatingActionButton for super_admin to create org
- ✅ Better loading states
- ✅ Empty state when no orgs
- ✅ Pull-to-refresh

**Dependencies:** None  
**API Calls:** Already implemented (GET /api/orgs)

---

#### Priority 2: OrgDetailPage (6-8 hours) ⭐⭐⭐
**File:** `lib/features/orgs/org_detail_page.dart`  
**Status:** Placeholder only  
**Why Second:** Core functionality, gateway to payment types

**Features:**
- Display org information (name, email, phone, USSD number)
- Edit form (super_admin only) with validation
- Navigation cards to:
  - Payment Types
  - Subscription Status
  - Reports
- Delete org button (super_admin, with confirmation)

**Dependencies:** OrgService (exists)  
**API Calls:**
- GET /api/orgs (get by ID from list)
- PATCH /api/orgs/:id (for editing)

---

#### Priority 3: PaymentTypesListPage (4-5 hours) ⭐⭐⭐
**File:** `lib/features/payments/payment_types_list_page.dart`  
**Status:** Placeholder only  
**Why Third:** Critical for org management

**Features:**
- List all payment types for an org
- Enable/disable toggle per type
- Show min/max amounts
- Tap to edit
- FAB to add new type
- Empty state when no types

**Dependencies:** PaymentTypeService (exists)  
**API Calls:**
- GET /api/orgs/:id/payment-types
- PATCH /api/orgs/:id/payment-types/:typeId (toggle enabled)

---

#### Priority 4: PaymentTypeEditPage (5-6 hours) ⭐⭐⭐
**File:** `lib/features/payments/payment_type_edit_page.dart`  
**Status:** Placeholder only  
**Why Fourth:** Completes payment type CRUD

**Features:**
- Form for create/edit
- Fields: typeId, name, description, minAmount, maxAmount, enabled
- Validation using Validators from helpers
- Save button
- Delete button (for existing types)

**Dependencies:** PaymentTypeService (exists)  
**API Calls:**
- POST /api/orgs/:id/payment-types (create)
- PATCH /api/orgs/:id/payment-types/:typeId (update)

---

### **PHASE 2: Dashboard & Subscriptions (Week 2 - 18 hours)**

#### Priority 5: DashboardPage Enhancement (6 hours) ⭐⭐
**File:** `lib/features/dashboard/dashboard_page.dart`  
**Status:** Shows placeholder data  
**Why Fifth:** High visibility, user's first view

**Features:**
- Fetch real transaction stats
- Display total balance, transactions count
- Weekly chart (bar chart of last 7 days)
- Recent transactions list
- Payment type breakdown
- Role-based data (org_admin sees own, super_admin sees all)

**Dependencies:** 
- ReportsService (exists)
- StatsCard widget (need to create)
- WeeklyChart widget (optional for now)

**API Calls:**
- GET /api/reports/transactions?page=1&limit=5
- GET /api/reports/orgs/:id/summary?startDate=...

---

#### Priority 6: StatsCard Widget (1 hour) ⭐⭐
**File:** `lib/widgets/stats_card.dart`  
**Status:** Need to create  
**Why Sixth:** Required for Dashboard

**Features:**
- Reusable stats display card
- Label, value, icon, optional trend
- Uses GlassCard as base
- Theme-consistent styling

**Dependencies:** GlassCard (exists)  
**API Calls:** None

---

#### Priority 7: SubscriptionStatusPage (3-4 hours) ⭐⭐
**File:** `lib/features/subscriptions/subscription_status_page.dart`  
**Status:** Placeholder only  
**Why Seventh:** Important for org status visibility

**Features:**
- Display subscription status with colored badge
- Show start date, end date, grace period
- Display billing period
- USSD enabled indicator
- "Manage Subscription" button (super_admin only)

**Dependencies:** SubscriptionService (exists)  
**API Calls:** GET /api/subscriptions/:id/status

---

#### Priority 8: SubscriptionManagePage (4-5 hours) ⭐⭐
**File:** `lib/features/subscriptions/subscription_manage_page.dart`  
**Status:** Placeholder only  
**Why Eighth:** Admin feature for subscription control

**Features:**
- Activate form (billing period selector, date picker)
- Cancel button with confirmation
- Current status display
- Super admin only access

**Dependencies:** SubscriptionService (exists)  
**API Calls:**
- GET /api/subscriptions/:id/status
- POST /api/subscriptions/:id/activate
- POST /api/subscriptions/:id/cancel

---

### **PHASE 3: Reports & Analytics (Week 3 - 14 hours)**

#### Priority 9: TransactionsPage (6-8 hours) ⭐⭐
**File:** `lib/features/reports/transactions_page.dart`  
**Status:** Placeholder only  
**Why Ninth:** Core reporting feature

**Features:**
- Filter form (org, status, date range)
- Paginated transaction list/table
- Export to CSV (optional)
- Format dates and currency
- Status badges

**Dependencies:** ReportsService (exists)  
**API Calls:** GET /api/reports/transactions (with filters)

---

#### Priority 10: OrgSummaryPage (5-6 hours) ⭐⭐
**File:** `lib/features/reports/org_summary_page.dart`  
**Status:** Placeholder only  
**Why Tenth:** Org-specific analytics

**Features:**
- Date range picker
- Summary cards (total transactions, amount, commission)
- Payment type breakdown table
- Optional: Pie/bar chart by payment type

**Dependencies:** ReportsService (exists)  
**API Calls:** GET /api/reports/orgs/:id/summary

---

#### Priority 11: UssdSessionsPage (3-4 hours) ⭐
**File:** `lib/features/reports/ussd_sessions_page.dart`  
**Status:** Placeholder only  
**Why Eleventh:** Super admin analytics only

**Features:**
- Super admin access check
- Date range filter
- Stats cards by status (completed, abandoned, failed)
- Average duration display

**Dependencies:** ReportsService (exists)  
**API Calls:** GET /api/reports/ussd/sessions (super_admin only)

---

### **PHASE 4: Admin & Settings (Week 4 - 12 hours)**

#### Priority 12: PayoutsSchedulePage (3-4 hours) ⭐
**File:** `lib/features/payouts/payouts_schedule_page.dart`  
**Status:** Placeholder only  
**Why Twelfth:** Super admin feature

**Features:**
- Organization dropdown selector
- Date picker for scheduled date
- Submit button
- Success message with count

**Dependencies:** PayoutService (exists), OrgService for dropdown  
**API Calls:**
- GET /api/orgs (for dropdown)
- POST /api/payouts/schedule

---

#### Priority 13: PayoutsPendingPage (4-5 hours) ⭐
**File:** `lib/features/payouts/payouts_pending_page.dart`  
**Status:** Placeholder only  
**Why Thirteenth:** Super admin payout processing

**Features:**
- List pending payouts
- Process button per payout
- Confirmation dialog
- Success feedback with payout ref

**Dependencies:** PayoutService (exists)  
**API Calls:**
- GET /api/payouts/pending
- POST /api/payouts/:id/process

---

#### Priority 14: ProfilePage (2-3 hours) ⭐
**File:** `lib/features/settings/profile_page.dart`  
**Status:** Placeholder only  
**Why Last:** Lower priority, simple page

**Features:**
- Display user info (email, role)
- Display organization (if org_admin)
- Sign out button
- Optional: Change password (if supported by API)

**Dependencies:** None (uses /auth/me)  
**API Calls:** GET /api/auth/me

---

## 📊 Summary Statistics

### By Priority Level
- ⭐⭐⭐ Critical (4 pages): 17-21 hours
- ⭐⭐ Important (7 pages): 38-45 hours
- ⭐ Optional (3 pages): 9-12 hours

### By Phase
- **Phase 1** (Core Org): 4 pages, 17-21 hours
- **Phase 2** (Dashboard): 4 pages, 14-16 hours
- **Phase 3** (Reports): 3 pages, 14-18 hours
- **Phase 4** (Admin): 3 pages, 9-12 hours

### Total Remaining
- **14 pages** to create/update
- **54-67 hours** estimated time
- **~3-4 weeks** at 20 hours/week

---

## 🎯 Recommended Weekly Schedule

### Week 1: Foundation
- Mon-Tue: OrgListPage enhancement + OrgDetailPage
- Wed-Thu: PaymentTypesListPage
- Fri: PaymentTypeEditPage (start)
- **Goal:** Complete core org management

### Week 2: Dashboard & Subscriptions
- Mon: PaymentTypeEditPage (finish)
- Tue: StatsCard + DashboardPage enhancement
- Wed-Thu: SubscriptionStatusPage + SubscriptionManagePage
- Fri: Testing and bug fixes
- **Goal:** Beautiful dashboard, working subscriptions

### Week 3: Reports
- Mon-Tue: TransactionsPage
- Wed-Thu: OrgSummaryPage
- Fri: UssdSessionsPage
- **Goal:** Complete reporting suite

### Week 4: Admin & Polish
- Mon-Tue: PayoutsSchedulePage + PayoutsPendingPage
- Wed: ProfilePage
- Thu-Fri: Testing, polish, responsive design
- **Goal:** Production ready

---

## 🔄 Quick Start for Each Page

### Standard Pattern
```dart
1. Create StatefulWidget
2. Add loading state (bool _loading = true)
3. Add data state (List<Model> _items = [])
4. Create initState() → call _load()
5. Implement _load() with try-catch
6. Build UI with loading/error/success states
7. Use helpers for formatting
8. Use theme constants for styling
```

### Always Include
- ✅ Loading state (CircularProgressIndicator)
- ✅ Error handling (ErrorHandlers.handleError)
- ✅ Empty state (when no data)
- ✅ Role checks (RoleHelpers when needed)
- ✅ Theme usage (AppColors, AppSpacing, etc.)
- ✅ Proper validation (Validators)

---

## 📚 Reference for Each Page

As you build each page, refer to:
1. **ROUTES_IMPLEMENTATION_MAP.md** - Detailed code examples
2. **QUICK_REFERENCE.md** - Quick utility lookups
3. **app_theme.dart** - Theme constants
4. **helpers.dart** - All utility functions

---

## ✅ Current Progress

**Completed:** 3/17 pages (18%)
- ✅ SplashPage
- ✅ LoginPage (enhanced)
- ✅ HomeShell (enhanced)

**Next Up:** OrgListPage enhancement (Priority 1)

---

**Let's build! 🚀**

Start with Priority 1 (OrgListPage enhancement) - it's the easiest next step and builds momentum!
