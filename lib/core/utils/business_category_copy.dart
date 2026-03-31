import 'package:flutter/material.dart';

import '../constants/business_card_constants.dart';
import '../theme/entity_listing_theme.dart';
import '../constants/business_category_constants.dart';
import '../constants/business_sub_category_constants.dart';
import '../constants/town_feature_constants.dart';

/// UI copy that depends on business category (e.g. equipment rentals → "listings").
/// Uses [CategoryWithCountDto.key] so both quick-access and Businesses → Categories behave the same.
class BusinessCategoryCopy {
  BusinessCategoryCopy._();

  static bool isEquipmentRentals(String? categoryKey) {
    final k = categoryKey?.trim().toLowerCase();
    return k == TownFeatureConstants.equipmentRentalsCategoryKey.toLowerCase();
  }

  static EntityListingTheme listingTheme(String? categoryKey) =>
      isEquipmentRentals(categoryKey)
          ? EntityListingTheme.equipmentRentals
          : EntityListingTheme.business;

  static String listingBackFooterLabel(String? categoryKey) =>
      isEquipmentRentals(categoryKey) ? 'Back to rentals' : 'Back to properties';

  static String entityPlural(String? categoryKey) =>
      isEquipmentRentals(categoryKey) ? 'listings' : 'businesses';

  static String noEntitiesYet(String? categoryKey) => isEquipmentRentals(categoryKey)
      ? 'No listings yet'
      : BusinessSubCategoryConstants.noBusinessesYet;

  /// Subcategory row: count + noun, or "No … yet" when zero.
  static String subCategoryCountLine(int count, String? categoryKey) {
    if (count == 0) return noEntitiesYet(categoryKey);
    return '$count ${entityPlural(categoryKey)}';
  }

  static String exploreIntro({
    required String subCategoryName,
    required String townName,
    required String? categoryKey,
  }) {
    if (isEquipmentRentals(categoryKey)) {
      return 'Explore $subCategoryName listings in $townName';
    }
    return 'Explore $subCategoryName businesses in $townName';
  }

  static String categoryInfoBarLine({
    required int count,
    required String categoryName,
    required String? categoryKey,
  }) =>
      '$count ${entityPlural(categoryKey)} \u2022 $categoryName';

  static String subCategoryInfoBarLine({
    required int count,
    required String subCategoryName,
    required String? categoryKey,
  }) =>
      '$count ${entityPlural(categoryKey)} \u2022 $subCategoryName';

  static IconData infoBarIcon(String? categoryKey) =>
      isEquipmentRentals(categoryKey) ? Icons.construction : Icons.business_center_rounded;

  static String emptyCardListTitle(String? categoryKey) => isEquipmentRentals(categoryKey)
      ? 'No listings found'
      : BusinessCardConstants.noBusinessesFound;

  static String emptyCardListMessage(String? categoryKey) => isEquipmentRentals(categoryKey)
      ? 'There are no rental listings in this category yet'
      : BusinessCardConstants.noBusinessesMessage;

  /// Category picker grid (Businesses → Categories).
  static String categoryGridSubtitle(int count, String? categoryKey) {
    if (count == 0) {
      return isEquipmentRentals(categoryKey)
          ? 'No listings yet'
          : BusinessCategoryConstants.noBusinessesText;
    }
    if (isEquipmentRentals(categoryKey)) {
      return '$count ${count == 1 ? 'listing' : 'listings'}';
    }
    return '$count ${count == 1 ? 'business' : 'businesses'}';
  }
}
