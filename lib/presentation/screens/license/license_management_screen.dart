import 'package:billing_app_flutter/dio/controllers/license_controller.dart';
import 'package:billing_app_flutter/dio/models/license/license_model.dart';
import 'package:billing_app_flutter/presentation/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LicenseManagementScreen extends GetView<LicenseController> {
  const LicenseManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Licenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadUserLicenses('user@example.com'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        if (controller.licenses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No licenses found'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.licenseActivation),
                  child: const Text('Activate a License'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.licenses.length,
          itemBuilder: (context, index) {
            final license = controller.licenses[index];
            return _LicenseCard(
              license: license,
              onRenewPressed: () {
                Get.toNamed(
                  AppRoutes.licenseRenewal,
                  arguments: license,
                );
              },
            );
          },
        );
      }),
    );
  }
}

class _LicenseCard extends StatelessWidget {
  final LicenseModel license;
  final VoidCallback onRenewPressed;

  const _LicenseCard({
    required this.license,
    required this.onRenewPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = license.expiryDate.isBefore(DateTime.now());
    final daysRemaining = license.expiryDate.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  license.softwareId,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    isExpired ? 'Expired' : 'Active',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: isExpired ? Colors.red : Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              license.licenseKey,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _LicenseDetailItem(
                  icon: Icons.calendar_today,
                  label: 'Expires',
                  value: DateFormat('MMM d, y').format(license.expiryDate),
                ),
                const SizedBox(width: 16),
                _LicenseDetailItem(
                  icon: Icons.timer,
                  label: isExpired ? 'Expired' : 'Remaining',
                  value: isExpired
                      ? '${-daysRemaining} days ago'
                      : '$daysRemaining days',
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRenewPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  foregroundColor: Theme.of(context).primaryColor,
                ),
                child: const Text('Renew License'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LicenseDetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _LicenseDetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}