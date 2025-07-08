// Intent for saving entities
import 'package:animate_do/animate_do.dart';
import 'package:billing_app_flutter/db/controllers/company_profile_controller.dart';
import 'package:billing_app_flutter/db/models/company_profile_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SaveIntent extends Intent {}

// Add/Edit Company Profile Screen
class AddEditCompanyProfileScreen extends StatefulWidget {
  const AddEditCompanyProfileScreen({super.key});

  @override
  State<AddEditCompanyProfileScreen> createState() => _AddEditCompanyProfileScreenState();
}

class _AddEditCompanyProfileScreenState extends State<AddEditCompanyProfileScreen> {
  final CompanyProfileController _companyController = Get.find();
  final _formKey = GlobalKey<FormState>();

  late CompanyProfileEntity company;
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _businessTypeController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _countryController;
  late final TextEditingController _panNumberController;
  late final TextEditingController _gstINController;
  late final TextEditingController _vatTRNController;
  late final TextEditingController _tinNumController;
  late final TextEditingController _companyRegNumController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _bankAccNumController;
  late final TextEditingController _ifscCodeController;
  late final TextEditingController _currencyCodeController;
  late final TextEditingController _taxationModelController;
  late final TextEditingController _financialYearStartController;

  final _nameFocus = FocusNode();
  final _codeFocus = FocusNode();
  final _businessTypeFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _addressLine1Focus = FocusNode();
  final _addressLine2Focus = FocusNode();
  final _cityFocus = FocusNode();
  final _postalCodeFocus = FocusNode();
  final _countryFocus = FocusNode();
  final _panNumberFocus = FocusNode();
  final _gstINFocus = FocusNode();
  final _vatTRNFocus = FocusNode();
  final _tinNumFocus = FocusNode();
  final _companyRegNumFocus = FocusNode();
  final _bankNameFocus = FocusNode();
  final _bankAccNumFocus = FocusNode();
  final _ifscCodeFocus = FocusNode();
  final _currencyCodeFocus = FocusNode();
  final _taxationModelFocus = FocusNode();
  final _financialYearStartFocus = FocusNode();
  final _saveFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    company = _companyController.selectedCompanyProfile.value ?? CompanyProfileEntity();

