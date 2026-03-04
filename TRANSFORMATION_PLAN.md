# PayHub Admin — Full Transformation Plan
> **All changes MUST be made exclusively using Desktop Commander MCP.**
> No changes should be made via any IDE, terminal, or other tool.
> All file reads, writes, and edits go through `desktop-commander:read_file`,
> `desktop-commander:write_file`, and `desktop-commander:edit_block`.

---

## Overview

This document defines a phased plan to transform the PayHub Admin Flutter app.
Phases are ordered: **functionality fixes first**, then **UI/UX redesign**.
Each phase is atomic — a different model can pick up at any phase by reading
`LOG.md` (which records what has been completed) and this document.

---

## How to Resume After a Handoff

1. Read `LOG.md` to see which phases and sub-phases are complete.
2. Read `TRANSFORMATION_PLAN.md` (this file) to understand what is next.
3. Use Desktop Commander MCP exclusively for all file operations.
4. After completing a sub-phase, append a log entry to `LOG.md`.
5. Never modify files outside of Desktop Commander MCP.

---

## Phase Map

| Phase | Category       | Title                                          | Priority |
|-------|----------------|------------------------------------------------|----------|
| 1     | Functionality  | Error Handling & HTTP Layer Hardening          | Critical |
| 2     | Functionality  | Missing Features & Dead Routes                 | Critical |
| 3     | Functionality  | State Management & Session Integrity           | High     |
| 4     | Functionality  | Data Layer Robustness                          | High     |
| 5     | Functionality  | UX Logic Gaps & Interaction Bugs               | Medium   |
| 6     | UI Redesign    | Design Token Overhaul (Theme Foundation)       | High     |
| 7     | UI Redesign    | Shared Widget Replacement                      | High     |
| 8     | UI Redesign    | Auth Screens (Splash + Login)                  | Medium   |
| 9     | UI Redesign    | Home Shell & Navigation                        | Medium   |
| 10    | UI Redesign    | Dashboard & Developer Dashboard                | High     |
| 11    | UI Redesign    | Transactions & Reports                         | Medium   |
| 12    | UI Redesign    | Payments (Types List + Edit)                   | Medium   |
| 13    | UI Redesign    | Settings / Profile Page                        | Medium   |
| 14    | UI Redesign    | Developer Pages (Webhooks + Detail)            | Medium   |
| 15    | Polish         | Micro-animations & Final Sweep                 | Low      |

---

## PHASE 1 — Error Handling & HTTP Layer Hardening

**Goal:** Make the app resilient to real-world API failures.
**Files:** `lib/shared/http/client.dart`, `lib/shared/utils/helpers.dart`,
           all service files under `lib/shared/services/`

### Sub-phase 1A — DioException is never cast as string
**Problem:** `ErrorHandlers.getErrorMessage()` checks
`error.toString().contains('DioException')` — a fragile string-match that
breaks in minified/obfuscated builds. DioException data fields (statusCode,
response.data) are never inspected directly.

**Fix:** Import `package:dio/dio.dart` in `helpers.dart`. Add a proper
`DioException` type-check branch that reads `e.type`, `e.response?.statusCode`,
and `e.response?.data['message']` directly.

```
// New getErrorMessage pattern (pseudocode):
if (error is DioException) {
  final code = error.response?.statusCode;
  final serverMsg = (error.response?.data is Map)
      ? error.response?.data['message'] as String?
      : null;
  if (error.type == DioExceptionType.connectionTimeout || ...) return 'Network timeout...';
  if (code == 401) return serverMsg ?? 'Session expired. Please log in again.';
  if (code == 403) return serverMsg ?? 'Access denied.';
  if (code == 404) return serverMsg ?? 'Resource not found.';
  if (code == 422) return serverMsg ?? 'Validation error.';
  if (code != null && code >= 500) return serverMsg ?? 'Server error. Try again later.';
  return serverMsg ?? 'Request failed.';
}
```

### Sub-phase 1B — Dio timeout configuration is too short
**Problem:** `connectTimeout: 10s` only. No `receiveTimeout` or `sendTimeout`
is set, so slow API responses (e.g., report generation) hang indefinitely.

**Fix:** In `client.dart`, add `receiveTimeout: const Duration(seconds: 30)`
and `sendTimeout: const Duration(seconds: 20)` to `BaseOptions`.

