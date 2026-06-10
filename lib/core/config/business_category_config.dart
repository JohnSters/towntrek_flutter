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
    'equipment-rentals': Icons.construction,
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
}
