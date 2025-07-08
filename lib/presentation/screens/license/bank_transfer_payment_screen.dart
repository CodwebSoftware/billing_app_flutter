import 'package:billing_app_flutter/dio/controllers/payment_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BankTransferPaymentScreen extends StatefulWidget {
  final Map<String, dynamic> purchaseDetails;

  const BankTransferPaymentScreen({super.key, required this.purchaseDetails});

  @override
  State<BankTransferPaymentScreen> createState() =>
      _BankTransferPaymentScreenState();
}

class _BankTransferPaymentScreenState extends State<BankTransferPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _routingNumberController = TextEditingController();

  @override
  void dispose() {
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _bankNameController.dispose();
    _routingNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentController = Get.find<PaymentController>();
    final userEmail = 'user@example.com'; // Replace with actual user email

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Transfer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bank Account Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
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
              TextFormField(
                controller: _accountNameController,
                decoration: const InputDecoration(
                  labelText: 'Account Holder Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account holder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _accountNumberController,
                decoration: const InputDecoration(
                  labelText: 'Account Number',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _routingNumberController,
                decoration: const InputDecoration(
                  labelText: 'Routing Number',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter routing number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'Transfer Instructions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Use the following details for your bank transfer:\n'
                    '   Bank: Global Fintech Bank\n'
                    '   Account: 1234567890\n'
                    '   Routing: 110000000\n'
                    '2. Include your email as reference\n'
                    '3. The license will be activated once payment is received',
              ),
              const SizedBox(height: 32),
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: paymentController.isLoading.value
                      ? null
                      : () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final license = await paymentController
                            .processBankTransferPayment(
                          accountNumber: _accountNumberController.text,
                          accountName: _accountNameController.text,
                          bankName: _bankNameController.text,
                          routingNumber: _routingNumberController.text,
                          email: userEmail,
                          purchaseDetails: widget.purchaseDetails,
                        );
                        Get.offAllNamed(
                          '/purchase-success',
                          arguments: license,
                        );
                      } catch (e) {
                        Get.snackbar(
                          'Payment Failed',
                          e.toString(),
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    }
                  },
                  child: paymentController.isLoading.value
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Confirm Transfer'),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}