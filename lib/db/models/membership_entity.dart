import 'package:billing_app_flutter/db/models/customer_entity.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class MembershipEntity {
  @Id()
  int id = 0;
  String? type; // e.g., Gold, Silver
  double? discount;
  DateTime? startDate;
  DateTime? endDate;

  final customer = ToOne<CustomerEntity>();

  MembershipEntity();
}