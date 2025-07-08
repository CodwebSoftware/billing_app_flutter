import 'package:billing_app_flutter/dio/controllers/license_controller.dart';
import 'package:billing_app_flutter/dio/models/license/license_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LicenseRenewalScreen extends GetView<LicenseController> {
  final LicenseModel license;
  final RxInt _selectedMonths = 12.obs;
  final List<int> _monthOptions = [1, 3, 6, 12, 24];

  LicenseRenewalScreen({super.key, required this.license});

  @override
  Widget build(BuildContext context) {
    final newExpiryDate =
    DateTime.now().add(Duration(days: 30 * _selectedMonths.value));
    final formatter = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Renew License'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Renew Your License',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Extend your software access by selecting a renewal period',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            Card(
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current License',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          license.licenseKey,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Expires On',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          DateFormat('MMM d, y').format(license.expiryDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Select Renewal Period',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _monthOptions.map((months) {
                return ChoiceChip(
                  label: Text('$months ${months == 1 ? 'Month' : 'Months'}'),
                  selected: _selectedMonths.value == months,
                  onSelected: (selected) {
                    if (selected) {
                      _selectedMonths.value = months;
                    }
                  },
                  selectedColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                    color: _selectedMonths.value == months ? Colors.white : null,
                  ),
                );
              }).toList(),
            )),
            const SizedBox(height: 32),
            Card(
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'New Expiry Date',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Obx(() => Text(
                          DateFormat('MMM d, y').format(newExpiryDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Obx(() => Text(
                          formatter.format(
                              license.amount * _selectedMonths.value / 12),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).primaryColor,
                          ),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                  try {
                    await controller.renewLicense(
                      license.licenseKey,
                      _selectedMonths.value,
                      null, // Keep same amount
                    );
                    Get.back();
                    Get.snackbar(
                      'Success',
                      'License renewed successfully until ${DateFormat('MMM d, y').format(newExpiryDate)}',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      e.toString(),
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                child: controller.isLoading.value
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('Confirm Renewal'),
              ),
            )),
          ],
        ),
      ),
    );
  }
}