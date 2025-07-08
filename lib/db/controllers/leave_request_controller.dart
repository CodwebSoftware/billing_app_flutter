import 'package:billing_app_flutter/db/models/employee_entity.dart';
import 'package:billing_app_flutter/db/models/leave_request_entity.dart';
import 'package:billing_app_flutter/db/models/leave_type_entity.dart';
import 'package:billing_app_flutter/objectboxes.dart';
import 'package:get/get.dart';

class LeaveRequestController extends GetxController {
  final ObjectBoxes objectBox;
  LeaveRequestController({required this.objectBox});

  // Additional specific methods for LeaveRequest
  Future<List<LeaveRequestEntity>> getLeaveRequests() async {
    return objectBox.leaveRequestBox.getAll();
  }

  Future<LeaveRequestEntity?> getLeaveRequestById(int id) async {
    return objectBox.leaveRequestBox.get(id);
  }

  Future<int> createLeaveRequest({
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    required EmployeeEntity employee,
    required LeaveTypeEntity leaveType,
    LeaveStatus status = LeaveStatus.pending,
    DateTime? decisionDate,
    String? decisionNotes,
    EmployeeEntity? approver,
  }) async {
    final request = LeaveRequestEntity(
    );
    request.startDate = startDate;
    request.endDate = endDate;
    request. reason = reason;
    request.status = status;
    request. requestDate = DateTime.now();
    request.decisionDate = decisionDate;
    request. decisionNotes = decisionNotes;


    request.employee.target = employee;
    request.leaveType.target = leaveType;
    if (approver != null) {
      request.approver.target = approver;
    }

    return objectBox.leaveRequestBox.put(request);
  }


  List<LeaveRequestEntity> getRequestsByEmployee(int employeeId) {
    return objectBox.leaveRequestBox
        .getAll()
        .where((request) => request.employee.target?.id == employeeId)
        .toList();
  }

  List<LeaveRequestEntity> getPendingRequests() {
    return objectBox.leaveRequestBox
        .getAll()
        .where((request) => request.status == LeaveStatus.pending)
        .toList();
  }
}
