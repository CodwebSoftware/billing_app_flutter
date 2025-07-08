import 'package:billing_app_flutter/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CustomTextDateField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final VoidCallback? onSubmitted;

  const CustomTextDateField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.focusNode,
    this.onSubmitted,
  });

  @override
  State<CustomTextDateField> createState() => _TextDateFieldState();
}

class _TextDateFieldState extends State<CustomTextDateField> {
  late final FocusNode _focusNode;
  final dateFormatter = MaskTextInputFormatter(
    mask: '##-##-####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    _focusNode = widget.focusNode ?? FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${widget.labelText}, format DD-MM-YYYY',
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: 'DD-MM-YYYY'
          // border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          // filled: true,
          // fillColor: Theme.of(context).colorScheme.surfaceVariant,
          // suffixIcon: Icon(Icons.date_range, color: Theme.of(context).colorScheme.primary),
        ),
        keyboardType: TextInputType.datetime,
        inputFormatters: [dateFormatter],
        validator: widget.validator ?? (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a ${widget.labelText}';
          }
          try {
            final date = df.parseStrict(value);
            if (date.year < 1900 || date.isAfter(DateTime.now())) {
              return 'Date must be between 1900 and today';
            }
            return null;
          } catch (e) {
            return 'Invalid date format (DD-MM-YYYY)';
          }
        },
        onFieldSubmitted: (value) {
          if (widget.onSubmitted != null) {
            widget.onSubmitted!();
          }
        },
      ),
    );
  }
}