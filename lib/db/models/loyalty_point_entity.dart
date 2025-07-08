import 'package:billing_app_flutter/db/models/customer_entity.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class LoyaltyPointEntity {
  @Id()
  int id = 0;

  int? points;
  String? reason = "";

  DateTime? earnedDate;
  DateTime? expiryDate;

  final customer = ToOne<CustomerEntity>();

  LoyaltyPointEntity();
}