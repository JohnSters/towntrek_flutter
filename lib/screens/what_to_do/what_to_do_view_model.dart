import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import '../../services/discovery_api_service.dart'
    show DiscoveryApiService, DiscoveryVoteException;
import '../discovery_detail/discovery_detail_page.dart';
import '../suggest_discovery/suggest_discovery_screen.dart';
import 'what_to_do_state.dart';

class WhatToDoViewModel extends ChangeNotifier {
  WhatToDoViewModel({
    required DiscoveryApiService discoveryApiService,
    required ErrorHandler errorHandler,
    required TownDto town,
  }) : _discoveryApiService = discoveryApiService,
       _errorHandler = errorHandler,
       _town = town {
    load();
  }

  final DiscoveryApiService _discoveryApiService;
  final ErrorHandler _errorHandler;
  final TownDto _town;
  final Set<int> _voteInFlightIds = <int>{};

  WhatToDoState _state = WhatToDoLoading();
  WhatToDoState get state => _state;
  TownDto get town => _town;
  bool isVotePending(int discoveryId) => _voteInFlightIds.contains(discoveryId);

  Future<void> load() async {
    _state = WhatToDoLoading();
    notifyListeners();

    try {
      final categories = await _discoveryApiService.getCategories();
      final count = await _discoveryApiService.getDiscoveryCount(_town.id);
      final featured = await _discoveryApiService.getFeatured(
        _town.id,
        count: 5,
      );
      final first = await _discoveryApiService.getDiscoveries(
        _town.id,
        page: 1,
        pageSize: WhatToDoConstants.pageSize,
      );

      _state = WhatToDoSuccess(
        town: _town,
        totalCount: count,
        categories: categories,
        featured: featured,
        items: first.items,
        selectedCategoryId: null,
        hasNextPage: first.hasNextPage,
        page: 1,
      );
      notifyListeners();
    } catch (error) {
      final appError = await _errorHandler.handleError(
        error,
        retryAction: load,
      );
      _state = WhatToDoError(appError);
      notifyListeners();
    }
  }

  Future<void> selectCategory(int? categoryId) async {
    final s = _state;
    if (s is! WhatToDoSuccess) return;

    _state = WhatToDoSuccess(
      town: s.town,
      totalCount: s.totalCount,
      categories: s.categories,
      featured: s.featured,
      items: [],
      selectedCategoryId: categoryId,
      hasNextPage: false,
      page: 1,
      loadingMore: true,
    );
    notifyListeners();

    try {
      final res = await _discoveryApiService.getDiscoveries(
        _town.id,
        category: categoryId,
        page: 1,
        pageSize: WhatToDoConstants.pageSize,
      );
      final cur = _state as WhatToDoSuccess;
      _state = WhatToDoSuccess(
        town: cur.town,
        totalCount: cur.totalCount,
        categories: cur.categories,
        featured: cur.featured,
        items: res.items,
        selectedCategoryId: categoryId,
        hasNextPage: res.hasNextPage,
        page: 1,
        loadingMore: false,
      );
      notifyListeners();
    } catch (error) {
      final appError = await _errorHandler.handleError(
        error,
        retryAction: () => selectCategory(categoryId),
      );
      _state = WhatToDoError(appError);
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    final s = _state;
    if (s is! WhatToDoSuccess || !s.hasNextPage || s.loadingMore) return;

    _state = s.copyWith(loadingMore: true);
    notifyListeners();

    try {
      final nextPage = s.page + 1;
      final res = await _discoveryApiService.getDiscoveries(
        _town.id,
        category: s.selectedCategoryId,
        page: nextPage,
        pageSize: WhatToDoConstants.pageSize,
      );
      final cur = _state as WhatToDoSuccess;
      _state = cur.copyWith(
        items: [...cur.items, ...res.items],
        hasNextPage: res.hasNextPage,
        page: nextPage,
        loadingMore: false,
      );
      notifyListeners();
    } catch (error) {
      final cur = _state;
      if (cur is WhatToDoSuccess) {
        _state = cur.copyWith(loadingMore: false);
      }
      notifyListeners();
      debugPrint('loadMore failed: $error');
    }
  }

  Future<void> vote(
    BuildContext context,
    TownDiscoveryDto discovery,
    int targetVote,
  ) async {
    final currentState = _state;
    if (currentState is! WhatToDoSuccess ||
        _voteInFlightIds.contains(discovery.id)) {
      return;
    }

    _voteInFlightIds.add(discovery.id);
    final previousState = currentState;
    _state = _applyOptimisticVote(previousState, discovery, targetVote);
    notifyListeners();

    try {
      final action = switch (targetVote) {
        1 => 'up',
        -1 => 'down',
        _ => 'clear',
      };
      final summary = await _discoveryApiService.voteDiscovery(
        discovery.id,
        action,
      );
      final refreshedState = _state;
      if (refreshedState is WhatToDoSuccess) {
        _state = _applyVoteSummary(refreshedState, summary);
        notifyListeners();
      }
      await _refreshCurrentState();
    } on DiscoveryVoteException catch (error) {
      _state = previousState;
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (error) {
      _state = previousState;
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to save your vote: $error')),
        );
      }
    } finally {
      _voteInFlightIds.remove(discovery.id);
      notifyListeners();
    }
  }

