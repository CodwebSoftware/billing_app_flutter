// Company Branch Profile Management Screen
import 'package:animate_do/animate_do.dart';
import 'package:billing_app_flutter/db/controllers/company_profile_controller.dart';
import 'package:billing_app_flutter/db/models/company_branch_profile_entity.dart';
import 'package:billing_app_flutter/presentation/screens/company/add_edit_company_branch_profile_screen.dart';
import 'package:billing_app_flutter/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CompanyBranchProfileManagementScreen extends StatefulWidget {
  const CompanyBranchProfileManagementScreen({super.key});

  @override
  State<CompanyBranchProfileManagementScreen> createState() =>
      _CompanyBranchProfileManagementScreenState();
}

class _CompanyBranchProfileManagementScreenState
    extends State<CompanyBranchProfileManagementScreen> {
  final CompanyProfileController _companyController =
      Get.find<CompanyProfileController>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterItems);
    _companyController.getCompanyBranchProfiles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _filterItems() {
    _companyController.getCompanyBranchesByName(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Branch Profiles'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
            tooltip: 'Add New Branch',
            onPressed: () => _openAddEditBranchDialog(),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.onPrimary),
            tooltip: 'Refresh',
            onPressed: _refreshBranches,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(theme),
          _buildBranchCountBar(theme),
          Expanded(
            child: Obx(() {
              return _companyController.companyBranches.isEmpty
                  ? _buildEmptyState(theme)
                  : isLargeScreen
                  ? _buildGridView(theme)
                  : _buildListView(theme);
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEditBranchDialog(),
        backgroundColor: theme.colorScheme.primary,
        child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search by branch name or code',
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _searchFocusNode.requestFocus();
                    },
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.2),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildBranchCountBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        'Showing ${_companyController.companyBranches.length} branches',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: FadeInUp(
        duration: const Duration(milliseconds: 300),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No branches found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first branch to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _openAddEditBranchDialog(),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Add Branch'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _refreshBranches,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _companyController.companyBranches.length,
        itemBuilder:
            (context, index) => FadeInUp(
              delay: Duration(milliseconds: index * 100),
              child: _buildBranchCard(
                theme,
                _companyController.companyBranches[index],
              ),
            ),
      ),
    );
  }

  Widget _buildGridView(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _refreshBranches,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _companyController.companyBranches.length,
        itemBuilder:
            (context, index) => FadeInUp(
              delay: Duration(milliseconds: index * 100),
              child: _buildBranchCard(
                theme,
                _companyController.companyBranches[index],
              ),
            ),
      ),
    );
  }

  Widget _buildBranchCard(ThemeData theme, CompanyBranchProfileEntity branch) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openDashboardScreen(branch: branch),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      branch.branchName?.isNotEmpty ?? false
                          ? branch.branchName![0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
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
                          branch.branchName ?? 'Unknown',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (branch.code?.isNotEmpty ?? false)
                          Text(
                            'Code: ${branch.code}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (branch.email?.isNotEmpty ?? false)
                _buildDetailRow(theme, Icons.email_outlined, branch.email!),
              if (branch.phone?.isNotEmpty ?? false)
                _buildDetailRow(theme, Icons.phone_outlined, branch.phone!),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    tooltip: 'Edit Branch',
                    onPressed: () => _openAddEditBranchDialog(branch: branch),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    tooltip: 'Delete Branch',
                    onPressed: () => _deleteBranch(branch),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDashboardScreen({
    CompanyBranchProfileEntity? branch,
  }) async {
    _companyController.selectedCompanyBranch.value = branch!;
    await Get.to(DashboardScreen());
    setState(() {});
  }

  Future<void> _openAddEditBranchDialog({
    CompanyBranchProfileEntity? branch,
  }) async {
    _companyController.selectedCompanyBranch.value =
        branch ?? CompanyBranchProfileEntity();
    await Get.dialog(const AddEditCompanyBranchProfileScreen());
    setState(() {});
  }

  Future<void> _refreshBranches() async {
    _searchController.clear();
    await _companyController.getCompanyBranchProfiles();
  }

  void _deleteBranch(CompanyBranchProfileEntity branch) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Branch'),
        content: Text('Are you sure you want to delete ${branch.branchName}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              branch.isActive = false;
              _companyController.saveCompanyBranchProfile(branch);
              setState(() {});
              Get.back();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Branch deleted successfully'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
