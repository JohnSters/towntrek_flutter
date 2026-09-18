import '../core/json/json_helpers.dart';

class TownMediaItemDto {
  const TownMediaItemDto({
    required this.id,
    required this.kind,
    required this.title,
    this.description,
    this.audioUrl,
    this.durationSeconds,
    this.youtubeVideoId,
    this.coverImageUrl,
    required this.publishedAtUtc,
  });

  final int id;
  final String kind;
  final String title;
  final String? description;
  final String? audioUrl;
  final int? durationSeconds;
  final String? youtubeVideoId;
  final String? coverImageUrl;
  final DateTime publishedAtUtc;

  bool get isAudio => kind.toLowerCase() == 'audio';
  bool get isYoutube => kind.toLowerCase() == 'youtubevideo';

  factory TownMediaItemDto.fromJson(Map<String, dynamic> json) {
    return TownMediaItemDto(
      id: JsonHelpers.readInt(json['id']),
      kind: (json['kind'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      description: JsonHelpers.dualString(json, 'description', 'Description'),
      audioUrl: JsonHelpers.dualString(json, 'audioUrl', 'AudioUrl'),
      durationSeconds: json['durationSeconds'] == null
          ? null
          : JsonHelpers.readInt(json['durationSeconds']),
      youtubeVideoId: JsonHelpers.dualString(json, 'youtubeVideoId', 'YoutubeVideoId'),
      coverImageUrl: JsonHelpers.dualString(json, 'coverImageUrl', 'CoverImageUrl'),
      publishedAtUtc:
          JsonHelpers.utcDate(json['publishedAtUtc'] ?? json['PublishedAtUtc']) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

class TownMediaDto {
  const TownMediaDto({
    required this.townId,
    required this.isMediaEnabled,
    required this.showTitle,
    this.coverImageUrl,
    this.audio = const [],
    this.videos = const [],
  });

  final int townId;
  final bool isMediaEnabled;
  final String showTitle;
  final String? coverImageUrl;
  final List<TownMediaItemDto> audio;
  final List<TownMediaItemDto> videos;

  bool get hasContent => audio.isNotEmpty || videos.isNotEmpty;

  factory TownMediaDto.fromJson(Map<String, dynamic> json) {
    List<TownMediaItemDto> parseList(dynamic raw) {
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((row) => TownMediaItemDto.fromJson(Map<String, dynamic>.from(row)))
          .toList();
    }

    return TownMediaDto(
      townId: JsonHelpers.readInt(json['townId'] ?? json['TownId']),
      isMediaEnabled: JsonHelpers.readBool(
        json['isMediaEnabled'] ?? json['IsMediaEnabled'],
      ),
      showTitle:
          JsonHelpers.dualString(json, 'showTitle', 'ShowTitle') ??
          'Town recordings',
      coverImageUrl: JsonHelpers.dualString(json, 'coverImageUrl', 'CoverImageUrl'),
      audio: parseList(json['audio'] ?? json['Audio']),
      videos: parseList(json['videos'] ?? json['Videos']),
    );
  }
}
