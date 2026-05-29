import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../core/constants/discovery_constants.dart';
import '../../core/utils/external_link_launcher.dart';
import '../../core/utils/url_utils.dart';
import '../../core/widgets/discovery_map_picker_page.dart';
import '../../core/widgets/discovery_map_widget.dart';
import '../../models/models.dart';
import 'discovery_detail_view_model.dart';

/// Meta chips aligned with [WhatToDoScreen] list cards.
/// Seasonal notes are shown in full in a dedicated section (not as a chip).
List<Widget> _discoveryDetailQuickFactChips(TownDiscoveryDetailDto d) {
  final chips = <Widget>[
    ListingInfoChip(icon: Icons.sell_outlined, label: d.categoryName),
  ];
  if (d.difficulty != null && d.difficulty!.trim().isNotEmpty) {
    chips.add(
      ListingInfoChip(
        icon: Icons.terrain_outlined,
        label: d.difficulty!.trim(),
      ),
    );
  }
  if (d.duration != null && d.duration!.trim().isNotEmpty) {
    chips.add(
      ListingInfoChip(
        icon: Icons.schedule_outlined,
        label: d.duration!.trim(),
      ),
    );
  }
  chips.add(
    ListingInfoChip(
      icon: d.isFreeAccess ? Icons.money_off_outlined : Icons.payments_outlined,
      label: d.isFreeAccess ? 'Free' : 'Paid',
    ),
  );
  return chips;
}

/// Gallery from API [images], or a single slide from cover/thumbnail when list is empty.
List<DiscoveryImageDto> _galleryImagesForDetail(TownDiscoveryDetailDto d) {
  if (d.images.isNotEmpty) return d.images;
  final raw = d.coverImageUrl ?? d.thumbnailUrl;
  if (raw != null && raw.trim().isNotEmpty) {
    return [
      DiscoveryImageDto(
        url: raw.trim(),
        thumbnailUrl: d.thumbnailUrl?.trim().isNotEmpty == true
            ? d.thumbnailUrl!.trim()
            : null,
        sortOrder: 0,
      ),
    ];
  }
  return const [];
}

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
  const _DiscoveryDetailBody({required this.initialTitle, required this.town});

  final String initialTitle;
  final TownDto town;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DiscoveryDetailViewModel>();
    final state = vm.state;

    return Scaffold(
      backgroundColor: context.entityListing.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            EntityListingHeroHeader(
              theme: context.entityListingTheme,
              categoryIcon: Icons.travel_explore_rounded,
              subCategoryName: state is DiscoveryDetailSuccess
                  ? state.discovery.title
                  : initialTitle,
              categoryName: TownFeatureConstants.whatToDoTitle,
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
      DiscoveryDetailLoading() => Center(
        child: CircularProgressIndicator(
          color: context.entityListingTheme.accent,
        ),
      ),
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

  static const double _galleryRadius = 14;
  static const double _sectionGap = 12;

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final listingTheme = context.entityListingTheme;
    final images = _galleryImagesForDetail(d);
    final hasPin = d.latitude != null && d.longitude != null;
    final directionsText = d.directionsHint?.trim();
    final hasDirectionsText =
        directionsText != null && directionsText.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (images.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_galleryRadius),
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
                          placeholder: (context, progress) => Center(
                            child: CircularProgressIndicator(
                              color: listingTheme.accent,
                              strokeWidth: 2,
                            ),
                          ),
                          errorWidget: (context, url, error) => ColoredBox(
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: listingTheme.accent,
                              size: 40,
                            ),
                          ),
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
                                  ? colorScheme.surface.withValues(alpha: 0.95)
                                  : colorScheme.surface.withValues(alpha: 0.55),
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
              height: 168,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.entityListing.cardBg,
                borderRadius: BorderRadius.circular(_galleryRadius),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: Icon(
                WhatToDoConstants.emptyIcon,
                size: 48,
                color: listingTheme.accent,
              ),
            ),
          if (d.isFeatured) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.star_rounded, size: 18, color: colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  'Featured in ${widget.town.name}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: _sectionGap),
          DetailSectionShell(
            icon: Icons.info_outline,
            title: 'Quick facts',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _discoveryDetailQuickFactChips(d),
                ),
                if (!d.isFreeAccess &&
                    d.entryInfo != null &&
                    d.entryInfo!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Entry',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    d.entryInfo!.trim(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
                if (d.submitterDisplayName != null &&
                    d.submitterDisplayName!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Suggested by ${d.submitterDisplayName!.trim()}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (d.description != null && d.description!.trim().isNotEmpty) ...[
            const SizedBox(height: _sectionGap),
            DetailSectionShell(
              icon: Icons.notes_outlined,
              title: 'About',
              child: Text(
                d.description!.trim(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.45,
                  color: colorScheme.onSurface.withValues(alpha: 0.92),
                ),
              ),
            ),
          ],
          if (d.seasonalNote != null && d.seasonalNote!.trim().isNotEmpty) ...[
            const SizedBox(height: _sectionGap),
            DetailSectionShell(
              icon: Icons.wb_sunny_outlined,
              title: 'Seasonal note',
              child: Text(
                d.seasonalNote!.trim(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  color: colorScheme.onSurface.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
          if (d.quickTip != null && d.quickTip!.trim().isNotEmpty) ...[
            const SizedBox(height: _sectionGap),
            DetailSectionShell(
              icon: Icons.lightbulb_outline,
              title: 'Quick tip',
              child: Text(
                d.quickTip!.trim(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  color: colorScheme.onSurface.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
          if (hasDirectionsText && !hasPin) ...[
            const SizedBox(height: _sectionGap),
            DetailSectionShell(
              icon: Icons.directions_outlined,
              title: 'Directions',
              child: Text(
                directionsText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  color: colorScheme.onSurface.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
          if (hasPin) ...[
            const SizedBox(height: _sectionGap),
            DetailSectionShell(
              icon: Icons.map_outlined,
              title: 'Location',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (hasDirectionsText)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Directions',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            directionsText,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.45,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.9,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  FutureBuilder<void>(
                    future: _mapboxReady,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return SizedBox(
                          height: 180,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: listingTheme.accent,
                            ),
                          ),
                        );
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: DiscoveryMapWidget(
                          height: 200,
                          latitude: d.latitude,
                          longitude: d.longitude,
                          fallbackCenterLat: widget.town.latitude,
                          fallbackCenterLng: widget.town.longitude,
                          interactive: false,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DiscoveryMapPickerPage(
                            title: d.title,
                            initialLatitude: d.latitude,
                            initialLongitude: d.longitude,
                            fallbackCenterLat: widget.town.latitude,
                            fallbackCenterLng: widget.town.longitude,
                            selectionEnabled: false,
                            enableSearch: false,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.fullscreen),
                    label: const Text('Expand map'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () async {
                      final q = Uri.encodeComponent(
                        '${d.latitude},${d.longitude}',
                      );
                      await ExternalLinkLauncher.openUri(
                        context,
                        Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=$q',
                        ),
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
          Center(
            child: TextButton(
              onPressed: () => ExternalLinkLauncher.openUri(
                context,
                Uri.parse(DiscoveryConstants.reportDiscoveryMailto(d.id)),
              ),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurfaceVariant,
              ),
              child: const Text('Report this content'),
            ),
          ),
        ],
      ),
    );
  }
}
