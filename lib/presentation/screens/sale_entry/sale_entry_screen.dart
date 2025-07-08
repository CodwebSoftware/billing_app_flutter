import 'dart:convert';

import 'package:billing_app_flutter/db/controllers/company_profile_controller.dart';
import 'package:billing_app_flutter/db/controllers/customer_controller.dart';
import 'package:billing_app_flutter/db/controllers/sale_entry_controller.dart';
import 'package:billing_app_flutter/db/controllers/product_controller.dart';
import 'package:billing_app_flutter/db/controllers/service_controller.dart';
import 'package:billing_app_flutter/db/models/batch_entity.dart';
import 'package:billing_app_flutter/db/models/company_profile_entity.dart';
import 'package:billing_app_flutter/db/models/customer_entity.dart';
import 'package:billing_app_flutter/db/models/employee_entity.dart';
import 'package:billing_app_flutter/db/models/sale_entry_entity.dart';
import 'package:billing_app_flutter/db/models/sale_entry_items_entity.dart';
import 'package:billing_app_flutter/db/models/sale_entry_services_entity.dart';
import 'package:billing_app_flutter/db/models/service_entity.dart';
import 'package:billing_app_flutter/presentation/pdf/generate_invoice_pdf.dart';
import 'package:billing_app_flutter/presentation/screens/sale_entry/add_sale_entry_item_screen.dart';
import 'package:billing_app_flutter/presentation/screens/sale_entry/add_sale_entry_service_screen.dart';
import 'package:billing_app_flutter/presentation/screens/sale_entry/add_payment_method_screen.dart';
import 'package:billing_app_flutter/presentation/screens/sale_entry/find_batch_screen.dart';
import 'package:billing_app_flutter/presentation/screens/sale_entry/find_customer_screen.dart';
import 'package:billing_app_flutter/presentation/screens/sale_entry/find_product_screen.dart';
import 'package:billing_app_flutter/presentation/screens/sale_entry/find_service_screen.dart';
import 'package:billing_app_flutter/presentation/screens/sale_return/sale_return_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class SaleEntryScreen extends StatefulWidget {
  final SaleEntryEntity invoiceEntity;

  const SaleEntryScreen({Key? key, required this.invoiceEntity})
    : super(key: key);

  @override
  State<SaleEntryScreen> createState() => _SaleEntryScreenState();
}

class _SaleEntryScreenState extends State<SaleEntryScreen> {
  late SaleEntryEntity invoice;
  late CustomerEntity customer;
  final invoiceController = Get.find<SaleEntryController>();
  final serviceController = Get.find<ServiceController>();
  final productController = Get.find<ProductController>();
  final companyProfileController = Get.find<CompanyProfileController>();

  CompanyProfileEntity companyProfileEntity = CompanyProfileEntity();
  EmployeeEntity? currentEmployee;
  late bool isSavedInvoice;
  bool _isPrinting = false;
  bool _isSaving = false;
  var totalItems = 0.obs, totalServices = 0.obs;

  @override
  void initState() {
    super.initState();
    invoice = widget.invoiceEntity;
    customer =
        (invoice.customer.target != null)
            ? invoice.customer.target!
            : CustomerEntity();
    isSavedInvoice =
        invoice.id != 0
            ? invoiceController.checkInvoice(invoiceId: invoice.id)
            : false;
    if (isSavedInvoice) {
      invoiceController.getInvoice(invoice);
    }
  }

  @override
  void dispose() {
    invoiceController.invoiceServiceList.value = [];
    invoiceController.invoiceItemList.value = [];
    super.dispose();
  }

  Future<void> getCompanyProfile() async {
    final companyProfiles = await companyProfileController.getCompanyProfiles();
    if (mounted) {
      setState(() {
        companyProfileEntity = companyProfiles.first;
      });
    }
  }

