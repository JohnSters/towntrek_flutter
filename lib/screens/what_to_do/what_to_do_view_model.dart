import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import '../business_details/business_details_page.dart';
import 'what_to_do_state.dart';

class WhatToDoViewModel extends ChangeNotifier {
  final BusinessRepository _businessRepository;
  final ErrorHandler _errorHandler;
  final TownDto _town;

  WhatToDoState _state = WhatToDoLoading();
  WhatToDoState get state => _state;

  WhatToDoViewModel({
    required BusinessRepository businessRepository,
    required ErrorHandler errorHandler,
    required TownDto town,
  }) : _businessRepository = businessRepository,
       _errorHandler = errorHandler,
       _town = town {
    loadWhatToDo();
  }

  Future<void> loadWhatToDo() async {
    _state = WhatToDoLoading();
    notifyListeners();

    try {
      // Audit finding: Existing API + DTOs already support this feature via:
      // - categories with subcategory counts for a town
      // - business list filters by town/category/subcategory
      final categories = await _businessRepository.getCategoriesWithCounts(
        _town.id,
      );
      final tourismCategory = _findTourismCategory(categories);

      if (tourismCategory == null || tourismCategory.businessCount == 0) {
        _state = WhatToDoSuccess(town: _town, sections: const []);
        notifyListeners();
        return;
      }

      final sections = await _buildSections(tourismCategory);
      _state = WhatToDoSuccess(town: _town, sections: sections);
      notifyListeners();
    } catch (error) {
      final appError = await _errorHandler.handleError(
        error,
        retryAction: loadWhatToDo,
      );
      _state = WhatToDoError(appError);
      notifyListeners();
    }
  }

  void openBusinessDetails(BuildContext context, BusinessDto business) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BusinessDetailsPage(
          businessId: business.id,
          businessName: business.name,
        ),
      ),
    );
  }

  CategoryWithCountDto? _findTourismCategory(
    List<CategoryWithCountDto> categories,
  ) {
    for (final category in categories) {
      final key = category.key.toLowerCase();
      final name = category.name.toLowerCase();
      final matchesTourism =
          key.contains('tourism') ||
          key.contains('visitor') ||
          name.contains('tourism') ||
          name.contains('visitor');
      if (matchesTourism) {
        return category;
      }
    }
    return null;
  }

  Future<List<WhatToDoSection>> _buildSections(
    CategoryWithCountDto tourismCategory,
  ) async {
    final activeSubCategories = tourismCategory.subCategories
        .where((subCategory) => subCategory.businessCount > 0)
        .toList();

    if (activeSubCategories.isEmpty) {
      final businesses = await _fetchAllBusinesses(
        categoryKey: tourismCategory.key,
      );
      if (businesses.isEmpty) return [];
      return [
        WhatToDoSection(
          title: WhatToDoConstants.fallbackSectionTitle,
          businesses: businesses,
        ),
      ];
    }

    final sectionResults = await Future.wait(
      activeSubCategories.map((subCategory) async {
        final businesses = await _fetchAllBusinesses(
          categoryKey: tourismCategory.key,
          subCategoryKey: subCategory.key,
        );
        if (businesses.isEmpty) {
          return null;
        }
        return WhatToDoSection(title: subCategory.name, businesses: businesses);
      }),
    );

    return sectionResults.whereType<WhatToDoSection>().toList();
  }

  Future<List<BusinessDto>> _fetchAllBusinesses({
    required String categoryKey,
    String? subCategoryKey,
  }) async {
    var page = 1;
    var hasNextPage = true;
    final allBusinesses = <BusinessDto>[];

    while (hasNextPage) {
      final response = await _businessRepository.getBusinesses(
        townId: _town.id,
        category: categoryKey,
        subCategory: subCategoryKey,
        page: page,
        pageSize: WhatToDoConstants.pageSize,
      );

      allBusinesses.addAll(response.businesses);
      hasNextPage = response.hasNextPage;
      page += 1;
    }

    return allBusinesses;
  }
}
