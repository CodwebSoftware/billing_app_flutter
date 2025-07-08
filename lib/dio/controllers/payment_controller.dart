import 'package:billing_app_flutter/dio/models/license/license_model.dart';
import 'package:billing_app_flutter/dio/models/payment/bank_transfer_payment.dart';
import 'package:billing_app_flutter/dio/models/payment/cash_payment.dart';
import 'package:billing_app_flutter/dio/models/payment/check_payment.dart';
import 'package:billing_app_flutter/dio/models/payment/credit_card_payment.dart';
import 'package:billing_app_flutter/dio/models/payment/paypal_payment.dart';
import 'package:billing_app_flutter/dio/models/purchase/purchase_model.dart';
import 'package:billing_app_flutter/dio/repositories/payment_repository.dart';
import 'package:get/get.dart';

class PaymentController extends GetxController {
  final PaymentRepository _repository = Get.find<PaymentRepository>();
  final Rx<PurchaseModel?> currentPurchase = Rx<PurchaseModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<CreditCardPayment?> creditCardPayment = Rx<CreditCardPayment?>(null);
  final Rx<PayPalPayment?> paypalPayment = Rx<PayPalPayment?>(null);
  final Rx<BankTransferPayment?> bankTransferPayment = Rx<BankTransferPayment?>(
    null,
  );
  final RxString selectedPaymentMethod = ''.obs;
  final Rx<CashPayment?> cashPayment = Rx<CashPayment?>(null);
  final Rx<CheckPayment?> checkPayment = Rx<CheckPayment?>(null);

  Future<void> createPurchase({
    required String email,
    required String softwareId,
    required String platform,
    required double amount,
    required String currency,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      currentPurchase.value = await _repository.createPurchase(
        email: email,
        softwareId: softwareId,
        platform: platform,
        amount: amount,
        currency: currency,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<LicenseModel> completePurchase({
    required String purchaseId,
    required String paymentId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final license = await _repository.completePurchase(
        purchaseId: purchaseId,
        paymentId: paymentId,
      );
      return license;
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<LicenseModel> processCreditCardPayment({
    required String cardNumber,
    required String cardHolder,
    required String expiryDate,
    required String cvv,
    required String email,
    required Map<String, dynamic> purchaseDetails,
  }) async {
    try {
      isLoading.value = true;

      // Validate card
      if (!_validateCreditCard(cardNumber, expiryDate, cvv)) {
        throw Exception('Invalid credit card details');
      }

      // Save payment method
      creditCardPayment.value = CreditCardPayment(
        cardNumber: cardNumber,
        cardHolder: cardHolder,
        expiryDate: expiryDate,
        cvv: cvv,
      );

      // Create purchase record
      await createPurchase(
        email: email,
        softwareId: purchaseDetails['softwareId'],
        platform: purchaseDetails['platform'],
        amount: purchaseDetails['amount'],
        currency: purchaseDetails['currency'],
      );

      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Complete purchase
      final license = await completePurchase(
        purchaseId: currentPurchase.value!.id,
        paymentId: 'cc_${DateTime.now().millisecondsSinceEpoch}',
      );

      return license;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<LicenseModel> processPayPalPayment({
    required String email,
    required String password,
    required String purchaseEmail,
    required Map<String, dynamic> purchaseDetails,
  }) async {
    try {
      isLoading.value = true;

      // Validate PayPal credentials
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Invalid PayPal credentials');
      }

      // Save payment method
      paypalPayment.value = PayPalPayment(email: email, password: password);

      // Create purchase record
      await createPurchase(
        email: purchaseEmail,
        softwareId: purchaseDetails['softwareId'],
        platform: purchaseDetails['platform'],
        amount: purchaseDetails['amount'],
        currency: purchaseDetails['currency'],
      );

      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Complete purchase
      final license = await completePurchase(
        purchaseId: currentPurchase.value!.id,
        paymentId: 'pp_${DateTime.now().millisecondsSinceEpoch}',
      );

      return license;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<LicenseModel> processBankTransferPayment({
    required String accountNumber,
    required String accountName,
    required String bankName,
    required String routingNumber,
    required String email,
    required Map<String, dynamic> purchaseDetails,
  }) async {
    try {
      isLoading.value = true;

      // Validate bank details
      if (accountNumber.isEmpty || routingNumber.isEmpty) {
        throw Exception('Invalid bank details');
      }

      // Save payment method
      bankTransferPayment.value = BankTransferPayment(
        accountNumber: accountNumber,
        accountName: accountName,
        bankName: bankName,
        routingNumber: routingNumber,
      );

      // Create purchase record
      await createPurchase(
        email: email,
        softwareId: purchaseDetails['softwareId'],
        platform: purchaseDetails['platform'],
        amount: purchaseDetails['amount'],
        currency: purchaseDetails['currency'],
      );

      // For bank transfer, we don't complete immediately
      // Instead we mark as pending and wait for actual transfer
      Get.snackbar(
        'Bank Transfer Initiated',
        'Please complete the transfer using the provided details',
        snackPosition: SnackPosition.BOTTOM,
      );

      // In a real app, you would wait for a webhook notification
      // that the transfer was completed
      await Future.delayed(const Duration(seconds: 4));

      // Complete purchase (simulated)
      final license = await completePurchase(
        purchaseId: currentPurchase.value!.id,
        paymentId: 'bt_${DateTime.now().millisecondsSinceEpoch}',
      );

      return license;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateCreditCard(String cardNumber, String expiryDate, String cvv) {
    // Simple validation - in a real app you would use proper validation
    return cardNumber.length >= 16 && expiryDate.length == 5 && cvv.length >= 3;
  }

  Future<PurchaseModel> processCashPayment({
    required String purchaseId,
    required String receiptNumber,
  }) async {
    try {
      isLoading.value = true;
      final purchase = await _repository.processCashPayment(
        purchaseId: purchaseId,
        receiptNumber: receiptNumber,
      );
      cashPayment.value = CashPayment(
        receiptNumber: receiptNumber,
        paymentDate: DateTime.now(),
      );
      return purchase;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<PurchaseModel> processCheckPayment({
    required String purchaseId,
    required String checkNumber,
    required String bankName,
  }) async {
    try {
      isLoading.value = true;
      final purchase = await _repository.processCheckPayment(
        purchaseId: purchaseId,
        checkNumber: checkNumber,
        bankName: bankName,
      );
      checkPayment.value = CheckPayment(
        checkNumber: checkNumber,
        bankName: bankName,
        issueDate: DateTime.now(),
      );
      return purchase;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
