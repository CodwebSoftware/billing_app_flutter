
import 'package:billing_app_flutter/db/controllers/employee_controller.dart';
import 'package:billing_app_flutter/db/models/employee_entity.dart';
import 'package:billing_app_flutter/db/models/working_hours_entity.dart';
import 'package:billing_app_flutter/objectbox.g.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkingHoursScreen extends StatefulWidget {
  final EmployeeEntity employee;

  const WorkingHoursScreen({Key? key, required this.employee})
    : super(key: key);

  @override
  _WorkingHoursScreenState createState() => _WorkingHoursScreenState();
}

class _WorkingHoursScreenState extends State<WorkingHoursScreen> {
  final EmployeeController _employeeController = Get.find<EmployeeController>();

  List<WorkingHoursEntity> _workingHours = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkingHours();
  }

  Future<void> _loadWorkingHours() async {
    setState(() => _isLoading = true);
    _workingHours = _employeeController.getWorkingHoursForEmployee(
      widget.employee.id,
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.employee.name}\'s Working Hours'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddWorkingHoursDialog(),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _workingHours.isEmpty
              ? const Center(child: Text('No working hours defined'))
              : ListView.builder(
                itemCount: _workingHours.length,
                itemBuilder: (context, index) {
                  final hours = _workingHours[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: Text(_getWeekdayName(hours.weekday!)),
                      subtitle: Text(
                        '${hours.startTime.format(context)} - ${hours.endTime.format(context)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteWorkingHours(hours),
                      ),
                    ),
                  );
                },
              ),
    );
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Day $weekday';
    }
  }

  Future<void> _showAddWorkingHoursDialog() async {
    int? selectedWeekday;
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Add Working Hours'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: selectedWeekday,
                      decoration: const InputDecoration(labelText: 'Weekday'),
                      items:
                          List.generate(7, (index) => index + 1).map((day) {
                            return DropdownMenuItem(
                              value: day,
                              child: Text(_getWeekdayName(day)),
                            );
                          }).toList(),
                      onChanged:
                          (value) => setState(() => selectedWeekday = value),
                      validator: (value) => value == null ? 'Required' : null,
                    ),
                    SizedBox(height: 20),
                    ListTile(
                      title: const Text('Start Time'),
                      trailing: Text(startTime?.format(context) ?? 'Select'),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() => startTime = time);
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      title: const Text('End Time'),
                      trailing: Text(endTime?.format(context) ?? 'Select'),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() => endTime = time);
                        }
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  TextButton(
                    child: const Text('Save'),
                    onPressed: () {
                      if (selectedWeekday != null &&
                          startTime != null &&
                          endTime != null) {
                        Navigator.pop(context, true);
                      }
                    },
                  ),
                ],
              );
            },
          ),
    );

    if (result ?? false) {
      final newHours = WorkingHoursEntity(

      );
      newHours.weekday = selectedWeekday!;
    newHours.  startHour =startTime!.hour;
    newHours.startMinute = startTime!.minute;
    newHours. endHour = endTime!.hour;
    newHours.endMinute = endTime!.minute;
      List<WorkingHoursEntity> workingHoursEntities = _employeeController
          .getWeekdayAndEmployee(
            employeeId: widget.employee.id,
            weekday: newHours.weekday!,
          );
      if (workingHoursEntities.isNotEmpty) {
        WorkingHoursEntity entity = workingHoursEntities.first;
        newHours.id = entity.id;
        _employeeController.saveWorkingHours(
          widget.employee.id,
          newHours,
          mode: PutMode.update,
        );
      } else {
        _employeeController.saveWorkingHours(
          widget.employee.id,
          newHours,
          mode: PutMode.insert,
        );
      }
      _loadWorkingHours();
    }
  }

  Future<void> _deleteWorkingHours(WorkingHoursEntity hours) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Working Hours'),
            content: const Text(
              'Are you sure you want to delete these working hours?',
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirmed ?? false) {
      hours.isDeleted = true;
      _employeeController.saveWorkingHours(widget.employee.id, hours);
      _loadWorkingHours();
    }
  }
}
