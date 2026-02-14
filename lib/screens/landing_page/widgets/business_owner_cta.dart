import 'package:flutter/material.dart';
import '../../../core/constants/landing_page_constants.dart';

/// Business Owner Call-to-Action widget
class BusinessOwnerCTA extends StatelessWidget {
  final VoidCallback onTap;

  const BusinessOwnerCTA({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: Color(LandingPageConstants.gradientStartColor),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, LandingPageConstants.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LandingPageConstants.borderRadiusMedium),
        ),
        elevation: 2,
        shadowColor: Color(LandingPageConstants.gradientEndColor).withValues(alpha: 0.3),
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
              Icons.add_business,
              color: Colors.white,
              size: LandingPageConstants.featureIconSize - 12,
            ),
          ),
          const SizedBox(width: LandingPageConstants.verticalSpacingSmall),
          Expanded(
            child: Text(
              LandingPageConstants.businessOwnerTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.start,
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