import 'package:flutter/material.dart';

/// Configuration for business category theming and icons
/// Centralizes all category-related visual mappings used throughout the app
class BusinessCategoryConfig {
  // Private constructor to prevent instantiation
  BusinessCategoryConfig._();

  /// Maps category keys to appropriate Material Design icons
  static const Map<String, IconData> _categoryIcons = {
    'restaurants': Icons.restaurant,
    'hotels': Icons.hotel,
    'shopping': Icons.shopping_bag,
    'entertainment': Icons.movie,
    'healthcare': Icons.local_hospital,
    'automotive': Icons.car_repair,
    'finance': Icons.account_balance,
    'education': Icons.school,
    'services': Icons.build,
    'sports': Icons.sports_soccer,
    'food': Icons.restaurant,
    'dining': Icons.restaurant,
    'accommodation': Icons.hotel,
    'retail': Icons.shopping_bag,
    'leisure': Icons.movie,
    'medical': Icons.local_hospital,
    'banking': Icons.account_balance,
    'learning': Icons.school,
    'maintenance': Icons.build,
    'fitness': Icons.sports_soccer,
    'beauty': Icons.spa,
    'travel': Icons.flight,
    'technology': Icons.computer,
    'pets': Icons.pets,
    'real estate': Icons.home,
    'legal': Icons.gavel,
    'transportation': Icons.directions_car,
  };

  /// Maps category keys to container colors using Material Design 3 color tokens
  static const Map<String, _ColorMapping> _categoryColors = {
    'restaurants': _ColorMapping.primaryContainer,
    'hotels': _ColorMapping.secondaryContainer,
    'shopping': _ColorMapping.tertiaryContainer,
    'entertainment': _ColorMapping.primaryContainer,
    'healthcare': _ColorMapping.errorContainer,
    'automotive': _ColorMapping.secondaryContainer,
    'finance': _ColorMapping.tertiaryContainer,
    'education': _ColorMapping.primaryContainer,
    'services': _ColorMapping.secondaryContainer,
    'sports': _ColorMapping.tertiaryContainer,
    'food': _ColorMapping.primaryContainer,
    'dining': _ColorMapping.primaryContainer,
    'accommodation': _ColorMapping.secondaryContainer,
    'retail': _ColorMapping.tertiaryContainer,
    'leisure': _ColorMapping.primaryContainer,
    'medical': _ColorMapping.errorContainer,
    'banking': _ColorMapping.tertiaryContainer,
    'learning': _ColorMapping.primaryContainer,
    'maintenance': _ColorMapping.secondaryContainer,
    'fitness': _ColorMapping.tertiaryContainer,
    'beauty': _ColorMapping.primaryContainer,
    'travel': _ColorMapping.secondaryContainer,
    'technology': _ColorMapping.tertiaryContainer,
    'pets': _ColorMapping.primaryContainer,
    'real estate': _ColorMapping.secondaryContainer,
    'legal': _ColorMapping.tertiaryContainer,
    'transportation': _ColorMapping.secondaryContainer,
  };

  /// Maps category keys to icon colors using Material Design 3 on-color tokens
  static const Map<String, _ColorMapping> _categoryIconColors = {
    'restaurants': _ColorMapping.onPrimaryContainer,
    'hotels': _ColorMapping.onSecondaryContainer,
    'shopping': _ColorMapping.onTertiaryContainer,
    'entertainment': _ColorMapping.onPrimaryContainer,
    'healthcare': _ColorMapping.onErrorContainer,
    'automotive': _ColorMapping.onSecondaryContainer,
    'finance': _ColorMapping.onTertiaryContainer,
    'education': _ColorMapping.onPrimaryContainer,
    'services': _ColorMapping.onSecondaryContainer,
    'sports': _ColorMapping.onTertiaryContainer,
    'food': _ColorMapping.onPrimaryContainer,
    'dining': _ColorMapping.onPrimaryContainer,
    'accommodation': _ColorMapping.onSecondaryContainer,
    'retail': _ColorMapping.onTertiaryContainer,
    'leisure': _ColorMapping.onPrimaryContainer,
    'medical': _ColorMapping.onErrorContainer,
    'banking': _ColorMapping.onTertiaryContainer,
    'learning': _ColorMapping.onPrimaryContainer,
    'maintenance': _ColorMapping.onSecondaryContainer,
    'fitness': _ColorMapping.onTertiaryContainer,
    'beauty': _ColorMapping.onPrimaryContainer,
    'travel': _ColorMapping.onSecondaryContainer,
    'technology': _ColorMapping.onTertiaryContainer,
    'pets': _ColorMapping.onPrimaryContainer,
    'real estate': _ColorMapping.onSecondaryContainer,
    'legal': _ColorMapping.onTertiaryContainer,
    'transportation': _ColorMapping.onSecondaryContainer,
  };

