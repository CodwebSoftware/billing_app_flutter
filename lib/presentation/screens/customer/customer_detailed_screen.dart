// Customer Detail Screen
import 'package:animate_do/animate_do.dart';
import 'package:billing_app_flutter/db/controllers/customer_controller.dart';
import 'package:billing_app_flutter/db/models/customer_entity.dart';
import 'package:billing_app_flutter/db/models/sale_entry_entity.dart';
import 'package:billing_app_flutter/presentation/screens/customer/add_edit_customer_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customerController = Get.find<CustomerController>();
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');
    final dateTimeFormat = DateFormat('MMM d, yyyy • hh:mm a');

    return Obx(() {
      final customer = customerController.selectedCustomer.value!;
      final isDesktop = MediaQuery.of(context).size.width > 900;
      final isTablet = MediaQuery.of(context).size.width > 600;
      final padding = isDesktop ? 32.0 : isTablet ? 24.0 : 16.0;

      return Scaffold(
        appBar: AppBar(
          title: Text(
            customer.name ?? 'Customer',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          centerTitle: false,
          backgroundColor: theme.colorScheme.primary,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Customer',
              onPressed: () => Get.to(() => const AddEditCustomerScreen()),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete Customer',
              onPressed: () => _showDeleteConfirmation(customerController, customer),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: FadeInUp(
            duration: const Duration(milliseconds: 300),
            child: isDesktop
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildProfileCard(customer, dateFormat, theme),
                      const SizedBox(height: 24),
                      _buildPurchaseHistory(customer, dateTimeFormat, theme),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      _buildCustomerStats(customer, theme),
                      const SizedBox(height: 24),
                      _buildLoyaltyProgram(customer, dateTimeFormat, theme),
                      const SizedBox(height: 24),
                      _buildNotesSection(customer, theme),
                    ],
                  ),
                ),
              ],
            )
                : Column(
              children: [
                _buildProfileCard(customer, dateFormat, theme),
                const SizedBox(height: 24),
                _buildCustomerStats(customer, theme),
                const SizedBox(height: 24),
                _buildPurchaseHistory(customer, dateTimeFormat, theme),
                const SizedBox(height: 24),
                _buildLoyaltyProgram(customer, dateTimeFormat, theme),
                const SizedBox(height: 24),
                _buildNotesSection(customer, theme),
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<void> _showDeleteConfirmation(
      CustomerController controller, CustomerEntity customer) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Customer?'),
        content: Text('Are you sure you want to delete ${customer.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(Get.context!).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      customer.isActive = false;
      controller.saveCustomer(customer);
      Get.back();
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: const Text('Customer deleted successfully'),
          backgroundColor: Theme.of(Get.context!).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Widget _buildProfileCard(CustomerEntity customer, DateFormat dateFormat, ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    customer.name?.substring(0, 1).toUpperCase() ?? '?',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name ?? 'Unknown',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (customer.customerGroup?.isNotEmpty ?? false)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Chip(
                            label: Text(customer.customerGroup!),
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            labelStyle: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Email', customer.email ?? 'Not specified', theme),
            _buildDetailRow('Phone', customer.phone ?? 'Not specified', theme),
            if (customer.dateOfBirth != null)
              _buildDetailRow('Birthday', dateFormat.format(customer.dateOfBirth!), theme),
            if (customer.anniversaryDate != null)
              _buildDetailRow('Anniversary', dateFormat.format(customer.anniversaryDate!), theme),
            _buildDetailRow('Address', [
              customer.addressLine1,
              customer.addressLine2,
              customer.city,
              customer.state,
              customer.postalCode,
              customer.country
            ].where((e) => e != null && e.isNotEmpty).join(', '), theme),
            _buildDetailRow('GSTIN', customer.gstIN ?? 'Not specified', theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerStats(CustomerEntity customer, ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Stats',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(Get.context!).size.width > 600 ? 3 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  'Total Spent',
                  '\$${customer.invoices.fold(0.0, (sum, item) => sum + item.totalAmount).toStringAsFixed(2)}',
                  Icons.shopping_bag_outlined,
                  theme.colorScheme.primary,
                  theme,
                ),
                _buildStatCard(
                  'Total Orders',
                  '${customer.invoices.length}',
                  Icons.receipt_outlined,
                  theme.colorScheme.secondary,
                  theme,
                ),
                _buildStatCard(
                  'Avg. Order',
                  '\$${(customer.invoices.isEmpty ? 0 : customer.invoices.fold(0.0, (sum, item) => sum + item.totalAmount) / customer.invoices.length).toStringAsFixed(2)}',
                  Icons.analytics_outlined,
                  theme.colorScheme.tertiary,
                  theme,
                ),
                _buildStatCard(
                  'Credit Limit',
                  '\$${customer.creditLimit?.toStringAsFixed(2) ?? '0.00'}',
                  Icons.account_balance_wallet_outlined,
                  theme.colorScheme.primaryContainer,
                  theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseHistory(
      CustomerEntity customer, DateFormat dateTimeFormat, ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Purchase History',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (customer.invoices.isNotEmpty)
                  Text(
                    'Total: \$${customer.invoices.fold(0.0, (sum, item) => sum + item.totalAmount).toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (customer.invoices.isEmpty)
              _buildEmptyState(
                icon: Icons.shopping_bag_outlined,
                title: 'No purchases yet',
                subtitle: 'This customer hasn\'t made any purchases yet',
                theme: theme,
              )
            else
              Column(
                children: customer.invoices
                    .asMap()
                    .entries
                    .map((entry) => FadeInRight(
                  delay: Duration(milliseconds: entry.key * 100),
                  child: _buildInvoiceItem(entry.value, dateTimeFormat, theme),
                ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceItem(SaleEntryEntity invoice, DateFormat dateTimeFormat, ThemeData theme) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.receipt_outlined,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(
        'Invoice #${invoice.invoiceNumber}',
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        dateTimeFormat.format(invoice.date!),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${invoice.totalAmount.toStringAsFixed(2)}',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: invoice.amountPaid != 0
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              invoice.amountPaid != 0 ? 'Paid' : 'Pending',
              style: theme.textTheme.labelSmall?.copyWith(
                color: invoice.amountPaid != 0 ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        // Handle invoice tap
      },
    );
  }

  Widget _buildLoyaltyProgram(
      CustomerEntity customer, DateFormat dateTimeFormat, ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Loyalty Program',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  '${customer.loyaltyPoints ?? 0} pts',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (customer.memberships.isEmpty)
              _buildEmptyState(
                icon: Icons.loyalty_outlined,
                title: 'No loyalty points',
                subtitle: 'This customer hasn\'t earned any loyalty points yet',
                theme: theme,
              )
            else
              Column(
                children: customer.memberships
                    .asMap()
                    .entries
                    .map((entry) => FadeInRight(
                  delay: Duration(milliseconds: entry.key * 100),
                  child: _buildLoyaltyPointItem(entry.value, dateTimeFormat, theme),
                ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoyaltyPointItem(dynamic point, DateFormat dateTimeFormat, ThemeData theme) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.bolt_outlined,
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
      title: Text(
        point.reason ?? 'Loyalty Points',
        style: theme.textTheme.bodyLarge,
      ),
      subtitle: Text(
        dateTimeFormat.format(point.earnedDate),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Chip(
        label: Text('+${point.points} pts'),
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        labelStyle: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildNotesSection(CustomerEntity customer, ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Notes',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            if (customer.feedbacks.isEmpty)
              _buildEmptyState(
                icon: Icons.notes_outlined,
                title: 'No notes yet',
                subtitle: 'Add notes about this customer',
                theme: theme,
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  customer.feedbacks.map((f) => f.comment).join('\n'),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(icon, size: 48, color: theme.colorScheme.outline),
        const SizedBox(height: 16),
        Text(
          title,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not specified',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}