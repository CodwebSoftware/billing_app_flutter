import 'package:billing_app_flutter/dio/controllers/payment_controller.dart';
import 'package:billing_app_flutter/dio/models/purchase/purchase_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CashPaymentScreen extends StatefulWidget {
  const CashPaymentScreen({super.key});

  @override
  State<CashPaymentScreen> createState() => _CashPaymentScreenState();
}

class _CashPaymentScreenState extends State<CashPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _receiptNumberController = TextEditingController();
  final PaymentController paymentController = Get.find<PaymentController>();

  @override
  void dispose() {
    _receiptNumberController.dispose();
    super.dispose();
  }

  Future<void> _submitCashPayment() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      PurchaseModel purchaseModel = await paymentController.processCashPayment(
        purchaseId: paymentController.currentPurchase.value!.id,
        receiptNumber: _receiptNumberController.text,
      );

      Get.back(result: true);
      Get.snackbar(
        'Success',
        'Cash payment processed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Cash Payment Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _receiptNumberController,
                decoration: const InputDecoration(
                  labelText: 'Receipt Number',
                  prefixIcon: Icon(Icons.receipt),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter receipt number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Instructions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Collect cash payment from customer\n'
                    '2. Issue official receipt\n'
                    '3. Enter receipt details above',
              ),
              const SizedBox(height: 32),
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: paymentController.isLoading.value
                        ? null
                        : _submitCashPayment,
                    child: paymentController.isLoading.value
                        ? const CircularProgressIndicator()
                        : const Text('Confirm Cash Payment'),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}