// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_purchase_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePurchaseRequest _$CreatePurchaseRequestFromJson(
  Map<String, dynamic> json,
) => CreatePurchaseRequest(
  email: json['email'] as String,
  softwareId: json['softwareId'] as String,
  platform: json['platform'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
);

Map<String, dynamic> _$CreatePurchaseRequestToJson(
  CreatePurchaseRequest instance,
) => <String, dynamic>{
  'email': instance.email,
  'softwareId': instance.softwareId,
  'platform': instance.platform,
  'amount': instance.amount,
  'currency': instance.currency,
};
