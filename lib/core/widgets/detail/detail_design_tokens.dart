import 'package:flutter/material.dart';

/// Shared colors for detail-screen quick actions and social (Business / Service / Property / Event).
abstract final class DetailQuickActionColors {
  static const directionsBackground = Color(0xFFE0F2F1);
  static const directionsIcon = Color(0xFF00695C);

  static const callBackground = Color(0xFFE8F5E9);
  static const callIcon = Color(0xFF2E7D32);

  static const callAltBackground = Color(0xFFDDEEE0);
  static const callAltIcon = Color(0xFF1B5E20);

  static const emailBackground = Color(0xFFE3F2FD);
  static const emailIcon = Color(0xFF1565C0);

  static const websiteBackground = Color(0xFFF3E5F5);
  static const websiteIcon = Color(0xFF6A1B9A);

  static const rateBackground = Color(0xFFFFF3E0);
  static const rateIcon = Color(0xFFEF6C00);

  /// Distinct from [rateBackground] / [rateIcon] so tickets never reads as "rate".
  static const ticketsBackground = Color(0xFFEDE7F6);
  static const ticketsIcon = Color(0xFF4527A0);
}

abstract final class DetailSocialColors {
  static const facebookBackground = Color(0xFFE8F1FE);
  static const facebookIcon = Color(0xFF1877F2);

  static const instagramBackground = Color(0xFFFCE4F0);
  static const instagramIcon = Color(0xFFC13584);

  static const whatsappBackground = Color(0xFFE8F7EC);
  static const whatsappIcon = Color(0xFF25D366);
}
