import 'package:json_annotation/json_annotation.dart';

part 'check_payment.g.dart';

@JsonSerializable()
class CheckPayment {
  final String checkNumber;
  final String bankName;
  final DateTime issueDate;

  CheckPayment({
    required this.checkNumber,
    required this.bankName,
    required this.issueDate,
  });

  factory CheckPayment.fromJson(Map<String, dynamic> json) =>
      _$CheckPaymentFromJson(json);
  Map<String, dynamic> toJson() => _$CheckPaymentToJson(this);
}