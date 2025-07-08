import 'package:billing_app_flutter/db/controllers/leave_request_controller.dart';
import 'package:billing_app_flutter/db/models/employee_entity.dart';
import 'package:billing_app_flutter/db/models/leave_request_entity.dart';
import 'package:billing_app_flutter/db/models/leave_type_entity.dart';
import 'package:billing_app_flutter/presentation/screens/leave/new_leave_request_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LeaveDashboardScreen extends StatelessWidget {
  final EmployeeEntity employee;
  final LeaveRequestController _leaveRequestController = Get.find<LeaveRequestController>();

  LeaveDashboardScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Management'),
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
      ),
      body: Expanded(child: _buildLeaveList(context)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToNewRequest(context),
        label: const Text('New Request', style: TextStyle(color: Colors.white),),
        icon: const Icon(Icons.add, color: Colors.white,),
        backgroundColor: Colors.blue.shade600,
      ),
    );
  }

  Widget _buildLeaveList(BuildContext context,) {
    final leaves = _leaveRequestController.getRequestsByEmployee(employee.id);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: leaves.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final leave = leaves[index];
        return _buildLeaveCard(context, leave);
      },
    );
  }

  Widget _buildLeaveCard(BuildContext context,LeaveRequestEntity leave) {
    final statusColor = _getStatusColor(leave.status!);
    final leaveType = leave.leaveType.target?.name ?? 'Unknown';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showLeaveDetailSheet(context, leave, leaveType),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    leaveType,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      leave.status!.name,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${DateFormat('MMM d').format(leave.startDate!)} - ${DateFormat('MMM d, y').format(leave.endDate!)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                leave.reason!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.approved:
        return Colors.green;
      case LeaveStatus.rejected:
        return Colors.red;
      case LeaveStatus.pending:
        return Colors.orange;
      case LeaveStatus.cancelled:
        return Colors.grey;
    }
  }

  void _navigateToNewRequest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewLeaveRequestScreen(
          employee: employee,
        ),
      ),
    );
  }

  void showLeaveDetailSheet(BuildContext context, LeaveRequestEntity leave, String leaveType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      leave.reason!,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(height: 10),
                _buildDetailRow('Leave Type:', leaveType),
                _buildDetailRow('From:', DateFormat('MMM d yyy').format(leave.startDate!).toString()),
                _buildDetailRow('To:', DateFormat('MMM d yyy').format(leave.endDate!).toString()),
                _buildDetailRow('Duration:', (leave.endDate!.difference(leave.startDate!).inDays + 1).toString()),
                _buildDetailRow('Status:', leave.status!.name, statusColor: Colors.green),
                _buildDetailRow('Reason:', leave.reason!),
                _buildDetailRow('Submitted On:', 'June 1, 2023'),
                _buildDetailRow('Approved By:', 'John Smith (Manager)'),
                SizedBox(height: 20),
                if (true) // Replace with your condition for showing actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Refused'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Approve action
                          Navigator.pop(context);
                        },
                        child: Text('Approved'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: statusColor ?? Colors.black,
                fontWeight: statusColor != null ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}