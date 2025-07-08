import 'package:billing_app_flutter/db/models/customer_entity.dart';
import 'package:billing_app_flutter/db/models/service_entity.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class WaitlistEntity {
  @Id()
  int id = 0;

  DateTime? preferredDate;
  String? notes;

  final services = ToMany<ServiceEntity>();
  final customer = ToOne<CustomerEntity>();

  WaitlistEntity();
}