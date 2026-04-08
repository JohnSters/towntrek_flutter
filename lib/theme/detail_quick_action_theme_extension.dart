import 'package:flutter/material.dart';

/// Detail-screen quick action + social tile colors (light / dark).
@immutable
class DetailQuickActionThemeExtension extends ThemeExtension<DetailQuickActionThemeExtension> {
  final Color directionsBackground;
  final Color directionsIcon;
  final Color callBackground;
  final Color callIcon;
  final Color callAltBackground;
  final Color callAltIcon;
  final Color emailBackground;
  final Color emailIcon;
  final Color websiteBackground;
  final Color websiteIcon;
  final Color rateBackground;
  final Color rateIcon;
  final Color ticketsBackground;
  final Color ticketsIcon;
  final Color towntrekWebBackground;
  final Color facebookBackground;
  final Color facebookIcon;
  final Color instagramBackground;
  final Color instagramIcon;
  final Color whatsappBackground;
  final Color whatsappIcon;
  final Color twitterBackground;
  final Color twitterIcon;

  const DetailQuickActionThemeExtension({
    required this.directionsBackground,
    required this.directionsIcon,
    required this.callBackground,
    required this.callIcon,
    required this.callAltBackground,
    required this.callAltIcon,
    required this.emailBackground,
    required this.emailIcon,
    required this.websiteBackground,
    required this.websiteIcon,
    required this.rateBackground,
    required this.rateIcon,
    required this.ticketsBackground,
    required this.ticketsIcon,
    required this.towntrekWebBackground,
    required this.facebookBackground,
    required this.facebookIcon,
    required this.instagramBackground,
    required this.instagramIcon,
    required this.whatsappBackground,
    required this.whatsappIcon,
    required this.twitterBackground,
    required this.twitterIcon,
  });

  static const DetailQuickActionThemeExtension light = DetailQuickActionThemeExtension(
    directionsBackground: Color(0xFFE0F2F1),
    directionsIcon: Color(0xFF00695C),
    callBackground: Color(0xFFE8F5E9),
    callIcon: Color(0xFF2E7D32),
    callAltBackground: Color(0xFFDDEEE0),
    callAltIcon: Color(0xFF1B5E20),
    emailBackground: Color(0xFFE3F2FD),
    emailIcon: Color(0xFF1565C0),
    websiteBackground: Color(0xFFF3E5F5),
    websiteIcon: Color(0xFF6A1B9A),
    rateBackground: Color(0xFFFFF3E0),
    rateIcon: Color(0xFFEF6C00),
    ticketsBackground: Color(0xFFEDE7F6),
    ticketsIcon: Color(0xFF4527A0),
    towntrekWebBackground: Color(0xFFE8EAF6),
    facebookBackground: Color(0xFFE8F1FE),
    facebookIcon: Color(0xFF1877F2),
    instagramBackground: Color(0xFFFCE4F0),
    instagramIcon: Color(0xFFC13584),
    whatsappBackground: Color(0xFFE8F7EC),
    whatsappIcon: Color(0xFF25D366),
    twitterBackground: Color(0xFFECEFF1),
    twitterIcon: Color(0xFF424242),
  );

  static const DetailQuickActionThemeExtension dark = DetailQuickActionThemeExtension(
    directionsBackground: Color(0xFF1A3835),
    directionsIcon: Color(0xFF4DD0C0),
    callBackground: Color(0xFF1E3A24),
    callIcon: Color(0xFF81C784),
    callAltBackground: Color(0xFF1B331F),
    callAltIcon: Color(0xFFA5D6A7),
    emailBackground: Color(0xFF1A2F4A),
    emailIcon: Color(0xFF64B5F6),
    websiteBackground: Color(0xFF342447),
    websiteIcon: Color(0xFFCE93D8),
    rateBackground: Color(0xFF3E2E1A),
    rateIcon: Color(0xFFFFB74D),
    ticketsBackground: Color(0xFF2D2640),
    ticketsIcon: Color(0xFFB39DDB),
    towntrekWebBackground: Color(0xFF252A45),
    facebookBackground: Color(0xFF1A2C40),
    facebookIcon: Color(0xFF5B9DFF),
    instagramBackground: Color(0xFF3A2438),
    instagramIcon: Color(0xFFF48FB1),
    whatsappBackground: Color(0xFF1A3328),
    whatsappIcon: Color(0xFF4ADE80),
    twitterBackground: Color(0xFF2A2F33),
    twitterIcon: Color(0xFFB0BEC5),
  );

