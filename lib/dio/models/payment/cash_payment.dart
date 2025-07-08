

import 'package:json_annotation/json_annotation.dart';

part 'cash_payment.g.dart';

@JsonSerializable()
class CashPayment {
  final String receiptNumber;
  final DateTime paymentDate;

  CashPayment({
    required this.receiptNumber,
    required this.paymentDate,
  });

  factory CashPayment.fromJson(Map<String, dynamic> json) =>
      _$CashPaymentFromJson(json);
  Map<String, dynamic> toJson() => _$CashPaymentToJson(this);
}