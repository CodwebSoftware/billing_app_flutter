// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'license_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LicenseModel _$LicenseModelFromJson(Map<String, dynamic> json) => LicenseModel(
  id: json['id'] as String,
  licenseKey: json['licenseKey'] as String,
  softwareId: json['softwareId'] as String,
  platform: json['platform'] as String,
  userEmail: json['userEmail'] as String,
  mobile: json['mobile'] as String,
  issueDate: LicenseModel._fromJson(json['issueDate'] as String),
  expiryDate: LicenseModel._fromJson(json['expiryDate'] as String),
  isActive: json['isActive'] as bool,
  amount: (json['amount'] as num).toInt(),
);

Map<String, dynamic> _$LicenseModelToJson(LicenseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'licenseKey': instance.licenseKey,
      'softwareId': instance.softwareId,
      'platform': instance.platform,
      'userEmail': instance.userEmail,
      'mobile': instance.mobile,
      'issueDate': LicenseModel._toJson(instance.issueDate),
      'expiryDate': LicenseModel._toJson(instance.expiryDate),
      'isActive': instance.isActive,
      'amount': instance.amount,
    };
