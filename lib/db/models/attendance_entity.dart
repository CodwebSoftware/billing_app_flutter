import 'package:billing_app_flutter/db/models/employee_entity.dart';
import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class AttendanceEntity {
  @Id()
  int id = 0;

  DateTime? date;
   TimeOfDay? checkIn;
   TimeOfDay? checkOut;
   String? notes;

  bool? isDeleted;

  final employee = ToOne<EmployeeEntity>();

  AttendanceEntity();
}