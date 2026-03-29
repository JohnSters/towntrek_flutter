import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../models/models.dart';
import 'business_card_hero_header.dart';

/// Widget for displaying loading state with header, results band, and search bar.
class BusinessLoadingView extends StatelessWidget {
  final CategoryWithCountDto category;
  final SubCategoryWithCountDto subCategory;
  final TownDto town;
  final EntityListingTheme listingTheme;
  final Widget searchBar;

  const BusinessLoadingView({
    super.key,
    required this.category,
    required this.subCategory,
    required this.town,
    required this.listingTheme,
    required this.searchBar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BusinessCardHeroHeader(
          theme: listingTheme,
          subCategoryName: subCategory.name,
          categoryName: category.name,
          categoryKey: category.key,
          townName: town.name,
        ),
        ListingResultsBand(
          count: subCategory.businessCount,
          categoryName: subCategory.name,
          bandColor: listingTheme.resultsBand,
        ),
        Padding(
          padding: EntityListingConstants.searchBarSectionPadding,
          child: searchBar,
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
