import 'package:billing_app_flutter/app.dart';
import 'package:billing_app_flutter/dio/controllers/onboarding_controller.dart';
import 'package:billing_app_flutter/presentation/routes/app_routes.dart';
import 'package:billing_app_flutter/presentation/screens/license/bank_transfer_payment_screen.dart';
import 'package:billing_app_flutter/presentation/screens/license/cash_payment_screen.dart';
import 'package:billing_app_flutter/presentation/screens/license/check_payment_screen.dart';
import 'package:billing_app_flutter/presentation/screens/license/credit_card_payment_screen.dart';
import 'package:billing_app_flutter/presentation/screens/license/license_activation_screen.dart';
import 'package:billing_app_flutter/presentation/screens/license/license_management_screen.dart';
import 'package:billing_app_flutter/presentation/screens/license/license_renewal_screen.dart';
import 'package:billing_app_flutter/presentation/screens/license/license_success_screen.dart';
import 'package:billing_app_flutter/presentation/screens/license/onboarding_screen.dart';
import 'package:billing_app_flutter/presentation/screens/license/paypal_payment_screen.dart';
import 'package:billing_app_flutter/presentation/screens/license/purchase_checkout_screen.dart';
import 'package:billing_app_flutter/presentation/screens/license/purchase_options_screen.dart';
import 'package:billing_app_flutter/presentation/screens/license/purchase_success_screen.dart';
import 'package:get/get.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.onboarding,
      page: () => OnboardingScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => OnboardingController());
      }),
    ),
    GetPage(
      name: AppRoutes.licenseActivation,
      page: () => LicenseActivationScreen(),
    ),
    GetPage(
      name: AppRoutes.licenseSuccess,
      page: () => LicenseSuccessScreen(license: Get.arguments),
    ),
    GetPage(
      name: AppRoutes.licenseManagement,
      page: () => LicenseManagementScreen(),
    ),
    GetPage(
      name: AppRoutes.licenseRenewal,
      page: () => LicenseRenewalScreen(license: Get.arguments),
    ),
    GetPage(
      name: AppRoutes.purchaseOptions,
      page: () => const PurchaseOptionsScreen(),
    ),
    GetPage(
      name: AppRoutes.purchaseCheckout,
      page: () => PurchaseCheckoutScreen(purchaseDetails: Get.arguments),
    ),
    GetPage(
      name: AppRoutes.purchaseSuccess,
      page: () => PurchaseSuccessScreen(license: Get.arguments),
    ),
    GetPage(
      name: AppRoutes.creditCardPayment,
      page: () => CreditCardPaymentScreen(purchaseDetails: Get.arguments),
    ),
    GetPage(
      name: AppRoutes.paypalPayment,
      page: () => PayPalPaymentScreen(purchaseDetails: Get.arguments),
    ),
    GetPage(
      name: AppRoutes.bankTransferPayment,
      page: () => BankTransferPaymentScreen(purchaseDetails: Get.arguments),
    ),
    GetPage(name: AppRoutes.app, page: () => App()),
    GetPage(
      name: AppRoutes.cashPayment,
      page: () => CashPaymentScreen(),
    ),
    GetPage(
      name: AppRoutes.checkPayment,
      page: () => CheckPaymentScreen(),
    )
  ];
}