    _nameController = TextEditingController(text: company.name ?? '');
    _codeController = TextEditingController(text: company.code?.toString() ?? '');
    _businessTypeController = TextEditingController(text: company.businessType ?? '');
    _emailController = TextEditingController(text: company.email ?? '');
    _phoneController = TextEditingController(text: company.phone ?? '');
    _addressLine1Controller = TextEditingController(text: company.addressLine1 ?? '');
    _addressLine2Controller = TextEditingController(text: company.addressLine2 ?? '');
    _cityController = TextEditingController(text: company.city ?? '');
    _postalCodeController = TextEditingController(text: company.postalCode ?? '');
    _countryController = TextEditingController(text: company.country ?? '');
    _panNumberController = TextEditingController(text: company.panNumber ?? '');
    _gstINController = TextEditingController(text: company.gstIN ?? '');
    _vatTRNController = TextEditingController(text: company.vatTRN ?? '');
    _tinNumController = TextEditingController(text: company.tinNum ?? '');
    _companyRegNumController = TextEditingController(text: company.companyRegNum ?? '');
    _bankNameController = TextEditingController(text: company.bankName ?? '');
    _bankAccNumController = TextEditingController(text: company.bankAccNum ?? '');
    _ifscCodeController = TextEditingController(text: company.ifscCode ?? '');
    _currencyCodeController = TextEditingController(text: company.currencyCode ?? '');
    _taxationModelController = TextEditingController(text: company.taxationModel ?? '');
    _financialYearStartController = TextEditingController(
      text: company.financialYearStart != null ? DateFormat('MMM dd, yyyy').format(company.financialYearStart!) : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _businessTypeController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _panNumberController.dispose();
    _gstINController.dispose();
    _vatTRNController.dispose();
    _tinNumController.dispose();
    _companyRegNumController.dispose();
    _bankNameController.dispose();
    _bankAccNumController.dispose();
    _ifscCodeController.dispose();
    _currencyCodeController.dispose();
    _taxationModelController.dispose();
    _financialYearStartController.dispose();

    _nameFocus.dispose();
    _codeFocus.dispose();
    _businessTypeFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _addressLine1Focus.dispose();
    _addressLine2Focus.dispose();
    _cityFocus.dispose();
    _postalCodeFocus.dispose();
    _countryFocus.dispose();
    _panNumberFocus.dispose();
    _gstINFocus.dispose();
    _vatTRNFocus.dispose();
    _tinNumFocus.dispose();
    _companyRegNumFocus.dispose();
    _bankNameFocus.dispose();
    _bankAccNumFocus.dispose();
    _ifscCodeFocus.dispose();
    _currencyCodeFocus.dispose();
    _taxationModelFocus.dispose();
    _financialYearStartFocus.dispose();
    _saveFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNewCompany = company.id == null || company.id == 0;

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): SaveIntent(),
      },
      child: Actions(
        actions: {
          SaveIntent: CallbackAction<SaveIntent>(
            onInvoke: (intent) => _saveCompany(),
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
                            isNewCompany ? 'Add New Company' : 'Edit Company',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
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
                              _buildSectionTitle(theme, 'Company Details'),
                              _buildTextField(
                                controller: _nameController,
                                focusNode: _nameFocus,
                                label: 'Company Name',
                                icon: Icons.business_outlined,
                                validator: (value) => value?.isEmpty ?? true ? 'Please enter a company name' : null,
                                nextFocus: _codeFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _codeController,
                                focusNode: _codeFocus,
                                label: 'Company Code',
                                icon: Icons.code,
                                keyboardType: TextInputType.number,
                                nextFocus: _businessTypeFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _businessTypeController,
                                focusNode: _businessTypeFocus,
                                label: 'Business Type',
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
                                nextFocus: _panNumberFocus,
                              ),
                              const SizedBox(height: 24),
                              _buildSectionTitle(theme, 'Tax and Compliance'),
                              _buildTextField(
                                controller: _panNumberController,
                                focusNode: _panNumberFocus,
                                label: 'PAN Number',
                                icon: Icons.description_outlined,
                                nextFocus: _gstINFocus,
                              ),
                              const SizedBox(height: 16),
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
                                nextFocus: _tinNumFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _tinNumController,
                                focusNode: _tinNumFocus,
                                label: 'TIN Number',
                                icon: Icons.description_outlined,
                                nextFocus: _companyRegNumFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _companyRegNumController,
                                focusNode: _companyRegNumFocus,
                                label: 'Company Registration Number',
                                icon: Icons.description_outlined,
                                nextFocus: _bankNameFocus,
                              ),
                              const SizedBox(height: 24),
                              _buildSectionTitle(theme, 'Financial Details'),
                              _buildTextField(
                                controller: _bankNameController,
                                focusNode: _bankNameFocus,
                                label: 'Bank Name',
                                icon: Icons.account_balance_outlined,
                                nextFocus: _bankAccNumFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _bankAccNumController,
                                focusNode: _bankAccNumFocus,
                                label: 'Bank Account Number',
                                icon: Icons.account_balance_wallet_outlined,
                                nextFocus: _ifscCodeFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _ifscCodeController,
                                focusNode: _ifscCodeFocus,
                                label: 'IFSC Code',
                                icon: Icons.code_outlined,
                                nextFocus: _currencyCodeFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _currencyCodeController,
                                focusNode: _currencyCodeFocus,
                                label: 'Currency Code',
                                icon: Icons.currency_exchange_outlined,
                                nextFocus: _taxationModelFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _taxationModelController,
                                focusNode: _taxationModelFocus,
                                label: 'Taxation Model',
                                icon: Icons.account_balance_wallet_outlined,
                                nextFocus: _financialYearStartFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _financialYearStartController,
                                focusNode: _financialYearStartFocus,
                                label: 'Financial Year Start',
                                icon: Icons.calendar_today_outlined,
                                keyboardType: TextInputType.datetime,
                                nextFocus: _saveFocus,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  focusNode: _saveFocus,
                                  onPressed: _saveCompany,
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: theme.colorScheme.primary,
                                  ),
                                  child: Text(
                                    'Save Company',
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
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

  void _saveCompany() {
    if (_formKey.currentState!.validate()) {
      try {
        company
          ..name = _nameController.text
          ..code = int.tryParse(_codeController.text)
          ..businessType = _businessTypeController.text
          ..email = _emailController.text
          ..phone = _phoneController.text
          ..addressLine1 = _addressLine1Controller.text
          ..addressLine2 = _addressLine2Controller.text
          ..city = _cityController.text
          ..postalCode = _postalCodeController.text
          ..country = _countryController.text
          ..panNumber = _panNumberController.text
          ..gstIN = _gstINController.text
          ..vatTRN = _vatTRNController.text
          ..tinNum = _tinNumController.text
          ..companyRegNum = _companyRegNumController.text
          ..bankName = _bankNameController.text
          ..bankAccNum = _bankAccNumController.text
          ..ifscCode = _ifscCodeController.text
          ..currencyCode = _currencyCodeController.text
          ..taxationModel = _taxationModelController.text
          ..financialYearStart = _financialYearStartController.text.isNotEmpty
              ? DateFormat('MMM dd, yyyy').parse(_financialYearStartController.text)
              : null;

        _companyController.saveCompanyProfile(company);
        _companyController.getCompanyProfiles();
        Get.back();

        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text(
              company.id == null || company.id == 0
                  ? 'Company added successfully'
                  : 'Company updated successfully',
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
            content: const Text('Error saving company'),
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