import 'dart:ffi';
import 'dart:io';
import 'package:billing_app_flutter/db/models/appointment_entity.dart';
import 'package:billing_app_flutter/db/models/attendance_entity.dart';
import 'package:billing_app_flutter/db/models/batch_entity.dart';
import 'package:billing_app_flutter/db/models/company_branch_profile_entity.dart';
import 'package:billing_app_flutter/db/models/company_profile_entity.dart';
import 'package:billing_app_flutter/db/models/coupon_entity.dart';
import 'package:billing_app_flutter/db/models/customer_entity.dart';
import 'package:billing_app_flutter/db/models/employee_entity.dart';
import 'package:billing_app_flutter/db/models/feedback_entity.dart';
import 'package:billing_app_flutter/db/models/held_cart_entity.dart';
import 'package:billing_app_flutter/db/models/inventory_part_entity.dart';
import 'package:billing_app_flutter/db/models/sale_entry_entity.dart';
import 'package:billing_app_flutter/db/models/sale_entry_items_entity.dart';
import 'package:billing_app_flutter/db/models/sale_entry_services_entity.dart';
import 'package:billing_app_flutter/db/models/leave_request_entity.dart';
import 'package:billing_app_flutter/db/models/leave_type_entity.dart';
import 'package:billing_app_flutter/db/models/loyalty_point_entity.dart';
import 'package:billing_app_flutter/db/models/membership_entity.dart';
import 'package:billing_app_flutter/db/models/reward_entity.dart';
import 'package:billing_app_flutter/db/models/payment_entity.dart';
import 'package:billing_app_flutter/db/models/product_category_entity.dart';
import 'package:billing_app_flutter/db/models/product_entity.dart';
import 'package:billing_app_flutter/db/models/sale_return_entity.dart';
import 'package:billing_app_flutter/db/models/sale_return_item_entity.dart';
import 'package:billing_app_flutter/db/models/sale_return_service_entity.dart';
import 'package:billing_app_flutter/db/models/service_entity.dart';
import 'package:billing_app_flutter/db/models/subscription_entity.dart';
import 'package:billing_app_flutter/db/models/user_entity.dart';
import 'package:billing_app_flutter/db/models/waitlist_entity.dart';
import 'package:billing_app_flutter/db/models/working_hours_entity.dart';
import 'package:billing_app_flutter/objectbox.g.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Manages ObjectBox database initialization and provides access to all entity boxes
class ObjectBoxes {
  /// The Store instance for this app
  late final Store store;

  // Core business entity boxes
  late final Box<CompanyProfileEntity> companyProfileBox;
  late final Box<CompanyBranchProfileEntity> companyBranchBox;
  late final Box<CustomerEntity> customerBox;
  late final Box<EmployeeEntity> employeeBox;
  late final Box<UserEntity> userBox;

  // Product and service boxes
  late final Box<ProductEntity> productBox;
  late final Box<ProductCategoryEntity> productCategoryBox;
  late final Box<ServiceEntity> serviceBox;
  late final Box<InventoryPartEntity> inventoryPartBox;
  late final Box<BatchEntity> batchBox;

  // Sales and transaction boxes
  late final Box<SaleEntryEntity> saleEntryBox;
  late final Box<SaleEntryItemEntity> saleEntryItemBox;
  late final Box<SaleEntryServicesEntity> saleEntryServiceBox;
  late final Box<SaleReturnEntity> saleReturnBox;
  late final Box<SaleReturnItemEntity> saleReturnItemBox;
  late final Box<SaleReturnServiceEntity> saleReturnServiceBox;
  late final Box<PaymentEntity> paymentBox;
  late final Box<HeldCartEntity> heldCartBox;

  // Appointment and scheduling boxes
  late final Box<AppointmentEntity> appointmentBox;
  late final Box<AttendanceEntity> attendanceBox;
  late final Box<LeaveRequestEntity> leaveRequestBox;
  late final Box<LeaveTypeEntity> leaveTypeBox;
  late final Box<WorkingHoursEntity> workingHoursBox;
  late final Box<WaitlistEntity> waitListBox;

  // Customer engagement boxes
  late final Box<CouponEntity> couponBox;
  late final Box<FeedbackEntity> feedbackBox;
  late final Box<LoyaltyPointEntity> loyaltyPointBox;
  late final Box<MembershipEntity> membershipBox;
  late final Box<RewardEntity> rewardBox;
  late final Box<SubscriptionEntity> subscriptionBox;

