// Add/Edit Customer Screen
import 'package:animate_do/animate_do.dart';
import 'package:billing_app_flutter/core/constants/constants.dart';
import 'package:billing_app_flutter/db/controllers/customer_controller.dart';
import 'package:billing_app_flutter/db/models/customer_entity.dart';
import 'package:billing_app_flutter/presentation/widgets/custom_gender_dropdown_textfield_widget.dart';
import 'package:billing_app_flutter/presentation/widgets/custom_text_date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Intent for saving customer
class SaveIntent extends Intent {}

class AddEditCustomerScreen extends StatefulWidget {
  const AddEditCustomerScreen({super.key});

  @override
  State<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends State<AddEditCustomerScreen> {
  final CustomerController _customerController = Get.find();
  final _formKey = GlobalKey<FormState>();

  late CustomerEntity customer;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _genderController;
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _countryController;
  late final TextEditingController _creditLimitController;
  late final TextEditingController _creditDaysController;
  late final TextEditingController _paymentTermsController;
  late final TextEditingController _gstINController;

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _birthDateFocus = FocusNode();
  final _genderFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _addressLine1Focus = FocusNode();
  final _addressLine2Focus = FocusNode();
  final _cityFocus = FocusNode();
  final _stateFocus = FocusNode();
  final _postalCodeFocus = FocusNode();
  final _countryFocus = FocusNode();
  final _creditLimitFocus = FocusNode();
  final _creditDaysFocus = FocusNode();
  final _paymentTermsFocus = FocusNode();
  final _gstINFocus = FocusNode();
  final _saveFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    customer = _customerController.selectedCustomer.value ?? CustomerEntity();

    _nameController = TextEditingController(text: customer.name ?? '');
    _emailController = TextEditingController(text: customer.email ?? '');
    _phoneController = TextEditingController(text: customer.phone ?? '');
    _birthDateController = TextEditingController(
      text: customer.dateOfBirth != null ? df.format(customer.dateOfBirth!) : '',
    );
    _genderController = TextEditingController(text: customer.gender ?? '');
    _addressLine1Controller = TextEditingController(text: customer.addressLine1 ?? '');
    _addressLine2Controller = TextEditingController(text: customer.addressLine2 ?? '');
    _cityController = TextEditingController(text: customer.city ?? '');
    _stateController = TextEditingController(text: customer.state ?? '');
    _postalCodeController = TextEditingController(text: customer.postalCode ?? '');
    _countryController = TextEditingController(text: customer.country ?? '');
    _creditLimitController = TextEditingController(text: customer.creditLimit?.toString() ?? '');
    _creditDaysController = TextEditingController(text: customer.creditDays?.toString() ?? '');
    _paymentTermsController = TextEditingController(text: customer.paymentTerms ?? '');
    _gstINController = TextEditingController(text: customer.gstIN ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _genderController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _creditLimitController.dispose();
    _creditDaysController.dispose();
    _paymentTermsController.dispose();
    _gstINController.dispose();

    _nameFocus.dispose();
    _phoneFocus.dispose();
    _birthDateFocus.dispose();
    _genderFocus.dispose();
    _emailFocus.dispose();
    _addressLine1Focus.dispose();
    _addressLine2Focus.dispose();
    _cityFocus.dispose();
    _stateFocus.dispose();
    _postalCodeFocus.dispose();
    _countryFocus.dispose();
    _creditLimitFocus.dispose();
    _creditDaysFocus.dispose();
    _paymentTermsFocus.dispose();
    _gstINFocus.dispose();
    _saveFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNewCustomer = customer.id == null || customer.id == 0;

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): SaveIntent(),
      },
      child: Actions(
        actions: {
          SaveIntent: CallbackAction<SaveIntent>(
            onInvoke: (intent) => _saveCustomer(),
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
                            isNewCustomer ? 'Add New Customer' : 'Edit Customer',
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
                              _buildSectionTitle(theme, 'Personal Details'),
                              _buildTextField(
                                controller: _nameController,
                                focusNode: _nameFocus,
                                label: 'Name',
                                icon: Icons.person_outline,
                                validator: (value) => value?.isEmpty ?? true
                                    ? 'Please enter a name'
                                    : null,
                                nextFocus: _phoneFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _phoneController,
                                focusNode: _phoneFocus,
                                label: 'Phone',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                validator: (value) => value?.isEmpty ?? true
                                    ? 'Please enter a phone number'
                                    : null,
                                nextFocus: _birthDateFocus,
                              ),
                              const SizedBox(height: 16),
                              CustomTextDateField(
                                controller: _birthDateController,
                                focusNode: _birthDateFocus,
                                labelText: 'Birth Date',
                                onSubmitted: () => FocusScope.of(context).requestFocus(_genderFocus),
                              ),
                              const SizedBox(height: 16),
                              CustomGenderDropdownTextfieldWidget(
                                genderController: _genderController,
                                focusNode: _genderFocus,
                                onSubmitted: () => FocusScope.of(context).requestFocus(_emailFocus),
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                label: 'Email',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                nextFocus: _addressLine1Focus,
                              ),
                              const SizedBox(height: 24),
                              _buildSectionTitle(theme, 'Address Details'),
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
                                      nextFocus: _stateFocus,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _stateController,
                                      focusNode: _stateFocus,
                                      label: 'State',
                                      icon: Icons.map_outlined,
                                      nextFocus: _postalCodeFocus,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
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
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _countryController,
                                      focusNode: _countryFocus,
                                      label: 'Country',
                                      icon: Icons.flag_outlined,
                                      nextFocus: _creditLimitFocus,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildSectionTitle(theme, 'Financial Details'),
                              _buildTextField(
                                controller: _creditLimitController,
                                focusNode: _creditLimitFocus,
                                label: 'Credit Limit',
                                icon: Icons.account_balance_wallet_outlined,
                                keyboardType: TextInputType.number,
                                nextFocus: _creditDaysFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _creditDaysController,
                                focusNode: _creditDaysFocus,
                                label: 'Credit Days',
                                icon: Icons.calendar_today_outlined,
                                keyboardType: TextInputType.number,
                                nextFocus: _paymentTermsFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _paymentTermsController,
                                focusNode: _paymentTermsFocus,
                                label: 'Payment Terms',
                                icon: Icons.payment_outlined,
                                nextFocus: _gstINFocus,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _gstINController,
                                focusNode: _gstINFocus,
                                label: 'GSTIN',
                                icon: Icons.description_outlined,
                                nextFocus: _saveFocus,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  focusNode: _saveFocus,
                                  onPressed: _saveCustomer,
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: theme.colorScheme.primary,
                                  ),
                                  child: Text(
                                    'Save Customer',
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

  void _saveCustomer() {
    if (_formKey.currentState!.validate()) {
      try {
        customer
          ..name = _nameController.text
          ..email = _emailController.text
          ..phone = _phoneController.text
          ..gender = _genderController.text
          ..addressLine1 = _addressLine1Controller.text
          ..addressLine2 = _addressLine2Controller.text
          ..city = _cityController.text
          ..state = _stateController.text
          ..postalCode = _postalCodeController.text
          ..country = _countryController.text
          ..creditLimit = double.tryParse(_creditLimitController.text)
          ..creditDays = int.tryParse(_creditDaysController.text)
          ..paymentTerms = _paymentTermsController.text
          ..gstIN = _gstINController.text;

        if (_birthDateController.text.isNotEmpty) {
          customer.dateOfBirth = df.parse(_birthDateController.text);
        }

        _customerController.saveCustomer(customer);
        Get.back();

        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text(
              customer.id == null || customer.id == 0
                  ? 'Customer added successfully'
                  : 'Customer updated successfully',
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
            content: const Text('Error saving customer'),
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
