import 'package:flutter/material.dart';
import '../../../core/constants/landing_page_constants.dart';

/// Main action button for starting exploration
class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final IconData leadingIcon;
  final Color backgroundColor;
  final bool compact;

  const ActionButton({
    super.key,
    required this.onPressed,
    this.buttonText = LandingPageConstants.exploreButtonText,
    this.leadingIcon = Icons.explore,
    this.backgroundColor = const Color(0xFFFF6B35),
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        minimumSize: Size(
          double.infinity,
          compact ? LandingPageConstants.compactButtonHeight : LandingPageConstants.buttonHeight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            LandingPageConstants.borderRadiusMedium,
          ),
        ),
        elevation: 2,
        shadowColor: backgroundColor.withValues(alpha: 0.3),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(
              10,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(
                LandingPageConstants.borderRadiusSmall,
              ),
            ),
            child: Icon(
              leadingIcon,
              color: Colors.white,
                size: compact ? 16 : LandingPageConstants.featureIconSize - 12,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              buttonText,
              style: (compact ? theme.textTheme.titleMedium : theme.textTheme.titleLarge)?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: 16,
          ),
        ],
      ),
    );
  }
}
