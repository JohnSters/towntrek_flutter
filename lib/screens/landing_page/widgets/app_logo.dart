import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/landing_page_constants.dart';

/// App logo widget with card styling
class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: LandingPageConstants.logoContainerHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LandingPageConstants.borderRadiusLarge),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(LandingPageConstants.logoPadding),
      child: SvgPicture.asset(
        'assets/images/logos/towntrek_starter_logo2.svg',
        fit: BoxFit.contain,
      ),
    );
  }
}