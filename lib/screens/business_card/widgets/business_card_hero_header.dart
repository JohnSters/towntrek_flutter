import 'package:flutter/material.dart';
import '../../../core/config/business_category_config.dart';
import '../../../core/widgets/entity_listing_hero_header.dart';
import '../../../core/theme/entity_listing_theme.dart';

/// Business / equipment listing hero; icon from [BusinessCategoryConfig].
class BusinessCardHeroHeader extends StatelessWidget {
  final EntityListingTheme theme;
  final String subCategoryName;
  final String categoryName;
  final String categoryKey;
  final String townName;

  const BusinessCardHeroHeader({
    super.key,
    required this.theme,
    required this.subCategoryName,
    required this.categoryName,
    required this.categoryKey,
    required this.townName,
  });

  @override
  Widget build(BuildContext context) {
    return EntityListingHeroHeader(
      theme: theme,
      categoryIcon: BusinessCategoryConfig.getCategoryIcon(categoryKey),
      subCategoryName: subCategoryName,
      categoryName: categoryName,
      townName: townName,
    );
  }
}
