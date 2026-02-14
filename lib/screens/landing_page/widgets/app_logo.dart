import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/landing_page_constants.dart';

/// App logo widget with card styling
class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: LandingPageConstants.logoContainerHeight,
      child: SvgPicture.asset(
        'assets/images/logos/towntrek_starter_logo2.svg',
        fit: BoxFit.contain,
      ),
    );
  }
}