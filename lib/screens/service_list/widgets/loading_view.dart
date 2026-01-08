import 'package:flutter/material.dart';
import '../../../core/widgets/page_header.dart';
import '../../../models/models.dart';
import '../../../core/constants/service_list_constants.dart';

/// Loading view for service list page
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
    return Column(
      children: [
        PageHeader(
          title: subCategory.name,
          subtitle: '${category.name} in ${town.name}',
          height: ServiceListConstants.pageHeaderHeight,
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