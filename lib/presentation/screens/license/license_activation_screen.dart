import 'package:billing_app_flutter/dio/controllers/license_controller.dart';
import 'package:billing_app_flutter/presentation/routes/app_routes.dart';
import 'package:billing_app_flutter/presentation/widgets/license_key_input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LicenseActivationScreen extends GetView<LicenseController> {
  final _formKey = GlobalKey<FormState>();
  final _licenseKeyController = TextEditingController();
  final _emailController = TextEditingController();

  LicenseActivationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('License Activation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your license details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please provide your license key and email address to activate your software',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              LicenseKeyInput(controller: _licenseKeyController),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await controller.validateLicense(
                          _licenseKeyController.text.trim(),
                          _emailController.text.trim(),
                        );
                        Get.toNamed(
                          AppRoutes.licenseSuccess,
                          arguments: controller.currentLicense.value,
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
                    }
                  },
                  icon: controller.isLoading.value
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.verified_user),
                  label: Text(controller.isLoading.value
                      ? 'Verifying...'
                      : 'Activate License'),
                ),
              )),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.purchaseOptions);
                  },
                  child: const Text('Don\'t have a license? Purchase one now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}