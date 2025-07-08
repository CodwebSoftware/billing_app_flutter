import 'package:billing_app_flutter/db/models/sale_entry_services_entity.dart';
import 'package:billing_app_flutter/db/models/service_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddInvoiceServiceScreen extends StatefulWidget {
  ServiceEntity service;
  AddInvoiceServiceScreen({super.key, required this.service});

  @override
  State<AddInvoiceServiceScreen> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddInvoiceServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _discountController = TextEditingController();
  bool _isDiscountPercentage = false;

  late ServiceEntity service;

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    service = widget.service;
    _priceController.text = service.price!.toStringAsFixed(2);
    _quantityController.text = '1';
    _discountController.text = '0.0';
    super.initState();
  }

  double _calculateTotal() {
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final subtotal = price * quantity;
    final discountAmount = _isDiscountPercentage ? subtotal * (discount / 100) : discount;
    return subtotal - discountAmount;
  }

  @override
  Widget build(BuildContext context) {
    // Responsive dialog size
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    final dialogWidth = isLargeScreen ? 500.0 : MediaQuery.of(context).size.width * 0.9;

    return AlertDialog(
      title: const Text('Add Invoice Service', style: TextStyle(
        fontWeight: FontWeight.w500,
      ),
      ),
      content: Container(
        width: dialogWidth,
        padding: EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.black45
            )
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                '${widget.service.name}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 16),
              // Price Field
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  prefixIcon: Icon(Icons.currency_rupee, color: Colors.blue.shade700, size: 15,),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  errorStyle: const TextStyle(color: Colors.redAccent),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Price is required';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {}); // Update total preview
                },
              ),
              const SizedBox(height: 16),

              // Quantity Field
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  prefixIcon: Icon(Icons.numbers, color: Colors.blue.shade700, size: 15,),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  errorStyle: const TextStyle(color: Colors.redAccent),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Quantity is required';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Enter a valid quantity';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {}); // Update total preview
                },
              ),
              const SizedBox(height: 16),

              // Discount Field
              TextFormField(
                controller: _discountController,
                decoration: InputDecoration(
                  labelText: 'Discount ${_isDiscountPercentage ? '(%)' : '(₹)'}',
                  prefixIcon: Icon(Icons.discount, color: Colors.blue.shade700, size: 15,),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  errorStyle: const TextStyle(color: Colors.redAccent),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null; // Discount is optional
                  }
                  final discount = double.tryParse(value);
                  if (discount == null || discount < 0) {
                    return 'Enter a valid discount';
                  }
                  if (_isDiscountPercentage && discount > 100) {
                    return 'Percentage discount cannot exceed 100%';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {}); // Update total preview
                },
              ),
              const SizedBox(height: 16),

              // Discount Type Toggle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discount Type: ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Amount (₹)'),
                        selected: !_isDiscountPercentage,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _isDiscountPercentage = false;
                            });
                          }
                        },
                        selectedColor: Colors.blue.shade100,
                        checkmarkColor: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Percentage (%)'),
                        selected: _isDiscountPercentage,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _isDiscountPercentage = true;
                            });
                          }
                        },
                        selectedColor: Colors.blue.shade100,
                        checkmarkColor: Colors.blue.shade700,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Total Preview
              AnimatedOpacity(
                opacity: _formKey.currentState?.validate() ?? false ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  'Total: ₹${_calculateTotal().toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final invoiceServiceEntity = SaleEntryServicesEntity();
                        invoiceServiceEntity.service.target = service;
                        invoiceServiceEntity.quantity = int.parse(_quantityController.text);
                        invoiceServiceEntity.price = double.parse(_priceController.text);
                        invoiceServiceEntity.discount =  double.parse(_discountController.text.isEmpty ? '0.0' : _discountController.text);
                        invoiceServiceEntity.isDiscountPercentage = _isDiscountPercentage;
                        invoiceServiceEntity.gstRate = 0;
                        invoiceServiceEntity.gstRate = 0;
                        invoiceServiceEntity.isHeld = false;
                        invoiceServiceEntity.isDeleted = false;
                        Navigator.pop(context, invoiceServiceEntity);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Add Service',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
