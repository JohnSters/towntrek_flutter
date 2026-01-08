import 'package:flutter/material.dart';
import '../../../core/constants/business_card_constants.dart';
import '../../../core/widgets/page_header.dart';
import '../../../models/models.dart';

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
        PageHeader(
          title: subCategory.name,
          subtitle: '${category.name} in ${town.name}',
          height: BusinessCardConstants.loadingHeaderHeight,
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