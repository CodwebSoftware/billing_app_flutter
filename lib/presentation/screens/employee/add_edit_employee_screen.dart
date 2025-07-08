import 'package:billing_app_flutter/db/controllers/employee_controller.dart';
import 'package:billing_app_flutter/db/models/employee_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEditEmployeeScreen extends StatefulWidget {
  final EmployeeEntity? employee;

  const AddEditEmployeeScreen({super.key, this.employee});

  @override
  _AddEditEmployeeScreenState createState() => _AddEditEmployeeScreenState();
}

class _AddEditEmployeeScreenState extends State<AddEditEmployeeScreen> {
  final EmployeeController _employeeController = Get.find<EmployeeController>();

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _specialtyController;
  late TextEditingController _roleController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employee?.name ?? '');
    _emailController = TextEditingController(
      text: widget.employee?.email ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.employee?.phone ?? '',
    );
    _specialtyController = TextEditingController(
      text: widget.employee?.specialty ?? '',
    );
    _roleController = TextEditingController(text: widget.employee?.role ?? '');
    _isActive = widget.employee?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialtyController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text(widget.employee == null ? 'Add Employee' : 'Edit Employee'),
      ),
      content: Container(
        width: 350,
        height: 450,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _specialtyController,
                decoration: const InputDecoration(labelText: 'Specialty'),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              SizedBox(height: 15),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                child: const Text('Save'),
                onPressed: _saveEmployee,
              ),
              if (widget.employee != null) ...[
                const SizedBox(height: 10),
                OutlinedButton(
                  child: Text('Delete'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: _deleteEmployee,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveEmployee() async {
    if (_formKey.currentState?.validate() ?? false) {
      final employee = widget.employee ?? EmployeeEntity();

      employee.name = _nameController.text;
      employee.email = _emailController.text;
      employee.phone = _phoneController.text;
      employee.specialty = _specialtyController.text;
      employee.role = _roleController.text;
      employee.isActive = _isActive;

      EmployeeEntity emp = await _employeeController.save(employee);
      if (emp.id.isNullOrBlank!) {
        Get.back(result: false);
      } else {
        Get.back(result: true);
      }
    }
  }

  Future<void> _deleteEmployee() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Employee'),
            content: const Text(
              'Are you sure you want to delete this employee?',
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
      widget.employee!.isDeleted = true;
      _employeeController.save(widget.employee!);
      Navigator.pop(context);
    }
  }
}
