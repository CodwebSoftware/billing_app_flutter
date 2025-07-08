import 'package:billing_app_flutter/db/controllers/leave_request_controller.dart';
import 'package:billing_app_flutter/db/controllers/leave_type_controller.dart';
import 'package:billing_app_flutter/db/models/employee_entity.dart';
import 'package:billing_app_flutter/db/models/leave_request_entity.dart';
import 'package:billing_app_flutter/db/models/leave_type_entity.dart';
import 'package:billing_app_flutter/presentation/screens/leave/leave_types_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NewLeaveRequestScreen extends StatefulWidget {
  final EmployeeEntity employee;

  const NewLeaveRequestScreen({required this.employee});

  @override
  _NewLeaveRequestScreenState createState() => _NewLeaveRequestScreenState();
}

class _NewLeaveRequestScreenState extends State<NewLeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _startDate;
  late DateTime _endDate;
  final _reasonController = TextEditingController();
  LeaveTypeEntity? _selectedLeaveType;

  final LeaveTypeController _leaveTypeController =
      Get.find<LeaveTypeController>();
  final LeaveRequestController _leaveRequestController =
      Get.find<LeaveRequestController>();

  var leaveTypes = <LeaveTypeEntity>[];

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 1));
    leaveTypes = _leaveTypeController.getLeaveTypes();
    _selectedLeaveType = leaveTypes.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Leave Request'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(12),
            width: 170,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black54, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: TextButton(
              onPressed: () {
                Get.to(LeaveTypesScreen());
              },
              child: Text("Add Leave Type", style: TextStyle(fontSize: 19)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leave Type Dropdown
              _buildLeaveTypeDropdown(leaveTypes),
              const SizedBox(height: 20),
              // Date Range Picker
              _buildDateRangePicker(),
              const SizedBox(height: 20),
              // Reason Field
              _buildReasonField(),
              const SizedBox(height: 30),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitRequest,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blue.shade600,
                  ),
                  child: const Text(
                    'Submit Request',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveTypeDropdown(List<LeaveTypeEntity> leaveTypes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Leave Type',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<LeaveTypeEntity>(
          value: _selectedLeaveType ?? leaveTypes.firstOrNull,
          items:
              leaveTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type.name!));
              }).toList(),
          onChanged: (value) => setState(() => _selectedLeaveType = value),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator:
              (value) => value == null ? 'Please select a leave type' : null,
        ),
      ],
    );
  }

  Widget _buildDateRangePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date Range',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDatePicker(
                'Start Date',
                _startDate,
                (date) => setState(() {
                  _startDate = date;
                  if (_endDate.isBefore(_startDate)) {
                    _endDate = _startDate.add(const Duration(days: 1));
                  }
                }),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDatePicker(
                'End Date',
                _endDate,
                (date) => setState(() => _endDate = date),
                firstDate: _startDate,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime selectedDate,
    ValueChanged<DateTime> onDateSelected, {
    DateTime? firstDate,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: firstDate ?? DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.blue.shade600,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) onDateSelected(date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(DateFormat('MMM d, y').format(selectedDate)),
      ),
    );
  }

  Widget _buildReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reason',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _reasonController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter reason for leave...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator:
              (value) =>
                  value?.isEmpty ?? true ? 'Please enter a reason' : null,
        ),
      ],
    );
  }

  void _submitRequest() async {
    if (_formKey.currentState?.validate() ?? false) {
      int val = await _leaveRequestController.createLeaveRequest(
        startDate: _startDate,
        endDate: _endDate,
        reason: _reasonController.text,
        employee: widget.employee,
        leaveType: _selectedLeaveType!,
      );

      if (val > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leave request submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leave request Not submitted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
