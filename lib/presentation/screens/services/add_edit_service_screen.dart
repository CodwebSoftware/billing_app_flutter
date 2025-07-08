import 'package:billing_app_flutter/db/controllers/service_controller.dart';
import 'package:billing_app_flutter/db/models/service_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AddEditServiceScreen extends StatefulWidget {
  final ServiceEntity service;

  const AddEditServiceScreen({super.key, required this.service});

  @override
  State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
}

class _AddEditServiceScreenState extends State<AddEditServiceScreen> with SingleTickerProviderStateMixin {
  final ServiceController serviceController = Get.find();
  late ServiceEntity service;
  final _formKey = GlobalKey<FormState>();
  late bool isEdit;
  late TextEditingController nameController;
  late TextEditingController codeController;
  late TextEditingController descriptionController;
  late TextEditingController hsnSacController;
  late TextEditingController priceController;
  late TextEditingController durationController;

  String gstType = 'Intra-state'; // Default GST type
  double gstRate = 18.0; // Default GST rate
  double? cgstAmount;
  double? sgstAmount;
  double? igstAmount;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    service = widget.service;
    isEdit = service.id != 0;
    nameController = TextEditingController(text: service.name ?? '');
    codeController = TextEditingController(text: service.code ?? '');
    descriptionController = TextEditingController(text: service.description ?? '');
    hsnSacController = TextEditingController(text: service.hsnSacCode ?? '');
    priceController = TextEditingController(text: service.price?.toStringAsFixed(2) ?? '');
    durationController = TextEditingController(text: service.duration?.toString() ?? '');
    gstType = service.gstType ?? 'Intra-state';
    gstRate = service.gstRate ?? 18.0;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();

    // Calculate taxes on init
    _calculateTaxes();
    // Add listeners for real-time tax updates
    priceController.addListener(_calculateTaxes);
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    descriptionController.dispose();
    hsnSacController.dispose();
    priceController.dispose();
    durationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _calculateTaxes() {
    final price = double.tryParse(priceController.text) ?? 0.0;

    setState(() {
      if (gstType == 'Intra-state') {
        cgstAmount = (price * (gstRate / 2) / 100);
        sgstAmount = cgstAmount;
        igstAmount = null;
      } else {
        cgstAmount = null;
        sgstAmount = null;
        igstAmount = (price * gstRate / 100);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    final dialogWidth = isLargeScreen ? 500.0 : MediaQuery.of(context).size.width * 0.9;

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
                        isEdit ? 'Edit Service' : 'Add Service',
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
                    controller: hsnSacController,
                    decoration: InputDecoration(
                      labelText: 'SAC Code',
                      prefixIcon: Icon(Icons.code, color: Colors.blue.shade700),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'SAC code is required';
                      }
                      if (value.length < 6) {
                        return '6-digit SAC code required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: gstType,
                    decoration: InputDecoration(
                      labelText: 'GST Type',
                      prefixIcon: Icon(Icons.account_balance, color: Colors.blue.shade700),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: ['Intra-state', 'Inter-state'].map((String type) {
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
                      prefixIcon: Icon(Icons.percent, color: Colors.blue.shade700),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: [0.0, 5.0, 12.0, 18.0, 28.0].map((double rate) {
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: durationController,
                    decoration: InputDecoration(
                      labelText: 'Duration (minutes)',
                      prefixIcon: Icon(Icons.timer, color: Colors.blue.shade700),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Duration is required';
                      }
                      final duration = int.tryParse(value);
                      if (duration == null || duration <= 0) {
                        return 'Enter a valid duration';
                      }
                      return null;
                    },
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
                        onPressed: () => Get.back(),
                        child: Text('Cancel', style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            service.name = nameController.text;
                            service.code = codeController.text;
                            service.description = descriptionController.text;
                            service.hsnSacCode = hsnSacController.text;
                            service.gstType = gstType;
                            service.gstRate = gstRate;
                            service.cgstAmount = cgstAmount;
                            service.sgstAmount = sgstAmount;
                            service.igstAmount = igstAmount;
                            service.price = double.parse(priceController.text);
                            service.duration = int.parse(durationController.text);
                            service.isDeleted = service.isDeleted ?? false;
                            serviceController.saveService(service);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Service saved successfully')),
                            );
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
      ),
    );
  }
}