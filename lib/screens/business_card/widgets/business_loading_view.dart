import 'package:flutter/material.dart';
import '../../../models/models.dart';
import 'business_card_hero_header.dart';

/// Widget for displaying loading state with header
class BusinessLoadingView extends StatelessWidget {
  final CategoryWithCountDto category;
  final SubCategoryWithCountDto subCategory;
  final TownDto town;

  const BusinessLoadingView({
    super.key,
    required this.category,
    required this.subCategory,
    required this.town,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BusinessCardHeroHeader(
          subCategoryName: subCategory.name,
          categoryName: category.name,
          categoryKey: category.key,
          townName: town.name,
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
