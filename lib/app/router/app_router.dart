import 'package:flutter/material.dart';
import '../../features/auth/splash_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/home/home_shell.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/orgs/org_list_page.dart';
import '../../features/orgs/org_detail_page.dart';
import '../../features/payments/payment_types_list_page.dart';
import '../../features/payments/payment_type_edit_page.dart';
import '../../features/subscriptions/subscription_status_page.dart';
import '../../features/subscriptions/subscription_manage_page.dart';
import '../../features/payouts/payouts_schedule_page.dart';
import '../../features/payouts/payouts_pending_page.dart';
import '../../features/reports/transactions_page.dart';
import '../../features/reports/org_summary_page.dart';
import '../../features/reports/ussd_sessions_page.dart';
import '../../features/settings/profile_page.dart';
import 'routes.dart';

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.splash:
      return MaterialPageRoute(builder: (_) => const SplashPage());
    case Routes.login:
      return MaterialPageRoute(builder: (_) => const LoginPage());
    case Routes.home:
      return MaterialPageRoute(builder: (_) => const HomeShell());
    case Routes.dashboard:
      return MaterialPageRoute(builder: (_) => const DashboardPage());
    case Routes.orgs:
      return MaterialPageRoute(builder: (_) => const OrgListPage());
    case Routes.orgDetail:
      return MaterialPageRoute(builder: (_) => OrgDetailPage(orgId: settings.arguments as String));
    case Routes.paymentTypes:
      return MaterialPageRoute(builder: (_) => PaymentTypesListPage(orgId: settings.arguments as String));
    case Routes.paymentTypeEdit:
      final args = settings.arguments as Map<String, String>;
      return MaterialPageRoute(builder: (_) => PaymentTypeEditPage(orgId: args['orgId']!, typeId: args['typeId']!));
    case Routes.subscriptionStatus:
      return MaterialPageRoute(builder: (_) => SubscriptionStatusPage(id: settings.arguments as String));
    case Routes.subscriptionManage:
      return MaterialPageRoute(builder: (_) => SubscriptionManagePage(id: settings.arguments as String));
    case Routes.payoutsSchedule:
      return MaterialPageRoute(builder: (_) => const PayoutsSchedulePage());
    case Routes.payoutsPending:
      return MaterialPageRoute(builder: (_) => const PayoutsPendingPage());
    case Routes.reportsTransactions:
      return MaterialPageRoute(builder: (_) => const TransactionsPage());
    case Routes.reportsOrgSummary:
      return MaterialPageRoute(builder: (_) => OrgSummaryPage(orgId: settings.arguments as String));
    case Routes.reportsUssdSessions:
      return MaterialPageRoute(builder: (_) => const UssdSessionsPage());
    case Routes.settingsProfile:
      return MaterialPageRoute(builder: (_) => const ProfilePage());
    default:
      return null;
  }
}