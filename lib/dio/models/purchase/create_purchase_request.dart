import 'package:json_annotation/json_annotation.dart';

part 'create_purchase_request.g.dart';

@JsonSerializable()
class CreatePurchaseRequest {
  final String email;
  final String softwareId;
  final String platform;
  final double amount;
  final String currency;

  CreatePurchaseRequest({
    required this.email,
    required this.softwareId,
    required this.platform,
    required this.amount,
    required this.currency,
  });

  factory CreatePurchaseRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePurchaseRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePurchaseRequestToJson(this);
}