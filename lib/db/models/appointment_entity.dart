import 'package:billing_app_flutter/db/models/customer_entity.dart';
import 'package:billing_app_flutter/db/models/employee_entity.dart';
import 'package:billing_app_flutter/db/models/service_entity.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class AppointmentEntity {
  @Id()
  int id = 0;
  DateTime? dateTime;
  String? notes;
  String? type;
  String? status;
  bool? sendReminder;
  bool? isDeleted;

  final client = ToOne<CustomerEntity>();
  final employees = ToMany<EmployeeEntity>();
  final services = ToMany<ServiceEntity>();


  AppointmentEntity();
}