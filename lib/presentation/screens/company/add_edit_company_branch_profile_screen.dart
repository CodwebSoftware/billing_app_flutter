// Add/Edit Company Branch Profile Screen
import 'package:animate_do/animate_do.dart';
import 'package:billing_app_flutter/db/controllers/company_profile_controller.dart';
import 'package:billing_app_flutter/db/models/company_branch_profile_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SaveIntent extends Intent {}

class AddEditCompanyBranchProfileScreen extends StatefulWidget {
  const AddEditCompanyBranchProfileScreen({super.key});

  @override
  State<AddEditCompanyBranchProfileScreen> createState() =>
      _AddEditCompanyBranchProfileScreenState();
}

class _AddEditCompanyBranchProfileScreenState
    extends State<AddEditCompanyBranchProfileScreen> {
  final CompanyProfileController _companyController = Get.find();
  final _formKey = GlobalKey<FormState>();

  late CompanyBranchProfileEntity branch;
  late final TextEditingController _branchNameController;
  late final TextEditingController _codeController;
  late final TextEditingController _branchTypeController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _countryController;
  late final TextEditingController _gstINController;
  late final TextEditingController _vatTRNController;
  late final TextEditingController _drugLicNumController;
  late final TextEditingController _fssaiLicNumController;
  late final TextEditingController _outletGroupController;
  late final TextEditingController _warehouseIdController;
  late final TextEditingController _priceLevelDefaultController;
  late final TextEditingController _reorderLevelController;
  late final TextEditingController _barcodePrefixController;
  late final TextEditingController _zoneClassificationController;
  late final TextEditingController _landmarkController;

  final _branchNameFocus = FocusNode();
  final _codeFocus = FocusNode();
  final _companyIdFocus = FocusNode();
  final _branchTypeFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _addressLine1Focus = FocusNode();
  final _addressLine2Focus = FocusNode();
  final _cityFocus = FocusNode();
  final _postalCodeFocus = FocusNode();
  final _countryFocus = FocusNode();
  final _gstINFocus = FocusNode();
  final _vatTRNFocus = FocusNode();
  final _drugLicNumFocus = FocusNode();
  final _fssaiLicNumFocus = FocusNode();
  final _outletGroupFocus = FocusNode();
  final _warehouseIdFocus = FocusNode();
  final _priceLevelDefaultFocus = FocusNode();
  final _reorderLevelFocus = FocusNode();
  final _barcodePrefixFocus = FocusNode();
  final _zoneClassificationFocus = FocusNode();
  final _landmarkFocus = FocusNode();
  final _saveFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    branch =
        _companyController.selectedCompanyBranch.value ??
        CompanyBranchProfileEntity();

    _branchNameController = TextEditingController(
      text: branch.branchName ?? '',
    );
    _codeController = TextEditingController(text: branch.code ?? '');
    _branchTypeController = TextEditingController(
      text: branch.branchType ?? '',
    );
    _emailController = TextEditingController(text: branch.email ?? '');
    _phoneController = TextEditingController(text: branch.phone ?? '');
    _addressLine1Controller = TextEditingController(
      text: branch.addressLine1 ?? '',
    );
    _addressLine2Controller = TextEditingController(
      text: branch.addressLine2 ?? '',
    );
    _cityController = TextEditingController(text: branch.city ?? '');
    _postalCodeController = TextEditingController(
      text: branch.postalCode ?? '',
    );
    _countryController = TextEditingController(text: branch.country ?? '');
    _gstINController = TextEditingController(text: branch.gstIN ?? '');
    _vatTRNController = TextEditingController(text: branch.vatTRN ?? '');
    _drugLicNumController = TextEditingController(
      text: branch.drugLicNum ?? '',
    );
    _fssaiLicNumController = TextEditingController(
      text: branch.fssaiLicNum ?? '',
    );
    _outletGroupController = TextEditingController(
      text: branch.outletGroup ?? '',
    );
    _warehouseIdController = TextEditingController(
      text: branch.warehouseId ?? '',
    );
    _priceLevelDefaultController = TextEditingController(
      text: branch.priceLevelDefault ?? '',
    );
    _reorderLevelController = TextEditingController(
      text: branch.reorderLevel?.toString() ?? '',
    );
    _barcodePrefixController = TextEditingController(
      text: branch.barcodePrefix ?? '',
    );
    _zoneClassificationController = TextEditingController(
      text: branch.zoneClassification ?? '',
    );
    _landmarkController = TextEditingController(text: branch.landmark ?? '');
  }

  @override
  void dispose() {
    _branchNameController.dispose();
    _codeController.dispose();
    _branchTypeController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _gstINController.dispose();
    _vatTRNController.dispose();
    _drugLicNumController.dispose();
    _fssaiLicNumController.dispose();
    _outletGroupController.dispose();
    _warehouseIdController.dispose();
    _priceLevelDefaultController.dispose();
    _reorderLevelController.dispose();
    _barcodePrefixController.dispose();
    _zoneClassificationController.dispose();
    _landmarkController.dispose();

    _branchNameFocus.dispose();
    _codeFocus.dispose();
    _companyIdFocus.dispose();
    _branchTypeFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _addressLine1Focus.dispose();
    _addressLine2Focus.dispose();
    _cityFocus.dispose();
    _postalCodeFocus.dispose();
    _countryFocus.dispose();
    _gstINFocus.dispose();
    _vatTRNFocus.dispose();
    _drugLicNumFocus.dispose();
    _fssaiLicNumFocus.dispose();
    _outletGroupFocus.dispose();
    _warehouseIdFocus.dispose();
    _priceLevelDefaultFocus.dispose();
    _reorderLevelFocus.dispose();
    _barcodePrefixFocus.dispose();
    _zoneClassificationFocus.dispose();
    _landmarkFocus.dispose();
    _saveFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNewBranch = branch.id == 0;

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
            SaveIntent(),
      },
      child: Actions(
        actions: {
          SaveIntent: CallbackAction<SaveIntent>(
            onInvoke: (intent) => _saveBranch(),
          ),
        },
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          backgroundColor: theme.colorScheme.surface,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              minWidth: 400,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: FadeInUp(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isNewBranch ? 'Add New Branch' : 'Edit Branch',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: theme.colorScheme.onSurface,
                            ),
                            onPressed: () => Get.back(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      FocusTraversalGroup(
                        policy: OrderedTraversalPolicy(),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildSectionTitle(theme, 'Branch Details'),
                              _buildTextField(
                                controller: _branchNameController,
                                focusNode: _branchNameFocus,
                                label: 'Branch Name',
                                icon: Icons.store_outlined,
                                validator:
                                    (value) =>
                                        value?.isEmpty ?? true
                                            ? 'Please enter a branch name'
                                            : null,
                                nextFocus: _codeFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _codeController,
                                focusNode: _codeFocus,
                                label: 'Branch Code',
                                icon: Icons.code,
                                nextFocus: _companyIdFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _branchTypeController,
                                focusNode: _branchTypeFocus,
                                label: 'Branch Type',
                                icon: Icons.category_outlined,
                                nextFocus: _emailFocus,
                              ),
                              const SizedBox(height: 24),
                              _buildSectionTitle(theme, 'Contact Details'),
                              _buildTextField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                label: 'Email',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                nextFocus: _phoneFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _phoneController,
                                focusNode: _phoneFocus,
                                label: 'Phone',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                nextFocus: _addressLine1Focus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _addressLine1Controller,
                                focusNode: _addressLine1Focus,
                                label: 'Address Line 1',
                                icon: Icons.location_on_outlined,
                                nextFocus: _addressLine2Focus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _addressLine2Controller,
                                focusNode: _addressLine2Focus,
                                label: 'Address Line 2',
                                icon: Icons.location_on_outlined,
                                nextFocus: _cityFocus,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _cityController,
                                      focusNode: _cityFocus,
                                      label: 'City',
                                      icon: Icons.location_city,
                                      nextFocus: _postalCodeFocus,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _postalCodeController,
                                      focusNode: _postalCodeFocus,
                                      label: 'Postal Code',
                                      icon: Icons.local_post_office_outlined,
                                      keyboardType: TextInputType.number,
                                      nextFocus: _countryFocus,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _countryController,
                                focusNode: _countryFocus,
                                label: 'Country',
                                icon: Icons.flag_outlined,
                                nextFocus: _gstINFocus,
                              ),
                              const SizedBox(height: 24),
                              _buildSectionTitle(theme, 'Tax and Compliance'),
                              _buildTextField(
                                controller: _gstINController,
                                focusNode: _gstINFocus,
                                label: 'GSTIN',
                                icon: Icons.description_outlined,
                                nextFocus: _vatTRNFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _vatTRNController,
                                focusNode: _vatTRNFocus,
                                label: 'VAT TRN',
                                icon: Icons.description_outlined,
                                nextFocus: _drugLicNumFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _drugLicNumController,
                                focusNode: _drugLicNumFocus,
                                label: 'Drug License Number',
                                icon: Icons.description_outlined,
                                nextFocus: _fssaiLicNumFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _fssaiLicNumController,
                                focusNode: _fssaiLicNumFocus,
                                label: 'FSSAI License Number',
                                icon: Icons.description_outlined,
                                nextFocus: _outletGroupFocus,
                              ),
                              const SizedBox(height: 24),
                              _buildSectionTitle(theme, 'Operational Settings'),
                              _buildTextField(
                                controller: _outletGroupController,
                                focusNode: _outletGroupFocus,
                                label: 'Outlet Group',
                                icon: Icons.group_outlined,
                                nextFocus: _warehouseIdFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _warehouseIdController,
                                focusNode: _warehouseIdFocus,
                                label: 'Warehouse ID',
                                icon: Icons.warehouse_outlined,
                                nextFocus: _priceLevelDefaultFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _priceLevelDefaultController,
                                focusNode: _priceLevelDefaultFocus,
                                label: 'Default Price Level',
                                icon: Icons.price_change_outlined,
                                nextFocus: _reorderLevelFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _reorderLevelController,
                                focusNode: _reorderLevelFocus,
                                label: 'Reorder Level',
                                icon: Icons.inventory_outlined,
                                keyboardType: TextInputType.number,
                                nextFocus: _barcodePrefixFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _barcodePrefixController,
                                focusNode: _barcodePrefixFocus,
                                label: 'Barcode Prefix',
                                icon: Icons.qr_code_outlined,
                                nextFocus: _zoneClassificationFocus,
                              ),
                              const SizedBox(height: 24),
                              _buildSectionTitle(
                                theme,
                                'Delivery and Area Details',
                              ),
                              _buildTextField(
                                controller: _zoneClassificationController,
                                focusNode: _zoneClassificationFocus,
                                label: 'Zone Classification',
                                icon: Icons.map_outlined,
                                nextFocus: _landmarkFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _landmarkController,
                                focusNode: _landmarkFocus,
                                label: 'Landmark',
                                icon: Icons.location_on_outlined,
                                nextFocus: _saveFocus,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  focusNode: _saveFocus,
                                  onPressed: _saveBranch,
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: theme.colorScheme.primary,
                                  ),
                                  child: Text(
                                    'Save Branch',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    FocusNode? nextFocus,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceVariant.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
      validator: validator,
      onFieldSubmitted: (_) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        }
      },
    );
  }

  void _saveBranch() {
    if (_formKey.currentState!.validate()) {
      try {
        branch
          ..branchName = _branchNameController.text
          ..code = _codeController.text
          ..companyId = _companyController.selectedCompanyProfile.value.id
          ..branchType = _branchTypeController.text
          ..email = _emailController.text
          ..phone = _phoneController.text
          ..addressLine1 = _addressLine1Controller.text
          ..addressLine2 = _addressLine2Controller.text
          ..city = _cityController.text
          ..postalCode = _postalCodeController.text
          ..country = _countryController.text
          ..gstIN = _gstINController.text
          ..vatTRN = _vatTRNController.text
          ..drugLicNum = _drugLicNumController.text
          ..fssaiLicNum = _fssaiLicNumController.text
          ..outletGroup = _outletGroupController.text
          ..warehouseId = _warehouseIdController.text
          ..priceLevelDefault = _priceLevelDefaultController.text
          ..reorderLevel = int.tryParse(_reorderLevelController.text)
          ..barcodePrefix = _barcodePrefixController.text
          ..zoneClassification = _zoneClassificationController.text
          ..landmark = _landmarkController.text;

        _companyController.saveCompanyBranchProfile(branch);
        _companyController.getCompanyBranchProfiles();
        Get.back();

        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text(
              branch.id == null || branch.id == 0
                  ? 'Branch added successfully'
                  : 'Branch updated successfully',
            ),
            backgroundColor: Theme.of(Get.context!).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: const Text('Error saving branch'),
            backgroundColor: Theme.of(Get.context!).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
