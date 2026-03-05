import '../../models/models.dart';
import '../../core/core.dart';

/// State classes for Creative Spaces listing page
sealed class CreativeSpacesState {
  const CreativeSpacesState();

  /// Current list of creative spaces for the current page/result set.
  List<CreativeSpaceDto> get spaces => const [];

  /// Available categories loaded for filtering.
  List<CreativeCategoryDto> get categories => const [];

  /// Total number of creative spaces available on the server.
  int get totalItemCount => 0;

  /// Indicates whether more pages are available.
  bool get hasNextPage => false;

  /// Current page index when the page has loaded data.
  int get currentPage => 0;
}

class CreativeSpacesLoading extends CreativeSpacesState {}

class CreativeSpacesLoadingMore extends CreativeSpacesState {
  final List<CreativeSpaceDto> spaces;
  final List<CreativeCategoryDto> categories;
  final int totalItemCount;
  final int currentPage;
  final bool hasNextPage;
  final int? selectedCategoryId;
  final int? selectedSubCategoryId;
  final String? searchTerm;

  CreativeSpacesLoadingMore({
    required this.spaces,
    required this.categories,
    required this.totalItemCount,
    required this.currentPage,
    required this.hasNextPage,
    this.selectedCategoryId,
    this.selectedSubCategoryId,
    this.searchTerm,
  });

  CreativeSpacesSuccess toSuccess() {
    return CreativeSpacesSuccess(
      spaces: spaces,
      categories: categories,
      totalItemCount: totalItemCount,
      currentPage: currentPage,
      hasNextPage: hasNextPage,
      selectedCategoryId: selectedCategoryId,
      selectedSubCategoryId: selectedSubCategoryId,
      searchTerm: searchTerm,
    );
  }
}

class CreativeSpacesSuccess extends CreativeSpacesState {
  final List<CreativeSpaceDto> spaces;
  final List<CreativeCategoryDto> categories;
  final int totalItemCount;
  final int currentPage;
  final bool hasNextPage;
  final int? selectedCategoryId;
  final int? selectedSubCategoryId;
  final String? searchTerm;

  CreativeSpacesSuccess({
    required this.spaces,
    required this.categories,
    required this.totalItemCount,
    required this.currentPage,
    required this.hasNextPage,
    this.selectedCategoryId,
    this.selectedSubCategoryId,
    this.searchTerm,
  });

  CreativeSpacesSuccess copyWith({
    List<CreativeSpaceDto>? spaces,
    List<CreativeCategoryDto>? categories,
    int? totalItemCount,
    int? currentPage,
    bool? hasNextPage,
    int? selectedCategoryId,
    int? selectedSubCategoryId,
    String? searchTerm,
    bool replaceSearchTerm = false,
  }) {
    return CreativeSpacesSuccess(
      spaces: spaces ?? this.spaces,
      categories: categories ?? this.categories,
      totalItemCount: totalItemCount ?? this.totalItemCount,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedSubCategoryId: selectedSubCategoryId ?? this.selectedSubCategoryId,
      searchTerm:
          replaceSearchTerm ? searchTerm : searchTerm ?? this.searchTerm,
    );
  }
}

class CreativeSpacesError extends CreativeSpacesState {
  final AppError error;

  CreativeSpacesError(this.error);
}
