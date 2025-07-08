import 'package:billing_app_flutter/dio/models/license/license_model.dart';
import 'package:billing_app_flutter/presentation/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PurchaseSuccessScreen extends StatelessWidget {
  final LicenseModel license;

  const PurchaseSuccessScreen({super.key, required this.license});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              Text(
                'Purchase Complete!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildDetailCard(
                context,
                'License Key',
                license.licenseKey,
                Icons.vpn_key,
              ),
              const SizedBox(height: 16),
              _buildDetailCard(
                context,
                'Valid Until',
                DateFormat('MMMM d, y').format(license.expiryDate),
                Icons.calendar_today,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAllNamed(AppRoutes.licenseManagement);
                  },
                  child: const Text('Start Using the Software'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}