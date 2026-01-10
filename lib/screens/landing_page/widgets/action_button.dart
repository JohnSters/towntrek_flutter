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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF6B35), // Orange
            Color(0xFFF7931E), // Yellow-Orange
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(LandingPageConstants.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(LandingPageConstants.borderRadiusMedium),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: LandingPageConstants.horizontalPadding,
              vertical: LandingPageConstants.verticalSpacingSmall,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                Text(
                  LandingPageConstants.exploreButtonText,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
          ),
        ),
      ),
    );
  }
}