import 'package:json_annotation/json_annotation.dart';

part 'purchase_model.g.dart';

@JsonSerializable()
class PurchaseModel {
  final String id;
  final String email;
  final String softwareId;
  final String platform;
  final double amount;
  final String currency;
  final String status;
  final String? paymentId;
  final String? licenseKey;
  final DateTime createdAt;

  PurchaseModel({
    required this.id,
    required this.email,
    required this.softwareId,
    required this.platform,
    required this.amount,
    required this.currency,
    required this.status,
    this.paymentId,
    this.licenseKey,
    required this.createdAt,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) =>
      _$PurchaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseModelToJson(this);
}
