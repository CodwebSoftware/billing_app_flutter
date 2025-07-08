import 'package:billing_app_flutter/db/models/employee_entity.dart';
import 'package:billing_app_flutter/db/models/working_hours_entity.dart';
import 'package:billing_app_flutter/objectbox.g.dart';
import 'package:billing_app_flutter/objectboxes.dart';
import 'package:get/get.dart';

class EmployeeController extends GetxController {
  final ObjectBoxes objectBox;

  EmployeeController({required this.objectBox});

  List<WorkingHoursEntity> getWorkingHoursForEmployee(int employeeId) {
    final query =
        objectBox.workingHoursBox
            .query(WorkingHoursEntity_.employee.equals(employeeId))
            .build();
    final hours = query.find();
    query.close();
    return hours;
  }

  List<WorkingHoursEntity> getWeekdayAndEmployee({
    required int employeeId,
    required int weekday,
  }) {
    final query =
        objectBox.workingHoursBox
            .query(
              WorkingHoursEntity_.employee
                  .equals(employeeId)
                  .and(WorkingHoursEntity_.weekday.equals(weekday)),
            )
            .build();
    final hours = query.find();
    query.close();
    return hours;
  }

  int saveWorkingHours(
    int employeeId,
    WorkingHoursEntity hours, {
    PutMode? mode,
  }) {
    // Set the employee relation
    hours.employee.targetId = employeeId;
    return objectBox.workingHoursBox.put(hours, mode: mode!);
  }

  void saveWorkingHoursToEmployee(int employeeId, WorkingHoursEntity hours) {
    final employee = objectBox.employeeBox.get(employeeId);
    if (employee != null) {
      hours.employee.target = employee;
      objectBox.workingHoursBox.put(hours);
      employee.workingHours.add(hours);
      objectBox.employeeBox.put(employee);
    }
  }

  List<EmployeeEntity> getAll() {
    return objectBox.employeeBox.getAll();
  }

  List<EmployeeEntity> getEmployeeByName(String str) {
    // Build a query to find invoices where the customer matches
    final query =
    objectBox.employeeBox
        .query(
      EmployeeEntity_.name
          .startsWith(str, caseSensitive: false),
    )
        .build();

    // Execute the query and get the results
    var result = query.find();
    query.close();

    return result;
  }

  List<EmployeeEntity> getAllEmployeeByRole(String role) {
    final query =
        objectBox.employeeBox.query(EmployeeEntity_.role.equals(role)).build();
    return query.find();
  }

  EmployeeEntity? get(int id) {
    return objectBox.employeeBox.get(id);
  }

  Future<EmployeeEntity> save(EmployeeEntity emp) {
    return objectBox.employeeBox.putAndGetAsync(emp);
  }
}
