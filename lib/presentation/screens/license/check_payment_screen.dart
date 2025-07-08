import 'package:billing_app_flutter/dio/controllers/payment_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckPaymentScreen extends StatefulWidget {
  const CheckPaymentScreen({super.key});

  @override
  State<CheckPaymentScreen> createState() => _CheckPaymentScreenState();
}

class _CheckPaymentScreenState extends State<CheckPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _checkNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final PaymentController paymentController = Get.find<PaymentController>();

  @override
  void dispose() {
    _checkNumberController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  Future<void> _submitCheckPayment() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await paymentController.processCheckPayment(
        purchaseId: paymentController.currentPurchase.value!.id,
        checkNumber: _checkNumberController.text,
        bankName: _bankNameController.text,
      );

      Get.back();
      Get.snackbar(
        'Success',
        'Check payment submitted',
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
        title: const Text('Check Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter Check Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _checkNumberController,
                decoration: const InputDecoration(
                  labelText: 'Check Number',
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter check number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  prefixIcon: Icon(Icons.account_balance),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter bank name';
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
                '1. Verify check details with customer\n'
                    '2. Ensure check is properly signed\n'
                    '3. License will be activated after check clears',
              ),
              const SizedBox(height: 32),
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: paymentController.isLoading.value
                        ? null
                        : _submitCheckPayment,
                    child: paymentController.isLoading.value
                        ? const CircularProgressIndicator()
                        : const Text('Submit Check Payment'),
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