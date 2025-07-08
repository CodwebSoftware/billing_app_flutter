import 'package:billing_app_flutter/db/models/leave_type_entity.dart';
import 'package:flutter/material.dart';

class LeaveTypeFormScreen extends StatefulWidget {
  final LeaveTypeEntity? leaveType;
  final Function(LeaveTypeEntity) onSave;

  const LeaveTypeFormScreen({Key? key, this.leaveType, required this.onSave})
    : super(key: key);

  @override
  _LeaveTypeFormState createState() => _LeaveTypeFormState();
}

class _LeaveTypeFormState extends State<LeaveTypeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _maxDaysController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.leaveType?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.leaveType?.description ?? '',
    );
    _maxDaysController = TextEditingController(
      text: widget.leaveType?.maxDaysPerYear.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  widget.leaveType == null
                      ? 'Add Leave Type'
                      : 'Edit Leave Type',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Leave Type Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.label),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _maxDaysController,
                  decoration: InputDecoration(
                    labelText: 'Max Days Allowed',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.calendar_view_day),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter max days';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Save Leave Type'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final leaveType = LeaveTypeEntity(

      );
      leaveType.name = _nameController.text;
    leaveType.description = _descriptionController.text;
    leaveType.maxDaysPerYear = int.parse(_maxDaysController.text);
      leaveType.id = widget.leaveType?.id ?? 0;
      widget.onSave(leaveType);
    }
  }
}