  Future<void> _applyDiscountDialog() async {
    final discountController = TextEditingController();
    bool isPercentage = false;

    await Get.dialog(
      AlertDialog(
        title: const Text('Apply Invoice Discount'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: discountController,
              decoration: const InputDecoration(labelText: 'Discount (₹ or %)'),
              keyboardType: TextInputType.number,
            ),
            CheckboxListTile(
              title: const Text('Percentage'),
              value: isPercentage,
              onChanged: (value) {
                isPercentage = value ?? false;
                (context as Element).markNeedsBuild();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final discount = double.tryParse(discountController.text) ?? 0.0;
              if (discount > 0) {
                invoiceController.applyInvoiceDiscount(discount, isPercentage);
                setState(() {});
                Navigator.pop(context);
              } else {
                Get.snackbar('Error', 'Invalid discount amount');
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _addNewItem() async {
    final productResult = await Get.dialog(
      const FindProductScreen(),
      barrierDismissible: false,
    );

    if (productResult != null) {
      final batchResult = await Get.dialog(
        FindBatchScreen(product: productResult),
        barrierDismissible: false,
      );

      if (batchResult != null) {
        final result = await Get.dialog(
          AddInvoiceItemScreen(batch: batchResult),
          barrierDismissible: false,
        );

        if (result != null) {
          invoiceController.addInvoiceItem(result);
          setState(() {});
        } else {
          await _addNewItem();
        }
      } else {
        await _addNewItem();
      }
    }
  }

  Future<void> _editInvoiceItem(BatchEntity batchEntity) async {
    final result = await Get.dialog(
      AddInvoiceItemScreen(batch: batchEntity),
      barrierDismissible: false,
    );

    if (result != null) {
      invoiceController.addInvoiceItem(result);
      setState(() {});
    }
  }

  Future<void> _removeInvoiceItem(SaleEntryItemEntity invoiceItemEntity) async {
    invoiceController.removeInvoiceItem(invoiceItemEntity);
    setState(() {});
  }

  Future<void> _removeAll() async {
    invoiceController.clearInvoiceItemsAndServices();
    customer = CustomerEntity();
    setState(() {});
  }

  Future<void> _addNewService() async {
    final serviceResult = await Get.dialog(
      const FindServiceScreen(),
      barrierDismissible: false,
    );

    if (serviceResult != null) {
      final result = await Get.dialog(
        AddInvoiceServiceScreen(service: serviceResult),
        barrierDismissible: false,
      );

      if (result != null) {
        invoiceController.addInvoiceService(result);
        setState(() {});
      } else {
        await _addNewService();
      }
    }
  }

  Future<void> _editInvoiceService(ServiceEntity serviceEntity) async {
    final result = await Get.dialog(
      AddInvoiceServiceScreen(service: serviceEntity),
      barrierDismissible: false,
    );

    if (result != null) {
      invoiceController.addInvoiceService(result);
      setState(() {});
    }
  }

  Future<void> _removeInvoiceService(
    SaleEntryServicesEntity serviceEntity,
  ) async {
    invoiceController.removeInvoiceService(serviceEntity);
    setState(() {});
  }

  Future<void> _toggleHeldInvoiceService(
    SaleEntryServicesEntity serviceEntity,
  ) async {
    if (serviceEntity.isHeld!) {
      invoiceController.unholdInvoiceService(serviceEntity);
    } else {
      invoiceController.holdInvoiceService(serviceEntity);
    }
    setState(() {});
  }

  Future<void> _toggleHeldInvoiceItem(SaleEntryItemEntity itemEntity) async {
    if (itemEntity.isHeld!) {
      invoiceController.unholdInvoiceItem(itemEntity);
    } else {
      invoiceController.holdInvoiceItem(itemEntity);
    }
    setState(() {});
  }

  Future<void> _scanBarcode() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancel',
      true,
      ScanMode.BARCODE,
    );

    if (barcodeScanRes != '-1') {
      final (batch, product) = productController.findProductAndBatchByBarcode(
        barcodeScanRes,
      );
      if (product != null) {
        var batchResult = batch;
        if (batch != null) {
          batchResult = await Get.dialog(
            FindBatchScreen(product: product),
            barrierDismissible: false,
          );
        }

        if (batchResult != null) {
          final result = await Get.dialog(
            AddInvoiceItemScreen(batch: batchResult),
            barrierDismissible: false,
          );

          if (result != null) {
            invoiceController.addInvoiceItem(result);
            setState(() {});
          }
        }
      } else {
        Get.snackbar(
          'Error',
          'No product found with barcode: $barcodeScanRes',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _generateAndOpenPdf() async {
    setState(() => _isPrinting = true);
    try {
      final pdfFile = await generateInvoicePdf(
        invoice: invoice,
        customer: customer,
      );
      await OpenFile.open(pdfFile.path);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate PDF: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  Future<void> _getCustomer() async {
    final result = await Get.dialog(
      FindCustomerScreen(),
      barrierDismissible: false,
    );

    if (result != null) {
      setState(() {
        customer = result;
      });
    }
  }

  Future<void> _saveInvoice() async {
    setState(() => _isSaving = true);
    try {
      await invoiceController.addInvoice(customer: customer, invoice: invoice);
      isSavedInvoice = invoiceController.checkInvoice(invoiceId: invoice.id);
      Get.snackbar(
        'Success',
        'Invoice saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _removeAll();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save invoice: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _showHeldInvoicesDialog() async {
    final heldCarts = invoiceController.objectBox.heldCartBox.getAll();
    if (heldCarts.isEmpty) {
      Get.snackbar(
        'Info',
        'No held invoices found.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await Get.dialog(
      AlertDialog(
        title: const Text(
          'Held Invoices',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: ListView.builder(
            itemCount: heldCarts.length,
            itemBuilder: (context, index) {
              final heldCart = heldCarts[index];
              final items = jsonDecode(heldCart.itemsJson!) as List<dynamic>;
              final services =
                  jsonDecode(heldCart.servicesJson!) as List<dynamic>;
              final totalItems = items.length;
              final totalServices = services.length;
              final totalAmount =
                  items.fold<double>(
                    0,
                    (sum, item) => sum + (item['unitPrice'] * item['quantity']),
                  ) +
                  services.fold<double>(
                    0,
                    (sum, service) =>
                        sum + (service['price'] * service['quantity']),
                  );

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                elevation: 2,
                child: ListTile(
                  title: Text('Hold ID: ${heldCart.holdId}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Items: $totalItems'),
                      Text('Services: $totalServices'),
                      Text('Total: ₹${totalAmount.toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.restore, color: Colors.blue),
                    onPressed: () {
                      invoiceController.resumeHeldCart(heldCart.holdId!);
                      customer =
                          Get.find<CustomerController>().getCustomer(
                            heldCart.customerId!,
                          )!;
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                companyProfileEntity.name ?? 'Company Name',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${companyProfileEntity.addressLine1 ?? ''} ${companyProfileEntity.addressLine2 ?? ''}',
              ),
              Text(
                '${companyProfileEntity.state ?? ''} ${companyProfileEntity.country ?? ''} ${companyProfileEntity.postalCode ?? ''}',
              ),
              if (companyProfileEntity.email?.isNotEmpty ?? false)
                Text('Email: ${companyProfileEntity.email}'),
              if (companyProfileEntity.phone?.isNotEmpty ?? false)
                Text('Phone: ${companyProfileEntity.phone}'),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'INVOICE',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Invoice No: ${invoice.id.toString().padLeft(6, '0')}'),
              Text('Date: ${DateTime.now().toString().split(' ')[0]}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillToSection() {
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
              const Text(
                'Bill To:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                customer.name ?? 'Customer Name',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (customer.email?.isNotEmpty ?? false) Text(customer.email!),
              if (customer.phone?.isNotEmpty ?? false) Text(customer.phone!),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Ship To:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                customer.name ?? 'Customer Name',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (customer.email?.isNotEmpty ?? false) Text(customer.email!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
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
                Expanded(
                  flex: 1,
                  child: const Text(
                    'Sl No',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: const Text(
                    'Unit Price',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: const Text(
                    'Quantity',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: const Text(
                    'Discount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: const Text(
                    'Discount (%)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: const Text(
                    'Tax',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: const Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          ...invoiceController.invoiceItemList.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final invoiceItem = entry.value;
            totalItems.value = totalItems.value + invoiceItem.quantity!;
            return _buildItemRow(
              index: index,
              description:
                  invoiceItem.product.target!.name ?? 'Unknown Product',
              unitPrice: invoiceItem.unitPrice!,
              quantity: invoiceItem.quantity!,
              discount: invoiceItem.discount!,
              isDiscountPer: invoiceItem.isDiscountPercentage!,
              gstType:
                  invoiceItem.gstType ??
                  (customer.state == companyProfileEntity.state
                      ? 'Intra-state'
                      : 'Inter-state'),
              gstRate: invoiceItem.gstRate ?? 0.0,
              isHeld: invoiceItem.isHeld!,
              onEdit: () => _editInvoiceItem(invoiceItem.batch.target!),
              onDelete: () => _removeInvoiceItem(invoiceItem),
              onToggleHeld: () => _toggleHeldInvoiceItem(invoiceItem),
            );
          }),
          ...invoiceController.invoiceServiceList.asMap().entries.map((entry) {
            final index =
                entry.key + 1 + invoiceController.invoiceItemList.length;
            final invoiceService = entry.value;
            totalServices.value =
                totalServices.value + invoiceService.quantity!;
            return _buildItemRow(
              index: index,
              description:
                  invoiceService.service.target!.name ?? 'Unknown Service',
              unitPrice: invoiceService.price!,
              quantity: invoiceService.quantity!,
              discount: invoiceService.discount!,
              isDiscountPer: invoiceService.isDiscountPercentage!,
              gstType:
                  invoiceService.gstType ??
                  (customer.state == companyProfileEntity.state
                      ? 'Intra-state'
                      : 'Inter-state'),
              gstRate: invoiceService.gstRate ?? 0.0,
              isHeld: invoiceService.isHeld!,
              onEdit: () => _editInvoiceService(invoiceService.service.target!),
              onDelete: () => _removeInvoiceService(invoiceService),
              onToggleHeld: () => _toggleHeldInvoiceService(invoiceService),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemRow({
    required int index,
    required String description,
    required double unitPrice,
    required double discount,
    required bool isDiscountPer,
    required String gstType,
    required double gstRate,
    required int quantity,
    required bool isHeld,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onToggleHeld,
  }) {
    double discountAmt, discountPer, taxAmt, total;
    if (isDiscountPer) {
      discountPer = discount;
      discountAmt = (unitPrice * discount / 100) * quantity;
    } else {
      discountAmt = discount * quantity;
      discountPer =
          unitPrice > 0 ? (discountAmt / (unitPrice * quantity)) * 100 : 0;
    }
    double taxableAmount = (unitPrice * quantity) - discountAmt;
    if (gstType == 'Intra-state') {
      double cgstRate = gstRate / 2;
      double sgstRate = gstRate / 2;
      double cgstAmt = taxableAmount * (cgstRate / 100);
      double sgstAmt = taxableAmount * (sgstRate / 100);
      taxAmt = cgstAmt + sgstAmt;
    } else {
      taxAmt = taxableAmount * (gstRate / 100);
    }
    total = taxableAmount + taxAmt;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHeld ? Colors.red[100] : Colors.transparent,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text('$index')),
          Expanded(flex: 4, child: Text(description)),
          Expanded(
            flex: 2,
            child: Text(
              '₹${unitPrice.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('$quantity', textAlign: TextAlign.right),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '₹${discountAmt.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${discountPer.toStringAsFixed(2)}%',
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '₹${taxAmt.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '₹${total.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 15),
                  onPressed: onEdit,
                  constraints: BoxConstraints(
                    maxHeight: 30,
                    maxWidth: 30,
                    minHeight: 28,
                    minWidth: 28,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 15),
                  onPressed: onDelete,
                  constraints: BoxConstraints(
                    maxHeight: 30,
                    maxWidth: 30,
                    minHeight: 28,
                    minWidth: 28,
                  ),
                ),
                IconButton(
                  icon: Icon(isHeld ? Icons.play_arrow : Icons.pause, size: 15),
                  onPressed: onToggleHeld,
                  constraints: BoxConstraints(
                    maxHeight: 30,
                    maxWidth: 30,
                    minHeight: 28,
                    minWidth: 28,
                  ),
                ),
              ],
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                return Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                        children: [
                          TextSpan(text: "Total Items "),
                          TextSpan(
                            text: totalItems.value.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 25),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                        children: [
                          TextSpan(text: "Total Services "),
                          TextSpan(
                            text: totalServices.value.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
              SizedBox(height: 12),
              if (!isSavedInvoice)
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addNewItem,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Add Product'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _scanBarcode,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan Barcode'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _addNewService,
                      icon: const Icon(Icons.miscellaneous_services),
                      label: const Text('Add Service'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _removeAll,
                      icon: const Icon(Icons.remove_shopping_cart_outlined),
                      label: const Text('Remove All'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (customer.id.isNullOrBlank!) {
                          invoiceController.holdCurrentCart(0);
                        } else {
                          invoiceController.holdCurrentCart(customer.id!);
                        }
                        customer = CustomerEntity();
                        setState(() {});
                      },
                      icon: const Icon(Icons.pause_circle),
                      label: const Text('Hold Invoice'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _showHeldInvoicesDialog,
                      icon: const Icon(Icons.history),
                      label: const Text('View Held'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed:
                          () =>
                              Get.to(() => SaleReturnScreen(originalInvoice: invoice)),
                      icon: const Icon(Icons.reply),
                      label: const Text('View Returns'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Obx(() {
                double subtotal = 0;
                double totalItemDiscount = 0;
                double totalTax = 0;
                double totalCGST = 0;
                double totalSGST = 0;
                double totalIGST = 0;
                double grandTotalBeforeDiscount = 0;

                for (var item in invoiceController.invoiceItemList.where(
                  (item) => !item.isHeld!,
                )) {
                  double itemSubtotal = item.unitPrice! * item.quantity!;
                  double itemDiscountAmt =
                      item.isDiscountPercentage!
                          ? (itemSubtotal * (item.discount! / 100))
                          : (item.discount! * item.quantity!);
                  double itemTaxableAmount = itemSubtotal - itemDiscountAmt;
                  double itemTax = 0;
                  if (item.gstType == 'Intra-state') {
                    double cgstRate = item.gstRate! / 2;
                    double sgstRate = item.gstRate! / 2;
                    double cgstAmt = itemTaxableAmount * (cgstRate / 100);
                    double sgstAmt = itemTaxableAmount * (sgstRate / 100);
                    itemTax = cgstAmt + sgstAmt;
                    totalCGST += cgstAmt;
                    totalSGST += sgstAmt;
                  } else {
                    double igstAmt = itemTaxableAmount * (item.gstRate! / 100);
                    itemTax = igstAmt;
                    totalIGST += igstAmt;
                  }
                  double itemTotal = itemTaxableAmount + itemTax;
                  subtotal += itemSubtotal;
                  totalItemDiscount += itemDiscountAmt;
                  totalTax += itemTax;
                  grandTotalBeforeDiscount += itemTotal;
                }

                for (var service in invoiceController.invoiceServiceList.where(
                  (service) => !service.isHeld!,
                )) {
                  double serviceSubtotal = service.price! * service.quantity!;
                  double serviceDiscountAmt =
                      service.isDiscountPercentage!
                          ? (serviceSubtotal * (service.discount! / 100))
                          : (service.discount! * service.quantity!);
                  double serviceTaxableAmount =
                      serviceSubtotal - serviceDiscountAmt;
                  double serviceTax = 0;
                  if (service.gstType == 'Intra-state') {
                    double cgstRate = service.gstRate! / 2;
                    double sgstRate = service.gstRate! / 2;
                    double cgstAmt = serviceTaxableAmount * (cgstRate / 100);
                    double sgstAmt = serviceTaxableAmount * (sgstRate / 100);
                    serviceTax = cgstAmt + sgstAmt;
                    totalCGST += cgstAmt;
                    totalSGST += sgstAmt;
                  } else {
                    double igstAmt =
                        serviceTaxableAmount * (service.gstRate! / 100);
                    serviceTax = igstAmt;
                    totalIGST += igstAmt;
                  }
                  double serviceTotal = serviceTaxableAmount + serviceTax;
                  subtotal += serviceSubtotal;
                  totalItemDiscount += serviceDiscountAmt;
                  totalTax += serviceTax;
                  grandTotalBeforeDiscount += serviceTotal;
                }

                double invoiceDiscountAmt =
                    invoiceController.isInvoiceDiscountPercentage.value
                        ? grandTotalBeforeDiscount *
                            (invoiceController.invoiceDiscount.value / 100)
                        : invoiceController.invoiceDiscount.value;
                double grandTotalAfterInvoiceDiscount =
                    grandTotalBeforeDiscount - invoiceDiscountAmt;
                double finalTotal = grandTotalAfterInvoiceDiscount;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(
                          width: 100,
                          child: Text(
                            'Subtotal:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            '₹${subtotal.toStringAsFixed(2)}',
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(
                          width: 100,
                          child: Text(
                            'Discount:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            '₹${totalItemDiscount.toStringAsFixed(2)}',
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(
                          width: 100,
                          child: Text(
                            'Tax:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            '₹${totalTax.toStringAsFixed(2)}',
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    if (invoiceDiscountAmt > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(
                            width: 100,
                            child: Text(
                              'Invoice Discount:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: Text(
                              '-₹${invoiceDiscountAmt.toStringAsFixed(2)}',
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(
                          width: 100,
                          child: Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            '₹${finalTotal.toStringAsFixed(2)}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (!isSavedInvoice) ...[
                    IconButton(
                      onPressed: _applyDiscountDialog,
                      icon: const Icon(Icons.discount_outlined),
                      tooltip: 'Apply Discount',
                      style: IconButton.styleFrom(
                        iconSize: 16,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  ElevatedButton.icon(
                    onPressed: _generateAndOpenPdf,
                    icon:
                        _isPrinting
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(Icons.print),
                    label: const Text('Print Invoice'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (!isSavedInvoice)
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveInvoice,
                      icon:
                          _isSaving
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.save),
                      label: const Text('Save Invoice'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    )
                  else if (invoice.amountPaid! < invoice.totalBillAmount!)
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Get.dialog(
                          AddPaymentMethodScreen(
                            customer: customer,
                            invoice: invoice,
                          ),
                          barrierDismissible: false,
                        );
                        setState(() {});
                      },
                      icon: const Icon(Icons.payment),
                      label: const Text('Add Payment'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed:
                          () =>
                              Get.to(() => SaleReturnScreen(originalInvoice: invoice)),
                      icon: const Icon(Icons.reply),
                      label: const Text('Process Refund'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    totalItems.value = 0;
    totalServices.value = 0;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Invoice Entry'),
        actions: [
          RawKeyboardListener(
            focusNode: FocusNode(),
            autofocus: true,
            onKey: (RawKeyEvent event) {
              if (event is RawKeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.keyC &&
                  event.isControlPressed) {
                _getCustomer();
              }
            },
            child: IconButton(
              icon: const Icon(Icons.person_2_outlined),
              tooltip: 'Customer (Ctrl+C)',
              onPressed: () {
                _getCustomer();
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.reply),
            tooltip: 'View Sale Returns',
            onPressed:
                isSavedInvoice
                    ? () => Get.to(() => SaleReturnScreen(originalInvoice: invoice))
                    : null,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildBillToSection(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildItemsTable(),
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }
}
