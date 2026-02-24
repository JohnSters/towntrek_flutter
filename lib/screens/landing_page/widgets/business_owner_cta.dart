import 'package:flutter/material.dart';
import '../../../core/constants/landing_page_constants.dart';

/// Business Owner Call-to-Action widget
class BusinessOwnerCTA extends StatelessWidget {
  final VoidCallback onTap;
  final String buttonText;
  final bool compact;

  const BusinessOwnerCTA({
    super.key,
    required this.onTap,
    this.buttonText = LandingPageConstants.businessOwnerTitle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: Color(LandingPageConstants.gradientStartColor),
        foregroundColor: Colors.white,
        minimumSize: Size(
          double.infinity,
          compact ? LandingPageConstants.compactButtonHeight : LandingPageConstants.buttonHeight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LandingPageConstants.borderRadiusMedium),
        ),
        elevation: 2,
        shadowColor: Color(LandingPageConstants.gradientEndColor).withValues(alpha: 0.3),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(LandingPageConstants.borderRadiusSmall),
            ),
            child: const Icon(
              Icons.add_business,
              color: Colors.white,
              size: 16,
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