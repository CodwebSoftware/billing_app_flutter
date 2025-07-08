import 'package:objectbox/objectbox.dart';

@Entity()
class HeldCartEntity{
  @Id()
  int id = 0;
  String? holdId;
  String? itemsJson;
  String? servicesJson;
  double? invoiceDiscount;
  bool? isInvoiceDiscountPercentage;
  int? customerId;

  HeldCartEntity();
}