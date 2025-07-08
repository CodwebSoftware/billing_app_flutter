import 'package:objectbox/objectbox.dart';
import 'sale_entry_entity.dart';

@Entity()
class PaymentEntity {
  @Id()
  int id  = 0;
  DateTime? date;
  double? paidAmount;
  double? refundAmount;
  double? remainingAmount;
  double? refund;
  bool? isDeleted;

  final invoice = ToOne<SaleEntryEntity>();

  PaymentEntity();
}
