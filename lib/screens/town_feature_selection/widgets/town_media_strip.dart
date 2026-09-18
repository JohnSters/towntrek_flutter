import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/core.dart';
import '../../../core/utils/url_utils.dart';
import '../../../models/models.dart';
import '../../town_media/town_audio_player_screen.dart';
import '../../town_media/town_youtube_player_screen.dart';
import 'town_hub_action_tile.dart';

class TownMediaStrip extends StatelessWidget {
  const TownMediaStrip({
    super.key,
    required this.town,
    required this.media,
  });

  final TownDto town;
  final TownMediaDto media;

  static const Color _listenAccent = Color(0xFFC4782A);
  static const Color _watchAccent = Color(0xFFC62828);

  @override
  Widget build(BuildContext context) {
    final audio = media.audio;
    final videos = media.videos;
    final tiles = <Widget>[
      if (audio.isNotEmpty)
        _CollapsibleMediaAction(
          label: TownMediaConstants.listenLabel,
          moreTooltip: TownMediaConstants.moreEpisodes,
          items: audio,
          accentColor: _listenAccent,
          fallbackIcon: Icons.graphic_eq_rounded,
          coverUrl: UrlUtils.resolveImageUrl(
            audio.first.coverImageUrl ?? media.coverImageUrl ?? '',
          ),
          subtitleFor: _publishedOn,
          onOpen: (item) => _openAudio(context, item),
        ),
      if (videos.isNotEmpty)
        _CollapsibleMediaAction(
          label: TownMediaConstants.watchLabel,
          moreTooltip: TownMediaConstants.moreVideos,
          items: videos,
          accentColor: _watchAccent,
          fallbackIcon: Icons.ondemand_video_rounded,
          coverUrl: _watchCover(videos.first),
          subtitleFor: _publishedOn,
          onOpen: (item) => _openYoutube(context, item),
        ),
    ];

    if (tiles.isEmpty) return const SizedBox.shrink();
    if (tiles.length == 1) return tiles.first;

    return Column(
      children: [
        tiles.first,
        const SizedBox(height: TownFeatureConstants.hubActionGap),
        tiles.last,
      ],
    );
  }

  void _openAudio(BuildContext context, TownMediaItemDto item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TownAudioPlayerScreen(town: town, item: item),
      ),
    );
  }

  void _openYoutube(BuildContext context, TownMediaItemDto item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TownYoutubePlayerScreen(town: town, item: item),
      ),
    );
  }

  static String _publishedOn(TownMediaItemDto item) =>
      DateFormat('d MMM yyyy').format(item.publishedAtUtc.toLocal());

  static String _watchCover(TownMediaItemDto item) {
    final cover = UrlUtils.resolveImageUrl(item.coverImageUrl ?? '');
    if (cover.isNotEmpty) return cover;
    return _youtubeThumb(item);
  }

  static String _youtubeThumb(TownMediaItemDto item) {
    final id = item.youtubeVideoId ?? '';
    if (id.isEmpty) return '';
    return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
  }
}

class _CollapsibleMediaAction extends StatefulWidget {
  const _CollapsibleMediaAction({
    required this.label,
    required this.moreTooltip,
    required this.items,
    required this.accentColor,
    required this.fallbackIcon,
    required this.coverUrl,
    required this.subtitleFor,
    required this.onOpen,
  });

  final String label;
  final String moreTooltip;
  final List<TownMediaItemDto> items;
  final Color accentColor;
  final IconData fallbackIcon;
  final String coverUrl;
  final String Function(TownMediaItemDto item) subtitleFor;
  final ValueChanged<TownMediaItemDto> onOpen;

  @override
  State<_CollapsibleMediaAction> createState() =>
      _CollapsibleMediaActionState();
}

class _CollapsibleMediaActionState extends State<_CollapsibleMediaAction> {
  var _expanded = false;

  TownMediaItemDto get _latest => widget.items.first;
  List<TownMediaItemDto> get _older =>
      widget.items.length > 1 ? widget.items.sublist(1) : const [];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasMore = _older.isNotEmpty;

    return Column(
      children: [
        TownHubActionTile(
          title: widget.label,
          subtitle: _latest.title,
          imageUrl: widget.coverUrl.isEmpty ? null : widget.coverUrl,
          fallbackIcon: widget.fallbackIcon,
          accentColor: widget.accentColor,
          tintColor: widget.accentColor,
          expanded: hasMore ? _expanded : null,
          showPlayOverlay: true,
          showChevron: !hasMore,
          onTap: () => widget.onOpen(_latest),
          trailing: hasMore
              ? IconButton(
                  tooltip: widget.moreTooltip,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : null,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: !_expanded || !hasMore
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    children: [
                      for (final item in _older)
                        _OlderMediaRow(
                          item: item,
                          meta: widget.subtitleFor(item),
                          accentColor: widget.accentColor,
                          onTap: () => widget.onOpen(item),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _OlderMediaRow extends StatelessWidget {
  const _OlderMediaRow({
    required this.item,
    required this.meta,
    required this.accentColor,
    required this.onTap,
  });

  final TownMediaItemDto item;
  final String meta;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final listing = context.entityListing;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.play_circle_fill_rounded, color: accentColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: listing.textTitle,
                        ),
                      ),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: listing.footerHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