  /// Get the icon for a category key
  static IconData getCategoryIcon(String categoryKey) {
    final lowerKey = categoryKey.toLowerCase();

    // Try exact match first
    if (_categoryIcons.containsKey(lowerKey)) {
      return _categoryIcons[lowerKey]!;
    }

    // Try to find a partial match (e.g., "restaurants-food" -> "restaurants")
    for (final key in _categoryIcons.keys) {
      if (lowerKey.contains(key) || key.contains(lowerKey)) {
        return _categoryIcons[key]!;
      }
    }

    // Try common variations
    final variations = _getKeyVariations(lowerKey);
    for (final variation in variations) {
      if (_categoryIcons.containsKey(variation)) {
        return _categoryIcons[variation]!;
      }
    }

    return Icons.business;
  }

  /// Get variations of a category key for better matching
  static List<String> _getKeyVariations(String key) {
    final variations = <String>[];
    final parts = key.split('-');

    // Add individual parts
    variations.addAll(parts);

    // Common mappings for compound keys
    if (key.contains('food') || key.contains('restaurant') || key.contains('dining')) {
      variations.addAll(['restaurants', 'food', 'dining']);
    }
    if (key.contains('hotel') || key.contains('lodging')) {
      variations.addAll(['hotels', 'accommodation']);
    }
    if (key.contains('shop') || key.contains('retail') || key.contains('store')) {
      variations.addAll(['shopping', 'retail']);
    }
    if (key.contains('health') || key.contains('medical') || key.contains('hospital')) {
      variations.addAll(['healthcare', 'medical']);
    }
    if (key.contains('bank') || key.contains('finance') || key.contains('financial')) {
      variations.addAll(['finance', 'banking']);
    }

    return variations;
  }

  /// Get the container color for a category key
  static Color getCategoryColor(String categoryKey, ColorScheme colorScheme) {
    final lowerKey = categoryKey.toLowerCase();

    // Try exact match first
    if (_categoryColors.containsKey(lowerKey)) {
      return _categoryColors[lowerKey]!.getColor(colorScheme);
    }

    // Try to find a partial match
    for (final key in _categoryColors.keys) {
      if (lowerKey.contains(key) || key.contains(lowerKey)) {
        return _categoryColors[key]!.getColor(colorScheme);
      }
    }

    // Try variations
    final variations = _getKeyVariations(lowerKey);
    for (final variation in variations) {
      if (_categoryColors.containsKey(variation)) {
        return _categoryColors[variation]!.getColor(colorScheme);
      }
    }

    return colorScheme.surfaceContainerHighest;
  }

  /// Get the icon color for a category key
  static Color getCategoryIconColor(String categoryKey, ColorScheme colorScheme) {
    final lowerKey = categoryKey.toLowerCase();

    // Try exact match first
    if (_categoryIconColors.containsKey(lowerKey)) {
      return _categoryIconColors[lowerKey]!.getColor(colorScheme);
    }

    // Try to find a partial match
    for (final key in _categoryIconColors.keys) {
      if (lowerKey.contains(key) || key.contains(lowerKey)) {
        return _categoryIconColors[key]!.getColor(colorScheme);
      }
    }

    // Try variations
    final variations = _getKeyVariations(lowerKey);
    for (final variation in variations) {
      if (_categoryIconColors.containsKey(variation)) {
        return _categoryIconColors[variation]!.getColor(colorScheme);
      }
    }

    return colorScheme.onSurfaceVariant;
  }
}

/// Internal enum for mapping color scheme properties
enum _ColorMapping {
  primaryContainer,
  onPrimaryContainer,
  secondaryContainer,
  onSecondaryContainer,
  tertiaryContainer,
  onTertiaryContainer,
  errorContainer,
  onErrorContainer;

  Color getColor(ColorScheme colorScheme) {
    switch (this) {
      case _ColorMapping.primaryContainer:
        return colorScheme.primaryContainer;
      case _ColorMapping.onPrimaryContainer:
        return colorScheme.onPrimaryContainer;
      case _ColorMapping.secondaryContainer:
        return colorScheme.secondaryContainer;
      case _ColorMapping.onSecondaryContainer:
        return colorScheme.onSecondaryContainer;
      case _ColorMapping.tertiaryContainer:
        return colorScheme.tertiaryContainer;
      case _ColorMapping.onTertiaryContainer:
        return colorScheme.onTertiaryContainer;
      case _ColorMapping.errorContainer:
        return colorScheme.errorContainer;
      case _ColorMapping.onErrorContainer:
        return colorScheme.onErrorContainer;
    }
  }
}
