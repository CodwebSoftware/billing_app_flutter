import 'dart:async';
import 'package:billing_app_flutter/db/models/sale_entry_entity.dart';
import 'package:billing_app_flutter/db/models/sale_return_entity.dart';
import 'package:billing_app_flutter/db/models/sale_return_item_entity.dart';
import 'package:billing_app_flutter/db/models/sale_return_service_entity.dart';
import 'package:billing_app_flutter/objectbox.g.dart';
import 'package:billing_app_flutter/objectboxes.dart';
import 'package:get/get.dart';

class SaleReturnController extends GetxController {
  final ObjectBoxes objectBox;
  final isLoading = false.obs;
  final returns = <SaleReturnEntity>[].obs;
  var returnItemList = <SaleReturnItemEntity>[].obs;
  var returnServiceList = <SaleReturnServiceEntity>[].obs;

  SaleReturnController({required this.objectBox});

  Future<int> createReturn({
    required SaleEntryEntity originalInvoice,
    required String reason,
  }) async {
    isLoading(true);
    try {
      final saleReturn = SaleReturnEntity();
      saleReturn.returnNumber = 'RET-${DateTime.now().millisecondsSinceEpoch}';
      saleReturn.date = DateTime.now();
      saleReturn.originalInvoice.target = originalInvoice;
      saleReturn.customer.target = originalInvoice.customer.target;
      saleReturn.reason = reason;
      saleReturn.status = "Completed";

      double totalReturnAmount = 0.0;

      // Process returned items
      for (final item in returnItemList) {
        objectBox.saleReturnItemBox.put(item);
        saleReturn.items.add(item);

        // Calculate return amount
        totalReturnAmount += item.getSubtotal();

        // Update inventory
        final product = item.product.target;
        if (product != null) {
          product.quantity = (product.quantity ?? 0) + item.quantity!;
          objectBox.productBox.put(product);
        }

        final batch = item.batch.target;
        if (batch != null) {
          batch.quantity = (batch.quantity ?? 0) + item.quantity!;
          objectBox.batchBox.put(batch);
        }
      }

      // Process returned services
      for (final service in returnServiceList) {
        objectBox.saleReturnServiceBox.put(service);
        saleReturn.services.add(service);

        // Calculate return amount
        totalReturnAmount += service.getSubtotal();
      }

      saleReturn.totalReturnAmount = totalReturnAmount;
      final returnId = objectBox.saleReturnBox.put(saleReturn);

      // Clear current return
      returnItemList.clear();
      returnServiceList.clear();

      returns.add(saleReturn);
      return returnId;
    } catch (e) {
      Get.snackbar("Return Error", "Failed to process return: ${e.toString()}");
      return 0;
    } finally {
      isLoading(false);
    }
  }

  void loadReturnsForInvoice(int invoiceId) {
    final query = objectBox.saleReturnBox.query(
        SaleReturnEntity_.originalInvoice.equals(invoiceId)
    ).build();
    returns.value = query.find();
    query.close();
  }

  void addReturnItem(SaleReturnItemEntity item) {
    returnItemList.add(item);
    update();
  }

  void addReturnService(SaleReturnServiceEntity service) {
    returnServiceList.add(service);
    update();
  }

  void removeReturnItem(SaleReturnItemEntity item) {
    returnItemList.remove(item);
    update();
  }

  void removeReturnService(SaleReturnServiceEntity service) {
    returnServiceList.remove(service);
    update();
  }

  double getTotalReturnAmount() {
    double total = 0.0;

    for (var item in returnItemList) {
      total += item.getSubtotal();
    }

    for (var service in returnServiceList) {
      total += service.getSubtotal();
    }

    return total;
  }
}