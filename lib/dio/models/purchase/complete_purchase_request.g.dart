// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_purchase_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompletePurchaseRequest _$CompletePurchaseRequestFromJson(
  Map<String, dynamic> json,
) => CompletePurchaseRequest(
  purchaseId: json['purchaseId'] as String,
  paymentId: json['paymentId'] as String,
);

Map<String, dynamic> _$CompletePurchaseRequestToJson(
  CompletePurchaseRequest instance,
) => <String, dynamic>{
  'purchaseId': instance.purchaseId,
  'paymentId': instance.paymentId,
};
