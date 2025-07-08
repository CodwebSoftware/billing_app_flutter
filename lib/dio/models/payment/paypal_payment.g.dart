// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paypal_payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PayPalPayment _$PayPalPaymentFromJson(Map<String, dynamic> json) =>
    PayPalPayment(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$PayPalPaymentToJson(PayPalPayment instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};
