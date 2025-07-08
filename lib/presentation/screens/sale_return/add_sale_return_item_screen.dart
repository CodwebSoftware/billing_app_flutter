import 'package:billing_app_flutter/db/models/sale_entry_entity.dart';
import 'package:billing_app_flutter/db/models/sale_return_item_entity.dart';
import 'package:billing_app_flutter/db/models/product_entity.dart';
import 'package:billing_app_flutter/db/models/batch_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddSaleReturnItemScreen extends StatefulWidget {
  final SaleEntryEntity originalInvoice;

  const AddSaleReturnItemScreen({Key? key, required this.originalInvoice}) : super(key: key);

  @override
  _AddSaleReturnItemScreenState createState() => _AddSaleReturnItemScreenState();
}

class _AddSaleReturnItemScreenState extends State<AddSaleReturnItemScreen> {
  ProductEntity? selectedProduct;
  BatchEntity? selectedBatch;
  int quantity = 1;
  double unitPrice = 0.0;
  double discount = 0.0;
  bool isDiscountPercentage = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Product Return"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<ProductEntity>(
              value: selectedProduct,
              decoration: InputDecoration(labelText: "Product"),
              items: widget.originalInvoice.items
                  .map((item) => DropdownMenuItem(
                value: item.product.target,
                child: Text(item.product.target?.name ?? "Unknown"),
              ))
                  .toList(),
              onChanged: (product) {
                setState(() {
                  selectedProduct = product;
                  selectedBatch = null;
                  if (product != null) {
                    unitPrice = widget.originalInvoice.items
                        .firstWhere((item) => item.product.target?.id == product.id)
                        .unitPrice ?? 0.0;
                  }
                });
              },
            ),
            if (selectedProduct != null)
              DropdownButtonFormField<BatchEntity>(
                value: selectedBatch,
                decoration: InputDecoration(labelText: "Batch"),
                items: selectedProduct!.batches
                    .map((batch) => DropdownMenuItem(
                  value: batch,
                  child: Text(batch.batchNumber ?? "Unknown"),
                ))
                    .toList(),
                onChanged: (batch) {
                  setState(() {
                    selectedBatch = batch;
                  });
                },
              ),
            TextFormField(
              decoration: InputDecoration(labelText: "Unit Price"),
              keyboardType: TextInputType.number,
              readOnly: true,
              initialValue: unitPrice.toStringAsFixed(2),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "Discount"),
                    keyboardType: TextInputType.number,
                    initialValue: discount.toString(),
                    onChanged: (value) {
                      discount = double.tryParse(value) ?? 0.0;
                    },
                  ),
                ),
                CheckboxListTile(
                  title: Text("%"),
                  value: isDiscountPercentage,
                  onChanged: (value) {
                    setState(() {
                      isDiscountPercentage = value ?? false;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Text("Quantity: "),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    if (quantity > 1) {
                      setState(() => quantity--);
                    }
                  },
                ),
                Text(quantity.toString()),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => setState(() => quantity++),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _saveItem,
          child: Text("Add"),
        ),
      ],
    );
  }

  void _saveItem() {
    if (selectedProduct == null) {
      Get.snackbar("Error", "Please select a product");
      return;
    }

    final returnItem = SaleReturnItemEntity();
    returnItem.product.target = selectedProduct;
    returnItem.batch.target = selectedBatch;
    returnItem.quantity = quantity;
    returnItem.unitPrice = unitPrice;
    returnItem.discount = discount;
    returnItem.isDiscountPercentage = isDiscountPercentage;

    // Copy GST info from original item
    final originalItem = widget.originalInvoice.items.firstWhere(
            (item) => item.product.target?.id == selectedProduct?.id,
        orElse: () => widget.originalInvoice.items.first
    );

    returnItem.gstType = originalItem.gstType;
    returnItem.gstRate = originalItem.gstRate;

    Get.back(result: returnItem);
  }
}