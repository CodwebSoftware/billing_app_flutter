import 'package:flutter/material.dart';

class PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onSelect;

  const PaymentMethodCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}