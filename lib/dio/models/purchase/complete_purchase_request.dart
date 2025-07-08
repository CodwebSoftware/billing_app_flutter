import 'package:json_annotation/json_annotation.dart';

part 'complete_purchase_request.g.dart';

@JsonSerializable()
class CompletePurchaseRequest {
  final String purchaseId;
  final String paymentId;

  CompletePurchaseRequest({
    required this.purchaseId,
    required this.paymentId,
  });

  factory CompletePurchaseRequest.fromJson(Map<String, dynamic> json) =>
      _$CompletePurchaseRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CompletePurchaseRequestToJson(this);
}