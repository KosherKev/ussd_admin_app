import 'package:flutter/material.dart';
import '../../features/auth/splash_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/home/home_shell.dart';
import '../../features/payments/payment_types_list_page.dart';
import '../../features/payments/payment_type_edit_page.dart';
import '../../features/subscriptions/subscription_status_page.dart';
import '../../features/reports/transactions_page.dart';
import '../../features/reports/org_summary_page.dart';
import '../../features/settings/profile_page.dart';
import '../../features/developer/webhooks_list_page.dart';
import '../../features/developer/webhook_delivery_detail_page.dart';
import 'routes.dart';

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.splash:
      return MaterialPageRoute(builder: (_) => const SplashPage());
    case Routes.login:
      return MaterialPageRoute(builder: (_) => const LoginPage());
    case Routes.home:
      final initialIndex = settings.arguments is int ? settings.arguments as int : 0;
      return MaterialPageRoute(builder: (_) => HomeShell(initialIndex: initialIndex));

    // --- Org Admin ---
    case Routes.paymentTypes:
      return MaterialPageRoute(builder: (_) => PaymentTypesListPage(orgId: settings.arguments as String));
    case Routes.paymentTypeEdit:
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) => PaymentTypeEditPage(
          orgId:  args['orgId'] as String,
          typeId: args['typeId'] as String?,
        ),
      );
    case Routes.subscriptionStatus:
      final subId = (settings.arguments as String?) ?? '';
      return MaterialPageRoute(builder: (_) => SubscriptionStatusPage(id: subId));
    case Routes.reportsTransactions:
      return MaterialPageRoute(builder: (_) => const TransactionsPage());
    case Routes.reportsOrgSummary:
      return MaterialPageRoute(builder: (_) => OrgSummaryPage(orgId: settings.arguments as String));
    case Routes.settingsProfile:
      return MaterialPageRoute(builder: (_) => const ProfilePage());

    // --- Developer ---
    case Routes.webhooksList:
      return MaterialPageRoute(builder: (_) => const WebhooksListPage());
    case Routes.webhookDetail:
      return MaterialPageRoute(builder: (_) => WebhookDeliveryDetailPage(deliveryId: settings.arguments as String));

    default:
      return null;
  }
}