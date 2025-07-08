import 'package:billing_app_flutter/dio/controllers/payment_controller.dart';
import 'package:billing_app_flutter/presentation/routes/app_routes.dart';
import 'package:billing_app_flutter/presentation/widgets/purchase_option_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PurchaseOptionsScreen extends GetView<PaymentController> {
  const PurchaseOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase License'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Select a License Plan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          PurchaseOptionCard(
            title: 'Annual Subscription',
            price: 99.99,
            features: const [
              '1 Year of Updates',
              'Priority Support',
              'All Features Included',
            ],
            onSelect: () => Get.toNamed(
              AppRoutes.purchaseCheckout,
              arguments: {
                'softwareId': 'your_software_id',
                'platform': 'mobile',
                'amount': 99.99,
                'currency': 'USD',
                'email':'email'
              },
            ),
          ),
          const SizedBox(height: 16),
          PurchaseOptionCard(
            title: 'Monthly Subscription',
            price: 9.99,
            features: const [
              'Monthly Updates',
              'Standard Support',
              'All Features Included',
            ],
            onSelect: () => Get.toNamed(
              AppRoutes.purchaseCheckout,
              arguments: {
                'softwareId': 'your_software_id',
                'platform': 'mobile',
                'amount': 9.99,
                'currency': 'USD',
                'email':'email'
              },
            ),
          ),
          const SizedBox(height: 16),
          PurchaseOptionCard(
            title: 'Lifetime License',
            price: 299.99,
            features: const [
              'Lifetime Updates',
              'Priority Support',
              'All Features Included',
              'Free Major Upgrades',
            ],
            onSelect: () => Get.toNamed(
              AppRoutes.purchaseCheckout,
              arguments: {
                'softwareId': 'your_software_id',
                'platform': 'mobile',
                'amount': 299.99,
                'currency': 'USD',
                'email':'email'
              },
            ),
          ),
        ],
      ),
    );
  }
}