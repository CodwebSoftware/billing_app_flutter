import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomGenderDropdownTextfieldWidget extends StatefulWidget {
  final TextEditingController genderController;
  final FocusNode? focusNode;
  final VoidCallback? onSubmitted;

  const CustomGenderDropdownTextfieldWidget({super.key, required this.genderController,this.focusNode,
    this.onSubmitted,});

  @override
  _GenderDropdownState createState() => _GenderDropdownState();
}

class _GenderDropdownState extends State<CustomGenderDropdownTextfieldWidget> {
  late final FocusNode _focusNode;
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    // Initialize selected gender from controller
    _selectedGender = widget.genderController.text.isNotEmpty
        ? widget.genderController.text.capitalizeFirst
        : null;
    // Listen to controller changes (optional, for external updates)
    widget.genderController.addListener(_updateSelectedGender);
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    widget.genderController.removeListener(_updateSelectedGender);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _updateSelectedGender() {
    if (widget.genderController.text != _selectedGender) {
      setState(() {
        _selectedGender = widget.genderController.text.isNotEmpty
            ? widget.genderController.text
            : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Gender selection',
      child: DropdownButtonFormField<String>(
        focusNode: _focusNode,
        value: _selectedGender,
        decoration: InputDecoration(
          labelText: 'Gender',
          // border: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(12),
          // ),
          // filled: true,
          // fillColor: Theme.of(context).colorScheme.surfaceVariant,
        ),
        items: _genderOptions.map((gender) {
          return DropdownMenuItem<String>(
            value: gender,
            child: Text(gender),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedGender = value;
            widget.genderController.text = value ?? '';
          });
        },
        onTap: () {
          if (widget.onSubmitted != null) {
            widget.onSubmitted!();
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a gender';
          }
          return null;
        },
        dropdownColor: Theme.of(context).colorScheme.surface,
        icon: Icon(
          Icons.arrow_drop_down,
          color: Theme.of(context).colorScheme.primary,
        ),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}