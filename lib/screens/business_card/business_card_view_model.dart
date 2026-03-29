import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import '../business_details/business_details.dart';
import 'business_card_state.dart';

/// ViewModel for Business Card page business logic
class BusinessCardViewModel extends ChangeNotifier {
  final BusinessRepository _businessRepository;
  final ErrorHandler _errorHandler;

  BusinessCardState _state = BusinessCardLoading();
  BusinessCardState get state => _state;

  final CategoryWithCountDto category;
  final SubCategoryWithCountDto subCategory;
  final TownDto town;

  int _currentPage = 1;
  String? _searchTerm;

  BusinessCardViewModel({
    required this.category,
    required this.subCategory,
    required this.town,
    required BusinessRepository businessRepository,
    required ErrorHandler errorHandler,
  })  : _businessRepository = businessRepository,
        _errorHandler = errorHandler {
    loadBusinesses();
  }

  String? get searchTerm => _searchTerm;

  bool get _hasSearchTerm {
    final q = _searchTerm?.trim();
    return q != null && q.isNotEmpty;
  }

  int bandCount(BusinessCardState state) {
    if (state is BusinessCardSuccess) return state.totalItemCount;
    return subCategory.businessCount;
  }

  Future<void> search(String? term) async {
    final normalizedTerm = term?.trim();
    if ((normalizedTerm == null || normalizedTerm.isEmpty) &&
        (_searchTerm == null || _searchTerm!.trim().isEmpty)) {
      return;
    }
    _searchTerm =
        normalizedTerm == null || normalizedTerm.isEmpty ? null : normalizedTerm;
    await loadBusinesses();
  }

  Future<void> loadBusinesses({bool loadMore = false}) async {
    if (loadMore && _state is BusinessCardSuccess) {
      final currentState = _state as BusinessCardSuccess;
      if (!currentState.hasMorePages || currentState.isLoadingMore) return;

      _state = currentState.copyWith(isLoadingMore: true);
      notifyListeners();
    } else {
      _state = BusinessCardLoading();
      notifyListeners();
      _currentPage = 1;
    }

    try {
      final response = _hasSearchTerm
          ? await _businessRepository.searchBusinesses(
              query: _searchTerm!,
              townId: town.id,
              category: category.key,
              subCategory: subCategory.key,
              page: loadMore ? _currentPage + 1 : 1,
              pageSize: BusinessCardConstants.pageSize,
            )
          : await _businessRepository.getBusinesses(
              townId: town.id,
              category: category.key,
              subCategory: subCategory.key,
              search: _searchTerm,
              page: loadMore ? _currentPage + 1 : 1,
              pageSize: BusinessCardConstants.pageSize,
            );

      if (loadMore && _state is BusinessCardSuccess) {
        final currentState = _state as BusinessCardSuccess;
        final newBusinesses = [
          ...currentState.businesses,
          ...response.businesses,
        ];
        _state = BusinessCardSuccess(
          businesses: newBusinesses,
          hasMorePages: response.hasNextPage,
          isLoadingMore: false,
          totalItemCount: response.totalCount,
        );
        _currentPage++;
      } else {
        if (response.businesses.isEmpty) {
          if (_hasSearchTerm) {
            _state = BusinessCardSuccess(
              businesses: const [],
              hasMorePages: false,
              totalItemCount: response.totalCount,
            );
          } else {
            _state = BusinessCardEmpty();
          }
        } else {
          _state = BusinessCardSuccess(
            businesses: response.businesses,
            hasMorePages: response.hasNextPage,
            totalItemCount: response.totalCount,
          );
        }
      }
      notifyListeners();
    } catch (e) {
      final appError = await _errorHandler.handleError(
        e,
        retryAction: () => loadBusinesses(loadMore: loadMore),
      );
      _state = BusinessCardError(appError);
      notifyListeners();
    }
  }

  void onBusinessTap(BuildContext context, BusinessDto business) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BusinessDetailsPage(
          businessId: business.id,
          businessName: business.name,
        ),
      ),
    );
  }
}