### Sub-phase 1C — Token refresh / 401 global interceptor
**Problem:** When a stored token expires, every API call fails with 401.
The user gets an error snackbar. They must manually go to settings and sign
out. There is no auto-redirect to login.

**Fix:** Add a `onResponse` / `onError` interceptor in `buildDio()` that
catches 401 responses, clears SharedPreferences (`token`, `role`, `org_id`,
`dev_mode`), and pushes the login route using a `NavigatorKey` singleton.

Add to `main.dart`:
```dart
final navigatorKey = GlobalKey<NavigatorState>();
```
Pass `navigatorKey` to `MaterialApp`. In `client.dart`, import and use it
to redirect on 401.

### Sub-phase 1D — DialogHelpers.showLoading leaks
**Problem:** `DialogHelpers.showLoading` opens a `showDialog` with
`barrierDismissible: false`. If the calling widget is disposed before
`hideLoading` is called (e.g., user navigates away), the dialog leaks and
leaves the app stuck. `_toggleEnabled` in `payment_types_list_page.dart`
calls this pattern.

**Fix:** Replace `showLoading` / `hideLoading` pattern with an in-widget
loading state approach (use `setState(() => _saving = true)` guard instead
of modal dialog). Remove modal loading from `_toggleEnabled`.

---

## PHASE 2 — Missing Features & Dead Routes

**Goal:** Wire up all features that exist as services/models but have no UI.
**Files:** `lib/app/router/routes.dart`, `lib/app/router/app_router.dart`,
           new page files under `lib/features/payouts/`

### Sub-phase 2A — Payout Management is fully missing
**Problem:** `PayoutService` has three methods (`schedule`, `listPending`,
`process`). The `Payout` model exists. The `routes.dart` has NO payout
routes. There is no payout page. The Dashboard never mentions payouts.

**Fix:**
1. Create `lib/features/payouts/payouts_page.dart` — lists pending payouts
   with schedule + process actions.
2. Add routes: `Routes.payouts = '/payouts'`
3. Register route in `app_router.dart`.
4. Add "Payouts" navigation item to Org Admin tab in `home_shell.dart`
   (replace one of the 4 tabs or add a 5th if design allows).
5. Link from Dashboard summary card with a "View Payouts" CTA.

### Sub-phase 2B — OrgSummaryPage is unreachable
**Problem:** `Routes.reportsOrgSummary` exists in routes + router but is
never called from any button or navigation action in the app. There is no
entry point.

**Fix:** On the Dashboard page, add an "Org Summary" action button or card
that navigates to `Routes.reportsOrgSummary` with the current `_orgId`.

### Sub-phase 2C — UssdSessionStats model and service method are orphaned
**Problem:** `ReportsService.getUssdSessions()` and `UssdSessionStats` model
exist but are called by zero pages.

**Fix:** Add a "USSD Sessions" card/tab to the Dashboard that calls this
endpoint and displays session metrics (total sessions, completion rate).

### Sub-phase 2D — Subscription page receives empty string when orgId is null
**Problem:** In `profile_page.dart`:
```dart
Navigator.pushNamed(context, Routes.subscriptionStatus, arguments: _orgId)
```
`_orgId` can be null here. In `app_router.dart`:
```dart
final subId = (settings.arguments as String?) ?? '';
```
This passes an empty string to `SubscriptionStatusPage`, which calls
`_service.getStatus('')` — hitting `/subscriptions//status` and getting a 404.

**Fix:** Guard the navigation:
```dart
if (_orgId != null && _orgId!.isNotEmpty) {
  Navigator.pushNamed(context, Routes.subscriptionStatus, arguments: _orgId);
} else {
  DialogHelpers.showInfo(context, 'No organisation linked to this account.');
}
```

---

## PHASE 3 — State Management & Session Integrity

**Goal:** Fix SharedPreferences race conditions and stale state bugs.

### Sub-phase 3A — HomeShell reads `dev_mode` only once at startup
**Problem:** `_loadSession()` in `HomeShell` is called once in `initState`.
When the user toggles Developer Mode in `profile_page.dart`, the code does
`Navigator.pushNamedAndRemoveUntil(context, Routes.home, ...)` which
re-creates `HomeShell`. This works, but if for any reason the route is
replaced without recreation, the stale `_devMode` value persists.

