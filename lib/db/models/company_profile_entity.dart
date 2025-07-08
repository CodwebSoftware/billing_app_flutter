import 'package:billing_app_flutter/db/models/product_entity.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class CompanyProfileEntity {
  // Core Identification Fields
  @Id()
  int id = 0;
  int? code;
  String? name;
  String? businessType;

  //Contact Info
  String? addressLine1;
  String? addressLine2;
  String? city;
  String? state;
  String? postalCode;
  String? country;
  String? email;
  String? phone;

  // Tax and Compliance Details
  String? panNumber;
  String? gstIN;
  String? vatTRN;
  String? tinNum;
  String? companyRegNum;

  // Financial Details
  String? bankName;
  String? bankAccNum;
  String? ifscCode;
  String? currencyCode;

  // Operational Settings
  DateTime? financialYearStart;
  String? taxationModel;

  // Audit and Metadata
  DateTime? createdDate;
  String? createdBy;
  DateTime? lastUpdateDate;
  String? lastUpdateBy;

  bool? isActive;

  CompanyProfileEntity();
}
