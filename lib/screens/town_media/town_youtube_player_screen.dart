import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../core/core.dart';
import '../../core/utils/external_link_launcher.dart';
import '../../core/utils/url_utils.dart';
import '../../models/models.dart';

class TownYoutubePlayerScreen extends StatefulWidget {
  const TownYoutubePlayerScreen({
    super.key,
    required this.town,
    required this.item,
  });

  final TownDto town;
  final TownMediaItemDto item;

  @override
  State<TownYoutubePlayerScreen> createState() => _TownYoutubePlayerScreenState();
}

class _TownYoutubePlayerScreenState extends State<TownYoutubePlayerScreen> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.item.youtubeVideoId ?? '',
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        strictRelatedVideos: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(item.title),
        actions: [
          IconButton(
            tooltip: TownMediaConstants.report,
            onPressed: () => ExternalLinkLauncher.openUri(
              context,
              Uri.parse(UrlUtils.reportTownMediaMailto(item.id, widget.town.name)),
            ),
            icon: const Icon(Icons.flag_outlined),
          ),
        ],
      ),
      body: Center(
        child: item.youtubeVideoId == null || item.youtubeVideoId!.isEmpty
            ? const Text('This video is unavailable.', style: TextStyle(color: Colors.white70))
            : YoutubePlayer(controller: _controller, aspectRatio: 16 / 9),
      ),
    );
  }
}
