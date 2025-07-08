// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CashPayment _$CashPaymentFromJson(Map<String, dynamic> json) => CashPayment(
  receiptNumber: json['receiptNumber'] as String,
  paymentDate: DateTime.parse(json['paymentDate'] as String),
);

Map<String, dynamic> _$CashPaymentToJson(CashPayment instance) =>
    <String, dynamic>{
      'receiptNumber': instance.receiptNumber,
      'paymentDate': instance.paymentDate.toIso8601String(),
    };
