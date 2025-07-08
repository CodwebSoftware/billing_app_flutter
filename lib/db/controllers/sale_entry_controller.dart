import 'dart:convert';

import 'package:billing_app_flutter/core/constants/constants.dart';
import 'package:billing_app_flutter/db/models/coupon_entity.dart';
import 'package:billing_app_flutter/db/models/customer_entity.dart';
import 'package:billing_app_flutter/db/models/held_cart_entity.dart';
import 'package:billing_app_flutter/db/models/sale_entry_entity.dart';
import 'package:billing_app_flutter/db/models/sale_entry_items_entity.dart';
import 'package:billing_app_flutter/db/models/sale_entry_services_entity.dart';
import 'package:billing_app_flutter/db/models/payment_entity.dart';
import 'package:billing_app_flutter/db/models/product_entity.dart';
import 'package:billing_app_flutter/objectbox.g.dart';
import 'package:billing_app_flutter/objectboxes.dart';
import 'package:billing_app_flutter/utils/whats_app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SaleEntryController extends GetxController {
  final ObjectBoxes objectBox;
  final isLoading = false.obs;
  var totalRemainingAmount = 0.0.obs;
  var invoices = <SaleEntryEntity>[].obs;
  var invoiceItemList = <SaleEntryItemEntity>[].obs;
  var invoiceServiceList = <SaleEntryServicesEntity>[].obs;
  var invoiceDiscount = 0.0.obs;
  var isInvoiceDiscountPercentage = false.obs;

  SaleEntryController({required this.objectBox});

  void applyItemDiscount(
      SaleEntryItemEntity item,
      double discount,
      bool isPercentage,
      ) {
    item.discount = discount;
    item.isDiscountPercentage = isPercentage;
    invoiceItemList.refresh();
  }

  void applyServiceDiscount(
      SaleEntryServicesEntity service,
      double discount,
      bool isPercentage,
      ) {
    service.discount = discount;
    service.isDiscountPercentage = isPercentage;
    invoiceServiceList.refresh();
  }

  void applyInvoiceDiscount(double discount, bool isPercentage) {
    invoiceDiscount.value = discount;
    isInvoiceDiscountPercentage.value = isPercentage;
  }

  double getTotalAmount() {
    double grandTotalBeforeDiscount = 0;

    for (var item in invoiceItemList.where((item) => !item.isHeld!)) {
      double itemSubtotal = item.unitPrice! * item.quantity!;
      double itemDiscountAmt = item.isDiscountPercentage!
          ? (itemSubtotal * (item.discount! / 100))
          : (item.discount! * item.quantity!);
      double itemTaxableAmount = itemSubtotal - itemDiscountAmt;
      double itemTax = 0;
      if (item.gstType == 'Intra-state') {
        double cgstRate = item.gstRate! / 2;
        double sgstRate = item.gstRate! / 2;
        itemTax = itemTaxableAmount * (cgstRate / 100) +
            itemTaxableAmount * (sgstRate / 100);
      } else {
        itemTax = itemTaxableAmount * (item.gstRate! / 100);
      }
      double itemTotal = itemTaxableAmount + itemTax;
      grandTotalBeforeDiscount += itemTotal;
    }

    for (var service in invoiceServiceList.where((service) => !service.isHeld!)) {
      double serviceSubtotal = service.price! * service.quantity!;
      double serviceDiscountAmt = service.isDiscountPercentage!
          ? (serviceSubtotal * (service.discount! / 100))
          : (service.discount! * service.quantity!);
      double serviceTaxableAmount = serviceSubtotal - serviceDiscountAmt;
      double serviceTax = 0;
      if (service.gstType == 'Intra-state') {
        double cgstRate = service.gstRate! / 2;
        double sgstRate = service.gstRate! / 2;
        serviceTax = serviceTaxableAmount * (cgstRate / 100) +
            serviceTaxableAmount * (sgstRate / 100);
      } else {
        serviceTax = serviceTaxableAmount * (service.gstRate! / 100);
      }
      double serviceTotal = serviceTaxableAmount + serviceTax;
      grandTotalBeforeDiscount += serviceTotal;
    }

    double invoiceDiscountAmt = isInvoiceDiscountPercentage.value
        ? grandTotalBeforeDiscount * (invoiceDiscount.value / 100)
        : invoiceDiscount.value;
    double grandTotalAfterInvoiceDiscount =
        grandTotalBeforeDiscount - invoiceDiscountAmt;

    double finalTotal = grandTotalAfterInvoiceDiscount;

    return finalTotal;
  }

  void holdCurrentCart(int customerId) {
    if (invoiceItemList.isNotEmpty || invoiceServiceList.isNotEmpty) {
      String holdId = DateTime.now().millisecondsSinceEpoch.toString();
      String itemsJson =
      jsonEncode(invoiceItemList.map((item) => item.toJson()).toList());
      String servicesJson = jsonEncode(
          invoiceServiceList.map((service) => service.toJson()).toList());
      var heldCart = HeldCartEntity();
      heldCart.holdId = holdId;
      heldCart.itemsJson = itemsJson;
      heldCart.customerId = customerId;
      heldCart.servicesJson = servicesJson;
      heldCart.invoiceDiscount = invoiceDiscount.value;
      heldCart.isInvoiceDiscountPercentage = isInvoiceDiscountPercentage.value;
      objectBox.heldCartBox.put(heldCart);
      invoiceItemList.clear();
      invoiceServiceList.clear();
      invoiceDiscount.value = 0.0;
      isInvoiceDiscountPercentage.value = false;
      Get.snackbar(
        "Cart Held",
        "Cart held with ID: $holdId. Note this ID to resume later.",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } else {
      Get.snackbar(
        "Error",
        "No items or services to hold.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void resumeHeldCart(String holdId) {
    final query = objectBox.heldCartBox
        .query(HeldCartEntity_.holdId.equals(holdId))
        .build();
    final heldCart = query.findFirst();
    query.close();
    if (heldCart != null) {
      List<dynamic> itemsData = jsonDecode(heldCart.itemsJson!);
      List<SaleEntryItemEntity> items =
      itemsData.map((data) => SaleEntryItemEntity.fromJson(data, objectBox)).toList();
      List<dynamic> servicesData = jsonDecode(heldCart.servicesJson!);
      List<SaleEntryServicesEntity> services = servicesData
          .map((data) => SaleEntryServicesEntity.fromJson(data, objectBox))
          .toList();
      invoiceItemList.value = items;
      invoiceServiceList.value = services;
      invoiceDiscount.value = heldCart.invoiceDiscount!;
      isInvoiceDiscountPercentage.value = heldCart.isInvoiceDiscountPercentage!;
      objectBox.heldCartBox.remove(heldCart.id);
      Get.snackbar(
        "Cart Resumed",
        "Resumed cart with ID: $holdId",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        "Error",
        "No held cart found with ID: $holdId",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<int> addInvoice({
    required CustomerEntity customer,
    required SaleEntryEntity invoice,
  }) async {
    final itemsToSave = invoiceItemList.where((item) => !item.isHeld!).toList();
    final servicesToSave =
    invoiceServiceList.where((service) => !service.isHeld!).toList();

    if (itemsToSave.isEmpty && servicesToSave.isEmpty) {
      Get.snackbar("Error", "No active items or services to save.");
      return 0;
    }

    invoice.invoiceNumber =
    'INV-${customer.id}-${count() + 1}-${DateTime.now().millisecondsSinceEpoch}';
    invoice.customer.target = customer;
    invoice.invoiceDiscount = invoiceDiscount.value;
    invoice.isInvoiceDiscountPercentage = isInvoiceDiscountPercentage.value;
    invoice.totalBillAmount = getTotalAmount();
    invoice.date = df.parse(DateTime.now().toString());
    invoice.amountPaid = 0;
    invoice.status = 'Pending';

    final invoiceId = objectBox.saleEntryBox.put(invoice);

    if (invoiceId != 0) {
      for (var item in itemsToSave) {
        item.invoice.target = invoice;
        objectBox.saleEntryItemBox.put(item);
        invoice.items.add(item);

        final product = objectBox.productBox.get(item.product.target!.id);
        if (product != null) {
          product.quantity = product.quantity! - item.quantity!;
          objectBox.productBox.put(product);
        } else {
          Get.snackbar(
            "Warning",
            "Product with ID ${item.product.target!.id} not found",
          );
        }
        final batch = objectBox.batchBox.get(item.batch.target!.id);
        if (batch != null) {
          batch.quantity = batch.quantity! - item.quantity!;
          objectBox.batchBox.put(batch);
        } else {
          Get.snackbar(
            "Warning",
            "Batch with ID ${item.batch.target!.id} not found",
          );
        }
      }

      for (var service in servicesToSave) {
        service.invoice.target = invoice;
        objectBox.saleEntryServiceBox.put(service);
        invoice.services.add(service);
      }

      objectBox.saleEntryBox.put(invoice, mode: PutMode.update);
      loadInvoicesByCustomer(customerId: customer.id);
    }
    return invoiceId;
  }

  void holdInvoiceItem(SaleEntryItemEntity item) {
    item.isHeld = true;
    invoiceItemList.refresh();
  }

  void unholdInvoiceItem(SaleEntryItemEntity item) {
    item.isHeld = false;
    invoiceItemList.refresh();
  }

  void holdInvoiceService(SaleEntryServicesEntity service) {
    service.isHeld = true;
    invoiceServiceList.refresh();
  }

  void unholdInvoiceService(SaleEntryServicesEntity service) {
    service.isHeld = false;
    invoiceServiceList.refresh();
  }

  void removeInvoiceItem(SaleEntryItemEntity item) {
    invoiceItemList.removeWhere((itm) => itm.id == item.id);
    update();
  }

  void removeInvoiceService(SaleEntryServicesEntity service) {
    invoiceServiceList.removeWhere((srv) => srv.id == service.id);
    update();
  }

  void clearInvoiceItemsAndServices() {
    invoiceItemList.clear();
    invoiceServiceList.clear();
    update();
  }

  loadInvoices() {
    totalRemainingAmount.value = 0;
    invoices.value = objectBox.saleEntryBox.getAll();
  }

  loadInvoicesByCustomer({required int customerId}) {
    totalRemainingAmount.value = 0;
    final query = objectBox.saleEntryBox
        .query(SaleEntryEntity_.customer.equals(customerId))
        .build();

    final invs = query.find().reversed.toList();
    query.close();

    invoices.value = invs;

    for (var inv in invs) {
      totalingRemainingAmount(inv);
    }
  }

  void totalingRemainingAmount(SaleEntryEntity inv) {
    if (inv.payments.isEmpty) {
      totalRemainingAmount.value =
          totalRemainingAmount.value + inv.totalBillAmount!;
    } else {
      totalRemainingAmount.value =
          totalRemainingAmount.value + inv.payments.last.remainingAmount!;
    }
  }

  loadInvoicesByCustomerAndInvoiceNumber({
    required int invoiceId,
    required int customerId,
  }) {
    final query = objectBox.saleEntryBox
        .query(
      SaleEntryEntity_.customer
          .equals(customerId)
          .and(SaleEntryEntity_.id.equals(invoiceId)),
    )
        .build();

    invoices.value = query.find();
    query.close();
  }

  void addInvoiceItem(SaleEntryItemEntity item) {
    final index = invoiceItemList.indexWhere(
          (itm) =>
      (itm.product.target!.id == item.product.target!.id &&
          itm.batch.target!.id == item.batch.target!.id),
    );
    if (index != -1) {
      invoiceItemList[index] = item;
    } else {
      invoiceItemList.add(item);
    }
    update();
  }

  void addInvoiceService(SaleEntryServicesEntity service) {
    final index = invoiceServiceList.indexWhere(
          (srv) => srv.service.target!.id == service.service.target!.id,
    );
    if (index != -1) {
      invoiceServiceList[index] = service;
    } else {
      invoiceServiceList.add(service);
    }
    update();
  }

  bool checkInvoice({required int invoiceId}) {
    return objectBox.saleEntryBox.contains(invoiceId);
  }

  int count() {
    return objectBox.saleEntryBox.count();
  }

  void getInvoice(SaleEntryEntity invoice) {
    invoiceItemList.value = invoice.items;
    invoiceServiceList.value = invoice.services;
    invoiceDiscount.value = invoice.invoiceDiscount ?? 0.0;
    isInvoiceDiscountPercentage.value = invoice.isInvoiceDiscountPercentage ?? false;
    update();
  }

  addPayment({
    required double payAmount,
    required CustomerEntity customer,
    required SaleEntryEntity invoice,
  }) {
    var payment = PaymentEntity();

    double previouslyPaidAmount = 0;
    for (var existingPayment in invoice.payments) {
      previouslyPaidAmount += existingPayment.paidAmount ?? 0;
    }

    double totalPaidAmount = previouslyPaidAmount + payAmount;

    if (totalPaidAmount < invoice.totalBillAmount!) {
      payment.remainingAmount = invoice.totalBillAmount! - totalPaidAmount;
      invoice.status = "Partially Paid";
    } else if (totalPaidAmount == invoice.totalBillAmount!) {
      payment.remainingAmount = 0;
      invoice.status = "Paid";
    } else {
      payment.remainingAmount = 0;
      invoice.status = "Paid";
      print(
        "Warning: Overpayment detected. Total paid: $totalPaidAmount, Invoice total: ${invoice.totalBillAmount}",
      );
    }

    payment.paidAmount = payAmount;
    payment.date = DateTime.now();
    objectBox.paymentBox.put(payment);
    invoice.payments.add(payment);
    invoice.amountPaid = totalPaidAmount;
    objectBox.saleEntryBox.put(invoice);

    sendWhatsAppMessage(
      customer.phone!,
      "🌟 Hello ${customer.name}! "
          "Thank you for paying your bill! 🎉 Your payment of ₹$payAmount for "
          "Bill No. ${invoice.id} has been successfully received. We truly appreciate your promptness! "
          "If you have any questions, feel free to reach out. 😊",
    );
    loadInvoicesByCustomer(customerId: customer.id!);
  }

  Future<bool> deletePayment(int paymentId) async {
    PaymentEntity? payment = objectBox.paymentBox.get(paymentId);
    if (payment != null) {
      payment.isDeleted = true;
      var val = objectBox.paymentBox.put(payment, mode: PutMode.update);
      if (val != 0) {
        SaleEntryEntity? invoice = payment.invoice.target;
        invoice!.amountPaid = invoice.amountPaid! - payment.paidAmount!;
        invoice.totalBillAmount = invoice.totalBillAmount!;
        invoice.status = invoice.amountPaid! < invoice.totalBillAmount!
            ? "Partially Paid"
            : "Pending";
        objectBox.saleEntryBox.put(invoice);
      }
      return (val != 0);
    }
    return false;
  }
}