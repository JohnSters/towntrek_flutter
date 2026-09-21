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
      body: Column(
        children: [
          Expanded(
            child: widget.flyers.isEmpty
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
                : PageView.builder(
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
          _FlyerActionDock(
            flyer: flyer,
            onPost: _openComposer,
          ),
        ],
      ),
    );
  }
}

class _FlyerActionDock extends StatelessWidget {
  const _FlyerActionDock({
    required this.flyer,
    required this.onPost,
  });

  static const Color _call = Color(0xFF2E7D32);
  static const Color _whatsApp = Color(0xFF128C7E);
  static const Color _directions = Color(0xFF0277BD);
  static const Color _post = Color(0xFF00838F);
  static const Color _surface = Color(0xFF161616);

  final TownFlyerDto? flyer;
  final VoidCallback onPost;

  @override
  Widget build(BuildContext context) {
    final phone = flyer?.contactPhone?.trim();
    final hasPhone = phone != null && phone.isNotEmpty;
    final wa = flyer?.whatsAppDigits?.trim();
    final hasWhatsApp = wa != null && wa.isNotEmpty;
    final remaining = flyer?.expiresAtUtc.difference(DateTime.now().toUtc());
    final hours = remaining == null || remaining.isNegative
        ? 0
        : remaining.inHours;
    final minutes = remaining == null || remaining.isNegative
        ? 0
        : remaining.inMinutes.remainder(60);
    final remainingLabel = flyer == null
        ? null
        : hours > 0
        ? '${hours}h ${minutes}m left'
        : '${minutes}m left';

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(
          top: BorderSide(color: Color(0x33FFFFFF)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (remainingLabel != null) ...[
                Text(
                  remainingLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (flyer != null)
                Row(
                  children: [
                    if (hasPhone)
                      Expanded(
                        child: _FlyerContactAction(
                          label: TownFlyerConstants.call,
                          icon: Icons.call_rounded,
                          color: _call,
                          onPressed: () =>
                              ExternalLinkLauncher.callPhone(context, phone),
                        ),
                      ),
                    if (hasWhatsApp)
                      Expanded(
                        child: _FlyerContactAction(
                          label: TownFlyerConstants.whatsapp,
                          icon: Icons.chat_rounded,
                          color: _whatsApp,
                          onPressed: () => ExternalLinkLauncher.openUri(
                            context,
                            Uri.parse('https://wa.me/$wa'),
                          ),
                        ),
                      ),
                    Expanded(
                      child: _FlyerContactAction(
                        label: TownFlyerConstants.directions,
                        icon: Icons.directions_rounded,
                        color: _directions,
                        onPressed: () => serviceLocator.navigationService
                            .openExternalNavigation(
                              flyer!.latitude,
                              flyer!.longitude,
                              flyer!.physicalAddress ?? flyer!.displayName,
                            ),
                      ),
                    ),
                  ],
                ),
              if (flyer != null) const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: onPost,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text(TownFlyerConstants.postAction),
                  style: FilledButton.styleFrom(
                    backgroundColor: _post,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlyerContactAction extends StatelessWidget {
  const _FlyerContactAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 26),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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
