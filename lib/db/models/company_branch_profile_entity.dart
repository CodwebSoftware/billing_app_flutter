import 'package:objectbox/objectbox.dart';

@Entity()
class CompanyBranchProfileEntity {
  // Core Identification Fields
  @Id()
  int id = 0;
  String? code;
  int? companyId;
  String? branchName;
  String? branchType;

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
  String? gstIN;
  String? vatTRN;
  String? drugLicNum;
  String? fssaiLicNum;

  // Operational Settings
  String? outletGroup;
  String? warehouseId;
  String? priceLevelDefault;
  int? reorderLevel;
  String? barcodePrefix;

  // Delivery and Area Details
  String? zoneClassification;
  String? landmark;

  // Audit and Metadata
  DateTime? createdDate;
  String? createdBy;
  DateTime? lastUpdatedDate;
  String? lastUpdatedBy;
  bool? isActive;

  CompanyBranchProfileEntity();
}
