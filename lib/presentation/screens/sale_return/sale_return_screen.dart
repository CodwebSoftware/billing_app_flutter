import 'package:billing_app_flutter/db/controllers/sale_return_controller.dart';
import 'package:billing_app_flutter/db/models/sale_entry_entity.dart';
import 'package:billing_app_flutter/db/models/sale_return_item_entity.dart';
import 'package:billing_app_flutter/db/models/sale_return_service_entity.dart';
import 'package:billing_app_flutter/db/models/product_entity.dart';
import 'package:billing_app_flutter/db/models/batch_entity.dart';
import 'package:billing_app_flutter/db/models/service_entity.dart';
import 'package:billing_app_flutter/presentation/screens/sale_return/add_sale_return_item_screen.dart';
import 'package:billing_app_flutter/presentation/screens/sale_return/add_sale_return_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SaleReturnScreen extends StatefulWidget {
  final SaleEntryEntity originalInvoice;

  const SaleReturnScreen({Key? key, required this.originalInvoice}) : super(key: key);

  @override
  _SaleReturnScreenState createState() => _SaleReturnScreenState();
}

class _SaleReturnScreenState extends State<SaleReturnScreen> {
  final returnController = Get.put(SaleReturnController(objectBox: Get.find()));
  final reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    returnController.loadReturnsForInvoice(widget.originalInvoice.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sale Return')),
      body: Column(
        children: [
          _buildHeader(),
          _buildOriginalInvoiceInfo(),
          Expanded(
            child: _buildItemsTable(),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "RETURN NOTE",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text("Original Invoice: #${widget.originalInvoice.id}"),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Date: ${DateTime.now().toString().split(' ')[0]}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOriginalInvoiceInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Customer: ${widget.originalInvoice.customer.target?.name ?? 'Unknown'}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (widget.originalInvoice.customer.target?.phone != null)
                Text("Phone: ${widget.originalInvoice.customer.target?.phone}"),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Original Amount: ₹${widget.originalInvoice.totalBillAmount?.toStringAsFixed(2) ?? '0.00'}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text("Description", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text("Qty", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text("Price", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text("Total", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: SizedBox()),
              ],
            ),
          ),
          ...returnController.returnItemList.map((item) => _buildItemRow(item)),
          ...returnController.returnServiceList.map((service) => _buildServiceRow(service)),
        ],
      ),
    );
  }

  Widget _buildItemRow(SaleReturnItemEntity item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(item.product.target?.name ?? 'Unknown Product'),
          ),
          Expanded(
            flex: 2,
            child: Text(item.quantity.toString()),
          ),
          Expanded(
            flex: 2,
            child: Text('₹${item.unitPrice?.toStringAsFixed(2) ?? '0.00'}'),
          ),
          Expanded(
            flex: 2,
            child: Text('₹${item.getSubtotal().toStringAsFixed(2)}'),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => returnController.removeReturnItem(item),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRow(SaleReturnServiceEntity service) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(service.service.target?.name ?? 'Unknown Service'),
          ),
          Expanded(
            flex: 2,
            child: Text(service.quantity.toString()),
          ),
          Expanded(
            flex: 2,
            child: Text('₹${service.price?.toStringAsFixed(2) ?? '0.00'}'),
          ),
          Expanded(
            flex: 2,
            child: Text('₹${service.getSubtotal().toStringAsFixed(2)}'),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => returnController.removeReturnService(service),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: _addReturnItem,
                icon: Icon(Icons.add_shopping_cart),
                label: Text("Add Product Return"),
              ),
              ElevatedButton.icon(
                onPressed: _addReturnService,
                icon: Icon(Icons.miscellaneous_services),
                label: Text("Add Service Return"),
              ),
            ],
          ),
          SizedBox(height: 16),
          TextField(
            controller: reasonController,
            decoration: InputDecoration(
              labelText: 'Return Reason',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            maxLines: 2,
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Return Amount:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Obx(() => Text(
                "₹${returnController.getTotalReturnAmount().toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
              )),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _processReturn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              "Process Return",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  void _addReturnItem() async {
    final result = await Get.dialog(
      AddSaleReturnItemScreen(originalInvoice: widget.originalInvoice),
      barrierDismissible: false,
    );

    if (result != null && result is SaleReturnItemEntity) {
      returnController.addReturnItem(result);
    }
  }

  void _addReturnService() async {
    final result = await Get.dialog(
      AddSaleReturnServiceScreen(originalInvoice: widget.originalInvoice),
      barrierDismissible: false,
    );

    if (result != null && result is SaleReturnServiceEntity) {
      returnController.addReturnService(result);
    }
  }

  void _processReturn() {
    if (returnController.returnItemList.isEmpty && returnController.returnServiceList.isEmpty) {
      Get.snackbar("Error", "No items or services to return");
      return;
    }

    if (reasonController.text.isEmpty) {
      Get.snackbar("Error", "Please enter return reason");
      return;
    }

    returnController.createReturn(
      originalInvoice: widget.originalInvoice,
      reason: reasonController.text,
    ).then((returnId) {
      if (returnId > 0) {
        Get.back();
        Get.snackbar(
          "Success",
          "Return processed successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    });
  }
}