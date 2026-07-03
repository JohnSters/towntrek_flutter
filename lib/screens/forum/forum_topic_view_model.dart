import 'package:flutter/material.dart';

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
  AppError? error;
  ForumTopicDetailDto? topic;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      topic = await _forumRepository.getTopicDetail(topicId);
    } catch (e) {
      error = await _errorHandler.handleError(e, retryAction: load);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> submitReply(String body) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty || topic == null || topic!.isLocked) {
      return false;
    }

    submitting = true;
    notifyListeners();
    try {
      await _forumRepository.createPost(
        topicId,
        CreateForumPostRequestDto(body: trimmed),
      );
      await load();
      return true;
    } catch (e) {
      error = await _errorHandler.handleError(e);
      notifyListeners();
      return false;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  Future<void> toggleReaction(int postId) async {
    try {
      await _forumRepository.toggleReaction(postId);
      await load();
    } catch (e) {
      error = await _errorHandler.handleError(e, retryAction: load);
      notifyListeners();
    }
  }

  Future<void> toggleSubscription() async {
    if (topic == null) return;
    try {
      final subscribed = await _forumRepository.toggleSubscription(topicId);
      topic = ForumTopicDetailDto(
        id: topic!.id,
        townId: topic!.townId,
        categoryName: topic!.categoryName,
        title: topic!.title,
        body: topic!.body,
        authorDisplayName: topic!.authorDisplayName,
        authorRoleBadge: topic!.authorRoleBadge,
        isSubscribedByCurrentUser: subscribed,
        isLocked: topic!.isLocked,
        createdAt: topic!.createdAt,
        lastActivityAt: topic!.lastActivityAt,
        posts: topic!.posts,
      );
      notifyListeners();
    } catch (e) {
      error = await _errorHandler.handleError(e);
      notifyListeners();
    }
  }
}
