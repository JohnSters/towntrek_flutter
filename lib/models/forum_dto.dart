class ForumCategoryDto {
  final int id;
  final int townId;
  final String name;
  final String? description;
  final int displayOrder;
  final bool isActive;
  final int topicCount;

  const ForumCategoryDto({
    required this.id,
    required this.townId,
    required this.name,
    this.description,
    required this.displayOrder,
    required this.isActive,
    required this.topicCount,
  });

  factory ForumCategoryDto.fromJson(Map<String, dynamic> json) {
    return ForumCategoryDto(
      id: json['id'] as int,
      townId: json['townId'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      displayOrder: json['displayOrder'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      topicCount: json['topicCount'] as int? ?? 0,
    );
  }
}

class ForumTopicSummaryDto {
  final int id;
  final int townId;
  final int forumCategoryId;
  final String title;
  final String bodyPreview;
  final String authorDisplayName;
  final String authorRoleBadge;
  final int replyCount;
  final int reactionCount;
  final DateTime createdAt;
  final DateTime lastActivityAt;
  final bool isPinned;
  final bool isAnnouncement;
  final bool isLocked;

  const ForumTopicSummaryDto({
    required this.id,
    required this.townId,
    required this.forumCategoryId,
    required this.title,
    required this.bodyPreview,
    required this.authorDisplayName,
    required this.authorRoleBadge,
    required this.replyCount,
    required this.reactionCount,
    required this.createdAt,
    required this.lastActivityAt,
    this.isPinned = false,
    this.isAnnouncement = false,
    this.isLocked = false,
  });

  factory ForumTopicSummaryDto.fromJson(Map<String, dynamic> json) {
    return ForumTopicSummaryDto(
      id: json['id'] as int,
      townId: json['townId'] as int,
      forumCategoryId: json['forumCategoryId'] as int,
      title: json['title'] as String,
      bodyPreview: json['bodyPreview'] as String? ?? '',
      authorDisplayName: json['authorDisplayName'] as String? ?? 'Member',
      authorRoleBadge: json['authorRoleBadge'] as String? ?? 'Resident',
      replyCount: json['replyCount'] as int? ?? 0,
      reactionCount: json['reactionCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActivityAt: DateTime.parse(json['lastActivityAt'] as String),
      isPinned: json['isPinned'] as bool? ?? false,
      isAnnouncement: json['isAnnouncement'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
    );
  }
}

class ForumTopicsResponseDto {
  final List<ForumTopicSummaryDto> items;
  final int page;
  final int pageSize;
  final int totalCount;

  const ForumTopicsResponseDto({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  factory ForumTopicsResponseDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return ForumTopicsResponseDto(
      items: rawItems
          .map((item) => ForumTopicSummaryDto.fromJson(item as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      totalCount: json['totalCount'] as int? ?? 0,
    );
  }
}

class ForumPostDto {
  final int id;
  final int forumTopicId;
  final String body;
  final String authorDisplayName;
  final String authorRoleBadge;
  final int reactionCount;
  final bool reactedByCurrentUser;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ForumPostDto({
    required this.id,
    required this.forumTopicId,
    required this.body,
    required this.authorDisplayName,
    required this.authorRoleBadge,
    required this.reactionCount,
    required this.reactedByCurrentUser,
    required this.createdAt,
    this.updatedAt,
  });

  factory ForumPostDto.fromJson(Map<String, dynamic> json) {
    return ForumPostDto(
      id: json['id'] as int,
      forumTopicId: json['forumTopicId'] as int,
      body: json['body'] as String,
      authorDisplayName: json['authorDisplayName'] as String? ?? 'Member',
      authorRoleBadge: json['authorRoleBadge'] as String? ?? 'Resident',
      reactionCount: json['reactionCount'] as int? ?? 0,
      reactedByCurrentUser: json['reactedByCurrentUser'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }
}

class ForumTopicDetailDto {
  final int id;
  final int townId;
  final String categoryName;
  final String title;
  final String body;
  final String authorDisplayName;
  final String authorRoleBadge;
  final bool isSubscribedByCurrentUser;
  final bool isLocked;
  final DateTime createdAt;
  final DateTime lastActivityAt;
  final List<ForumPostDto> posts;

  const ForumTopicDetailDto({
    required this.id,
    required this.townId,
    required this.categoryName,
    required this.title,
    required this.body,
    required this.authorDisplayName,
    required this.authorRoleBadge,
    required this.isSubscribedByCurrentUser,
    required this.isLocked,
    required this.createdAt,
    required this.lastActivityAt,
    required this.posts,
  });

  factory ForumTopicDetailDto.fromJson(Map<String, dynamic> json) {
    final rawPosts = json['posts'] as List<dynamic>? ?? const [];
    return ForumTopicDetailDto(
      id: json['id'] as int,
      townId: json['townId'] as int,
      categoryName: json['categoryName'] as String? ?? '',
      title: json['title'] as String,
      body: json['body'] as String,
      authorDisplayName: json['authorDisplayName'] as String? ?? 'Member',
      authorRoleBadge: json['authorRoleBadge'] as String? ?? 'Resident',
      isSubscribedByCurrentUser: json['isSubscribedByCurrentUser'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActivityAt: DateTime.parse(json['lastActivityAt'] as String),
      posts: rawPosts
          .map((item) => ForumPostDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CreateForumTopicRequestDto {
  final int townId;
  final int forumCategoryId;
  final String title;
  final String body;

  const CreateForumTopicRequestDto({
    required this.townId,
    required this.forumCategoryId,
    required this.title,
    required this.body,
  });

  Map<String, dynamic> toJson() => {
        'townId': townId,
        'forumCategoryId': forumCategoryId,
        'title': title,
        'body': body,
      };
}

class CreateForumPostRequestDto {
  final String body;

  const CreateForumPostRequestDto({required this.body});

  Map<String, dynamic> toJson() => {'body': body};
}
