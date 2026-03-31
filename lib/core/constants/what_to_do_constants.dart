import 'package:flutter/material.dart';

/// Constants for the What To Do screen.
class WhatToDoConstants {
  static const double headerHeight = 96.0;
  static const double pagePadding = 24.0;
  static const double sectionSpacing = 24.0;
  static const double tileSpacing = 10.0;
  static const int pageSize = 100;

  static const IconData sectionIcon = Icons.place_outlined;
  static const IconData emptyIcon = Icons.travel_explore;

  static const String titlePrefix = 'What to do in';
  static const String subtitle = 'Tourism & Visitor Information';
  static const String emptyTitle = 'No visitor information yet';
  static const String emptyDescription =
      'No tourism businesses are registered for this town yet. Please check back soon.';
  static const String fallbackSectionTitle = 'Recommended Places';
}
