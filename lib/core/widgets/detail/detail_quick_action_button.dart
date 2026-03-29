import 'package:flutter/material.dart';

/// 56×56 square quick action matching detail-screen design (tooltip + icon only).
class DetailQuickActionButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onPressed;

  const DetailQuickActionButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 56,
        height: 56,
        child: IconButton(
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: Icon(
            icon,
            size: 24,
            color: onPressed == null
                ? iconColor.withValues(alpha: 0.38)
                : iconColor,
          ),
        ),
      ),
    );
  }
}
