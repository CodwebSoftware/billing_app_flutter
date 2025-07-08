import 'package:billing_app_flutter/db/controllers/employee_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:billing_app_flutter/db/models/employee_entity.dart';
import 'package:billing_app_flutter/presentation/screens/employee/add_edit_employee_screen.dart';
import 'package:billing_app_flutter/presentation/screens/employee/working_hours_screen.dart';
import 'package:billing_app_flutter/presentation/screens/leave/leave_dashboard_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final EmployeeController _employeeController = Get.find<EmployeeController>();

  final TextEditingController _searchController = TextEditingController();

  List<EmployeeEntity> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    List<EmployeeEntity> denylist = _employeeController.getEmployeeByName(
      _searchController.text,
    );
    setState(() {
      _employees = denylist;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Employee',
            onPressed: _navigateToAddEmployee,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _employees.isEmpty
                ? Center(
                  child: Text(
                    'No employees found',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
                : isLargeScreen
                ? _buildGridView()
                : _buildListView(),
      ),
    );
  }

  Widget _buildListView() {
    return RefreshIndicator(
      onRefresh: _loadEmployees,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _employees.length,
        itemBuilder: (context, index) => _buildEmployeeCard(_employees[index]),
      ),
    );
  }

  Widget _buildGridView() {
    return RefreshIndicator(
      onRefresh: _loadEmployees,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          childAspectRatio: 4 / 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _employees.length,
        itemBuilder: (context, index) => _buildEmployeeCard(_employees[index]),
      ),
    );
  }

  Widget _buildEmployeeCard(EmployeeEntity employee) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showEmployeeDetails(employee),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      employee.name![0],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.name!,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          employee.role!,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton(
                    icon: Icons.work_off_outlined,
                    tooltip: 'Leave Details',
                    onPressed:
                        () => Get.to(LeaveDashboardScreen(employee: employee)),
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.schedule,
                    tooltip: 'Working Hours',
                    onPressed: () => _navigateToWorkingHours(employee),
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.edit,
                    tooltip: 'Edit',
                    onPressed: () => _navigateToEditEmployee(employee),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      color: Theme.of(context).colorScheme.primary,
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  _navigateToAddEmployee() async {
    bool value = await Get.dialog(const AddEditEmployeeScreen());
    if (value) {
      await _loadEmployees();
      setState(() {});
    }
  }

  void _navigateToEditEmployee(EmployeeEntity employee) async {
    await Get.dialog(AddEditEmployeeScreen(employee: employee));
    await _loadEmployees();
  }

  void _navigateToWorkingHours(EmployeeEntity employee) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkingHoursScreen(employee: employee),
      ),
    );
  }

  void _showEmployeeDetails(EmployeeEntity employee) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name!,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Email', employee.email!),
                    _buildDetailRow('Phone', employee.phone!),
                    _buildDetailRow('Specialty', employee.specialty!),
                    _buildDetailRow('Role', employee.role!),
                    _buildDetailRow(
                      'Status',
                      employee.isActive! ? 'Active' : 'Inactive',
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Close',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
