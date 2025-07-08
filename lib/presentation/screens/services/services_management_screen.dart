import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:billing_app_flutter/db/controllers/service_controller.dart';
import 'package:billing_app_flutter/db/models/service_entity.dart';
import 'package:billing_app_flutter/presentation/screens/services/add_edit_service_screen.dart';

class ServicesManagementScreen extends StatefulWidget {
  const ServicesManagementScreen({super.key});

  @override
  State<ServicesManagementScreen> createState() => _ServicesManagementScreenState();
}

class _ServicesManagementScreenState extends State<ServicesManagementScreen> {
  final ServiceController serviceController = Get.find<ServiceController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    serviceController.loadServicesByNameOrCode(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Catalog'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or code',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add New Service',
            onPressed: () async {
              await Get.dialog(AddEditServiceScreen(service: ServiceEntity()));
              setState(() {});
            },
          ),
        ],
      ),
      body: Obx(
            () => serviceController.services.isEmpty
            ? Center(
          child: Text(
            'No services found',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        )
            : isLargeScreen
            ? _buildGridView()
            : _buildListView(),
      ),
    );
  }

  Widget _buildListView() {
    return RefreshIndicator(
      onRefresh: () async {
        serviceController.loadServicesByNameOrCode(_searchController.text);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: serviceController.services.length,
        itemBuilder: (context, index) => _buildServiceCard(serviceController.services[index]),
      ),
    );
  }

  Widget _buildGridView() {
    return RefreshIndicator(
      onRefresh: () async {
        serviceController.loadServicesByNameOrCode(_searchController.text);
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: serviceController.services.length,
        itemBuilder: (context, index) => _buildServiceCard(serviceController.services[index]),
      ),
    );
  }

  Widget _buildServiceCard(ServiceEntity service) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: service.isDeleted! ? Colors.grey.shade200 : Theme.of(context).colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name!,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('Price', '₹${service.price!.toStringAsFixed(2)}'),
                      _buildDetailRow('Status', service.isDeleted! ? 'Deleted' : 'Active'),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Close',
                            style: TextStyle(color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      service.name!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (service.isDeleted!)
                    Chip(
                      label: const Text('Deleted'),
                      backgroundColor: Theme.of(context).colorScheme.errorContainer,
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Price: ₹${service.price!.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit Service',
                    onPressed: () async {
                      await Get.dialog(AddEditServiceScreen(service: service));
                      setState(() {});
                    },
                  ),
                  _buildActionButton(
                    icon: service.isDeleted! ? Icons.add : Icons.delete_outline,
                    tooltip: service.isDeleted! ? 'Revoke Service' : 'Delete Service',
                    onPressed: () {
                      service.isDeleted = !service.isDeleted!;
                      serviceController.saveService(service);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      color: Theme.of(context).colorScheme.primary,
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}