import 'package:billing_app_flutter/dio/models/license/license_model.dart';
import 'package:billing_app_flutter/dio/repositories/license_repository.dart';
import 'package:get/get.dart';

class LicenseController extends GetxController {
  final LicenseRepository _repository = Get.find<LicenseRepository>();

  final RxList<LicenseModel> licenses = <LicenseModel>[].obs;
  final Rx<LicenseModel?> currentLicense = Rx<LicenseModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<LicenseModel> userLicenses = <LicenseModel>[].obs;

  Future<void> validateLicense(String key, String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final license = await _repository.validateLicense(key, email);
      currentLicense.value = license;

      // Add to licenses list if not already present
      if (!licenses.any((l) => l.licenseKey == license.licenseKey)) {
        licenses.insert(0, license);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserLicenses(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final licenses = await _repository.getUserLicenses(email);
      userLicenses.assignAll(licenses);

      if (licenses.isEmpty) {
        errorMessage.value = 'No licenses found for this email';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> renewLicense(
    String licenseKey,
    int months,
    int? newAmount,
  ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final renewedLicense = await _repository.renewLicense(
        licenseKey,
        months,
        newAmount,
      );

      // Update the license in the list
      final index = licenses.indexWhere((l) => l.licenseKey == licenseKey);
      if (index != -1) {
        licenses[index] = renewedLicense;
      }

      currentLicense.value = renewedLicense;
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
