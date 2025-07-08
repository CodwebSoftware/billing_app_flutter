import 'package:json_annotation/json_annotation.dart';

part 'license_model.g.dart';

@JsonSerializable()
class LicenseModel {
  final String id;
  final String licenseKey;
  final String softwareId;
  final String platform;
  final String userEmail;
  final String mobile;
  @JsonKey(fromJson: _fromJson, toJson: _toJson)
  final DateTime issueDate;
  @JsonKey(fromJson: _fromJson, toJson: _toJson)
  final DateTime expiryDate;
  final bool isActive;
  final int amount;

  LicenseModel({
    required this.id,
    required this.licenseKey,
    required this.softwareId,
    required this.platform,
    required this.userEmail,
    required this.mobile,
    required this.issueDate,
    required this.expiryDate,
    required this.isActive,
    required this.amount,
  });

  factory LicenseModel.fromJson(Map<String, dynamic> json) =>
      _$LicenseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LicenseModelToJson(this);

  static DateTime _fromJson(String date) => DateTime.parse(date);
  static String _toJson(DateTime date) => date.toIso8601String();
}