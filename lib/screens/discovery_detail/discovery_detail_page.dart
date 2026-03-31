import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../core/constants/discovery_constants.dart';
import '../../core/utils/external_link_launcher.dart';
import '../../core/utils/url_utils.dart';
import '../../core/widgets/discovery_map_widget.dart';
import '../../models/models.dart';
import 'discovery_detail_view_model.dart';

class DiscoveryDetailPage extends StatelessWidget {
  const DiscoveryDetailPage({
    super.key,
    required this.discoveryId,
    required this.title,
    required this.town,
  });

  final int discoveryId;
  final String title;
  final TownDto town;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DiscoveryDetailViewModel(
        discoveryId: discoveryId,
        discoveryApiService: serviceLocator.discoveryApiService,
        errorHandler: serviceLocator.errorHandler,
      ),
      child: _DiscoveryDetailBody(initialTitle: title, town: town),
    );
  }
}

class _DiscoveryDetailBody extends StatelessWidget {
  const _DiscoveryDetailBody({
    required this.initialTitle,
    required this.town,
  });

  final String initialTitle;
  final TownDto town;

  static const EntityListingTheme _theme = EntityListingTheme.business;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DiscoveryDetailViewModel>();
    final state = vm.state;

    return Scaffold(
      backgroundColor: EntityListingTheme.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            EntityListingHeroHeader(
              theme: _theme,
              categoryIcon: Icons.explore_outlined,
              subCategoryName: state is DiscoveryDetailSuccess
                  ? state.discovery.title
                  : initialTitle,
              categoryName: 'Discovery',
              townName: town.name,
            ),
            Expanded(child: _buildContent(context, state, vm)),
            const ListingBackFooter(label: 'Back'),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    DiscoveryDetailState state,
    DiscoveryDetailViewModel vm,
  ) {
    return switch (state) {
      DiscoveryDetailLoading() => const Center(child: CircularProgressIndicator()),
      DiscoveryDetailError(error: final e) => ErrorView(error: e),
      DiscoveryDetailSuccess(discovery: final d) => _SuccessScroll(
          discovery: d,
          town: town,
        ),
    };
  }
}

class _SuccessScroll extends StatefulWidget {
  const _SuccessScroll({required this.discovery, required this.town});

  final TownDiscoveryDetailDto discovery;
  final TownDto town;

  @override
  State<_SuccessScroll> createState() => _SuccessScrollState();
}

class _SuccessScrollState extends State<_SuccessScroll> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  late final Future<void> _mapboxReady;

  @override
  void initState() {
    super.initState();
    _mapboxReady = () async {
      final token = await serviceLocator.configService.getMapboxAccessToken();
      if (token != null && token.isNotEmpty) {
        MapboxOptions.setAccessToken(token);
      }
    }();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.discovery;
    final images = d.images.isNotEmpty
        ? d.images
        : <DiscoveryImageDto>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (images.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (i) => setState(() => _pageIndex = i),
                      itemBuilder: (context, i) {
                        final url = UrlUtils.resolveImageUrl(
                          images[i].thumbnailUrl ?? images[i].url,
                        );
                        return CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          placeholder: (context, progress) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == _pageIndex
                                  ? Colors.white
                                  : Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              height: 160,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
              ),
              child: Icon(
                WhatToDoConstants.emptyIcon,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 16),
          DetailSectionShell(
            icon: Icons.info_outline,
            title: 'Quick facts',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (d.difficulty != null && d.difficulty!.isNotEmpty)
                  Text('Difficulty: ${d.difficulty}'),
                if (d.duration != null && d.duration!.isNotEmpty)
                  Text('Duration: ${d.duration}'),
                Text(
                  d.isFreeAccess
                      ? 'Free access'
                      : 'Entry: ${d.entryInfo?.trim().isNotEmpty == true ? d.entryInfo : 'See venue'}',
                ),
                if (d.seasonalNote != null && d.seasonalNote!.isNotEmpty)
                  Text('Season: ${d.seasonalNote}'),
              ],
            ),
          ),
          if (d.description != null && d.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            DetailSectionShell(
              icon: Icons.notes_outlined,
              title: 'About',
              child: Text(d.description!.trim()),
            ),
          ],
          if (d.quickTip != null && d.quickTip!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(d.quickTip!.trim())),
                ],
              ),
            ),
          ],
          if (d.latitude != null && d.longitude != null) ...[
            const SizedBox(height: 12),
            DetailSectionShell(
              icon: Icons.map_outlined,
              title: 'Location',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (d.directionsHint != null && d.directionsHint!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(d.directionsHint!.trim()),
                    ),
                  FutureBuilder<void>(
                    future: _mapboxReady,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const SizedBox(
                          height: 180,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return DiscoveryMapWidget(
                        height: 200,
                        latitude: d.latitude,
                        longitude: d.longitude,
                        fallbackCenterLat: widget.town.latitude,
                        fallbackCenterLng: widget.town.longitude,
                        interactive: false,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: () async {
                      final q = Uri.encodeComponent('${d.latitude},${d.longitude}');
                      await ExternalLinkLauncher.openUri(
                        context,
                        Uri.parse('https://www.google.com/maps/search/?api=1&query=$q'),
                      );
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open in Maps'),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => ExternalLinkLauncher.openUri(
              context,
              Uri.parse(DiscoveryConstants.reportDiscoveryMailto(d.id)),
            ),
            child: const Text('Report this content'),
          ),
        ],
      ),
    );
  }
}
