import 'package:billing_app_flutter/dio/controllers/payment_controller.dart';
import 'package:billing_app_flutter/presentation/widgets/credit_card_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CreditCardPaymentScreen extends StatefulWidget {
  final Map<String, dynamic> purchaseDetails;

  const CreditCardPaymentScreen({super.key, required this.purchaseDetails});

  @override
  State<CreditCardPaymentScreen> createState() => _CreditCardPaymentScreenState();
}

class _CreditCardPaymentScreenState extends State<CreditCardPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentController = Get.find<PaymentController>();
    final userEmail = 'user@example.com'; // Replace with actual user email

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your card details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              CreditCardInput(
                controller: _cardNumberController,
                label: 'Card Number',
                hint: '1234 5678 9012 3456',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  CardNumberFormatter(),
                ],
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card number';
                  }
                  if (value.length < 16) {
                    return 'Invalid card number';
                  }
                  return null;
                },
                prefixIcon: Icons.credit_card,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cardHolderController,
                decoration: const InputDecoration(
                  labelText: 'Cardholder Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cardholder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryDateController,
                      decoration: const InputDecoration(
                        labelText: 'Expiry Date',
                        hintText: 'MM/YY',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        ExpiryDateFormatter(),
                      ],
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter expiry date';
                        }
                        if (value.length < 5) { // MM/YY is 5 chars
                          return 'Invalid expiry date';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter CVV';
                        }
                        if (value.length < 3) {
                          return 'Invalid CVV';
                        }
                        return null;
                      },
                      obscureText: true,
                    ),
                  ),
                ],
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
                            .processCreditCardPayment(
                          cardNumber: _cardNumberController.text
                              .replaceAll(' ', ''),
                          cardHolder: _cardHolderController.text,
                          expiryDate: _expiryDateController.text,
                          cvv: _cvvController.text,
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
                      : const Text('Pay Now'),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var text = newValue.text.replaceAll(' ', '');
    if (text.length > 16) text = text.substring(0, 16);

    var formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) formatted += ' ';
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var text = newValue.text.replaceAll('/', '');
    if (text.length > 4) text = text.substring(0, 4);

    var formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 2) formatted += '/';
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}