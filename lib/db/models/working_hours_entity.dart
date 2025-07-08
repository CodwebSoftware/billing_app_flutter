import 'package:billing_app_flutter/db/models/employee_entity.dart';
import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class WorkingHoursEntity {
  @Id()
  int id = 0;

  int? weekday;
  int? startHour;
  int? startMinute;
  int? endHour;
  int? endMinute;
  bool? isDeleted;

  final employee = ToOne<EmployeeEntity>();

  WorkingHoursEntity();

  TimeOfDay get startTime => TimeOfDay(hour: startHour!, minute: startMinute!);
  TimeOfDay get endTime => TimeOfDay(hour: endHour!, minute: endMinute!);
}