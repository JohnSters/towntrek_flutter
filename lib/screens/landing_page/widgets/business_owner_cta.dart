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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(LandingPageConstants.gradientStartColor),
            Color(LandingPageConstants.gradientEndColor),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(LandingPageConstants.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: const Color(LandingPageConstants.gradientEndColor).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(LandingPageConstants.borderRadiusMedium),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: LandingPageConstants.horizontalPadding,
              vertical: LandingPageConstants.verticalSpacingSmall,
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
                    size: LandingPageConstants.featureIconSize - 12, // Slightly smaller for CTA
                  ),
                ),
                const SizedBox(width: LandingPageConstants.verticalSpacingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        LandingPageConstants.businessOwnerTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
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