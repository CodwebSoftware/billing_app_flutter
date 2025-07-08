import 'package:billing_app_flutter/db/models/feedback_entity.dart';
import 'package:billing_app_flutter/db/models/sale_entry_entity.dart';
import 'package:billing_app_flutter/db/models/membership_entity.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class CustomerEntity {
  // Core Identification Fields
  @Id()
  int id = 0;
  String? code;
  String? name;
  String? type;

  // Contact Information
  String? email;
  String? phone;
  String? addressLine1;
  String? addressLine2;
  String? city;
  String? state;
  String? postalCode;
  String? country;

  // Financial and Transactional Details
  double? creditLimit;
  int? creditDays;
  double? outstandingBalance;
  String? paymentTerms;
  String? bankDetails;
  String? panNumber;
  String? gstIN;

  // CRM and Loyalty Fields
  String? loyaltyID;
  int? loyaltyPoints;
  String? customerGroup;
  String? priceLevel;
  double? discountPercentage;

  // Personal and Engagement Details
  @Property(type: PropertyType.date)
  DateTime? dateOfBirth;
  @Property(type: PropertyType.date)
  DateTime? anniversaryDate;
  String? gender;

  // Audit and Metadata
  DateTime? createdAt;
  DateTime? createdBy;
  DateTime? lastUpdateDate;
  DateTime? lastUpdatedBy;
  String? outletId;
  bool? isActive;

  final invoices = ToMany<SaleEntryEntity>();
  final feedbacks = ToMany<FeedbackEntity>();
  final memberships = ToMany<MembershipEntity>();

  CustomerEntity();

  static bool isTodayBirthday(DateTime dateOfBirth) {
    final today = DateTime.now();
    return today.day == dateOfBirth.day && today.month == dateOfBirth.month;
  }
}