  Future<void> _refreshCurrentState() async {
    final currentState = _state;
    if (currentState is! WhatToDoSuccess) return;

    try {
      final count = await _discoveryApiService.getDiscoveryCount(_town.id);
      final featured = await _discoveryApiService.getFeatured(
        _town.id,
        count: 5,
      );
      final res = await _discoveryApiService.getDiscoveries(
        _town.id,
        category: currentState.selectedCategoryId,
        page: 1,
        pageSize: WhatToDoConstants.pageSize,
      );

      final latestState = _state;
      if (latestState is! WhatToDoSuccess) return;

      _state = latestState.copyWith(
        totalCount: count,
        featured: featured,
        items: res.items,
        hasNextPage: res.hasNextPage,
        page: 1,
        loadingMore: false,
      );
      notifyListeners();
    } catch (error) {
      debugPrint('refresh after vote failed: $error');
    }
  }

  WhatToDoSuccess _applyOptimisticVote(
    WhatToDoSuccess state,
    TownDiscoveryDto discovery,
    int targetVote,
  ) {
    TownDiscoveryDto updateDiscovery(TownDiscoveryDto item) {
      if (item.id != discovery.id) return item;
      final previousVote = item.currentDeviceVote ?? 0;
      final nextVote = targetVote;
      return item.copyWith(
        voteScore: item.voteScore - previousVote + nextVote,
        upvoteCount:
            item.upvoteCount -
            (previousVote == 1 ? 1 : 0) +
            (nextVote == 1 ? 1 : 0),
        downvoteCount:
            item.downvoteCount -
            (previousVote == -1 ? 1 : 0) +
            (nextVote == -1 ? 1 : 0),
        currentDeviceVote: nextVote == 0 ? null : nextVote,
        clearCurrentDeviceVote: nextVote == 0,
      );
    }

    return state.copyWith(
      items: state.items.map(updateDiscovery).toList(),
      featured: state.featured.map(updateDiscovery).toList(),
    );
  }

  WhatToDoSuccess _applyVoteSummary(
    WhatToDoSuccess state,
    TownDiscoveryVoteSummaryDto summary,
  ) {
    if (summary.isCommunityHidden) {
      return state.copyWith(
        totalCount: state.totalCount > 0 ? state.totalCount - 1 : 0,
        items: state.items
            .where((item) => item.id != summary.discoveryId)
            .toList(),
        featured: state.featured
            .where((item) => item.id != summary.discoveryId)
            .toList(),
      );
    }

    TownDiscoveryDto updateDiscovery(TownDiscoveryDto item) {
      if (item.id != summary.discoveryId) return item;
      return item.copyWith(
        voteScore: summary.voteScore,
        upvoteCount: summary.upvoteCount,
        downvoteCount: summary.downvoteCount,
        currentDeviceVote: summary.currentDeviceVote,
        clearCurrentDeviceVote: summary.currentDeviceVote == null,
      );
    }

    return state.copyWith(
      items: state.items.map(updateDiscovery).toList(),
      featured: state.featured.map(updateDiscovery).toList(),
    );
  }

  void openDiscoveryDetail(BuildContext context, int id, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            DiscoveryDetailPage(discoveryId: id, title: title, town: _town),
      ),
    );
  }

  void openSuggest(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SuggestDiscoveryScreen(town: _town),
      ),
    );
  }
}
