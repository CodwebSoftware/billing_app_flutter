import 'package:billing_app_flutter/db/models/leave_type_entity.dart';
import 'package:billing_app_flutter/objectboxes.dart';
import 'package:get/get.dart';
import 'package:objectbox/objectbox.dart';

class LeaveTypeController extends GetxController {
  final ObjectBoxes objectBox;

  LeaveTypeController({required this.objectBox});

  List<LeaveTypeEntity> getLeaveTypes() {
    return objectBox.leaveTypeBox.getAll();
  }

  LeaveTypeEntity? getLeaveTypeById(int id) {
    return objectBox.leaveTypeBox.get(id);
  }

  int saveLeaveType(LeaveTypeEntity object) {
    return objectBox.leaveTypeBox.put(object, mode: PutMode.put);
  }

  Future<List<LeaveTypeEntity>> searchLeaveTypes(String query) async {
    final allTypes = objectBox.leaveTypeBox.getAll();
    return allTypes.where((type) =>
    type.name!.toLowerCase().contains(query.toLowerCase()) ||
        type.description!.toLowerCase().contains(query.toLowerCase())).toList();
  }
}
