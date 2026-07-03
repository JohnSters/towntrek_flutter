import 'package:flutter/material.dart';

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
  AppError? error;
  List<ForumCategoryDto> categories = const [];
  List<ForumTopicSummaryDto> topics = const [];
  int? selectedCategoryId;
  String filter = 'Recent';
  String searchQuery = '';

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _forumRepository.getCategories(townId),
        _forumRepository.getTopics(
          townId: townId,
          categoryId: selectedCategoryId,
          query: searchQuery.trim().isEmpty ? null : searchQuery.trim(),
          filter: filter,
        ),
      ]);
      categories = results[0] as List<ForumCategoryDto>;
      topics = (results[1] as ForumTopicsResponseDto).items;
    } catch (e) {
      error = await _errorHandler.handleError(e, retryAction: load);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> setCategory(int? categoryId) async {
    selectedCategoryId = categoryId;
    await load();
  }

  Future<void> setFilter(String nextFilter) async {
    filter = nextFilter;
    await load();
  }

  Future<void> setSearchQuery(String query) async {
    searchQuery = query;
    await load();
  }
}
