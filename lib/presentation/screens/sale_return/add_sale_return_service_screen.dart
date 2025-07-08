import 'package:billing_app_flutter/db/models/sale_entry_entity.dart';
import 'package:billing_app_flutter/db/models/sale_return_service_entity.dart';
import 'package:billing_app_flutter/db/models/service_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddSaleReturnServiceScreen extends StatefulWidget {
  final SaleEntryEntity originalInvoice;

  const AddSaleReturnServiceScreen({Key? key, required this.originalInvoice}) : super(key: key);

  @override
  _AddSaleReturnServiceScreenState createState() => _AddSaleReturnServiceScreenState();
}

class _AddSaleReturnServiceScreenState extends State<AddSaleReturnServiceScreen> {
  ServiceEntity? selectedService;
  int quantity = 1;
  double price = 0.0;
  double discount = 0.0;
  bool isDiscountPercentage = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Service Return"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<ServiceEntity>(
              value: selectedService,
              decoration: InputDecoration(labelText: "Service"),
              items: widget.originalInvoice.services
                  .map((service) => DropdownMenuItem(
                value: service.service.target,
                child: Text(service.service.target?.name ?? "Unknown"),
              ))
                  .toList(),
              onChanged: (service) {
                setState(() {
                  selectedService = service;
                  if (service != null) {
                    price = widget.originalInvoice.services
                        .firstWhere((s) => s.service.target?.id == service.id)
                        .price ?? 0.0;
                  }
                });
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
              readOnly: true,
              initialValue: price.toStringAsFixed(2),
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
          onPressed: _saveService,
          child: Text("Add"),
        ),
      ],
    );
  }

  void _saveService() {
    if (selectedService == null) {
      Get.snackbar("Error", "Please select a service");
      return;
    }

    final returnService = SaleReturnServiceEntity();
    returnService.service.target = selectedService;
    returnService.quantity = quantity;
    returnService.price = price;
    returnService.discount = discount;
    returnService.isDiscountPercentage = isDiscountPercentage;

    // Copy GST info from original service
    final originalService = widget.originalInvoice.services.firstWhere(
            (s) => s.service.target?.id == selectedService?.id,
        orElse: () => widget.originalInvoice.services.first
    );

    returnService.gstType = originalService.gstType;
    returnService.gstRate = originalService.gstRate;

    Get.back(result: returnService);
  }
}