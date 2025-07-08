import 'package:billing_app_flutter/dio/models/license/license_model.dart';
import 'package:billing_app_flutter/dio/models/purchase/complete_purchase_request.dart';
import 'package:billing_app_flutter/dio/models/purchase/create_purchase_request.dart';
import 'package:billing_app_flutter/dio/models/purchase/purchase_model.dart';
import 'package:billing_app_flutter/dio/services/license_api_service.dart';
import 'package:get/get.dart';

class PaymentRepository {
  final LicenseApiService _apiService = Get.find<LicenseApiService>();

  Future<PurchaseModel> createPurchase({
    required String email,
    required String softwareId,
    required String platform,
    required double amount,
    required String currency,
  }) async {
    try {
      return await _apiService.createPurchase(
        CreatePurchaseRequest(
          email: email,
          softwareId: softwareId,
          platform: platform,
          amount: amount,
          currency: currency,
        ),
      );
    } catch (e) {
      throw Exception('Failed to create purchase: ${e.toString()}');
    }
  }

  Future<LicenseModel> completePurchase({
    required String purchaseId,
    required String paymentId,
  }) async {
    try {
      return await _apiService.completePurchase(
        CompletePurchaseRequest(
          purchaseId: purchaseId,
          paymentId: paymentId,
        ),
      );
    } catch (e) {
      throw Exception('Failed to complete purchase: ${e.toString()}');
    }
  }

  Future<PurchaseModel> getPurchase(String id) async {
    try {
      return await _apiService.getPurchase(id);
    } catch (e) {
      throw Exception('Failed to get purchase: ${e.toString()}');
    }
  }

  Future<PurchaseModel> processCashPayment({
    required String purchaseId,
    required String receiptNumber,
  }) async {
    try {
      return await _apiService.processCashPayment({
        'purchaseId': purchaseId,
        'receiptNumber': receiptNumber,
      });
    } catch (e) {
      throw Exception('Failed to process cash payment: ${e.toString()}');
    }
  }

  Future<PurchaseModel> processCheckPayment({
    required String purchaseId,
    required String checkNumber,
    required String bankName,
  }) async {
    try {
      return await _apiService.processCheckPayment({
        'purchaseId': purchaseId,
        'checkNumber': checkNumber,
        'bankName': bankName,
      });
    } catch (e) {
      throw Exception('Failed to process check payment: ${e.toString()}');
    }
  }
}