**Fix:** Keep the current navigation rebuild approach but add a
`WidgetsBindingObserver` + `didChangeAppLifecycleState` reload to
re-check `dev_mode` whenever the app resumes. Also add a
`notifyListeners`-style refresh when returning from profile settings.

### Sub-phase 3B — `org_name` is never persisted
**Problem:** `DashboardPage` reads `prefs.getString('org_name')` but nothing
in the app ever writes `org_name` to SharedPreferences. Login (`login_page.dart`)
fetches `user.organizationId` but not the org name. The dashboard title
logic `_orgName != null ? 'Dashboard' : 'Dashboard'` is a no-op (same string
either way).

**Fix:** In `login_page.dart` after fetching `/auth/me`, if `organizationId`
is present, call `OrgService().get(orgId)` and store the org name:
```dart
await prefs.setString('org_name', org.name);
```
Then update `DashboardPage` to actually use `_orgName` in the greeting:
```dart
GradientHeader(title: _orgName != null ? 'Welcome, $_orgName' : 'Dashboard')
```

### Sub-phase 3C — Developer mode `key_id` is never stored by login
**Problem:** `DeveloperDashboardPage` reads `prefs.getString('key_id')` but
login never stores it. The developer dashboard always shows the
"No API Key linked" empty state even for valid developer accounts.

**Fix:** In `login_page.dart`, after `/auth/me` response, check if
`user['apiKeyId']` (or equivalent field from your API) is present and
store it:
```dart
if (user['apiKeyId'] != null) {
  await prefs.setString('key_id', user['apiKeyId'].toString());
}
```
*(Exact field name must be verified against the API response schema.)*

---

## PHASE 4 — Data Layer Robustness

**Goal:** Prevent crashes from unexpected API response shapes.

### Sub-phase 4A — Transaction.fromJson can throw on null initiatedAt
**Problem:**
```dart
initiatedAt: DateTime.parse(json['initiatedAt'] ?? DateTime.now().toIso8601String()),
```
If `json['initiatedAt']` is present but not a valid ISO string (e.g., an
epoch int, a partial date), `DateTime.parse` throws `FormatException`,
crashing the entire list.

**Fix:** Wrap in a try/catch:
```dart
initiatedAt: _parseDate(json['initiatedAt']),

static DateTime _parseDate(dynamic raw) {
  if (raw == null) return DateTime.now();
  if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
  try { return DateTime.parse(raw.toString()); } catch (_) { return DateTime.now(); }
}
```

### Sub-phase 4B — Subscription.fromJson double-nests
**Problem:** The `fromJson` checks both `json['subscription']` (nested) and
`json` (flat) but then reads `ussdEnabled` from **both** `json['ussdEnabled']`
and `sub['ussdEnabled']`. If the API returns `ussdEnabled` inside
`subscription`, it is correctly read. But if it returns it at the root level
only, `sub['ussdEnabled']` is checked first and will be false (since `sub`
points to the nested map).

**Fix:** Always normalise to a single resolved map and read all fields from it:
```dart
factory Subscription.fromJson(Map<String, dynamic> json) {
  final sub = (json['subscription'] as Map<String, dynamic>?) ?? json;
  return Subscription(
    ...
    ussdEnabled: (sub['ussdEnabled'] ?? json['ussdEnabled']) == true,
  );
}
```

### Sub-phase 4C — Paged.fromJson silently discards total on alternate response shapes
**Problem:** `Paged.fromJson` reads `json['items']` but the webhook deliveries
endpoint returns `json['data']` (as seen in `developer_service.dart` which
manually maps the `data` key). The Paged generic parser and the manual parser
are inconsistent. If the endpoint ever returns `items` for webhook deliveries,
the manual code breaks.

**Fix:** Extend `Paged.fromJson` to accept an optional `itemsKey` parameter:
```dart
static Paged<R> fromJson<R>(
  Map<String, dynamic> json,
  R Function(Map<String, dynamic>) convert, {
  String itemsKey = 'items',
})
```
Update `DeveloperService` to use `Paged.fromJson(..., itemsKey: 'data')`.

### Sub-phase 4D — PaymentTypeService: `list()` fetches ALL to find ONE
**Problem:** `PaymentTypeEditPage._loadPaymentType()` calls `_service.list(orgId)`
and then does `types.firstWhere(...)` to find the single type by ID. This
fetches all payment types (could be many) just to load one.

