
import 'package:json_annotation/json_annotation.dart';

part 'renew_license_request.g.dart';

@JsonSerializable()
class RenewLicenseRequest {
  final String licenseKey;
  final int renewalDurationMonths;
  final int? newAmount;

  RenewLicenseRequest({
    required this.licenseKey,
    required this.renewalDurationMonths,
    this.newAmount,
  });

  factory RenewLicenseRequest.fromJson(Map<String, dynamic> json) =>
      _$RenewLicenseRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RenewLicenseRequestToJson(this);
}