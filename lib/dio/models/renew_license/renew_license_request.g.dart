// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'renew_license_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RenewLicenseRequest _$RenewLicenseRequestFromJson(Map<String, dynamic> json) =>
    RenewLicenseRequest(
      licenseKey: json['licenseKey'] as String,
      renewalDurationMonths: (json['renewalDurationMonths'] as num).toInt(),
      newAmount: (json['newAmount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RenewLicenseRequestToJson(
  RenewLicenseRequest instance,
) => <String, dynamic>{
  'licenseKey': instance.licenseKey,
  'renewalDurationMonths': instance.renewalDurationMonths,
  'newAmount': instance.newAmount,
};
