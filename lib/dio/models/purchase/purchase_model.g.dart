// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseModel _$PurchaseModelFromJson(Map<String, dynamic> json) =>
    PurchaseModel(
      id: json['id'] as String,
      email: json['email'] as String,
      softwareId: json['softwareId'] as String,
      platform: json['platform'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      paymentId: json['paymentId'] as String?,
      licenseKey: json['licenseKey'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PurchaseModelToJson(PurchaseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'softwareId': instance.softwareId,
      'platform': instance.platform,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.status,
      'paymentId': instance.paymentId,
      'licenseKey': instance.licenseKey,
      'createdAt': instance.createdAt.toIso8601String(),
    };
