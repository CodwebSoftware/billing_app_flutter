import 'package:billing_app_flutter/db/controllers/appointments_controller.dart';
import 'package:billing_app_flutter/db/controllers/company_profile_controller.dart';
import 'package:billing_app_flutter/db/controllers/customer_controller.dart';
import 'package:billing_app_flutter/db/controllers/employee_controller.dart';
import 'package:billing_app_flutter/db/controllers/sale_entry_controller.dart';
import 'package:billing_app_flutter/db/controllers/leave_request_controller.dart';
import 'package:billing_app_flutter/db/controllers/leave_type_controller.dart';
import 'package:billing_app_flutter/db/controllers/product_category_controller.dart';
import 'package:billing_app_flutter/db/controllers/product_controller.dart';
import 'package:billing_app_flutter/db/controllers/sale_return_controller.dart';
import 'package:billing_app_flutter/db/controllers/service_controller.dart';
import 'package:billing_app_flutter/dio/controllers/license_controller.dart';
import 'package:billing_app_flutter/dio/controllers/onboarding_controller.dart';
import 'package:billing_app_flutter/dio/controllers/payment_controller.dart';
import 'package:billing_app_flutter/dio/repositories/license_repository.dart';
import 'package:billing_app_flutter/dio/repositories/payment_repository.dart';
import 'package:billing_app_flutter/dio/services/license_api_service.dart';
import 'package:billing_app_flutter/objectboxes.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class AppBindings extends Bindings {
  final ObjectBoxes objectBox;

  AppBindings(this.objectBox);

  @override
  void dependencies() {
    try {
      _initializeNetworkDependencies();
      _initializeControllers();
      _initializeDatabaseControllers();
    } catch (e) {
      debugPrint('Error initializing dependencies: $e');
      rethrow;
    }
  }

  void _initializeNetworkDependencies() {
    // Configure Dio with proper settings
    final dio = Dio();

    // Add interceptors for better debugging and error handling
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: true,
          error: true,
        ),
      );
    }

    // Set default timeout
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);

    // Register network dependencies
    Get.put(dio, permanent: true);
    Get.put(LicenseApiService(dio), permanent: true);
    Get.put(LicenseRepository(), permanent: true);
    Get.put(PaymentRepository(), permanent: true);
  }

  void _initializeControllers() {
    // Initialize API controllers
    Get.put(OnboardingController(), permanent: true);
    Get.put(LicenseController(), permanent: true);
    Get.put(PaymentController(), permanent: true);
  }

  void _initializeDatabaseControllers() {
    // Initialize database controllers with lazy loading and fenix for automatic recreation
    Get.lazyPut<CompanyProfileController>(
      () => CompanyProfileController(objectBox: objectBox),
      fenix: true,
    );

    Get.lazyPut<CustomerController>(
      () => CustomerController(objectBox: objectBox),
      fenix: true,
    );

    Get.lazyPut<SaleEntryController>(
      () => SaleEntryController(objectBox: objectBox),
      fenix: true,
    );

    Get.lazyPut<SaleReturnController>(
      () => SaleReturnController(objectBox: objectBox),
      fenix: true,
    );

    Get.lazyPut<ProductCategoryController>(
      () => ProductCategoryController(objectBox: objectBox),
      fenix: true,
    );

    Get.lazyPut<ProductController>(
      () => ProductController(objectBox: objectBox),
      fenix: true,
    );

    Get.lazyPut<ServiceController>(
      () => ServiceController(objectBox: objectBox),
      fenix: true,
    );

    Get.lazyPut<EmployeeController>(
      () => EmployeeController(objectBox: objectBox),
      fenix: true,
    );

    Get.lazyPut<AppointmentsController>(
      () => AppointmentsController(objectBox: objectBox),
      fenix: true,
    );

    Get.lazyPut<LeaveRequestController>(
      () => LeaveRequestController(objectBox: objectBox),
      fenix: true,
    );

    Get.lazyPut<LeaveTypeController>(
      () => LeaveTypeController(objectBox: objectBox),
      fenix: true,
    );
  }
}
