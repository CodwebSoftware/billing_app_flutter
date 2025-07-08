import 'package:billing_app_flutter/db/controllers/customer_controller.dart';
import 'package:billing_app_flutter/db/models/customer_entity.dart';
import 'package:billing_app_flutter/presentation/screens/customer/add_edit_customer_screen.dart';
import 'package:billing_app_flutter/presentation/screens/customer/customer_detailed_screen.dart';
import 'package:billing_app_flutter/presentation/screens/sale_entry/sale_entries_screen.dart';
import 'package:billing_app_flutter/utils/whats_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';



// Customer Management Screen
class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  State<CustomerManagementScreen> createState() =>
      _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  final CustomerController _customerController = Get.find<CustomerController>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _customerController.getCustomersByNameOrMobile("");
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _filterItems() {
    _customerController.getCustomersByNameOrMobile(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
            tooltip: 'Add New Customer',
            onPressed: () => _openAddEditCustomerDialog(),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.onPrimary),
            tooltip: 'Refresh',
            onPressed: _refreshCustomers,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(theme),
          _buildCustomerCountBar(theme),
          Expanded(
            child: Obx(() {
              if (_customerController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return _customerController.customers.isEmpty
                  ? _buildEmptyState(theme)
                  : isLargeScreen
                  ? _buildGridView(theme)
                  : _buildListView(theme);
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEditCustomerDialog(),
        backgroundColor: theme.colorScheme.primary,
        child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search by name or mobile',
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _searchFocusNode.requestFocus();
                    },
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.2),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerCountBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Showing ${_customerController.customers.length} of ${_customerController.getCustomersCount()} customers',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _showBirthDateCustomerDialog,
            icon: const Icon(Icons.cake_outlined),
            label: Text(
              'Birthdays (${_customerController.birthDateCustomers.length})',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: FadeInUp(
        duration: const Duration(milliseconds: 300),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No customers found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first customer to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _openAddEditCustomerDialog(),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Add Customer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _refreshCustomers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _customerController.customers.length,
        itemBuilder:
            (context, index) => FadeInUp(
              delay: Duration(milliseconds: index * 100),
              child: _buildCustomerCard(
                theme,
                _customerController.customers[index],
              ),
            ),
      ),
    );
  }

  Widget _buildGridView(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _refreshCustomers,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _customerController.customers.length,
        itemBuilder:
            (context, index) => FadeInUp(
              delay: Duration(milliseconds: index * 100),
              child: _buildCustomerCard(
                theme,
                _customerController.customers[index],
              ),
            ),
      ),
    );
  }

  Widget _buildCustomerCard(ThemeData theme, CustomerEntity customer) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color:
          CustomerEntity.isTodayBirthday(customer.dateOfBirth!)
              ? theme.colorScheme.secondaryContainer.withOpacity(0.3)
              : theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showCustomerDetails(customer),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      customer.name?.isNotEmpty ?? false
                          ? customer.name![0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name ?? 'Unknown',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (customer.phone?.isNotEmpty ?? false)
                          Text(
                            customer.phone!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (CustomerEntity.isTodayBirthday(customer.dateOfBirth!))
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cake,
                            size: 16,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Birthday',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (customer.email?.isNotEmpty ?? false)
                _buildCustomerDetailRow(
                  theme,
                  Icons.email_outlined,
                  customer.email!,
                ),
              if (customer.addressLine1?.isNotEmpty ?? false)
                _buildCustomerDetailRow(
                  theme,
                  Icons.location_on_outlined,
                  customer.addressLine1!,
                ),
              const Spacer(),
              _buildCustomerActions(theme, customer),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerDetailRow(ThemeData theme, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerActions(ThemeData theme, CustomerEntity customer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildCustomerActionButton(
          theme,
          icon: Icons.receipt_outlined,
          tooltip: 'View Invoices',
          onPressed: () => Get.to(() => SaleEntriesScreen(customer: customer)),
        ),
        _buildCustomerActionButton(
          theme,
          icon: Icons.info_outline,
          tooltip: 'Customer Details',
          onPressed: () {
            _customerController.selectedCustomer.value = customer;
            Get.to(() => const CustomerDetailScreen());
          },
        ),
        _buildCustomerActionButton(
          theme,
          icon: Icons.edit_outlined,
          tooltip: 'Edit Customer',
          onPressed: () => _openAddEditCustomerDialog(customer: customer),
        ),
        _buildCustomerActionButton(
          theme,
          icon: Icons.delete_outline,
          tooltip: 'Delete Customer',
          onPressed: () => _deleteCustomer(customer),
        ),
      ],
    );
  }

  Widget _buildCustomerActionButton(
    ThemeData theme, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      color: theme.colorScheme.primary,
      style: IconButton.styleFrom(
        backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _openAddEditCustomerDialog({CustomerEntity? customer}) async {
    _customerController.selectedCustomer.value = customer ?? CustomerEntity();
    await Get.dialog(const AddEditCustomerScreen());
    setState(() {});
  }

  Future<void> _refreshCustomers() async {
    _searchController.clear();
    await _customerController.getCustomersByNameOrMobile("");
  }

  void _deleteCustomer(CustomerEntity customer) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete ${customer.name}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              customer.isActive = false;
              _customerController.saveCustomer(customer);
              setState(() {});
              Get.back();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Customer deleted successfully'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomerDetails(CustomerEntity customer) {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: FadeInUp(
          duration: const Duration(milliseconds: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      customer.name?.isNotEmpty ?? false
                          ? customer.name![0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name ?? 'Unknown',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (CustomerEntity.isTodayBirthday(customer.dateOfBirth!))
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.cake,
                                  size: 16,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Birthday Today!',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailItem(
                Theme.of(context),
                'Phone',
                customer.phone ?? 'Not specified',
              ),
              _buildDetailItem(
                Theme.of(context),
                'Email',
                customer.email ?? 'Not specified',
              ),
              _buildDetailItem(
                Theme.of(context),
                'Address',
                [
                  customer.addressLine1,
                  customer.addressLine2,
                  customer.city,
                  customer.state,
                  customer.postalCode,
                  customer.country,
                ].where((e) => e != null && e.isNotEmpty).join(', '),
              ),
              _buildDetailItem(
                Theme.of(context),
                'Birth Date',
                customer.dateOfBirth != null
                    ? DateFormat('MMM dd, yyyy').format(customer.dateOfBirth!)
                    : 'Not specified',
              ),
              _buildDetailItem(
                Theme.of(context),
                'Gender',
                customer.gender ?? 'Not specified',
              ),
              _buildDetailItem(
                Theme.of(context),
                'Status',
                customer.isActive == false ? 'Inactive' : 'Active',
                statusColor:
                    customer.isActive == false
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
              ),
              _buildDetailItem(
                Theme.of(context),
                'Credit Limit',
                '\$${customer.creditLimit?.toStringAsFixed(2) ?? '0.00'}',
              ),
              _buildDetailItem(
                Theme.of(context),
                'GSTIN',
                customer.gstIN ?? 'Not specified',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Get.back(),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    ThemeData theme,
    String label,
    String value, {
    Color? statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: statusColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _showBirthDateCustomerDialog() {
    _customerController.getCustomersByNameOrMobileAndDOB(_searchController.text, DateTime.now());

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Birthday Customers',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search birthday customers',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.2),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    _customerController.getCustomersByNameOrMobileAndDOB(value, DateTime.now());
                  },
                ),
              ),
              Flexible(
                child: Obx(() {
                  if (_customerController.birthDateCustomers.isEmpty) {
                    return Center(
                      child: Text(
                        'No birthday customers found',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _customerController.birthDateCustomers.length,
                    itemBuilder: (context, index) {
                      final customer =
                          _customerController.birthDateCustomers[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              customer.name?.isNotEmpty ?? false
                                  ? customer.name![0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          title: Text(customer.name ?? 'Unknown'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(customer.phone ?? 'Not specified'),
                              Text(
                                'Birthday: ${customer.dateOfBirth != null ? DateFormat('MMM dd').format(customer.dateOfBirth!) : 'Not specified'}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.cake,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            onPressed:
                                () => sendWhatsAppMessage(
                                  customer.phone ?? '',
                                  "🎉 Hi ${customer.name}! Wishing you a very Happy Birthday! 🥳",
                                ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
