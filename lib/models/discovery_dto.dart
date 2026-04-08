/// Discovery list / card DTO (mirrors API `TownDiscoveryDto`).
class TownDiscoveryDto {
  final int id;
  final String title;
  final int category;
  final String categoryName;
  final String? coverImageUrl;
  final String? thumbnailUrl;
  final String? quickTip;
  final String? difficulty;
  final String? duration;
  final bool isFreeAccess;
  final bool isFeatured;
  final double? latitude;
  final double? longitude;
  final int voteScore;
  final int upvoteCount;
  final int downvoteCount;
  final int? currentDeviceVote;

  const TownDiscoveryDto({
    required this.id,
    required this.title,
    required this.category,
    required this.categoryName,
    this.coverImageUrl,
    this.thumbnailUrl,
    this.quickTip,
    this.difficulty,
    this.duration,
    required this.isFreeAccess,
    required this.isFeatured,
    this.latitude,
    this.longitude,
    this.voteScore = 0,
    this.upvoteCount = 0,
    this.downvoteCount = 0,
    this.currentDeviceVote,
  });

  factory TownDiscoveryDto.fromJson(Map<String, dynamic> json) {
    return TownDiscoveryDto(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as int,
      categoryName: json['categoryName'] as String? ?? '',
      coverImageUrl: json['coverImageUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      quickTip: json['quickTip'] as String?,
      difficulty: json['difficulty'] as String?,
      duration: json['duration'] as String?,
      isFreeAccess: json['isFreeAccess'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      voteScore: (json['voteScore'] as num?)?.toInt() ?? 0,
      upvoteCount: (json['upvoteCount'] as num?)?.toInt() ?? 0,
      downvoteCount: (json['downvoteCount'] as num?)?.toInt() ?? 0,
      currentDeviceVote: (json['currentDeviceVote'] as num?)?.toInt(),
    );
  }

  TownDiscoveryDto copyWith({
    int? id,
    String? title,
    int? category,
    String? categoryName,
    String? coverImageUrl,
    String? thumbnailUrl,
    String? quickTip,
    String? difficulty,
    String? duration,
    bool? isFreeAccess,
    bool? isFeatured,
    double? latitude,
    double? longitude,
    int? voteScore,
    int? upvoteCount,
    int? downvoteCount,
    int? currentDeviceVote,
    bool clearCurrentDeviceVote = false,
  }) {
    return TownDiscoveryDto(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      categoryName: categoryName ?? this.categoryName,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      quickTip: quickTip ?? this.quickTip,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      isFreeAccess: isFreeAccess ?? this.isFreeAccess,
      isFeatured: isFeatured ?? this.isFeatured,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      voteScore: voteScore ?? this.voteScore,
      upvoteCount: upvoteCount ?? this.upvoteCount,
      downvoteCount: downvoteCount ?? this.downvoteCount,
      currentDeviceVote: clearCurrentDeviceVote
          ? null
          : (currentDeviceVote ?? this.currentDeviceVote),
    );
  }
}

class DiscoveryImageDto {
  final String url;
  final String? thumbnailUrl;
  final String? altText;
  final int sortOrder;

  const DiscoveryImageDto({
    required this.url,
    this.thumbnailUrl,
    this.altText,
    required this.sortOrder,
  });

  factory DiscoveryImageDto.fromJson(Map<String, dynamic> json) {
    return DiscoveryImageDto(
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      altText: json['altText'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }
}

class TownDiscoveryDetailDto extends TownDiscoveryDto {
  final String? description;
  final String? directionsHint;
  final String? entryInfo;
  final String? seasonalNote;
  final String? submitterDisplayName;
  final List<DiscoveryImageDto> images;

  TownDiscoveryDetailDto({
    required super.id,
    required super.title,
    required super.category,
    required super.categoryName,
    super.coverImageUrl,
    super.thumbnailUrl,
    super.quickTip,
    super.difficulty,
    super.duration,
    required super.isFreeAccess,
    required super.isFeatured,
    super.latitude,
    super.longitude,
    this.description,
    this.directionsHint,
    this.entryInfo,
    this.seasonalNote,
    this.submitterDisplayName,
    this.images = const [],
  });

  factory TownDiscoveryDetailDto.fromJson(Map<String, dynamic> json) {
    final base = TownDiscoveryDto.fromJson(json);
    final imgs =
        (json['images'] as List<dynamic>?)
            ?.map((e) => DiscoveryImageDto.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return TownDiscoveryDetailDto(
      id: base.id,
      title: base.title,
      category: base.category,
      categoryName: base.categoryName,
      coverImageUrl: base.coverImageUrl,
      thumbnailUrl: base.thumbnailUrl,
      quickTip: base.quickTip,
      difficulty: base.difficulty,
      duration: base.duration,
      isFreeAccess: base.isFreeAccess,
      isFeatured: base.isFeatured,
      latitude: base.latitude,
      longitude: base.longitude,
      description: json['description'] as String?,
      directionsHint: json['directionsHint'] as String?,
      entryInfo: json['entryInfo'] as String?,
      seasonalNote: json['seasonalNote'] as String?,
      submitterDisplayName: json['submitterDisplayName'] as String?,
      images: imgs,
    );
  }
}

class DiscoveryListResponse {
  final List<TownDiscoveryDto> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final bool hasNextPage;

  const DiscoveryListResponse({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.hasNextPage,
  });

  factory DiscoveryListResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['items'] as List<dynamic>? ?? [];
    return DiscoveryListResponse(
      items: raw
          .map((e) => TownDiscoveryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );
  }
}

class DiscoveryCategoryDto {
  final int id;
  final String name;
  final String iconClass;

  const DiscoveryCategoryDto({
    required this.id,
    required this.name,
    required this.iconClass,
  });

  factory DiscoveryCategoryDto.fromJson(Map<String, dynamic> json) {
    return DiscoveryCategoryDto(
      id: json['id'] as int,
      name: json['name'] as String,
      iconClass: json['iconClass'] as String? ?? '',
    );
  }
}

class TownDiscoveryVoteSummaryDto {
  final int discoveryId;
  final int voteScore;
  final int upvoteCount;
  final int downvoteCount;
  final int? currentDeviceVote;
  final bool isCommunityHidden;

  const TownDiscoveryVoteSummaryDto({
    required this.discoveryId,
    required this.voteScore,
    required this.upvoteCount,
    required this.downvoteCount,
    required this.currentDeviceVote,
    required this.isCommunityHidden,
  });

  factory TownDiscoveryVoteSummaryDto.fromJson(Map<String, dynamic> json) {
    return TownDiscoveryVoteSummaryDto(
      discoveryId: (json['discoveryId'] as num).toInt(),
      voteScore: (json['voteScore'] as num?)?.toInt() ?? 0,
      upvoteCount: (json['upvoteCount'] as num?)?.toInt() ?? 0,
      downvoteCount: (json['downvoteCount'] as num?)?.toInt() ?? 0,
      currentDeviceVote: (json['currentDeviceVote'] as num?)?.toInt(),
      isCommunityHidden: json['isCommunityHidden'] as bool? ?? false,
    );
  }
}
