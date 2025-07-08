import 'package:billing_app_flutter/db/models/employee_entity.dart';
import 'package:billing_app_flutter/db/models/leave_type_entity.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class LeaveRequestEntity {
  @Id()
  int id = 0;

  DateTime? startDate;
  DateTime? endDate;
  String? reason;
  LeaveStatus? status;
  DateTime? requestDate;
  DateTime? decisionDate;
  String? decisionNotes;
  bool? isDeleted;

  final employee = ToOne<EmployeeEntity>();
  final leaveType = ToOne<LeaveTypeEntity>();
  final approver = ToOne<EmployeeEntity>(); // For managers

  LeaveRequestEntity();
}

enum LeaveStatus {
  pending,
  approved,
  rejected,
  cancelled,
}