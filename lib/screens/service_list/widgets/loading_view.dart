import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../models/models.dart';

/// Loading layout with listing hero + results band (for reuse if needed).
class ServiceListLoadingView extends StatelessWidget {
  final ServiceCategoryDto category;
  final ServiceSubCategoryDto subCategory;
  final TownDto town;

  const ServiceListLoadingView({
    super.key,
    required this.category,
    required this.subCategory,
    required this.town,
  });

  static final EntityListingTheme _theme = EntityListingTheme.services;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EntityListingHeroHeader(
          theme: _theme,
          categoryIcon: Icons.handyman_rounded,
          subCategoryName: subCategory.name,
          categoryName: category.name,
          townName: town.name,
        ),
        ListingResultsBand(
          count: subCategory.serviceCount,
          categoryName: subCategory.name,
          bandColor: _theme.resultsBand,
        ),
        const Expanded(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }
}
