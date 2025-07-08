import 'package:billing_app_flutter/db/controllers/service_controller.dart';
import 'package:billing_app_flutter/db/models/service_entity.dart';
import 'package:billing_app_flutter/presentation/screens/services/add_edit_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FindServiceScreen extends StatefulWidget {
  const FindServiceScreen({super.key});

  @override
  State<FindServiceScreen> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<FindServiceScreen> {
  final serviceController = Get.find<ServiceController>();
  final _searchController = TextEditingController();
  List<ServiceEntity>? filteredServiceList;

  @override
  void initState() {
    serviceController.loadServices();
    filteredServiceList = serviceController.services;
    _searchController.addListener(_filterServices);
    super.initState();
  }

  void _filterServices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredServiceList = serviceController.services;
      } else {
        final exactMatches =
            serviceController.services
                .where((service) => service.name!.toLowerCase() == query)
                .toList();
        final partialMatches =
            serviceController.services
                .where(
                  (service) =>
                      service.name!.toLowerCase().contains(query) &&
                      service.name!.toLowerCase() != query,
                )
                .toList();
        final otherMatches =
            serviceController.services
                .where(
                  (service) =>
                      service.description!.toLowerCase().contains(query) ||
                      service.price.toString().contains(query),
                )
                .toList();
        filteredServiceList =
            [...exactMatches, ...partialMatches, ...otherMatches].toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterServices);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Find Services',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await Get.dialog(
                      AddEditServiceScreen(service: ServiceEntity()),
                    );
                    setState(() {});
                  },
                  icon: Icon(Icons.add_outlined),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, description or price...',
                prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () => _searchController.clear(),
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade700),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  filteredServiceList!.isEmpty
                      ? Center(
                        child: Text(
                          'No services found',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                      : ListView.builder(
                        itemCount: filteredServiceList!.length,
                        itemBuilder: (context, index) {
                          final service = filteredServiceList![index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              title: Text(
                                service.name!,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                service.description!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              trailing: Text(
                                '₹ ${service.price!.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.blue.shade700),
                              ),
                              onTap: () => Get.back(result: service),
                            ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.blue.shade700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
