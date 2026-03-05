import '../../core/core.dart';
import '../../core/config/api_config.dart';
import '../../repositories/repositories.dart';
import '../../models/models.dart';
import 'creative_spaces_state.dart';

/// ViewModel for Creative Spaces listing page
class CreativeSpacesViewModel extends ChangeNotifier {
  final CreativeSpaceRepository _creativeSpaceRepository;
  final ErrorHandler _errorHandler;
  final int? _townId;

  CreativeSpacesState _state = CreativeSpacesLoading();
  int _currentPage = 1;
  int? _selectedCategoryId;
  int? _selectedSubCategoryId;
  String? _searchTerm;

  CreativeSpacesViewModel({
    required CreativeSpaceRepository creativeSpaceRepository,
    required ErrorHandler errorHandler,
    int? townId,
  })  : _creativeSpaceRepository = creativeSpaceRepository,
        _errorHandler = errorHandler,
        _townId = townId {
    loadCreativeSpaces();
  }

  /// Current state of the creative spaces list
  CreativeSpacesState get state => _state;

  /// Current selected category
  int? get selectedCategoryId => _selectedCategoryId;

  /// Current selected subcategory
  int? get selectedSubCategoryId => _selectedSubCategoryId;

  /// Current search term
  String? get searchTerm => _searchTerm;

  /// Available creative space categories
  List<CreativeCategoryDto> get categories {
    final currentState = _state;
    if (currentState is CreativeSpacesSuccess) {
      return currentState.categories;
    }
    if (currentState is CreativeSpacesLoadingMore) {
      return currentState.categories;
    }
    return const [];
  }

  /// Available subcategories for the selected category
  List<CreativeSubCategoryDto> get availableSubCategories {
    final category = _selectedCategory;
    if (category == null) return const [];
    return category.subCategories;
  }

  CreativeCategoryDto? get _selectedCategory {
    if (_selectedCategoryId == null || categories.isEmpty) return null;
    for (final category in categories) {
      if (category.id == _selectedCategoryId) return category;
    }
    return null;
  }

  /// Loads creative spaces with optional filters and pagination
  Future<void> loadCreativeSpaces({bool loadMore = false}) async {
    if (loadMore && !_canLoadMore()) return;

    final previousSuccess = _state is CreativeSpacesSuccess
        ? _state as CreativeSpacesSuccess
        : _state is CreativeSpacesLoadingMore
            ? (_state as CreativeSpacesLoadingMore).toSuccess()
            : null;

    if (loadMore) {
      if (previousSuccess == null) return;
      _state = CreativeSpacesLoadingMore(
        spaces: previousSuccess.spaces,
        categories: previousSuccess.categories,
        totalItemCount: previousSuccess.totalItemCount,
        currentPage: previousSuccess.currentPage,
        hasNextPage: previousSuccess.hasNextPage,
        selectedCategoryId: previousSuccess.selectedCategoryId,
        selectedSubCategoryId: previousSuccess.selectedSubCategoryId,
        searchTerm: previousSuccess.searchTerm,
      );
      notifyListeners();
    } else {
      _state = CreativeSpacesLoading();
      _currentPage = 1;
      notifyListeners();
    }

    try {
      final categories = await _loadCategories();
      _normalizeFilterSelection(categories);

      final nextPage = loadMore ? _currentPage + 1 : 1;
      final response = _hasSearchTerm
          ? await _creativeSpaceRepository.searchCreativeSpaces(
              query: _searchTerm!,
              townId: _townId,
              categoryId: _selectedCategoryId,
              subCategoryId: _selectedSubCategoryId,
              page: nextPage,
              pageSize: ApiConfig.defaultPageSize,
            )
          : await _creativeSpaceRepository.getCreativeSpaces(
              townId: _townId,
              categoryId: _selectedCategoryId,
              subCategoryId: _selectedSubCategoryId,
              search: _searchTerm,
              page: nextPage,
              pageSize: ApiConfig.defaultPageSize,
            );

      final hasNextPage = response.hasNextPage;

      if (loadMore) {
        if (_state is! CreativeSpacesLoadingMore) return;
        final currentState = _state as CreativeSpacesLoadingMore;

        _state = CreativeSpacesSuccess(
          spaces: [...currentState.spaces, ...response.items],
          categories: categories,
          totalItemCount: response.totalCount,
          currentPage: nextPage,
          hasNextPage: hasNextPage,
          selectedCategoryId: _selectedCategoryId,
          selectedSubCategoryId: _selectedSubCategoryId,
          searchTerm: _searchTerm,
        );
        _currentPage = nextPage;
      } else {
        _state = CreativeSpacesSuccess(
          spaces: response.items,
          categories: categories,
          totalItemCount: response.totalCount,
          currentPage: 1,
          hasNextPage: hasNextPage,
          selectedCategoryId: _selectedCategoryId,
          selectedSubCategoryId: _selectedSubCategoryId,
          searchTerm: _searchTerm,
        );
        _currentPage = 1;
      }

      notifyListeners();
    } catch (error) {
      final appError = await _errorHandler.handleError(
        error,
        retryAction: () => loadCreativeSpaces(loadMore: loadMore),
      );

      if (_state is CreativeSpacesLoadingMore && previousSuccess != null) {
        _state = previousSuccess;
      } else {
        _state = CreativeSpacesError(appError);
      }
      notifyListeners();
    }
  }

