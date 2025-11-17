# Quick Command Reference

## 🚀 Getting Started

```bash
# Navigate to project
cd /Users/kevinafenyo/Documents/GitHub/ussd-service/apps/flutter/ussd_admin

# Install new dependency (intl)
flutter pub get

# Check for errors
flutter analyze

# Run app
flutter run

# Run on specific device
flutter devices
flutter run -d <device_id>
```

---

## 📁 Project Structure

```
lib/
├── app/
│   ├── router/
│   │   ├── app_router.dart
│   │   └── routes.dart
│   └── theme/
│       └── app_theme.dart         ✅ Already updated
│
├── features/
│   ├── auth/
│   │   ├── login_page.dart        ✅ Working
│   │   └── splash_page.dart       ⚠️  Need to create
│   ├── dashboard/
│   │   └── dashboard_page.dart    ⚠️  Need real data
│   ├── orgs/
│   │   ├── org_list_page.dart     ✅ Working (enhance)
│   │   ├── org_detail_page.dart   ⚠️  Need to implement
│   │   └── org_store.dart         ✅ Working
│   ├── payments/
│   │   ├── payment_types_list_page.dart   ⚠️  Need to implement
│   │   └── payment_type_edit_page.dart    ⚠️  Need to implement
│   ├── subscriptions/
│   │   ├── subscription_status_page.dart  ⚠️  Need to implement
│   │   └── subscription_manage_page.dart  ⚠️  Need to implement
│   ├── payouts/
│   │   ├── payouts_schedule_page.dart     ⚠️  Need to implement
│   │   └── payouts_pending_page.dart      ⚠️  Need to implement
│   ├── reports/
│   │   ├── transactions_page.dart         ⚠️  Need to implement
│   │   ├── org_summary_page.dart          ⚠️  Need to implement
│   │   └── ussd_sessions_page.dart        ⚠️  Need to implement
│   └── settings/
│       └── profile_page.dart              ⚠️  Need to implement
│
├── shared/
│   ├── http/
│   │   └── client.dart            ✅ Working
│   ├── models/
│   │   ├── organization.dart      ✅ Working
│   │   ├── paged.dart             ✅ Working
│   │   ├── payment_type.dart      ✅ NEW - Ready
│   │   ├── subscription.dart      ✅ NEW - Ready
│   │   ├── transaction.dart       ✅ NEW - Ready
│   │   ├── payout.dart            ✅ NEW - Ready
│   │   ├── org_summary.dart       ✅ NEW - Ready
│   │   └── ussd_session_stats.dart ✅ NEW - Ready
│   ├── services/
│   │   ├── org_service.dart             ✅ Working
│   │   ├── payment_type_service.dart    ✅ NEW - Ready
│   │   ├── subscription_service.dart    ✅ NEW - Ready
│   │   ├── payout_service.dart          ✅ NEW - Ready
│   │   └── reports_service.dart         ✅ NEW - Ready
│   └── utils/
│       └── helpers.dart           ✅ NEW - Ready
│
├── widgets/
│   ├── glass_card.dart            ✅ Working
│   ├── gradient_header.dart       ✅ Working
│   └── stats_card.dart            ⚠️  Need to create
│
└── main.dart                      ✅ Working (update initialRoute)
```

---

## 🔧 Common Flutter Commands

```bash
# Clean build
flutter clean

# Reinstall dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Check for updates
flutter pub outdated

# Format code
flutter format lib/

# Analyze code
flutter analyze

# Run tests
flutter test

# Build APK (Android)
flutter build apk

# Build iOS
flutter build ios
```

---

## 🐛 Debugging

```bash
# Run in debug mode
flutter run

# Run with verbose logging
flutter run -v

# Hot reload (in running app)
# Press 'r' in terminal

# Hot restart (in running app)
# Press 'R' in terminal

# Clear cache and rebuild
flutter clean
flutter pub get
flutter run
```

---

## 📦 Using New Code

### Import New Models
```dart
import 'package:ussd_admin/shared/models/payment_type.dart';
import 'package:ussd_admin/shared/models/subscription.dart';
```

### Import New Services
```dart
import 'package:ussd_admin/shared/services/payment_type_service.dart';
import 'package:ussd_admin/shared/services/subscription_service.dart';
```

### Import Helpers
```dart
import 'package:ussd_admin/shared/utils/helpers.dart';
```

### Use Helpers
```dart
// Currency
final formatted = CurrencyFormatters.formatGHS(1234.56);

// Dates
final date = DateFormatters.formatDate(DateTime.now());

// Validation
final error = Validators.email(email);

// Dialogs
DialogHelpers.showSuccess(context, 'Success!');

// Status
StatusHelpers.buildStatusBadge('active');
```

---

## 🎯 Quick Tasks

### Task 1: Install New Dependency
```bash
flutter pub get
```

### Task 2: Verify Everything Compiles
```bash
flutter analyze
# Should show no errors
```

### Task 3: Test Run
```bash
flutter run
# App should start normally
```

### Task 4: Start Building
```
See IMPLEMENTATION_NEXT_STEPS.md for detailed guide
```

---

## 📚 Documentation Files

In your project root:
- ✅ `IMPLEMENTATION_NEXT_STEPS.md` - What to do next
- ✅ `FILES_ADDED.md` - What was added
- ✅ `COMMANDS.md` - This file

In `/mnt/user-data/outputs/`:
- ✅ Complete implementation guides
- ✅ Detailed API documentation
- ✅ Code examples
- ✅ Architecture diagrams

---

## 🆘 Need Help?

1. Check `IMPLEMENTATION_NEXT_STEPS.md` for step-by-step guide
2. Check `QUICK_REFERENCE.md` in outputs for quick lookups
3. Check `ROUTES_IMPLEMENTATION_MAP.md` for detailed page examples
4. Run `flutter doctor` to check your Flutter installation

---

## ✅ Checklist

Before you start coding:
- [ ] Run `flutter pub get`
- [ ] Run `flutter analyze` (should pass)
- [ ] Run `flutter run` (app should start)
- [ ] Read `IMPLEMENTATION_NEXT_STEPS.md`
- [ ] Understand the project structure above

After each page:
- [ ] Test the page
- [ ] Check for errors
- [ ] Verify API calls work
- [ ] Test role-based access
- [ ] Commit your code

---

**Ready to build! 🚀**
