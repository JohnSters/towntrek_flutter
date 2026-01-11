import 'package:flutter/material.dart';
import '../../../core/constants/landing_page_constants.dart';

/// Main action button for starting exploration
class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFFF6B35), // Orange
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, LandingPageConstants.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LandingPageConstants.borderRadiusMedium),
        ),
        elevation: 2,
        shadowColor: const Color(0xFFFF6B35).withValues(alpha: 0.3),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(LandingPageConstants.verticalSpacingSmall),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(LandingPageConstants.borderRadiusSmall),
            ),
            child: const Icon(
              Icons.explore,
              color: Colors.white,
              size: LandingPageConstants.featureIconSize - 12,
            ),
          ),
          const SizedBox(width: LandingPageConstants.verticalSpacingSmall),
          Expanded(
            child: Text(
              LandingPageConstants.exploreButtonText,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: LandingPageConstants.verticalSpacingSmall),
          const Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: LandingPageConstants.featureIconSize - 12,
          ),
        ],
      ),
    );
  }
}