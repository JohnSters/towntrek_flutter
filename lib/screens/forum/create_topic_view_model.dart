import 'package:flutter/material.dart';

import '../../core/constants/forum_constants.dart';
import '../../models/forum_dto.dart';
import '../../repositories/forum_repository.dart';

class CreateTopicViewModel extends ChangeNotifier {
  CreateTopicViewModel({
    required ForumRepository forumRepository,
    required this.townId,
    required this.townName,
    required List<ForumCategoryDto> categories,
    int? initialCategoryId,
  })  : _forumRepository = forumRepository,
        categories = categories.where((c) => c.isActive).toList() {
    if (this.categories.isNotEmpty) {
      final preferred = initialCategoryId != null
          ? this.categories.where((c) => c.id == initialCategoryId)
          : const Iterable<ForumCategoryDto>.empty();
      selectedCategoryId =
          preferred.isNotEmpty ? preferred.first.id : this.categories.first.id;
    }
  }

  final ForumRepository _forumRepository;
  final int townId;
  final String townName;
  final List<ForumCategoryDto> categories;

  int? selectedCategoryId;
  bool submitting = false;
  String? validationError;

  void setCategory(int? categoryId) {
    selectedCategoryId = categoryId;
    validationError = null;
    notifyListeners();
  }

  Future<ForumTopicDetailDto?> submit({
    required String title,
    required String body,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedBody = body.trim();

    if (selectedCategoryId == null) {
      validationError = 'Choose a category.';
      notifyListeners();
      return null;
    }
    if (trimmedTitle.isEmpty) {
      validationError = 'Add a title for your topic.';
      notifyListeners();
      return null;
    }
    if (trimmedBody.isEmpty) {
      validationError = 'Add a message for your topic.';
      notifyListeners();
      return null;
    }

    submitting = true;
    validationError = null;
    notifyListeners();

    try {
      return await _forumRepository.createTopic(
        CreateForumTopicRequestDto(
          townId: townId,
          forumCategoryId: selectedCategoryId!,
          title: trimmedTitle.length > ForumConstants.titleMaxLength
              ? trimmedTitle.substring(0, ForumConstants.titleMaxLength)
              : trimmedTitle,
          body: trimmedBody.length > ForumConstants.bodyMaxLength
              ? trimmedBody.substring(0, ForumConstants.bodyMaxLength)
              : trimmedBody,
        ),
      );
    } finally {
      submitting = false;
      notifyListeners();
    }
  }
}