  ObjectBoxes._create(this.store) {
    _initializeBoxes();
  }

  /// Initialize all entity boxes
  void _initializeBoxes() {
    try {
      // Core business entities
      companyProfileBox = Box<CompanyProfileEntity>(store);
      companyBranchBox = Box<CompanyBranchProfileEntity>(store);
      customerBox = Box<CustomerEntity>(store);
      employeeBox = Box<EmployeeEntity>(store);
      userBox = Box<UserEntity>(store);

      // Product and service entities
      productBox = Box<ProductEntity>(store);
      productCategoryBox = Box<ProductCategoryEntity>(store);
      serviceBox = Box<ServiceEntity>(store);
      inventoryPartBox = Box<InventoryPartEntity>(store);
      batchBox = Box<BatchEntity>(store);

      // Sales and transaction entities
      saleEntryBox = Box<SaleEntryEntity>(store);
      saleEntryItemBox = Box<SaleEntryItemEntity>(store);
      saleEntryServiceBox = Box<SaleEntryServicesEntity>(store);
      saleReturnBox = Box<SaleReturnEntity>(store);
      saleReturnItemBox = Box<SaleReturnItemEntity>(store);
      saleReturnServiceBox = Box<SaleReturnServiceEntity>(store);
      paymentBox = Box<PaymentEntity>(store);
      heldCartBox = Box<HeldCartEntity>(store);

      // Appointment and scheduling entities
      appointmentBox = Box<AppointmentEntity>(store);
      attendanceBox = Box<AttendanceEntity>(store);
      leaveRequestBox = Box<LeaveRequestEntity>(store);
      leaveTypeBox = Box<LeaveTypeEntity>(store);
      workingHoursBox = Box<WorkingHoursEntity>(store);
      waitListBox = Box<WaitlistEntity>(store);

      // Customer engagement entities
      couponBox = Box<CouponEntity>(store);
      feedbackBox = Box<FeedbackEntity>(store);
      loyaltyPointBox = Box<LoyaltyPointEntity>(store);
      membershipBox = Box<MembershipEntity>(store);
      rewardBox = Box<RewardEntity>(store);
      subscriptionBox = Box<SubscriptionEntity>(store);

      debugPrint('ObjectBox initialized successfully with ${_getBoxCount()} entity types');
    } catch (e) {
      debugPrint('Error initializing ObjectBox boxes: $e');
      rethrow;
    }
  }

  /// Get the total number of entity types managed by ObjectBox
  int _getBoxCount() => 26;

  /// Create an instance of ObjectBox to use throughout the app
  static Future<ObjectBoxes> create() async {
    try {
      final databasePath = await _getDatabasePath();

      debugPrint('Database Path: $databasePath');

      // Ensure the database directory exists
      await _ensureDirectoryExists(databasePath);

      // Initialize ObjectBox with the database path
      final store = await openStore(directory: databasePath);

      return ObjectBoxes._create(store);
    } catch (e) {
      debugPrint('Error creating ObjectBox instance: $e');
      rethrow;
    }
  }

  /// Get the appropriate database path for the current platform
  static Future<String> _getDatabasePath() async {
    final Directory directory = await getApplicationSupportDirectory();
    return p.join(directory.path, 'objectbox');
  }

  /// Ensure the database directory exists
  static Future<void> _ensureDirectoryExists(String path) async {
    try {
      final directory = Directory(path);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        debugPrint('Created database directory: $path');
      }
    } catch (e) {
      debugPrint('Error creating database directory: $e');
      rethrow;
    }
  }

  /// Close the ObjectBox store and clean up resources
  void close() {
    try {
      store.close();
      debugPrint('ObjectBox store closed successfully');
    } catch (e) {
      debugPrint('Error closing ObjectBox store: $e');
    }
  }

  /// Get database statistics for debugging
  Map<String, dynamic> getDatabaseStats() {
    return {
      'isOpen': !store.isClosed(),
      'companyProfiles': companyProfileBox.count(),
      'customers': customerBox.count(),
      'products': productBox.count(),
      'services': serviceBox.count(),
      'invoices': saleEntryBox.count(),
      'appointments': appointmentBox.count(),
      'employees': employeeBox.count(),
    };
  }
}