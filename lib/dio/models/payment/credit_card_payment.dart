import 'package:json_annotation/json_annotation.dart';

part 'credit_card_payment.g.dart';

@JsonSerializable()
class CreditCardPayment {
  final String cardNumber;
  final String cardHolder;
  final String expiryDate;
  final String cvv;

  CreditCardPayment({
    required this.cardNumber,
    required this.cardHolder,
    required this.expiryDate,
    required this.cvv,
  });

  factory CreditCardPayment.fromJson(Map<String, dynamic> json) =>
      _$CreditCardPaymentFromJson(json);

  Map<String, dynamic> toJson() => _$CreditCardPaymentToJson(this);
}