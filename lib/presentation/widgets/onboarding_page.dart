import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final Color color;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                image,
                width: MediaQuery.of(context).size.width * 0.8,
              ).animate().fadeIn().scale(),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn().slideY(),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn().slideY(delay: 100.ms),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}