  /// Reload from first page
  Future<void> refresh() async {
    _currentPage = 1;
    await loadCreativeSpaces();
  }

  /// Load additional creative spaces
  Future<void> loadMore() async {
    await loadCreativeSpaces(loadMore: true);
  }

  /// Retry loading
  Future<void> retry() async {
    await loadCreativeSpaces();
  }

  /// Apply a category filter
  Future<void> selectCategory(int? categoryId) async {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    _selectedSubCategoryId = null;
    await loadCreativeSpaces();
  }

  /// Apply a subcategory filter
  Future<void> selectSubCategory(int? subCategoryId) async {
    if (_selectedCategoryId == null) {
      return;
    }

    final selectedCategory = _selectedCategory;
    if (selectedCategory == null) return;

    if (subCategoryId != null) {
      final exists = selectedCategory.subCategories
          .any((subCategory) => subCategory.id == subCategoryId);
      if (!exists) return;
    }

    if (_selectedSubCategoryId == subCategoryId) return;
    _selectedSubCategoryId = subCategoryId;
    await loadCreativeSpaces();
  }

  /// Apply search term
  Future<void> search(String? term) async {
    final normalizedTerm = term?.trim();
    if ((normalizedTerm == null || normalizedTerm.isEmpty) &&
        (_searchTerm == null || _searchTerm!.trim().isEmpty)) {
      return;
    }
    _searchTerm =
        normalizedTerm == null || normalizedTerm.isEmpty ? null : normalizedTerm;
    await loadCreativeSpaces();
  }

  /// Clear filters and search
  Future<void> clearFilters() async {
    _selectedCategoryId = null;
    _selectedSubCategoryId = null;
    _searchTerm = null;
    await loadCreativeSpaces();
  }

  bool get _hasSearchTerm {
    final query = _searchTerm?.trim();
    return query != null && query.isNotEmpty;
  }

  bool _canLoadMore() {
    final currentState = _state;
    if (currentState is CreativeSpacesSuccess) {
      return currentState.hasNextPage;
    }
    return false;
  }

  Future<List<CreativeCategoryDto>> _loadCategories() async {
    if (_townId != null) {
      try {
        final withCounts =
            await _creativeSpaceRepository.getCategoriesWithCounts(_townId!);
        if (withCounts.isNotEmpty) {
          return withCounts;
        }
      } catch (_) {
        // Fallback to all categories
      }
    }

    return _creativeSpaceRepository.getCategories();
  }

  void _normalizeFilterSelection(List<CreativeCategoryDto> categories) {
    final selectedCategory = categories.where((item) => item.id == _selectedCategoryId).toList();
    if (_selectedCategoryId != null && selectedCategory.isEmpty) {
      _selectedCategoryId = null;
      _selectedSubCategoryId = null;
      return;
    }

    if (selectedCategory.isEmpty) return;
    final selectedCategoryDto = selectedCategory.first;

    final hasSubCategory = selectedCategoryDto.subCategories
        .any((subCategory) => subCategory.id == _selectedSubCategoryId);
    if (_selectedSubCategoryId != null && !hasSubCategory) {
      _selectedSubCategoryId = null;
    }
  }
}
