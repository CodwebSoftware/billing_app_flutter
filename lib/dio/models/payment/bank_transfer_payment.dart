import 'package:json_annotation/json_annotation.dart';

part 'bank_transfer_payment.g.dart';

@JsonSerializable()
class BankTransferPayment {
  final String accountNumber;
  final String accountName;
  final String bankName;
  final String routingNumber;

  BankTransferPayment({
    required this.accountNumber,
    required this.accountName,
    required this.bankName,
    required this.routingNumber,
  });

  factory BankTransferPayment.fromJson(Map<String, dynamic> json) =>
      _$BankTransferPaymentFromJson(json);

  Map<String, dynamic> toJson() => _$BankTransferPaymentToJson(this);
}