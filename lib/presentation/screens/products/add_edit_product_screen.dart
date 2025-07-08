import 'package:billing_app_flutter/db/controllers/product_controller.dart';
import 'package:billing_app_flutter/db/models/product_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductEntity product;

  const AddEditProductScreen({super.key, required this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final ProductController productController = Get.find();
  final _formKey = GlobalKey<FormState>();
  late bool isEdit;
  late TextEditingController nameController;
  late TextEditingController codeController;
  late TextEditingController descriptionController;
  late TextEditingController barcodeController;
  late TextEditingController priceController;

  late ProductEntity product;

  @override
  void initState() {
    super.initState();
    product = widget.product;
    isEdit = product.id != null && product.id != 0;
    nameController = TextEditingController(text: product.name);
    codeController = TextEditingController(text: product.code);
    descriptionController = TextEditingController(text: product.description ?? '');
    barcodeController = TextEditingController(text: product.barcode ?? '');
    priceController = TextEditingController(text: product.price?.toString() ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    descriptionController.dispose();
    barcodeController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    final dialogWidth = isLargeScreen ? 500.0 : MediaQuery.of(context).size.width * 0.9;

    return Dialog(
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
                Text(
                  isEdit ? 'Edit Product' : 'Add Product',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.label, color: Colors.blue.shade700),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: codeController,
                  decoration: InputDecoration(
                    labelText: 'Code',
                    prefixIcon: Icon(Icons.code, color: Colors.blue.shade700),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Code is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description, color: Colors.blue.shade700),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: barcodeController,
                  decoration: InputDecoration(
                    labelText: 'Barcode',
                    prefixIcon: Icon(Icons.qr_code, color: Colors.blue.shade700),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Price (₹)',
                    prefixIcon: Icon(Icons.currency_rupee, color: Colors.blue.shade700),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
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
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Cancel', style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          product.name = nameController.text;
                          product.code = codeController.text;
                          product.description = descriptionController.text;
                          product.barcode = barcodeController.text;
                          product.price = double.parse(priceController.text);
                          product.quantity = 0;
                          product.isDeleted = product.isDeleted ?? false;
                          productController.saveProduct(product);
                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}