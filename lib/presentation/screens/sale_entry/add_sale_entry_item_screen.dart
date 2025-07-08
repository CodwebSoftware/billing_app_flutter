import 'package:billing_app_flutter/db/models/batch_entity.dart';
import 'package:billing_app_flutter/db/models/sale_entry_items_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddInvoiceItemScreen extends StatefulWidget {
  final BatchEntity batch;

  const AddInvoiceItemScreen({super.key, required this.batch});

  @override
  State<AddInvoiceItemScreen> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddInvoiceItemScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _discountController = TextEditingController();
  bool _isDiscountPercentage = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _priceController.text = widget.batch.unitPrice!.toStringAsFixed(2);
    _quantityController.text = '1';
    _discountController.text = '0.0';

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    _discountController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  double _calculateTotal() {
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final subtotal = price * quantity;
    final discountAmount =
        _isDiscountPercentage ? subtotal * (discount / 100) : discount;
    return subtotal - discountAmount;
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
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
                      'Add Item: ${widget.batch.product.target!.name}',
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
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Price (₹)',
                    prefixIcon: Icon(
                      Icons.currency_rupee,
                      color: Colors.blue.shade700,
                      size: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
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
                      return 'Price is required';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Enter a valid price';
                    }
                    if (price > widget.batch.unitPrice!) {
                      return 'Price cannot exceed batch price (₹${widget.batch.unitPrice!.toStringAsFixed(2)})';
                    }
                    return null;
                  },
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    prefixIcon: Icon(
                      Icons.numbers,
                      color: Colors.blue.shade700,
                      size: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
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
                    final quantity = int.tryParse(value);
                    if (quantity == null || quantity <= 0) {
                      return 'Enter a valid quantity';
                    }
                    if (quantity > widget.batch.quantity!) {
                      return 'Quantity exceeds available stock (${widget.batch.quantity})';
                    }
                    return null;
                  },
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _discountController,
                  decoration: InputDecoration(
                    labelText:
                        'Discount ${_isDiscountPercentage ? '(%)' : '(₹)'}',
                    prefixIcon: Icon(
                      Icons.discount,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
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
                    if (value == null || value.isEmpty) return null;
                    final discount = double.tryParse(value);
                    if (discount == null || discount < 0) {
                      return 'Enter a valid discount';
                    }
                    if (_isDiscountPercentage && discount > 100) {
                      return 'Percentage discount cannot exceed 100%';
                    }
                    return null;
                  },
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Text(
                      'Discount Type: ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ChoiceChip(
                      label: const Text('Amount (₹)'),
                      selected: !_isDiscountPercentage,
                      onSelected: (selected) {
                        if (selected)
                          setState(() => _isDiscountPercentage = false);
                      },
                      selectedColor: Colors.blue.shade100,
                      checkmarkColor: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Percentage (%)'),
                      selected: _isDiscountPercentage,
                      onSelected: (selected) {
                        if (selected)
                          setState(() => _isDiscountPercentage = true);
                      },
                      selectedColor: Colors.blue.shade100,
                      checkmarkColor: Colors.blue.shade700,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                AnimatedOpacity(
                  opacity:
                      _formKey.currentState?.validate() ?? false ? 1.0 : 0.5,
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
                          final item = SaleEntryItemEntity();
                          item.quantity = int.parse(_quantityController.text);
                          item.unitPrice = double.parse(_priceController.text);
                          item.discount = double.parse(
                            _discountController.text.isEmpty
                                ? '0.0'
                                : _discountController.text,
                          );
                          item.isDiscountPercentage = _isDiscountPercentage;
                          item.isHeld = false;
                          item.isDeleted = false;
                          item.product.target = widget.batch.product.target;
                          item.batch.target = widget.batch;
                          Navigator.pop(context, item);
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
                        elevation: 2,
                      ),
                      child: const Text(
                        'Add Item',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
