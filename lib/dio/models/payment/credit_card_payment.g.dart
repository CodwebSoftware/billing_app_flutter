// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card_payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreditCardPayment _$CreditCardPaymentFromJson(Map<String, dynamic> json) =>
    CreditCardPayment(
      cardNumber: json['cardNumber'] as String,
      cardHolder: json['cardHolder'] as String,
      expiryDate: json['expiryDate'] as String,
      cvv: json['cvv'] as String,
    );

Map<String, dynamic> _$CreditCardPaymentToJson(CreditCardPayment instance) =>
    <String, dynamic>{
      'cardNumber': instance.cardNumber,
      'cardHolder': instance.cardHolder,
      'expiryDate': instance.expiryDate,
      'cvv': instance.cvv,
    };