**Fix:** Add `PaymentTypeService.get(orgId, typeId)` method that hits
`GET /payment-types/:orgId/:typeId` (or equivalent single-resource endpoint).
If the API doesn't support this, document it and keep the list approach but
add a TODO comment.

---

## PHASE 5 — UX Logic Gaps & Interaction Bugs

**Goal:** Fix broken interactions and confusing UX flows.

### Sub-phase 5A — TransactionsPage filter chips don't auto-apply
**Problem:** Tapping a status chip in `transactions_page.dart` calls
`setState(() => _status = s)` but NOT `_fetch()`. The user must tap
"Apply Filters" to see results. Status chips in `DeveloperTransactionsPage`
and `WebhooksListPage` DO auto-fetch on tap — inconsistent.

**Fix:** In `TransactionsPage`, call `_fetch(page: 1)` inside the chip
`onTap` after setting state, removing the need to press "Apply Filters"
for status changes (keep Apply Filters only for date range changes).

### Sub-phase 5B — Dashboard weekly chart uses wrong day labels
**Problem:** `_buildWeeklyChart` maps `labels[(e.key.weekday - 1) % 7]`
to `['Mo','Tu','We','Th','Fr','Sa','Su']`. Dart's `DateTime.weekday`
returns `1=Monday ... 7=Sunday`, so Monday maps to index 0 ('Mo') — correct.
BUT `_buildDailyCounts` generates 7 days ending TODAY, and sorts them.
If today is Wednesday, the days are Mon/Tue/Wed/Thu/Fri/Sat/Sun of the
PAST 7 days — which crosses week boundaries correctly, but the labels
show the day-of-week label, not the actual calendar date. There is no
way to know WHICH Monday/Tuesday it is.

**Fix:** Replace single-char labels with short dates (`MMM dd` format,
e.g., "Feb 28"). Display as two lines: abbreviated weekday + date.

### Sub-phase 5C — Infinite scroll triggers multiple loads
**Problem:** In `DeveloperTransactionsPage` and `WebhooksListPage`, the
list item at index `_items.length` (the "load more" trigger) calls
`_load(reset: false)` directly in `itemBuilder`. This means every time
the ListView rebuilds (e.g., on orientation change, parent setState), it
calls `_load(reset: false)` again, causing duplicate API calls.

**Fix:** Guard with `_loadingMore` check properly:
```dart
if (i == _items.length && !_loadingMore && _hasMore) {
  WidgetsBinding.instance.addPostFrameCallback((_) => _load(reset: false));
  return Center(child: CircularProgressIndicator(...));
}
```

### Sub-phase 5D — Export CSV silently fails on empty page
**Problem:** `TransactionsPage._exportCsv` exports only the current page
items (`_paged?.items`), not all transactions. The function shows
"CSV copied to clipboard" without any indication that this is only the
current page. A user with 500 transactions would get only 15 rows.

**Fix:** Add a clear label to the success message:
`'Page ${_paged!.page} (${items.length} rows) copied to clipboard'`
And add a tooltip/hint near the export icon explaining it only exports
the current page.

### Sub-phase 5E — PaymentTypeEditPage shows hardcoded white text in light mode
**Problem:**
```dart
Text('Type ID', style: Theme.of(context).textTheme.titleMedium?.copyWith(
  color: AppColors.white,
))
```
`AppColors.white` is hardcoded in three section headers in
`payment_type_edit_page.dart`. In light mode, this renders white text on
a white/near-white GlassCard background — invisible.

**Fix:** Replace `AppColors.white` with `c.textPrimary` for all GlassCard
section headers in `PaymentTypeEditPage`.

---

## PHASE 6 — Design Token Overhaul (Theme Foundation)

**Goal:** Update `app_theme.dart` tokens to the Refined Financial Brutalism
system. This is the foundation all subsequent UI phases depend on.

### Key changes:
- **Surface system:** Add `bgBase`, `bgSurface`, `bgRaised`, `bgHigh`, `bgOverlay`
  tokens replacing the current `surfaceLow/Mid/High` (keep old names as aliases
  for backward compat during migration).
- **Colour palette:** Refine amber: dark `#E8831C`, light `#C96A00`.
  Introduce `textMono` colour for reference/code text.
- **Radius reduction:** xs=4, sm=6, md=10, lg=14, xl=18, xxl=22, full=9999.
- **Typography:** Replace Google Fonts `Inter` with `Sora` (UI) +
  `DM Mono` (codes/refs). Add `displayHero` style (56px, Sora, w800).
