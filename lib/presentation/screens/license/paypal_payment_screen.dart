import 'package:billing_app_flutter/dio/controllers/payment_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PayPalPaymentScreen extends StatefulWidget {
  final Map<String, dynamic> purchaseDetails;

  const PayPalPaymentScreen({super.key, required this.purchaseDetails});

  @override
  State<PayPalPaymentScreen> createState() => _PayPalPaymentScreenState();
}

class _PayPalPaymentScreenState extends State<PayPalPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentController = Get.find<PaymentController>();
    final userEmail = 'user@example.com'; // Replace with actual user email

    return Scaffold(
      appBar: AppBar(
        title: const Text('PayPal Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: FlutterLogo(size: 80),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Log in to your PayPal account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'PayPal Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your PayPal email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'PayPal Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // For demo purposes, we'll auto-fill with test credentials
                  _emailController.text = 'test@example.com';
                  _passwordController.text = 'password123';
                },
                child: const Text('Use test credentials'),
              ),
              const SizedBox(height: 32),
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003087),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: paymentController.isLoading.value
                      ? null
                      : () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final license = await paymentController
                            .processPayPalPayment(
                          email: _emailController.text,
                          password: _passwordController.text,
                          purchaseEmail: userEmail,
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
                      : const Text('Log In and Pay'),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}