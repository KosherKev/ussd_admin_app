# PayHub Admin — Context File

> Read this file at the start of every session before touching any code.

---

## Project Identity

**App name:** PayHub SuperAdmin  
**Flutter package name:** `ussd_admin` (pubspec name unchanged after folder rename)  
**Repository:** `/Users/kevinafenyo/Documents/GitHub/payhub_admin`  
**Design system:** Refined Financial Brutalism  
**Design mockup:** `/Users/kevinafenyo/Documents/GitHub/payhub_admin/payhub_redesign_mockup.html`

---

## Tooling Rules (Non-Negotiable)

- Use **Desktop Commander MCP** exclusively for ALL file system and terminal ops.
- Flutter binary: `/Users/kevinafenyo/flutter/bin/flutter`
- Run `flutter analyze` after every sub-phase via `desktop-commander:start_process`.
- Zero analyzer errors must be maintained at all times.
- Never write file content inline in chat — always use `edit_block` or `write_file`.
- All paths are absolute. Never use relative paths.

---

## Key Files

| File | Purpose |
|---|---|
| `CONTEXT.md` | **This file** — read first every session |
| `TRANSFORMATION_PLAN.md` | Full phase-by-phase spec (all 15 phases) |
| `LOG.md` | Append-only progress log |
| `payhub_redesign_mockup.html` | Visual reference — read before any UI phase |
| `pubspec.yaml` | Dependencies (`fl_chart`, `google_fonts`, etc.) |
| `lib/main.dart` | App entry + `navigatorKey` global |
| `lib/app/theme/app_theme.dart` | Design token source of truth |
| `lib/app/router/app_router.dart` | Route registrations |
| `lib/app/router/routes.dart` | Route name constants |
| `lib/shared/http/client.dart` | Dio HTTP client factory + 401 interceptor |
| `lib/shared/utils/helpers.dart` | All utility/helper classes |
| `lib/shared/models/` | Data models (Transaction, Subscription, Paged, etc.) |
| `lib/shared/services/` | All API service classes |
| `lib/widgets/app_card.dart` | Primary card widget (Phase 7A) |
| `lib/widgets/page_header.dart` | Screen header widget (Phase 7B) |
| `lib/widgets/metric_card.dart` | Stats/metric display widget (Phase 7C) |
| `lib/widgets/status_chip.dart` | Status badge widget (Phase 7D) |
| `lib/widgets/filter_chips_row.dart` | Horizontal filter chip row (Phase 7E) |
| `lib/widgets/glass_card.dart` | Backward-compat wrapper → AppCard |
| `lib/widgets/gradient_header.dart` | Backward-compat wrapper → PageHeader |
| `lib/widgets/stats_card.dart` | Backward-compat wrapper → MetricCard |
| `lib/features/auth/splash_page.dart` | Splash screen |
| `lib/features/auth/login_page.dart` | Login screen |
| `lib/features/home/home_shell.dart` | Bottom nav shell + lifecycle observer |
| `lib/features/dashboard/dashboard_page.dart` | Org admin dashboard |
| `lib/features/developer/developer_dashboard_page.dart` | Developer dashboard |
| `lib/features/developer/developer_transactions_page.dart` | Dev transaction list |
| `lib/features/developer/webhooks_list_page.dart` | Webhook deliveries list |
| `lib/features/developer/webhook_delivery_detail_page.dart` | Webhook detail view |
| `lib/features/payments/payment_types_list_page.dart` | Payment types list |
| `lib/features/payments/payment_type_edit_page.dart` | Payment type edit form |
| `lib/features/reports/transactions_page.dart` | Org transactions + CSV export |
| `lib/features/reports/org_summary_page.dart` | Org summary stats |
| `lib/features/payouts/payouts_page.dart` | Payout management |
| `lib/features/settings/profile_page.dart` | Settings / profile |

---

## Design System — Refined Financial Brutalism

**Always read the HTML mockup before implementing any visual change.**

### Core Principles
- Sharp geometry — no blur, no translucency, no gradient pills.
- Dark base `#080B0F` / light base `#F3F4F7` with amber accent (`#E8831C` dark / `#C96A00` light).
- All surfaces separated by explicit `1px borderStrong` lines, not shadows.
- Typography: **Sora** for all UI text, **DM Mono** for reference codes and numeric data.
- Left `3px` accent bars on list items encode status — no floating status blobs.

### Token Quick Reference

```
// Dark palette
background:   #080B0F    bgSurface: #0F1318    bgRaised: #161B22
borderStrong: 18% white  primaryAmber: #E8831C  textPrimary: #F0F2F5
textSecondary:#8B919E    textTertiary: #555D6B   textMono: #7AAEC8

// Light palette
background:   #F3F4F7    bgSurface: #FFFFFF     bgRaised: #F8F9FB
borderStrong: 14% black  primaryAmber: #C96A00  textPrimary: #0D1117
textSecondary:#5A6170    textTertiary: #8E96A3   textMono: #4A7A9B

// Radius: xs=4  sm=6  md=10  lg=14  xl=18  xxl=22  full=9999
// Typography: Sora (all UI), DM Mono (refs/codes/amounts)
// AppTypography.displayHero(color)  — 56px Sora w800 (splash/login)
// AppTypography.labelMono(color)    — 12px DM Mono
// AppTypography.monoBody(color)     — 13px DM Mono
```

### Widget Patterns