- **Shadows:** Add `glow` shadow variant using amber with opacity.
- **New tokens:** `borderStrong` (visible dividers), `accentLine` (left accent
  bars on transaction cards), `cardBg` (slightly lighter than surface).
- Add font assets to `pubspec.yaml` if needed (or use GoogleFonts CDN).

### Files touched:
- `lib/app/theme/app_theme.dart` (full rewrite of tokens section)
- `pubspec.yaml` (add fonts if needed)

---

## PHASE 7 — Shared Widget Replacement

**Goal:** Replace `GlassCard`, `GradientHeader`, `StatsCard` with new
Refined Financial Brutalism variants.

### 7A — New `AppCard` widget (replaces GlassCard)
- Remove: blur/translucency illusion (no actual BackdropFilter used)
- Add: sharp corners (r=10–14px), strong `1px borderStrong` border,
  left `3px` accent bar variant for list items, `elevated` variant for
  hero cards.
- File: `lib/widgets/app_card.dart`
- Keep `glass_card.dart` as a thin wrapper calling `AppCard` during migration.

### 7B — New `PageHeader` widget (replaces GradientHeader)
- Remove: identical gradient pill on every screen.
- Replace with: plain text section title + optional subtitle on a
  `bgBase` background. Each screen can pass a unique `accentIcon`.
- Screens that currently use GradientHeader will be updated screen by
  screen in phases 8–14.
- File: `lib/widgets/page_header.dart`
- Keep `gradient_header.dart` as a stub during migration.

### 7C — New `MetricCard` widget (replaces StatsCard)
- Add hero number (large 36px Sora font), sub-label, trend indicator
  (optional +/-% badge), icon in corner.
- File: `lib/widgets/metric_card.dart`

### 7D — New `StatusChip` widget
- A reusable status badge that uses `AppColors` semantic colours (not
  `StatusHelpers.getStatusColor` with hardcoded hex values).
- Replace all inline `Container(padding:..., decoration: BoxDecoration(...),
  child: Text(status))` patterns throughout the app.
- File: `lib/widgets/status_chip.dart`

### 7E — New `FilterChip` row widget
- Consistent, reusable chip row for status filters used across 4+ pages.
- File: `lib/widgets/filter_chips_row.dart`

---

## PHASE 8 — Auth Screens (Splash + Login)

### Splash Page
- Replace flat gradient background with `bgBase` + subtle noise texture layer.
- Keep logo/icon, centre the PayHub wordmark in `displayHero` style.
- Use `Sora` font for brand name.

### Login Page
- Remove decorative gradient blobs (too soft for brutalism aesthetic).
- Replace with a clean `bgBase` background with a single top-right geometric
  accent (amber rectangle at 3% opacity).
- Logo: amber square with `P` monogram, sharp corners (r=10px), no glow shadow.
- Form card: `AppCard` elevated variant, no glass effect.
- Inputs: reduce border radius to match new tokens.
- "Sign In" button: full-width, sharp, amber fill, dark text.
- Add a "Forgot password?" text link (UI only — navigates nowhere for now,
  but shows the design).

---

## PHASE 9 — Home Shell & Navigation

- Replace `NavigationBar` (Material 3) with a custom bottom nav that matches
  the brutalism aesthetic:
  - `bgSurface` background, `1px borderStrong` top border.
  - Active item: amber underline bar + amber icon + amber label.
  - Inactive items: `textTertiary`.
  - No animated background indicator pill.
- Smooth `IndexedStack` with `AnimatedSwitcher` fade transition between tabs.
- Add safe area handling for bottom insets.

---

## PHASE 10 — Dashboard & Developer Dashboard

### Org Admin Dashboard
- **Hero section:** Remove GradientHeader. Add large greeting text
  (`Good morning, [OrgName]`) in `displayHero` + date sub-label.
- **Stats cards:** Replace 3 separate `StatsCard`s with a 2×2 `MetricCard`
  grid. Add a 4th card for "USSD Sessions" (Phase 2C data).
- **Weekly chart:** Replace DIY `AnimatedContainer` bars with proper
  `fl_chart` `BarChart` widget with axes, gridlines, value tooltips.
  (Add `fl_chart` to `pubspec.yaml`.)
- **Transaction list:** Replace `GlassCard` transaction item with a
  compact `AppCard` row featuring a 3px left accent line
  (green=completed, amber=processing, red=failed).
