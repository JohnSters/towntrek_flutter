import 'package:flutter/material.dart';

/// Single source of truth for open/closed status colors.
///
/// Two presentation contexts intentionally use different closed palettes:
/// - [detail*]: the full-width strip under a detail hero (dark closed bar).
/// - [chip*]: the compact open/closed pill on listing cards (blue-grey closed).
abstract final class ListingStatusColors {
  // Detail hero strip (EntityOpenClosedBanner).
  static const Color detailOpenBg = Color(0xFFE9F7EF);
  static const Color detailOpenFg = Color(0xFF1D7A38);
  static const Color detailOpenBorder = Color(0xFFBFE5CB);
  static const Color detailClosedBg = Color(0xFF3A3A3A);
  static const Color detailClosedFg = Colors.white;
  static const Color detailClosedBorder = Color(0xFF4A4A4A);

  /// Views pill rendered on the open detail bar.
  static const Color detailOpenPillFg = Color(0xFF146C2E);
  static const Color detailOpenPillBorder = Color(0xFFBFE5CB);

  // Listing card pill (ListingOpenClosedChip).
  static const Color chipOpenBg = Color(0xFFE8F5E9);
  static const Color chipOpenFg = Color(0xFF2E7D32);
  static const Color chipOpenBorder = Color(0xFFC8E6C9);
  static const Color chipClosedBg = Color(0xFFECEFF1);
  static const Color chipClosedFg = Color(0xFF546E7A);
  static const Color chipClosedBorder = Color(0xFFB0BEC5);
}
