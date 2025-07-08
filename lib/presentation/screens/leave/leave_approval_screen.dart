import 'package:billing_app_flutter/db/controllers/leave_request_controller.dart';
import 'package:billing_app_flutter/db/models/employee_entity.dart';
import 'package:billing_app_flutter/db/models/leave_request_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LeaveApprovalScreen extends StatelessWidget {
  final EmployeeEntity manager;
final LeaveRequestController _leaveRequestController = Get.find<LeaveRequestController>();

   LeaveApprovalScreen({
    required this.manager,
  });

  @override
  Widget build(BuildContext context) {
    final List<LeaveRequestEntity> pendingLeaves = _leaveRequestController.getPendingRequests();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals'),
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
      body: pendingLeaves.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No pending leave requests',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: pendingLeaves.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final leave = pendingLeaves[index];
          return _buildApprovalCard(leave, context);
        },
      ),
    );
  }

  Widget _buildApprovalCard(LeaveRequestEntity leave, BuildContext context) {
    final employee = leave.employee.target;
    final leaveType = leave.leaveType.target;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(employee!.name!.substring(0, 1) ?? '?'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${employee.name}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      leaveType?.name ?? 'Unknown Type',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${DateFormat('MMM d').format(leave.startDate!)} - ${DateFormat('MMM d, y').format(leave.endDate!)}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              leave.reason!,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _processLeave(leave, LeaveStatus.rejected, context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _processLeave(leave, LeaveStatus.approved, context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processLeave(
      LeaveRequestEntity leave, LeaveStatus status, BuildContext context) async {
    final notes = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${status.toString().split('.').last} Leave'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to ${status.toString().split('.').last.toLowerCase()} this leave request?'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'Notes entered'),
            child: Text(status.toString().split('.').last),
          ),
        ],
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Leave request ${status.toString().split('.').last.toLowerCase()}'),
        backgroundColor: status == LeaveStatus.approved ? Colors.green : Colors.red,
      ),
    );
  }
}