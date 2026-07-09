import 'package:flutter/material.dart';

import '../../core/constants/forum_constants.dart';
import '../../core/errors/app_error.dart';
import '../../core/errors/error_handler.dart';
import '../../models/forum_dto.dart';
import '../../repositories/forum_repository.dart';

class ForumListViewModel extends ChangeNotifier {
  ForumListViewModel({
    required ForumRepository forumRepository,
    required ErrorHandler errorHandler,
    required this.townId,
    required this.townName,
  })  : _forumRepository = forumRepository,
        _errorHandler = errorHandler;

  final ForumRepository _forumRepository;
  final ErrorHandler _errorHandler;
  final int townId;
  final String townName;

  bool loading = true;
  bool loadingMore = false;
  AppError? error;
  List<ForumCategoryDto> categories = const [];
  List<ForumTopicSummaryDto> topics = const [];
  int? selectedCategoryId;
  String filter = 'Recent';
  String searchQuery = '';
  int page = 1;
  int totalCount = 0;
  int pageSize = ForumConstants.defaultPageSize;

  bool get hasNextPage => topics.length < totalCount;

  List<ForumCategoryDto> get activeCategories =>
      categories.where((c) => c.isActive).toList();

  Future<void> load() async {
    loading = true;
    error = null;
    page = 1;
    notifyListeners();

    try {
      final results = await Future.wait([
        _forumRepository.getCategories(townId),
        _forumRepository.getTopics(
          townId: townId,
          categoryId: selectedCategoryId,
          query: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
          filter: filter,
          page: 1,
          pageSize: pageSize,
        ),
      ]);
      categories = results[0] as List<ForumCategoryDto>;
      final response = results[1] as ForumTopicsResponseDto;
      topics = response.items;
      page = response.page;
      pageSize = response.pageSize;
      totalCount = response.totalCount;
    } catch (e) {
      error = await _errorHandler.handleError(e, retryAction: load);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (loading || loadingMore || !hasNextPage) return;

    loadingMore = true;
    notifyListeners();

    try {
      final response = await _forumRepository.getTopics(
        townId: townId,
        categoryId: selectedCategoryId,
        query: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
        filter: filter,
        page: page + 1,
        pageSize: pageSize,
      );
      final existingIds = topics.map((t) => t.id).toSet();
      final newItems =
          response.items.where((t) => !existingIds.contains(t.id)).toList();
      topics = [...topics, ...newItems];
      page = response.page;
      pageSize = response.pageSize;
      totalCount = response.totalCount;
    } catch (e) {
      await _errorHandler.handleError(e, retryAction: loadMore);
    } finally {
      loadingMore = false;
      notifyListeners();
    }
  }

  Future<void> setCategory(int? categoryId) async {
    selectedCategoryId = categoryId;
    await load();
  }

  Future<void> setFilter(String nextFilter) async {
    if (filter == nextFilter) return;
    filter = nextFilter;
    await load();
  }

  Future<void> setSearchQuery(String query) async {
    searchQuery = query;
    await load();
  }
}
