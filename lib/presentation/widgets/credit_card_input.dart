import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreditCardInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;

  const CreditCardInput({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.inputFormatters,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}