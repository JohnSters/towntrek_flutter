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

  @override
  Widget build(BuildContext context) {
    final listingTheme = context.entityListingTheme;
    return Column(
      children: [
        EntityListingHeroHeader(
          theme: listingTheme,
          categoryIcon: Icons.handyman_rounded,
          subCategoryName: subCategory.name,
          categoryName: category.name,
          townName: town.name,
        ),
        ListingResultsBand(
          count: subCategory.serviceCount,
          categoryName: subCategory.name,
          bandColor: listingTheme.resultsBand,
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
