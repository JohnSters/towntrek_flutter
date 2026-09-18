import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/core.dart';
import '../../core/utils/external_link_launcher.dart';
import '../../core/utils/url_utils.dart';
import '../../models/models.dart';

class TownAudioPlayerScreen extends StatefulWidget {
  const TownAudioPlayerScreen({
    super.key,
    required this.town,
    required this.item,
  });

  final TownDto town;
  final TownMediaItemDto item;

  @override
  State<TownAudioPlayerScreen> createState() => _TownAudioPlayerScreenState();
}

class _TownAudioPlayerScreenState extends State<TownAudioPlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
  var _speed = 1.0;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = widget.item.audioUrl;
    if (raw == null || raw.trim().isEmpty) {
      setState(() => _loadError = 'This recording is unavailable.');
      return;
    }
    try {
      await _player.setUrl(UrlUtils.resolveApiUrl(raw));
      await _player.play();
    } catch (e) {
      if (mounted) setState(() => _loadError = e);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final cover = UrlUtils.resolveImageUrl(item.coverImageUrl ?? '');
    return Scaffold(
      backgroundColor: const Color(TownMediaConstants.panelColor),
      appBar: AppBar(
        backgroundColor: const Color(TownMediaConstants.panelColor),
        foregroundColor: Colors.white,
        title: Text(widget.town.name),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: cover.isEmpty
                          ? const ColoredBox(
                              color: Color(TownMediaConstants.panelInner),
                              child: Icon(Icons.graphic_eq_rounded, color: Color(0xFFE8C07A), size: 72),
                            )
                          : CachedNetworkImage(imageUrl: cover, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (item.description != null && item.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  item.description!,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
              const SizedBox(height: 20),
              if (_loadError != null)
                Text(
                  'Could not start playback.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                )
              else
                StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = _player.duration ?? Duration.zero;
                    final max = duration.inMilliseconds <= 0 ? 1.0 : duration.inMilliseconds.toDouble();
                    return Column(
                      children: [
                        Slider(
                          value: position.inMilliseconds.clamp(0, max.toInt()).toDouble(),
                          max: max,
                          activeColor: const Color(0xFFE8C07A),
                          onChanged: (value) => _player.seek(Duration(milliseconds: value.round())),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_fmt(position), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            Text(_fmt(duration), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder<PlayerState>(
                    stream: _player.playerStateStream,
                    builder: (context, snapshot) {
                      final playing = snapshot.data?.playing ?? false;
                      return IconButton(
                        iconSize: 64,
                        color: Colors.white,
                        onPressed: () => playing ? _player.pause() : _player.play(),
                        icon: Icon(playing ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () async {
                      final next = _speed == 1.0 ? 1.5 : 1.0;
                      await _player.setSpeed(next);
                      setState(() => _speed = next);
                    },
                    child: Text(
                      '${_speed == 1.0 ? '1.0' : '1.5'}x',
                      style: const TextStyle(color: Color(0xFFE8C07A), fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