| Widget | Usage |
|---|---|
| `AppCard(variant: base)` | Standard content card |
| `AppCard(variant: elevated)` | Hero/form cards |
| `AppCard(variant: accent, accentColor: c.success)` | List items with status bar |
| `PageHeader(title:, subtitle:, trailing:)` | Every screen header |
| `MetricCard(value:, label:, icon:, trend:)` | Dashboard stats |
| `StatusChip(status:)` | Status badges (adapts to theme) |
| `FilterChipsRow(items:, selected:, onSelect:)` | Horizontal filter rows |

---

## Phase Status

| Phase | Title | Status |
|---|---|---|
| 1 | Error Handling & HTTP Hardening | ✅ Complete |
| 2 | Missing Features & Dead Routes | ✅ Complete |
| 3 | State Management & Session Integrity | ✅ Complete |
| 4 | Data Layer Robustness | ✅ Complete |
| 5 | UX Logic Gaps & Interaction Bugs | ✅ Complete |
| 6 | Design Token Overhaul | ✅ Complete |
| 7 | Shared Widget Replacement | ✅ Complete |
| 8 | Auth Screens | ✅ Complete |
| 9 | Home Shell & Navigation | ✅ Complete |
| 10 | Dashboard & Developer Dashboard | ✅ Complete |
| 11 | Transactions & Reports | ⬜ Pending — **START HERE** |
| 12 | Payments Pages | ⬜ Pending |
| 13 | Settings / Profile Page | ⬜ Pending |
| 14 | Developer Pages | ⬜ Pending |
| 15 | Micro-animations & Final Sweep | ⬜ Pending |

---

## Completed Work Summary (Phases 1–10)

### Phases 1–5 — Functionality
- **Ph 1:** DioException type-safe handling, Dio timeouts (15s connect / 30s receive / 20s send), global 401 interceptor → auto-logout + session clear, `showLoading` leak fixed with in-widget bool guard.
- **Ph 2:** `PayoutsPage` created and wired (routes + nav tab), `OrgSummaryPage` quick-action on Dashboard, USSD Sessions metric card, subscription nav null-guard.
- **Ph 3:** `HomeShell` `WidgetsBindingObserver` for app-resume session refresh, `org_name` persisted on login + fetched as fallback in Dashboard, `key_id` stored on login (3 candidate field names tried).
- **Ph 4:** `Transaction._parseDate` safe (null/int/string), `Subscription.fromJson` normalised (`ussdEnabled` ambiguity fixed, date fields safe), `Paged.fromJson` `itemsKey` param, `PaymentTypeService.get()` single-resource endpoint, edit page uses it.
- **Ph 5:** Status chips auto-apply on tap (`TransactionsPage`), weekly chart uses real calendar dates, infinite scroll `addPostFrameCallback` guard (both developer list pages), export CSV states page scope, `PaymentTypeEditPage` white-text-on-light-bg fixed.

### Phases 6–10 — UI Redesign
- **Ph 6:** `app_theme.dart` full rewrite. New surface hierarchy, Refined Financial Brutalism dark/light palettes, Sora + DM Mono via GoogleFonts, `AppTypography.displayHero/labelMono/monoBody`, `AppRadius` reduced, `AppGradients.amber` 2-stop clean linear, `AppShadows.cardDecoration` border-based.
- **Ph 7:** `AppCard` (3 variants), `PageHeader`, `MetricCard`, `StatusChip`, `FilterChipsRow` created. Existing `GlassCard`/`GradientHeader`/`StatsCard` are now thin backward-compat wrappers.
- **Ph 8:** Auth screens audited — already fully compliant (Hero tag, no blobs, sharp corners, AppCard form, amber fill button, "Forgot password?" link).
- **Ph 9:** `NavigationBar` replaced with custom `_CustomBottomNav` (64px, bgSurface, borderStrong top, amber 3px indicator line, no pill). `IndexedStack` + `FadeTransition` (150ms) between tabs.
- **Ph 10:** Both dashboards fully redesigned. Instrument Serif italic headers, `fl_chart` BarCharts (amber bars, DM Mono axis labels, today-column highlight), `MetricCard` 2×2 grids, `AppCard(accent)` transaction rows, `FilterChipsRow` period selector on developer dashboard.

---

## Key Technical Notes

- **`fl_chart 0.68` API:** `SideTitleWidget` requires `axisSide: meta.axisSide` parameter.
- **`google_fonts 6.2.1`:** `GoogleFonts.instrumentSerif()` is available for headers.
- **`key_id` field:** Three candidates tried at login (`apiKeyId`, `keyId`, `api_key_id`). Confirm against live API response and remove unused fallbacks once known.
- **Backward compat wrappers:** `GlassCard`, `GradientHeader`, `StatsCard` still exist as wrappers. Remove them in Phase 15 after all screens are migrated.
- **`navigatorKey`:** Declared in `lib/main.dart`, passed to `MaterialApp`. Used by the 401 interceptor for auth-redirect without a BuildContext.
- **`WidgetsBindingObserver`:** Active in `HomeShell` — calls `_loadSession()` on `AppLifecycleState.resumed`.

---

## Session Workflow

1. Read `CONTEXT.md` (this file) — confirm current phase from the status table above.
2. Read `LOG.md` — check the last completed entry for any notes or blockers.
3. Read the HTML mockup for any UI phase before writing a single widget line.
4. Read all files you intend to modify before touching them.
5. Execute sub-phases sequentially — never skip ahead.
6. Run `flutter analyze` after each sub-phase. Zero errors required to continue.
7. Append a completed entry to `LOG.md` after each phase.
