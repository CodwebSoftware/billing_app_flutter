import 'package:billing_app_flutter/dio/models/license/license_model.dart';
import 'package:billing_app_flutter/dio/models/renew_license/renew_license_request.dart';
import 'package:billing_app_flutter/dio/services/license_api_service.dart';
import 'package:get/get.dart';

class LicenseRepository {
  final LicenseApiService _licenseApiService = Get.find<LicenseApiService>();

  Future<List<LicenseModel>> getUserLicenses(String email) async {
    try {
      final response = await _licenseApiService.getUserLicenses(email);
      return response;
    } catch (e) {
      throw Exception('Failed to load licenses: ${e.toString()}');
    }
  }

  Future<LicenseModel> validateLicense(String key, String email) async {
    try {
      return await _licenseApiService.validateLicense({
        'licenseKey': key,
        'email': email,
      });
    } catch (e) {
      throw Exception('Failed to validate license: ${e.toString()}');
    }
  }

  Future<LicenseModel> renewLicense(
      String licenseKey,
      int months,
      int? newAmount,
      ) async {
    try {
      return await _licenseApiService.renewLicense(
        RenewLicenseRequest(
          licenseKey: licenseKey,
          renewalDurationMonths: months,
          newAmount: newAmount,
        ),
      );
    } catch (e) {
      throw Exception('Failed to renew license: ${e.toString()}');
    }
  }
}