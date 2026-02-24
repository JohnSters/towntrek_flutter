import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/town_dto.dart';

/// Stores a single locally pinned town for quick access.
class FavouriteTownStorage {
  static const String _favouriteTownKey = 'favourite_town';

  static Future<TownDto?> getFavouriteTown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedTownJson = prefs.getString(_favouriteTownKey);
      if (storedTownJson == null || storedTownJson.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(storedTownJson);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return TownDto.fromJson(decoded);
    } catch (error) {
      debugPrint('Failed to read favourite town: $error');
      return null;
    }
  }

  static Future<void> setFavouriteTown(TownDto town) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_favouriteTownKey, jsonEncode(town.toJson()));
  }

  static Future<void> clearFavouriteTown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favouriteTownKey);
  }
}