- **Payment type breakdown:** Replace flat text rows with horizontal bar
  chart per type.

### Developer Dashboard
- **Period selector:** Replace custom GestureDetector containers with
  `FilterChipsRow` widget.
- **Stats:** Use `MetricCard` 2×2 grid.
- **Channel bars:** Enhance `LinearProgressIndicator` rows with value
  labels on right + percentage on bar.
- **Daily chart:** Use `fl_chart` instead of manual bars.

---

## PHASE 11 — Transactions & Reports

### TransactionsPage
- **Filter bar:** Move filter section into a collapsible `ExpansionTile`
  or a slide-in bottom sheet — saves vertical space.
- **Transaction card:** Use `AppCard` with left accent status bar.
  Add a `DM Mono` font for `transactionRef` reference field.
- **Pagination:** Replace text `Page X / Y` with visual dot indicator
  or compact `< Prev | Next >` row.

### OrgSummaryPage
- Make accessible from Dashboard (Phase 2B).
- Replace stats cards with `MetricCard` widgets.
- Add a simple `fl_chart` `PieChart` or `BarChart` for type breakdown.

---

## PHASE 12 — Payments (Types List + Edit)

### PaymentTypesListPage
- Remove duplicate Edit + Enable/Disable button row on each card (crowded).
- Replace with: tap card to edit, swipe to reveal "Disable" action
  (`Dismissible` widget).
- Card layout: left icon block, name + description + status chip row,
  min/max amounts in mono font.
- FAB stays for "Add new".

### PaymentTypeEditPage
- Fix white text on light mode (Phase 5E).
- Use `AppCard` for sections.
- Remove the GradientHeader embedded inside a scrollable page
  (doesn't make sense below an AppBar).
- Group all fields in clean section cards: ID section, Info section,
  Amounts section. Use `PageHeader` widget.

---

## PHASE 13 — Settings / Profile Page

- Replace `GradientHeader` with `PageHeader`.
- **Account section:** Use `AppCard` with icon rows.
- **Theme toggle:** Move to top-right of PageHeader as a sun/moon icon
  button (standard pattern).
- **Organisation settings:** Make phone field inline-edit style with
  pencil icon (not always open).
- **Developer mode toggle:** Move to bottom under a collapsible "Advanced"
  section — less prominent so users don't accidentally toggle it.
- **Sign out:** Keep at bottom, red text, full-width outlined button.

---

## PHASE 14 — Developer Pages (Webhooks + Detail)

### WebhooksListPage
- Use `AppCard` for delivery items.
- Add a `DM Mono` style for `transactionRef` and `targetUrl`.
- Status chip → `StatusChip` widget.
- Filter row → `FilterChipsRow` widget.

### WebhookDeliveryDetailPage
- Remove GradientHeader dependency (page uses AppBar, which is correct).
- Payload JSON: Use a styled code block with `DM Mono` font and
  `bgOverlay` background. Add line numbers.
- Attempt history: Use `AppCard` with left accent dot (green/red).

---

## PHASE 15 — Micro-animations & Final Sweep

- Add `Hero` animation to logo between SplashPage and LoginPage.
- Add stagger animation to dashboard MetricCards on first load.
- Run `flutter analyze` via Desktop Commander — fix all warnings and
  lints with zero errors.
- Remove all hardcoded hex colours from non-theme files (use `c.*` tokens).
- Remove all `// ignore:` comments unless absolutely necessary.
- Final `flutter pub get` and test build.

---

## Dependency Changes Summary

| Package          | Action                         | Phase |
|------------------|--------------------------------|-------|
| `fl_chart`       | Add to pubspec.yaml            | 10    |
| `google_fonts`   | Already present, add Sora/DM Mono | 6  |
| No new packages for phases 1–5 |                  |       |

---

## File Creation Summary (new files)

| File                                    | Phase |
|-----------------------------------------|-------|
| `lib/features/payouts/payouts_page.dart`| 2A    |
| `lib/widgets/app_card.dart`             | 7A    |
| `lib/widgets/page_header.dart`          | 7B    |
| `lib/widgets/metric_card.dart`          | 7C    |
| `lib/widgets/status_chip.dart`          | 7D    |
| `lib/widgets/filter_chips_row.dart`     | 7E    |

---

*Last updated: See LOG.md for current progress.*
