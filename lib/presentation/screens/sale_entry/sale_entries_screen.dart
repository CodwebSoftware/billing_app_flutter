import 'package:billing_app_flutter/db/controllers/sale_entry_controller.dart';
import 'package:billing_app_flutter/core/constants/constants.dart';
import 'package:billing_app_flutter/db/models/customer_entity.dart';
import 'package:billing_app_flutter/db/models/sale_entry_entity.dart';
import 'package:billing_app_flutter/db/models/payment_entity.dart';
import 'package:billing_app_flutter/presentation/screens/sale_entry/sale_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SaleEntriesScreen extends StatefulWidget {
  final CustomerEntity customer;

  const SaleEntriesScreen({super.key, required this.customer});

  @override
  State<SaleEntriesScreen> createState() => _SaleEntriesScreenState();
}

class _SaleEntriesScreenState extends State<SaleEntriesScreen> {
  final _invoiceController = Get.find<SaleEntryController>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInvoices();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInvoices() async {
    if (widget.customer.id == 0) {
      await _invoiceController.loadInvoices();
    } else {
      await _invoiceController.loadInvoicesByCustomer(
        customerId: widget.customer.id!,
      );
    }
    setState(() {});
  }

  void _filterItems() {
    if (_searchController.text.isNotEmpty) {
      _invoiceController.loadInvoicesByCustomerAndInvoiceNumber(
        invoiceId: int.tryParse(_searchController.text) ?? 0,
        customerId: widget.customer.id!,
      );
    } else {
      _invoiceController.loadInvoicesByCustomer(
        customerId: widget.customer.id!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.customer.name}'s Invoices"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: theme.colorScheme.onPrimaryContainer),
            tooltip: "Add new invoice",
            onPressed: () => _navigateToInvoiceScreen(SaleEntryEntity()),
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            tooltip: "Refresh",
            onPressed: _loadInvoices,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndSummaryBar(theme, isLargeScreen),
          Expanded(
            child: Obx(() {
              if (_invoiceController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return _invoiceController.invoices.isEmpty
                  ? _buildEmptyState(theme)
                  : _buildInvoiceList(theme, isLargeScreen);
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToInvoiceScreen(SaleEntryEntity()),
        backgroundColor: theme.colorScheme.primary,
        child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildSearchAndSummaryBar(ThemeData theme, bool isLargeScreen) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search by invoice number",
                    prefixIcon: Icon(
                      Icons.search,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (isLargeScreen) ...[
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Remaining: ₹${_invoiceController.totalRemainingAmount.toStringAsFixed(2)}",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (!isLargeScreen) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Remaining: ₹${_invoiceController.totalRemainingAmount.toStringAsFixed(2)}",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No invoices found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first invoice to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceList(ThemeData theme, bool isLargeScreen) {
    return RefreshIndicator(
      onRefresh: _loadInvoices,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _invoiceController.invoices.length,
        itemBuilder: (context, index) {
          final invoice = _invoiceController.invoices[index];
          return _buildInvoiceCard(theme, invoice, isLargeScreen);
        },
      ),
    );
  }

  Widget _buildInvoiceCard(
      ThemeData theme,
      SaleEntryEntity invoice,
      bool isLargeScreen,
      ) {
    final statusColor = _getStatusColor(theme, invoice.status!);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToInvoiceScreen(invoice),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Invoice #${invoice.id}",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      invoice.status!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Date: ${dftm.format(invoice.date!)}",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              if (isLargeScreen) _buildInvoiceDetailsLarge(theme, invoice),
              if (!isLargeScreen) _buildInvoiceDetailsSmall(theme, invoice),
              if (invoice.payments.isNotEmpty) ...[
                const Divider(height: 24),
                Text(
                  "Payment History",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ...invoice.payments.map(
                      (payment) => _buildPaymentRow(theme, payment),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceDetailsLarge(ThemeData theme, SaleEntryEntity invoice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInvoiceDetailItem(
          theme,
          "Total",
          "₹${invoice.totalBillAmount!.toStringAsFixed(2)}",
        ),
        _buildInvoiceDetailItem(
          theme,
          "Paid",
          "₹${invoice.amountPaid!.toStringAsFixed(2)}",
        ),
        _buildInvoiceDetailItem(
          theme,
          "Due",
          "₹${(invoice.totalBillAmount! - invoice.amountPaid!).toStringAsFixed(2)}",
          isHighlighted: true,
        ),
      ],
    );
  }

  Widget _buildInvoiceDetailsSmall(ThemeData theme, SaleEntryEntity invoice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInvoiceDetailItem(
          theme,
          "Total",
          "₹${invoice.totalBillAmount!.toStringAsFixed(2)}",
        ),
        _buildInvoiceDetailItem(
          theme,
          "Paid",
          "₹${invoice.amountPaid!.toStringAsFixed(2)}",
        ),
        _buildInvoiceDetailItem(
          theme,
          "Due",
          "₹${(invoice.totalBillAmount! - invoice.amountPaid!).toStringAsFixed(2)}",
          isHighlighted: true,
        ),
      ],
    );
  }

  Widget _buildInvoiceDetailItem(
      ThemeData theme,
      String label,
      String value, {
        bool isHighlighted = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color:
              isHighlighted
                  ? _getStatusColor(theme, "Due")
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(ThemeData theme, PaymentEntity payment) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Paid ₹${payment.paidAmount!.toStringAsFixed(2)} on ${dftm.format(payment.date!)}",
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 20),
                  onPressed: () => _deletePayment(payment),
                  tooltip: "Delete payment",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ThemeData theme, String status) {
    switch (status) {
      case "Paid":
        return theme.colorScheme.tertiary;
      case "Partially Paid":
        return theme.colorScheme.secondary;
      case "Due":
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurface;
    }
  }

  Future<void> _navigateToInvoiceScreen(SaleEntryEntity invoice) async {
    await Get.to(
          () => SaleEntryScreen(invoiceEntity: invoice),
    );
    await _loadInvoices();
  }

  Future<void> _deletePayment(PaymentEntity payment) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Delete Payment"),
        content: const Text("Are you sure you want to delete this payment?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _invoiceController.deletePayment(payment.id);
      await _loadInvoices();
    }
  }
}