import 'package:billing_app_flutter/db/controllers/product_controller.dart';
import 'package:billing_app_flutter/db/models/batch_entity.dart';
import 'package:billing_app_flutter/db/models/product_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddEditBatchScreen extends StatefulWidget {
  final ProductEntity product;
  final BatchEntity batch;

  const AddEditBatchScreen({
    super.key,
    required this.product,
    required this.batch,
  });

  @override
  State<AddEditBatchScreen> createState() => _AddEditBatchScreenState();
}

class _AddEditBatchScreenState extends State<AddEditBatchScreen>
    with SingleTickerProviderStateMixin {
  final ProductController _productController = Get.find();
  final _formKey = GlobalKey<FormState>();
  late ProductEntity product;
  late BatchEntity batch;

  final TextEditingController batchNumberController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController hsnSacController = TextEditingController();

  DateTime manufacturingDate = DateTime.now();
  DateTime expiryDate = DateTime.now();
  String gstType = 'Intra-state'; // Default to Intra-state
  double gstRate = 18.0; // Default GST rate
  double? cgstAmount;
  double? sgstAmount;
  double? igstAmount;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    product = widget.product;
    batch = widget.batch;

    if (batch.id != 0 && batch.id != null) {
      batchNumberController.text =
          batch.batchNumber ??
          (_productController.countBatches() + 1).toString();
      barcodeController.text = batch.barcode ?? '';
      quantityController.text = batch.quantity?.toString() ?? '1';
      unitPriceController.text = batch.unitPrice?.toStringAsFixed(2) ?? '';
      hsnSacController.text = batch.hsnSacCode ?? '';
      manufacturingDate = batch.manufactureDate ?? DateTime.now();
      expiryDate = batch.expiryDate ?? DateTime.now();
      gstType = batch.gstType ?? 'Intra-state';
      gstRate = batch.gstRate ?? 18.0;
    } else {
      batchNumberController.text =
          (_productController.countBatches() + 1).toString();
      barcodeController.text = '';
      quantityController.text = '1';
      unitPriceController.text = product.price?.toStringAsFixed(2) ?? '0.00';
      hsnSacController.text = product.hsnSacCode ?? '';
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Calculate taxes on init
    _calculateTaxes();
    // Add listeners to recalculate taxes on input change
    unitPriceController.addListener(_calculateTaxes);
    quantityController.addListener(_calculateTaxes);
  }

  @override
  void dispose() {
    batchNumberController.dispose();
    barcodeController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
    hsnSacController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _calculateTaxes() {
    final price = double.tryParse(unitPriceController.text) ?? 0.0;
    final qty = int.tryParse(quantityController.text) ?? 0;
    final totalAmount = price * qty;

    setState(() {
      if (gstType == 'Intra-state') {
        cgstAmount = (totalAmount * (gstRate / 2) / 100);
        sgstAmount = cgstAmount;
        igstAmount = null;
      } else {
        cgstAmount = null;
        sgstAmount = null;
        igstAmount = (totalAmount * gstRate / 100);
      }
    });
  }

  Future<void> _selectDate(BuildContext context, bool isManufacturing) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isManufacturing ? manufacturingDate : expiryDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.grey.shade800,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isManufacturing) {
          manufacturingDate = picked;
        } else {
          expiryDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    final dialogWidth =
        isLargeScreen ? 500.0 : MediaQuery.of(context).size.width * 0.9;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        backgroundColor: Colors.white,
        child: Container(
          width: dialogWidth,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        batch.id != 0 && batch.id != null
                            ? 'Edit Batch'
                            : 'Add Batch',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: batchNumberController,
                    decoration: InputDecoration(
                      labelText: 'Batch Number',
                      prefixIcon: Icon(Icons.tag, color: Colors.blue.shade700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Batch number is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: barcodeController,
                    decoration: InputDecoration(
                      labelText: 'Barcode',
                      prefixIcon: Icon(
                        Icons.qr_code,
                        color: Colors.blue.shade700,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: hsnSacController,
                    decoration: InputDecoration(
                      labelText: 'HSN/SAC Code',
                      prefixIcon: Icon(Icons.code, color: Colors.blue.shade700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'HSN/SAC code is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: gstType,
                    decoration: InputDecoration(
                      labelText: 'GST Type',
                      prefixIcon: Icon(
                        Icons.account_balance,
                        color: Colors.blue.shade700,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items:
                        ['Intra-state', 'Inter-state'].map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        gstType = value!;
                        _calculateTaxes();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<double>(
                    value: gstRate,
                    decoration: InputDecoration(
                      labelText: 'GST Rate (%)',
                      prefixIcon: Icon(
                        Icons.percent,
                        color: Colors.blue.shade700,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items:
                        [0.0, 5.0, 12.0, 18.0, 28.0].map((double rate) {
                          return DropdownMenuItem<double>(
                            value: rate,
                            child: Text('$rate%'),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        gstRate = value!;
                        _calculateTaxes();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: unitPriceController,
                    decoration: InputDecoration(
                      labelText: 'Unit Price (₹)',
                      prefixIcon: Icon(
                        Icons.currency_rupee,
                        color: Colors.blue.shade700,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}$'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Unit price is required';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Enter a valid price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: quantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      prefixIcon: Icon(
                        Icons.numbers,
                        color: Colors.blue.shade700,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Quantity is required';
                      }
                      final qty = int.tryParse(value);
                      if (qty == null || qty <= 0) {
                        return 'Enter a valid quantity';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Manufacturing Date',
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: Colors.blue.shade700,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      child: Text(
                        DateFormat("MMM d, y").format(manufacturingDate),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Expiry Date',
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: Colors.blue.shade700,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      child: Text(
                        DateFormat("MMM d, y").format(expiryDate),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (gstType == 'Intra-state') ...[
                    Text(
                      'CGST (${gstRate / 2}%): ₹${cgstAmount?.toStringAsFixed(2) ?? '0.00'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'SGST (${gstRate / 2}%): ₹${sgstAmount?.toStringAsFixed(2) ?? '0.00'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ] else
                    Text(
                      'IGST ($gstRate%): ₹${igstAmount?.toStringAsFixed(2) ?? '0.00'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (expiryDate.isBefore(manufacturingDate)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Expiry date cannot be before manufacturing date',
                                  ),
                                ),
                              );
                              return;
                            }
                            batch.batchNumber = batchNumberController.text;
                            batch.barcode = barcodeController.text;
                            batch.hsnSacCode = hsnSacController.text;
                            batch.gstType = gstType;
                            batch.gstRate = gstRate;
                            batch.unitPrice = double.parse(
                              unitPriceController.text,
                            );
                            batch.quantity = int.parse(quantityController.text);
                            batch.manufactureDate = manufacturingDate;
                            batch.expiryDate = expiryDate;
                            batch.isDeleted = false;
                            batch.cgstAmount = cgstAmount;
                            batch.sgstAmount = sgstAmount;
                            batch.igstAmount = igstAmount;
                            _productController.saveBatchToProduct(
                              product,
                              batch,
                            );
                            _productController.update();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Batch saved successfully'),
                              ),
                            );
                            Get.back();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
