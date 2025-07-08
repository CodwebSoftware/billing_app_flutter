import 'package:billing_app_flutter/db/controllers/sale_entry_controller.dart';
import 'package:billing_app_flutter/core/constants/constants.dart';
import 'package:billing_app_flutter/db/models/customer_entity.dart';
import 'package:billing_app_flutter/db/models/sale_entry_entity.dart';
import 'package:billing_app_flutter/db/models/payment_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  CustomerEntity customer;
  SaleEntryEntity invoice;
  AddPaymentMethodScreen({
    super.key,
    required this.customer,
    required this.invoice,
  });

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final saleEntryController = Get.find<SaleEntryController>();

  final _formKey = GlobalKey<FormState>();

  final _paidAmountController = TextEditingController();

  String? _selectedPaymentMethod; // Make sure this is nullable
  final List<String> _paymentMethods = [
    'Cash',
    'UPI',
    'Credit Card',
    'Debit Card',
    'Buy now pay later',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Payment'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          height: 400,
          width: 300,
          child: ListView(
            children: [
              SizedBox(height: 25),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                ),
                hint: Text('Select payment method'), // Important for null value
                items:
                    _paymentMethods.map((String method) {
                      return DropdownMenuItem<String>(
                        value: method, // Each value must be unique
                        child: Text(method),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPaymentMethod = newValue;
                  });
                },
                validator:
                    (value) =>
                        value == null ? 'Please select a payment method' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _paidAmountController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a gender';
                  }
                  if (double.parse(value) >
                      (widget.invoice.totalAmount -
                          widget.invoice.amountPaid!)) {
                    return 'Please enter valid amount';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              if (_formKey.currentState!.validate()) {
                await saleEntryController.addPayment(
                  payAmount: double.parse(_paidAmountController.text),
                  customer: widget.customer,
                  invoice: widget.invoice
                );
                Get.back();
              }
            } catch (e) {
              Get.snackbar(
                "Warning",
                "Error is : $e",
                backgroundColor: snackbarBackgroundColor,
                colorText: snackbarTextColor,
              );
            }
          },
          child: const Text('Pay'),
        ),
      ],
    );
  }
}
