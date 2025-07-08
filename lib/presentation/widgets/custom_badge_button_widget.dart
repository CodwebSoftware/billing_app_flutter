import 'package:flutter/material.dart';

class CustomBadgeButtonWidget extends StatelessWidget {
  final String label;
  final int badgeNumber;
  final VoidCallback onPressed;
  final IconData? icon;
  final double buttonHeight;
  final double buttonWidth;
  final double badgeSize;
  final Color badgeColor;
  final Color textColor;
  final List<Color> gradientColors;

  const CustomBadgeButtonWidget({
    super.key,
    required this.label,
    required this.badgeNumber,
    required this.onPressed,
    this.icon,
    this.buttonHeight = 50,
    this.buttonWidth = 200,
    this.badgeSize = 24,
    this.badgeColor = Colors.red,
    this.textColor = Colors.white,
    this.gradientColors = const [Colors.blue, Colors.purple],
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Button with gradient and shadow
          Container(
            height: buttonHeight,
            width: buttonWidth,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onPressed,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          color: textColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Badge with number
          if (badgeNumber > 0)
            Positioned(
              top: -badgeSize / 2,
              right: -badgeSize / 2,
              child: Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    badgeNumber.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: badgeSize * 0.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}