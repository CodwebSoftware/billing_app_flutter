// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_transfer_payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BankTransferPayment _$BankTransferPaymentFromJson(Map<String, dynamic> json) =>
    BankTransferPayment(
      accountNumber: json['accountNumber'] as String,
      accountName: json['accountName'] as String,
      bankName: json['bankName'] as String,
      routingNumber: json['routingNumber'] as String,
    );

Map<String, dynamic> _$BankTransferPaymentToJson(
  BankTransferPayment instance,
) => <String, dynamic>{
  'accountNumber': instance.accountNumber,
  'accountName': instance.accountName,
  'bankName': instance.bankName,
  'routingNumber': instance.routingNumber,
};
