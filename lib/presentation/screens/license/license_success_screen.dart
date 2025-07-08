import 'package:billing_app_flutter/dio/models/license/license_model.dart';
import 'package:billing_app_flutter/presentation/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LicenseSuccessScreen extends StatelessWidget {
  final LicenseModel license;

  const LicenseSuccessScreen({super.key, required this.license});

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
                Icons.verified,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'License Activated Successfully!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _LicenseDetailCard(
                title: 'License Key',
                value: license.licenseKey,
                icon: Icons.vpn_key,
              ),
              const SizedBox(height: 16),
              _LicenseDetailCard(
                title: 'Valid Until',
                value: DateFormat('MMMM d, y').format(license.expiryDate),
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 16),
              _LicenseDetailCard(
                title: 'Plan',
                value: 'Annual Subscription',
                icon: Icons.credit_card,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAllNamed(AppRoutes.app);
                  },
                  child: const Text('Continue to Dashboard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LicenseDetailCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _LicenseDetailCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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