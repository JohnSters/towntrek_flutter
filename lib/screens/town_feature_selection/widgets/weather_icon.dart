import 'package:flutter/material.dart';

/// Presentation mapping from a WMO weather interpretation code to an icon.
/// Kept in the UI layer so the weather data model stays presentation-free.
IconData weatherIconForCode(int code) {
  return switch (code) {
    0 || 1 => Icons.wb_sunny_rounded,
    2 => Icons.wb_cloudy_rounded,
    3 => Icons.cloud_rounded,
    45 || 48 => Icons.cloud_rounded,
    51 || 53 || 55 || 56 || 57 => Icons.grain_rounded,
    61 || 63 || 65 || 66 || 67 => Icons.water_drop_rounded,
    71 || 73 || 75 || 77 => Icons.ac_unit_rounded,
    80 || 81 || 82 => Icons.water_drop_rounded,
    85 || 86 => Icons.ac_unit_rounded,
    95 || 96 || 99 => Icons.flash_on_rounded,
    _ => Icons.wb_cloudy_rounded,
  };
}
