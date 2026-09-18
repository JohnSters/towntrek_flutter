import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../../../core/utils/url_utils.dart';
import '../../../models/models.dart';
import 'town_hub_action_tile.dart';

class TownFlyerStrip extends StatelessWidget {
  const TownFlyerStrip({
    super.key,
    required this.townName,
    required this.flyers,
    required this.loading,
    required this.onOpenGallery,
  });

  static const Color _accent = Color(0xFF00838F);

  final String townName;
  final List<TownFlyerDto> flyers;
  final bool loading;
  final ValueChanged<int> onOpenGallery;

  int get _latestIndex {
    if (flyers.isEmpty) return 0;
    var best = 0;
    for (var i = 1; i < flyers.length; i++) {
      if (flyers[i].publishedAtUtc.isAfter(flyers[best].publishedAtUtc)) {
        best = i;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final latest = flyers.isEmpty ? null : flyers[_latestIndex];
    final previewUrl = latest == null
        ? ''
        : UrlUtils.resolveImageUrl(
            (latest.thumbnailUrl?.trim().isNotEmpty == true)
                ? latest.thumbnailUrl!
                : latest.imageUrl,
          );

    return TownHubActionTile(
      title: TownFlyerConstants.boardTitle(townName),
      subtitle: loading
          ? TownFlyerConstants.stripLoading
          : TownFlyerConstants.liveCountLabel(flyers.length),
      imageUrl: previewUrl.isEmpty ? null : previewUrl,
      fallbackIcon: Icons.burst_mode_rounded,
      accentColor: _accent,
      tintColor: _accent,
      showChevron: !loading,
      onTap: loading ? null : () => onOpenGallery(_latestIndex),
      trailing: loading
          ? const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          : null,
    );
  }
}
