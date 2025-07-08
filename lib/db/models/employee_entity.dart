
import 'package:billing_app_flutter/db/models/attendance_entity.dart';
import 'package:billing_app_flutter/db/models/leave_request_entity.dart';
import 'package:billing_app_flutter/db/models/working_hours_entity.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class EmployeeEntity {
  @Id()
  int id = 0;
  String? name;
  String? email;
  String? phone;
  String? specialty;
  String? role;
  DateTime? joiningDate;
  int? totalLeavesAllowed;
  int? leavesTaken;

  bool? isDeleted;
  bool? isActive;

  final workingHours = ToMany<WorkingHoursEntity>();
  final attendanceRecords = ToMany<AttendanceEntity>();
  final leaveRequests = ToMany<LeaveRequestEntity>();
  final approvedLeaveRequests = ToMany<LeaveRequestEntity>();



  EmployeeEntity();
}
