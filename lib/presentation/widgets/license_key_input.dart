import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LicenseKeyInput extends StatelessWidget {
  final TextEditingController controller;

  const LicenseKeyInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'License Key',
        prefixIcon: const Icon(Icons.vpn_key),
        suffixIcon: IconButton(
          icon: const Icon(Icons.paste),
          onPressed: () async {
            final clipboardData = await Clipboard.getData('text/plain');
            if (clipboardData != null && clipboardData.text != null) {
              controller.text = clipboardData.text!;
            }
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your license key';
        }
        if (value.length < 10) {
          return 'License key is too short';
        }
        return null;
      },
    );
  }
}