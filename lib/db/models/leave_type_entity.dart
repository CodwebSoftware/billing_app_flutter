import 'package:billing_app_flutter/db/models/leave_request_entity.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class LeaveTypeEntity {
  @Id()
  int id = 0;

  String? name;
  String? description;
  int? maxDaysPerYear;
  bool? requiresApproval;

  bool? isDeleted;

  final leaveRequests = ToMany<LeaveRequestEntity>();

  LeaveTypeEntity();
}