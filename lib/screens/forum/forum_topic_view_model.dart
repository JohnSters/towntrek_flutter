import 'package:flutter/material.dart';

import '../../core/constants/forum_constants.dart';
import '../../core/errors/app_error.dart';
import '../../core/errors/error_handler.dart';
import '../../models/forum_dto.dart';
import '../../repositories/forum_repository.dart';

class ForumTopicViewModel extends ChangeNotifier {
  ForumTopicViewModel({
    required ForumRepository forumRepository,
    required ErrorHandler errorHandler,
    required this.topicId,
  })  : _forumRepository = forumRepository,
        _errorHandler = errorHandler;

  final ForumRepository _forumRepository;
  final ErrorHandler _errorHandler;
  final int topicId;

  bool loading = true;
  bool submitting = false;
  bool loadingMoreReplies = false;
  AppError? error;
  ForumTopicDetailDto? topic;

  bool get hasMoreReplies {
    final current = topic;
    if (current == null) return false;
    return current.posts.length < current.postsTotalCount;
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      topic = await _forumRepository.getTopicDetail(
        topicId,
        postsPage: 1,
        postsPageSize: ForumConstants.defaultPageSize,
      );
    } catch (e) {
      error = await _errorHandler.handleError(e, retryAction: load);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreReplies() async {
    final current = topic;
    if (current == null || loadingMoreReplies || !hasMoreReplies) return;

    loadingMoreReplies = true;
    notifyListeners();

    try {
      final nextPage = current.postsPage + 1;
      final page = await _forumRepository.getTopicDetail(
        topicId,
        postsPage: nextPage,
        postsPageSize: current.postsPageSize,
      );
      final existingIds = current.posts.map((p) => p.id).toSet();
      final newPosts =
          page.posts.where((p) => !existingIds.contains(p.id)).toList();
      topic = current.copyWith(
        posts: [...current.posts, ...newPosts],
        postsPage: page.postsPage,
        postsPageSize: page.postsPageSize,
        postsTotalCount: page.postsTotalCount,
      );
    } catch (e) {
      // Keep existing posts; surface via snackbar from the screen.
      rethrow;
    } finally {
      loadingMoreReplies = false;
      notifyListeners();
    }
  }

  /// Throws on failure so [runWithParcelSession] can handle 401 / snackbars.
  Future<void> submitReply(String body) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty || topic == null || topic!.isLocked) {
      return;
    }

    submitting = true;
    notifyListeners();
    try {
      await _forumRepository.createPost(
        topicId,
        CreateForumPostRequestDto(body: trimmed),
      );
      await load();
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  /// Throws on failure so [runWithParcelSession] can handle 401 / snackbars.
  Future<void> toggleReaction(int postId) async {
    await _forumRepository.toggleReaction(postId);
    await load();
  }

  /// Throws on failure so [runWithParcelSession] can handle 401 / snackbars.
  Future<void> toggleSubscription() async {
    if (topic == null) return;
    final subscribed = await _forumRepository.toggleSubscription(topicId);
    topic = topic!.copyWith(isSubscribedByCurrentUser: subscribed);
    notifyListeners();
  }

  /// Throws on failure so [runWithParcelSession] can handle 401 / snackbars.
  Future<void> reportPost(int postId, String reason) async {
    final trimmed = reason.trim();
    if (trimmed.isEmpty) return;
    await _forumRepository.reportPost(postId, trimmed);
  }

  /// Throws on failure so [runWithParcelSession] can handle 401 / snackbars.
  Future<void> reportTopic(String reason) async {
    final trimmed = reason.trim();
    if (trimmed.isEmpty) return;
    await _forumRepository.reportTopic(topicId, trimmed);
  }
}
