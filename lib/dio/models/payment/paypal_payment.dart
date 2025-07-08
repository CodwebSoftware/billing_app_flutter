import 'package:json_annotation/json_annotation.dart';

part 'paypal_payment.g.dart';

@JsonSerializable()
class PayPalPayment {
  final String email;
  final String password;

  PayPalPayment({
    required this.email,
    required this.password,
  });

  factory PayPalPayment.fromJson(Map<String, dynamic> json) =>
      _$PayPalPaymentFromJson(json);

  Map<String, dynamic> toJson() => _$PayPalPaymentToJson(this);
}