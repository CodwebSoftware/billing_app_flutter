// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckPayment _$CheckPaymentFromJson(Map<String, dynamic> json) => CheckPayment(
  checkNumber: json['checkNumber'] as String,
  bankName: json['bankName'] as String,
  issueDate: DateTime.parse(json['issueDate'] as String),
);

Map<String, dynamic> _$CheckPaymentToJson(CheckPayment instance) =>
    <String, dynamic>{
      'checkNumber': instance.checkNumber,
      'bankName': instance.bankName,
      'issueDate': instance.issueDate.toIso8601String(),
    };
