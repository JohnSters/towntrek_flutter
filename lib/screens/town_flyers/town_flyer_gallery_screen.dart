import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../core/utils/external_link_launcher.dart';
import '../../core/utils/url_utils.dart';
import '../../models/models.dart';
import 'town_flyer_composer_screen.dart';

class TownFlyerGalleryScreen extends StatefulWidget {
  const TownFlyerGalleryScreen({
    super.key,
    required this.town,
    required this.flyers,
    this.initialIndex = 0,
  });

  final TownDto town;
  final List<TownFlyerDto> flyers;
  final int initialIndex;

  @override
  State<TownFlyerGalleryScreen> createState() => _TownFlyerGalleryScreenState();
}

class _TownFlyerGalleryScreenState extends State<TownFlyerGalleryScreen> {
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(
      0,
      widget.flyers.isEmpty ? 0 : widget.flyers.length - 1,
    );
    _pageController = PageController(
      initialPage: _index,
      viewportFraction: TownFlyerConstants.galleryViewportFraction,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  TownFlyerDto? get _current =>
      widget.flyers.isEmpty ? null : widget.flyers[_index];

  Future<void> _openComposer() async {
    final posted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TownFlyerComposerScreen(town: widget.town),
      ),
    );
    if (posted == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final flyer = _current;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(TownFlyerConstants.boardTitle(widget.town.name)),
        actions: [
          if (flyer != null)
            IconButton(
              tooltip: TownFlyerConstants.report,
              onPressed: () => ExternalLinkLauncher.openUri(
                context,
                Uri.parse(UrlUtils.reportFlyerMailto(flyer.id)),
              ),
              icon: const Icon(Icons.flag_outlined),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openComposer,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text(TownFlyerConstants.postAction),
      ),
      body: widget.flyers.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  TownFlyerConstants.stripEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.flyers.length,
                    onPageChanged: (value) => setState(() => _index = value),
                    itemBuilder: (context, index) {
                      final item = widget.flyers[index];
                      final url = UrlUtils.resolveImageUrl(item.imageUrl);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: TappableImage(
                          imageUrls: [url],
                          child: ColoredBox(
                            color: const Color(0xFF111111),
                            child: CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              errorWidget: (_, _, _) => const Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white54,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: _FlyerActionDock(flyer: flyer!),
                ),
              ],
            ),
    );
  }
}

class _FlyerActionDock extends StatelessWidget {
  const _FlyerActionDock({required this.flyer});

  final TownFlyerDto flyer;

  @override
  Widget build(BuildContext context) {
    final phone = flyer.contactPhone?.trim();
    final hasPhone = phone != null && phone.isNotEmpty;
    final wa = flyer.whatsAppDigits?.trim();
    final remaining = flyer.expiresAtUtc.difference(DateTime.now().toUtc());
    final hours = remaining.isNegative ? 0 : remaining.inHours;
    final minutes = remaining.isNegative ? 0 : remaining.inMinutes.remainder(60);

    return SizedBox(
      height: TownFlyerConstants.dockHeight + 28,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          children: [
            Text(
              hours > 0 ? '${hours}h ${minutes}m left' : '${minutes}m left',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                if (hasPhone)
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () =>
                          ExternalLinkLauncher.callPhone(context, phone),
                      icon: const Icon(Icons.call_outlined),
                      label: const Text(TownFlyerConstants.call),
                    ),
                  ),
                if (hasPhone && wa != null && wa.isNotEmpty)
                  const SizedBox(width: 8),
                if (wa != null && wa.isNotEmpty)
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => ExternalLinkLauncher.openUri(
                        context,
                        Uri.parse('https://wa.me/$wa'),
                      ),
                      icon: const Icon(Icons.chat_outlined),
                      label: const Text(TownFlyerConstants.whatsapp),
                    ),
                  ),
                if (hasPhone || (wa != null && wa.isNotEmpty))
                  const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        serviceLocator.navigationService.openExternalNavigation(
                          flyer.latitude,
                          flyer.longitude,
                          flyer.physicalAddress ?? flyer.displayName,
                        ),
                    icon: const Icon(Icons.directions_rounded),
                    label: const Text(TownFlyerConstants.directions),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
