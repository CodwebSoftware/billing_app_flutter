import 'package:billing_app_flutter/db/controllers/leave_request_controller.dart';
import 'package:billing_app_flutter/db/controllers/leave_type_controller.dart';
import 'package:billing_app_flutter/db/models/leave_type_entity.dart';
import 'package:billing_app_flutter/presentation/screens/leave/leave_type_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeaveTypesScreen extends StatefulWidget {
  @override
  _LeaveTypesScreenState createState() => _LeaveTypesScreenState();
}

class _LeaveTypesScreenState extends State<LeaveTypesScreen> {
  final LeaveTypeController _leaveTypeController =
      Get.find<LeaveTypeController>();
  late List<LeaveTypeEntity> _leaveTypeEntities;

  @override
  void initState() {
    _leaveTypeEntities = _leaveTypeController.getLeaveTypes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Types'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await _showLeaveTypeForm(context);
              setState(() {});
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _leaveTypeEntities.length,
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildLeaveTypeCard(_leaveTypeEntities[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search leave types...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.1),
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      ),
      onChanged: (value) {
        // Implement search functionality
      },
    );
  }

  Widget _buildLeaveTypeCard(LeaveTypeEntity leaveType) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showLeaveTypeDetails(context, leaveType),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leaveType.name!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      leaveType.description!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text('${leaveType.maxDaysPerYear} days'),
                backgroundColor: Colors.lightBlue.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showLeaveTypeForm(BuildContext context, {LeaveTypeEntity? leaveType}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return LeaveTypeFormScreen(
          leaveType: leaveType,
          onSave: (newLeaveType) {
            int val = _leaveTypeController.saveLeaveType(newLeaveType);
            if (val > 0) {
              setState(() {});
              Navigator.pop(context);
            } else {
              Get.snackbar("Warning", "Leave type is not created.");
            }
          },
        );
      },
    );
    setState(() {
      _leaveTypeEntities = _leaveTypeController.getLeaveTypes();
    });
  }

  void _showLeaveTypeDetails(BuildContext context, LeaveTypeEntity leaveType) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(children: [SizedBox(width: 12), Text(leaveType.name!)]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(leaveType.description!, style: TextStyle(fontSize: 14)),
              SizedBox(height: 16),
              _buildDetailItem('Max Days', '${leaveType.maxDaysPerYear} days'),
              SizedBox(height: 8),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _showLeaveTypeForm(context, leaveType: leaveType);
                setState(() {});
              },
              child: Text('Edit'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  leaveType.isDeleted = true;
                  _leaveTypeController.saveLeaveType(leaveType);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${leaveType.name} deleted')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[100],
                foregroundColor: Colors.red,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          if (color != null)
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            )
          else
            Text(value),
        ],
      ),
    );
  }
}