  @override
  DetailQuickActionThemeExtension copyWith({
    Color? directionsBackground,
    Color? directionsIcon,
    Color? callBackground,
    Color? callIcon,
    Color? callAltBackground,
    Color? callAltIcon,
    Color? emailBackground,
    Color? emailIcon,
    Color? websiteBackground,
    Color? websiteIcon,
    Color? rateBackground,
    Color? rateIcon,
    Color? ticketsBackground,
    Color? ticketsIcon,
    Color? towntrekWebBackground,
    Color? facebookBackground,
    Color? facebookIcon,
    Color? instagramBackground,
    Color? instagramIcon,
    Color? whatsappBackground,
    Color? whatsappIcon,
    Color? twitterBackground,
    Color? twitterIcon,
  }) {
    return DetailQuickActionThemeExtension(
      directionsBackground:
          directionsBackground ?? this.directionsBackground,
      directionsIcon: directionsIcon ?? this.directionsIcon,
      callBackground: callBackground ?? this.callBackground,
      callIcon: callIcon ?? this.callIcon,
      callAltBackground: callAltBackground ?? this.callAltBackground,
      callAltIcon: callAltIcon ?? this.callAltIcon,
      emailBackground: emailBackground ?? this.emailBackground,
      emailIcon: emailIcon ?? this.emailIcon,
      websiteBackground: websiteBackground ?? this.websiteBackground,
      websiteIcon: websiteIcon ?? this.websiteIcon,
      rateBackground: rateBackground ?? this.rateBackground,
      rateIcon: rateIcon ?? this.rateIcon,
      ticketsBackground: ticketsBackground ?? this.ticketsBackground,
      ticketsIcon: ticketsIcon ?? this.ticketsIcon,
      towntrekWebBackground:
          towntrekWebBackground ?? this.towntrekWebBackground,
      facebookBackground: facebookBackground ?? this.facebookBackground,
      facebookIcon: facebookIcon ?? this.facebookIcon,
      instagramBackground: instagramBackground ?? this.instagramBackground,
      instagramIcon: instagramIcon ?? this.instagramIcon,
      whatsappBackground: whatsappBackground ?? this.whatsappBackground,
      whatsappIcon: whatsappIcon ?? this.whatsappIcon,
      twitterBackground: twitterBackground ?? this.twitterBackground,
      twitterIcon: twitterIcon ?? this.twitterIcon,
    );
  }

  @override
  ThemeExtension<DetailQuickActionThemeExtension> lerp(
    ThemeExtension<DetailQuickActionThemeExtension>? other,
    double t,
  ) {
    if (other is! DetailQuickActionThemeExtension) return this;
    Color lc(Color a, Color b) => Color.lerp(a, b, t) ?? a;
    return DetailQuickActionThemeExtension(
      directionsBackground:
          lc(directionsBackground, other.directionsBackground),
      directionsIcon: lc(directionsIcon, other.directionsIcon),
      callBackground: lc(callBackground, other.callBackground),
      callIcon: lc(callIcon, other.callIcon),
      callAltBackground: lc(callAltBackground, other.callAltBackground),
      callAltIcon: lc(callAltIcon, other.callAltIcon),
      emailBackground: lc(emailBackground, other.emailBackground),
      emailIcon: lc(emailIcon, other.emailIcon),
      websiteBackground: lc(websiteBackground, other.websiteBackground),
      websiteIcon: lc(websiteIcon, other.websiteIcon),
      rateBackground: lc(rateBackground, other.rateBackground),
      rateIcon: lc(rateIcon, other.rateIcon),
      ticketsBackground: lc(ticketsBackground, other.ticketsBackground),
      ticketsIcon: lc(ticketsIcon, other.ticketsIcon),
      towntrekWebBackground:
          lc(towntrekWebBackground, other.towntrekWebBackground),
      facebookBackground: lc(facebookBackground, other.facebookBackground),
      facebookIcon: lc(facebookIcon, other.facebookIcon),
      instagramBackground:
          lc(instagramBackground, other.instagramBackground),
      instagramIcon: lc(instagramIcon, other.instagramIcon),
      whatsappBackground: lc(whatsappBackground, other.whatsappBackground),
      whatsappIcon: lc(whatsappIcon, other.whatsappIcon),
      twitterBackground: lc(twitterBackground, other.twitterBackground),
      twitterIcon: lc(twitterIcon, other.twitterIcon),
    );
  }
}

extension DetailQuickActionThemeContext on BuildContext {
  DetailQuickActionThemeExtension get detailQuickActions =>
      Theme.of(this).extension<DetailQuickActionThemeExtension>() ??
      DetailQuickActionThemeExtension.light;
}
