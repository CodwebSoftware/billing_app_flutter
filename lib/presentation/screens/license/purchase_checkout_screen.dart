import 'package:billing_app_flutter/dio/controllers/payment_controller.dart';
import 'package:billing_app_flutter/dio/models/purchase/purchase_model.dart';
import 'package:billing_app_flutter/presentation/routes/app_routes.dart';
import 'package:billing_app_flutter/presentation/screens/license/cash_payment_screen.dart';
import 'package:billing_app_flutter/presentation/screens/license/check_payment_screen.dart';
import 'package:billing_app_flutter/presentation/widgets/payment_method_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PurchaseCheckoutScreen extends GetView<PaymentController> {
  final Map<String, dynamic> purchaseDetails;

  const PurchaseCheckoutScreen({super.key, required this.purchaseDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            PaymentMethodCard(
              icon: Icons.credit_card,
              title: 'Credit Card',
              onSelect:
                  () => _processPayment(
                    context,
                    purchaseDetails['email'],
                    'credit_card',
                  ),
            ),
            const SizedBox(height: 16),
            PaymentMethodCard(
              icon: Icons.paypal,
              title: 'PayPal',
              onSelect:
                  () => _processPayment(
                    context,
                    purchaseDetails['email'],
                    'paypal',
                  ),
            ),
            const SizedBox(height: 16),
            PaymentMethodCard(
              icon: Icons.account_balance,
              title: 'Bank Transfer',
              onSelect:
                  () => _processPayment(
                    context,
                    purchaseDetails['email'],
                    'bank_transfer',
                  ),
            ),
            const SizedBox(height: 16),
            PaymentMethodCard(
              icon: Icons.money,
              title: 'Cash Payment',
              onSelect:
                  () => _processPayment(
                    context,
                    purchaseDetails['email'],
                    'cash_payment',
                  ),
            ),
            const SizedBox(height: 16),
            PaymentMethodCard(
              icon: Icons.description,
              title: 'Check Payment',
              onSelect:
                  () => _processPayment(
                    context,
                    purchaseDetails['email'],
                    'check_payment',
                  ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryRow('Software', purchaseDetails['softwareId']),
                    const Divider(),
                    _buildSummaryRow('Platform', purchaseDetails['platform']),
                    const Divider(),
                    _buildSummaryRow(
                      'Amount',
                      '\$${purchaseDetails['amount'].toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _processPayment(
    BuildContext context,
    String email,
    String method,
  ) async {
    try {
      // In a real app, you would integrate with a payment gateway here
      // For demo purposes, we'll simulate a successful payment

      // 1. Create purchase record
      await controller.createPurchase(
        email: email,
        softwareId: purchaseDetails['softwareId'],
        platform: purchaseDetails['platform'],
        amount: purchaseDetails['amount'],
        currency: purchaseDetails['currency'],
      );

      // 2. Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      late bool isPaid;
      if (method == 'credit_card') {
        isPaid = await Get.toNamed(AppRoutes.creditCardPayment, arguments: purchaseDetails);
      }else if (method == 'paypal') {
        isPaid = await Get.toNamed(AppRoutes.paypalPayment, arguments: purchaseDetails);
      }else if (method == 'bank_transfer') {
        isPaid = await Get.toNamed(AppRoutes.bankTransferPayment, arguments: purchaseDetails);
      }else if (method == 'cash_payment') {
        isPaid = await Get.toNamed(AppRoutes.cashPayment);
      }else if (method == 'check_payment') {
        isPaid = await Get.toNamed(AppRoutes.checkPayment);
      }

      if (isPaid) {
        // 3. Complete purchase with simulated payment ID
        final license = await controller.completePurchase(
          purchaseId: controller.currentPurchase.value!.id,
          paymentId:
              'simulated_payment_${DateTime.now().millisecondsSinceEpoch}',
        );

        // 4. Navigate to success screen
        Get.offAllNamed(AppRoutes.purchaseSuccess, arguments: license);
      }
    } catch (e) {
      Get.snackbar(
        'Payment Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print(e.toString());
    }
  }
}
