import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/town_dto.dart';

/// Stores a single locally pinned town for quick access.
class FavouriteTownStorage {
  static const String _favouriteTownKey = 'favourite_town';
  static final ValueNotifier<TownDto?> favouriteTownNotifier =
      ValueNotifier<TownDto?>(null);
  static Future<void>? _initializationFuture;

  static Future<void> ensureInitialized() {
    _initializationFuture ??= _loadFavouriteTownFromPrefs();
    return _initializationFuture!;
  }

  static Future<void> _loadFavouriteTownFromPrefs() async {
    favouriteTownNotifier.value = await _readFavouriteTownFromPrefs();
  }

  static Future<TownDto?> _readFavouriteTownFromPrefs() async {
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

  static Future<TownDto?> getFavouriteTown() async {
    await ensureInitialized();
    return favouriteTownNotifier.value;
  }

  static Future<void> setFavouriteTown(TownDto town) async {
    await ensureInitialized();
    final previousTown = favouriteTownNotifier.value;
    favouriteTownNotifier.value = town;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_favouriteTownKey, jsonEncode(town.toJson()));
    } catch (error) {
      favouriteTownNotifier.value = previousTown;
      rethrow;
    }
  }

  static Future<void> clearFavouriteTown() async {
    await ensureInitialized();
    final previousTown = favouriteTownNotifier.value;
    favouriteTownNotifier.value = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favouriteTownKey);
    } catch (error) {
      favouriteTownNotifier.value = previousTown;
      rethrow;
    }
  }
}
