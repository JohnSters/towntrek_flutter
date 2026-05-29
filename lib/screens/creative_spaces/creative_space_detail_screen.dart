import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../core/utils/external_link_launcher.dart';
import '../../core/utils/listing_aggregate_rating.dart';
import '../../core/utils/url_utils.dart';
import '../../models/models.dart';
import '../business_details/widgets/business_documents_section.dart';
import '../shared/detail_widgets/detail_widgets.dart';
import 'creative_space_detail_state.dart';
import 'creative_space_detail_view_model.dart';

/// Header + body surface (soft material) for gallery multiselect blocks — order matches web `tone-0…6`.
// Intentional fixed palette — not theme-dependent.
const _kGallerySurfaceTones = <({Gradient header, Color title, Color body})>[
  (
    header: LinearGradient(
      colors: [Color(0x8FC4B5FD), Color(0x73A5B4FC)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    title: Color(0xFF312E81),
    body: Color(0xE6EEF2FF),
  ),
  (
    header: LinearGradient(
      colors: [Color(0x8FA7F3D0), Color(0x736EE7B7)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    title: Color(0xFF064E3B),
    body: Color(0xE6ECFDF5),
  ),
  (
    header: LinearGradient(
      colors: [Color(0x8FBFD7FE), Color(0x7393C5FD)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    title: Color(0xFF1E3A5F),
    body: Color(0xE6EFF6FF),
  ),
  (
    header: LinearGradient(
      colors: [Color(0x8FFED7AA), Color(0x73FDBA74)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    title: Color(0xFF7C2D12),
    body: Color(0xF2FFF7ED),
  ),
  (
    header: LinearGradient(
      colors: [Color(0x8FE9D5FF), Color(0x73D8B4FE)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    title: Color(0xFF581C87),
    body: Color(0xE6FAF5FF),
  ),
  (
    header: LinearGradient(
      colors: [Color(0x8F99F6E4), Color(0x735EEAD4)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    title: Color(0xFF115E59),
    body: Color(0xF2F0FDFA),
  ),
  (
    header: LinearGradient(
      colors: [Color(0x8FFECACA), Color(0x73FCA5A5)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    title: Color(0xFF7F1D1D),
    body: Color(0xE6FFF1F2),
  ),
];

/// Narrow screens: single-column accordions instead of the 2-column card grid.
const double _kGalleryMultiselectAccordionMaxWidth = 600;

bool _useGalleryMultiselectAccordionLayout(BuildContext context) {
  return MediaQuery.sizeOf(context).width < _kGalleryMultiselectAccordionMaxWidth;
}

/// Expandable row + chips; reuses [ _kGallerySurfaceTones ] (mobile layout only).
class _GalleryMultiselectAccordionTile extends StatefulWidget {
  final ThemeData theme;
  final String headerLabel;
  final List<String> items;
  final int toneIndex;
  final bool uppercaseHeader;

  const _GalleryMultiselectAccordionTile({
    required this.theme,
    required this.headerLabel,
    required this.items,
    required this.toneIndex,
    this.uppercaseHeader = true,
  });

  @override
  State<_GalleryMultiselectAccordionTile> createState() =>
      _GalleryMultiselectAccordionTileState();
}

class _GalleryMultiselectAccordionTileState
    extends State<_GalleryMultiselectAccordionTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tone =
        _kGallerySurfaceTones[widget.toneIndex % _kGallerySurfaceTones.length];
    final title = widget.uppercaseHeader
        ? widget.headerLabel.toUpperCase()
        : widget.headerLabel;
    final chipLabelStyle = const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      height: 1.2,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Ink(
                  decoration: BoxDecoration(gradient: tone.header),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: tone.title,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: widget.theme.textTheme.titleSmall?.copyWith(
                              color: tone.title,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.35,
                              fontSize: 12,
                              height: 1.2,
                            ),
                          ),
                        ),
                        Text(
                          '${widget.items.length}',
                          style: widget.theme.textTheme.labelLarge?.copyWith(
                            color: tone.title.withValues(alpha: 0.88),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          _expanded ? Icons.expand_less : Icons.expand_more,
                          color: tone.title,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _expanded
                  ? ColoredBox(
                      color: tone.body,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: widget.items
                              .map(
                                (s) => Chip(
                                  label: Text(s, style: chipLabelStyle),
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.zero,
                                  labelPadding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single multiselect “card” ( art forms, styles, … digital ) with shared tone strip + centered chips.
class _GallerySurfaceCard extends StatelessWidget {
  const _GallerySurfaceCard({
    required this.theme,
    required this.headerLabel,
    required this.items,
    required this.toneIndex,
    this.uppercaseHeader = true,
    this.compact = false,
  });

  final ThemeData theme;
  final String headerLabel;
  final List<String> items;
  final int toneIndex;
  final bool uppercaseHeader;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final tone = _kGallerySurfaceTones[toneIndex % _kGallerySurfaceTones.length];
    final h = uppercaseHeader ? headerLabel.toUpperCase() : headerLabel;
    final radius = compact ? 10.0 : 14.0;
    final headerPad = compact
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 9);
    final headerStyle = theme.textTheme.labelLarge?.copyWith(
      color: tone.title,
      fontWeight: FontWeight.w800,
      letterSpacing: compact ? 0.35 : 0.4,
      fontSize: compact ? 10.5 : 12,
      height: compact ? 1.2 : null,
    );
    final bodyPad = compact
        ? const EdgeInsets.fromLTRB(6, 6, 6, 7)
        : const EdgeInsets.fromLTRB(8, 10, 8, 12);
    final chipSpacing = compact ? 4.0 : 6.0;
    final chipLabelStyle = TextStyle(
      fontSize: compact ? 11 : 12,
      fontWeight: FontWeight.w600,
      height: compact ? 1.2 : null,
    );
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 0 : 10),
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tone.body,
              border: Border.all(color: Colors.black.withValues(alpha: 0.07)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: compact ? 2 : 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: double.infinity,
                  padding: headerPad,
                  decoration: BoxDecoration(gradient: tone.header),
                  child: Text(
                    h,
                    textAlign: TextAlign.center,
                    maxLines: compact ? 2 : null,
                    overflow: compact ? TextOverflow.ellipsis : null,
                    style: headerStyle,
                  ),
                ),
                Padding(
                  padding: bodyPad,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: chipSpacing,
                    runSpacing: chipSpacing,
                    children: items
                        .map(
                          (s) => Chip(
                            label: Text(s, style: chipLabelStyle),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: compact
                                ? EdgeInsets.zero
                                : const EdgeInsets.symmetric(horizontal: 4),
                            labelPadding: compact
                                ? const EdgeInsets.symmetric(horizontal: 6)
                                : null,
                          ),
                        )
                        .toList(),
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

bool _creativeSpaceHasSocial(CreativeSpaceDetailDto space) {
  bool nonEmpty(String? s) => s != null && s.trim().isNotEmpty;
  return nonEmpty(space.facebookUrl) ||
      nonEmpty(space.instagramUrl) ||
      nonEmpty(space.twitterUrl);
}

bool _shouldShowGalleryStudio(CreativeSpaceDetailDto space) {
  final g = space.galleryStudio;
  if (g == null || !g.hasAnyVisible) return false;
  return space.categoryKey == CreativeSpacesConstants.categoryKeyArtGalleriesStudios;
}

/// Group composite art-form tokens (`Medium|Option`) for display (mirrors server grouping).
Map<String, List<String>> _groupArtFormTokensForDisplay(List<String> tokens) {
  final map = <String, List<String>>{};
  for (final raw in tokens) {
    final t = raw.trim();
    if (t.isEmpty) continue;
    final i = t.indexOf('|');
    final medium = i < 0 ? '' : t.substring(0, i).trim();
    final opt = (i < 0 ? t : t.substring(i + 1)).trim();
    if (medium.isEmpty) continue;
    map.putIfAbsent(medium, () => []).add(opt);
  }
  for (final list in map.values) {
    list.sort();
  }
  final keys = map.keys.toList()..sort();
  return {for (final k in keys) k: map[k]!};
}

typedef _GalleryMultiselectTileRec = ({
  String header,
  List<String> items,
  int tone,
  bool uppercaseHeader,
});

({List<_GalleryMultiselectTileRec> tiles, bool hasArtFormTiles})
    _buildGalleryMultiselectTileData(
  CreativeSpaceGalleryStudioDetailDto detail,
) {
  final artGroups = _groupArtFormTokensForDisplay(detail.artFormsOffered);
  final artFormEntries = artGroups.entries.toList();
  var toneCursor = 0;
  final multiselectTiles = <_GalleryMultiselectTileRec>[];
  var hasArtFormTiles = false;
  for (var i = 0; i < artFormEntries.length; i++) {
    final e = artFormEntries[i];
    if (e.value.isEmpty) continue;
    hasArtFormTiles = true;
    multiselectTiles.add((
      header: e.key,
      items: e.value,
      tone: toneCursor++,
      uppercaseHeader: true,
    ));
  }
  void addSurfaceCard(String header, List<String> items) {
    if (items.isEmpty) return;
    multiselectTiles.add((
      header: header,
      items: items,
      tone: toneCursor++,
      uppercaseHeader: false,
    ));
  }

  addSurfaceCard('Styles & genres', detail.stylesAndGenres);
  addSurfaceCard('Artist representation', detail.artistRepresentation);
  addSurfaceCard('Price ranges', detail.priceRanges);
  addSurfaceCard('Services', detail.servicesOffered);
  addSurfaceCard('Visitor experience', detail.visitorExperience);
  addSurfaceCard('Exhibition types', detail.exhibitionTypes);
  addSurfaceCard('Digital presence', detail.digitalPresence);
  return (tiles: multiselectTiles, hasArtFormTiles: hasArtFormTiles);
}

class CreativeSpaceDetailPage extends StatelessWidget {
  final int creativeSpaceId;
  final String creativeSpaceName;

  const CreativeSpaceDetailPage({
    super.key,
    required this.creativeSpaceId,
    required this.creativeSpaceName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreativeSpaceDetailViewModel(
        creativeSpaceRepository: serviceLocator.creativeSpaceRepository,
        errorHandler: serviceLocator.errorHandler,
        creativeSpaceId: creativeSpaceId,
        creativeSpaceName: creativeSpaceName,
      ),
      child: const _CreativeSpaceDetailPageContent(),
    );
  }
}

class _CreativeSpaceDetailPageContent extends StatelessWidget {
  const _CreativeSpaceDetailPageContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreativeSpaceDetailViewModel>();
    final state = viewModel.state;

    return Scaffold(
      backgroundColor: context.entityListing.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _CreativeDetailHero(state: state, viewModel: viewModel),
            if (state is CreativeSpaceDetailSuccess)
              _CreativeOpenClosedBanner(space: state.creativeSpace),
            Expanded(
              child: switch (state) {
                CreativeSpaceDetailLoading() =>
                  const _CreativeSpaceLoadingView(),
                CreativeSpaceDetailError(error: final error) =>
                  _CreativeSpaceErrorState(
                    error: error,
                    viewModel: viewModel,
                  ),
                CreativeSpaceDetailSuccess(creativeSpace: final space) =>
                  _CreativeSpaceDetailBody(space: space),
              },
            ),
            const ListingBackFooter(label: 'Back'),
          ],
        ),
      ),
    );
  }
}

class _CreativeDetailHero extends StatelessWidget {
  const _CreativeDetailHero({
    required this.state,
    required this.viewModel,
  });

  final CreativeSpaceDetailState state;
  final CreativeSpaceDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final title = switch (state) {
      CreativeSpaceDetailSuccess(:final creativeSpace) => creativeSpace.name,
      _ => viewModel.creativeSpaceName,
    };
    final categoryLine = switch (state) {
      CreativeSpaceDetailSuccess(:final creativeSpace) =>
        creativeSpace.categoryName ?? 'Creative space',
      _ => 'Creative space',
    };
    final townLine = switch (state) {
      CreativeSpaceDetailSuccess(:final creativeSpace) =>
        creativeSpace.townName ?? creativeSpace.city ?? 'Details',
      _ => 'Details',
    };
    return EntityListingHeroHeader(
      theme: context.entityListingTheme,
      categoryIcon: Icons.palette_rounded,
      subCategoryName: title,
      categoryName: categoryLine,
      townName: townLine,
    );
  }
}

class _CreativeSpaceLoadingView extends StatelessWidget {
  const _CreativeSpaceLoadingView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
      children: [
        DetailLoadingBlock(
          height: 104,
          color: colorScheme.surfaceContainerHigh,
          borderRadius: CreativeSpacesConstants.sectionRadius,
        ),
        const SizedBox(height: 12),
        DetailLoadingBlock(
          height: 140,
          color: colorScheme.surfaceContainerLow,
          borderRadius: CreativeSpacesConstants.sectionRadius,
        ),
        const SizedBox(height: 12),
        DetailLoadingBlock(
          height: 120,
          color: colorScheme.surfaceContainerHighest,
          borderRadius: CreativeSpacesConstants.sectionRadius,
        ),
        const SizedBox(height: 12),
        DetailLoadingBlock(
          height: 84,
          color: colorScheme.surfaceContainerHigh,
          borderRadius: CreativeSpacesConstants.sectionRadius,
        ),
      ],
    );
  }
}

class _CreativeSpaceErrorState extends StatelessWidget {
  const _CreativeSpaceErrorState({
    required this.error,
    required this.viewModel,
  });

  final AppError error;
  final CreativeSpaceDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (error.actionText != null && error.action != null) {
      return ErrorView(error: error);
    }

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        ErrorView(error: error),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: viewModel.retry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text(CreativeSpacesConstants.retryLabel),
        ),
      ],
    );
  }
}

class _CreativeOpenClosedBanner extends StatelessWidget {
  final CreativeSpaceDetailDto space;

  const _CreativeOpenClosedBanner({required this.space});

  @override
  Widget build(BuildContext context) {
    // Same source as list cards: server [CreativeSpaceOpenStatusHelper] (SAST, weekly hours only).
    final openNow = space.isOpenNow;

    return EntityOpenClosedBanner(
      isOpen: openNow,
      viewCount: space.viewCount,
    );
  }
}

class _CreativeSpaceDetailBody extends StatelessWidget {
  final CreativeSpaceDetailDto space;

  const _CreativeSpaceDetailBody({required this.space});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
      children: [
        _InfoSection(space: space),
        const SizedBox(height: CreativeSpacesConstants.sectionSpacing),
        _QuickActionsSection(space: space),
        if (_shouldShowGalleryStudio(space)) ...[
          const SizedBox(height: CreativeSpacesConstants.sectionSpacing),
          _GalleryStudioSection(detail: space.galleryStudio!),
        ],
        if (space.images.isNotEmpty) ...[
          const SizedBox(height: CreativeSpacesConstants.sectionSpacing),
          _GallerySection(images: space.images),
        ],
        if (_creativeSpaceHasSocial(space)) ...[
          const SizedBox(height: CreativeSpacesConstants.sectionSpacing),
          _CreativeSocialSection(space: space),
        ],
        if (space.operatingHours.isNotEmpty ||
            space.bestVisitWindow != null) ...[
          const SizedBox(height: CreativeSpacesConstants.sectionSpacing),
          _RegularCreativeHoursSection(
            title: CreativeSpacesConstants.operatingHoursTitle,
            hours: space.operatingHours,
            summary: space.bestVisitWindow,
          ),
        ],
        if (space.specialOperatingHours.isNotEmpty) ...[
          const SizedBox(height: CreativeSpacesConstants.sectionSpacing),
          _SpecialCreativeHoursSection(
            title: CreativeSpacesConstants.specialHoursTitle,
            hours: space.specialOperatingHours,
          ),
        ],
        if (space.reviews.isNotEmpty) ...[
          const SizedBox(height: CreativeSpacesConstants.sectionSpacing),
          _ReviewsSection(reviews: space.reviews),
        ],
        if (space.documents.isNotEmpty) ...[
          const SizedBox(height: CreativeSpacesConstants.sectionSpacing),
          BusinessDocumentsSection(documents: space.documents),
        ],
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final CreativeSpaceDetailDto space;

  const _InfoSection({required this.space});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final location = _buildLocationText();
    final rating = space.rating;
    final rawDescription = space.description.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          CreativeSpacesConstants.sectionRadius,
        ),
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.72),
            colorScheme.secondaryContainer.withValues(alpha: 0.50),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (space.categoryName != null ||
              space.subCategoryName != null ||
              space.visitType != null) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (space.categoryName != null &&
                    space.categoryName!.trim().isNotEmpty)
                  DetailInfoPill(
                    icon: Icons.category_rounded,
                    text: space.categoryName!.trim(),
                  ),
                if (space.subCategoryName != null &&
                    space.subCategoryName!.trim().isNotEmpty)
                  DetailInfoPill(
                    icon: Icons.layers_rounded,
                    text: space.subCategoryName!.trim(),
                  ),
                if (space.visitType != null &&
                    space.visitType!.trim().isNotEmpty)
                  DetailInfoPill(
                    icon: Icons.schedule_rounded,
                    text: space.visitType!.trim(),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (location.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.place_rounded, size: 16, color: colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    location,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (rawDescription.isEmpty)
            Text(
              CreativeSpacesConstants.noDescriptionText,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.45,
                color: colorScheme.onSurface.withValues(alpha: 0.72),
              ),
            )
          else
            CollapsibleDetailTextBlock(
              text: rawDescription,
              headerLabel: 'About',
              textStyle: theme.textTheme.bodyMedium?.copyWith(
                height: 1.45,
                color: colorScheme.onSurface.withValues(alpha: 0.88),
              ),
            ),
          if (space.contactMessage != null &&
              space.contactMessage!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              space.contactMessage!.trim(),
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.4,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (shouldShowAggregateRating(rating, space.totalReviews))
            Row(
              children: [
                ...List.generate(5, (index) {
                  final starIndex = index + 1;
                  final score = space.rating!;
                  final isFilled = starIndex <= score;
                  final isHalf =
                      starIndex - 0.5 <= score && starIndex > score;
                  return Icon(
                    isFilled
                        ? Icons.star_rounded
                        : isHalf
                        ? Icons.star_half_rounded
                        : Icons.star_border_rounded,
                    size: 14,
                    color: isFilled || isHalf
                        ? colorScheme.tertiary
                        : colorScheme.onSurfaceVariant,
                  );
                }),
                const SizedBox(width: 6),
                Text(
                  space.totalReviews > 0
                      ? CreativeSpacesConstants.ratingSummaryTemplate
                          .replaceAll(
                            '{rating}',
                            space.rating!.toStringAsFixed(1),
                          )
                          .replaceAll(
                            '{reviews}',
                            space.totalReviews.toString(),
                          )
                      : space.rating!.toStringAsFixed(1),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
          if ((space.craftType?.trim() ?? '').isNotEmpty ||
              (space.materials?.trim() ?? '').isNotEmpty ||
              (space.languages?.trim() ?? '').isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (space.craftType != null &&
                    space.craftType!.trim().isNotEmpty)
                  DetailInfoChip(
                    text: space.craftType!.trim(),
                    icon: Icons.brush_rounded,
                  ),
                if (space.materials != null &&
                    space.materials!.trim().isNotEmpty)
                  DetailInfoChip(
                    text: space.materials!.trim(),
                    icon: Icons.foundation_rounded,
                  ),
                if (space.languages != null &&
                    space.languages!.trim().isNotEmpty)
                  DetailInfoChip(
                    text: space.languages!.trim(),
                    icon: Icons.translate_rounded,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _buildLocationText() {
    return [
      if (space.physicalAddress != null &&
          space.physicalAddress!.trim().isNotEmpty)
        space.physicalAddress!.trim(),
      if (space.city != null && space.city!.trim().isNotEmpty)
        space.city!.trim(),
      if (space.province != null && space.province!.trim().isNotEmpty)
        space.province!.trim(),
      if (space.postalCode != null && space.postalCode!.trim().isNotEmpty)
        space.postalCode!.trim(),
    ].join(CreativeSpacesConstants.itemInfoDivider);
  }
}

class _QuickActionsSection extends StatelessWidget {
  final CreativeSpaceDetailDto space;

  const _QuickActionsSection({required this.space});

  @override
  Widget build(BuildContext context) {
    final qa = context.detailQuickActions;
    final canNavigate = (space.latitude != null && space.longitude != null) ||
        (space.physicalAddress != null &&
            space.physicalAddress!.trim().isNotEmpty);

    return DetailSectionShell(
      title: CreativeSpacesConstants.quickActionsTitle,
      icon: Icons.bolt_rounded,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          DetailQuickActionButton(
            tooltip: DetailTownTrekWebAction.tooltip,
            assetImagePath: DetailTownTrekWebAction.assetPath,
            backgroundColor: qa.towntrekWebBackground,
            iconColor: qa.websiteIcon,
            onPressed: () => context
                .read<CreativeSpaceDetailViewModel>()
                .openFullDetailsOnWeb(context),
          ),
          if (canNavigate)
            DetailQuickActionButton(
              tooltip: CreativeSpacesConstants.mapActionLabel,
              icon: Icons.directions_rounded,
              backgroundColor: qa.directionsBackground,
              iconColor: qa.directionsIcon,
              onPressed: () => _openMap(context),
            ),
          if (space.contactPhone != null &&
              space.contactPhone!.trim().isNotEmpty)
            DetailQuickActionButton(
              tooltip: CreativeSpacesConstants.callActionLabel,
              icon: Icons.call_rounded,
              backgroundColor: qa.callBackground,
              iconColor: qa.callIcon,
              onPressed: () => ExternalLinkLauncher.callPhone(
                context,
                space.contactPhone!.trim(),
              ),
            ),
          if (space.contactPhoneSecondary != null &&
              space.contactPhoneSecondary!.trim().isNotEmpty)
            DetailQuickActionButton(
              tooltip: CreativeSpacesConstants.altCallActionTooltip,
              icon: Icons.phone_callback_rounded,
              backgroundColor: qa.callAltBackground,
              iconColor: qa.callAltIcon,
              onPressed: () => ExternalLinkLauncher.callPhone(
                context,
                space.contactPhoneSecondary!.trim(),
              ),
            ),
          if (space.contactEmail != null &&
              space.contactEmail!.trim().isNotEmpty)
            DetailQuickActionButton(
              tooltip: CreativeSpacesConstants.emailActionLabel,
              icon: Icons.mail_rounded,
              backgroundColor: qa.emailBackground,
              iconColor: qa.emailIcon,
              onPressed: () => ExternalLinkLauncher.sendEmail(
                context,
                space.contactEmail!.trim(),
              ),
            ),
          if (space.contactWebsite != null &&
              space.contactWebsite!.trim().isNotEmpty)
            DetailQuickActionButton(
              tooltip: CreativeSpacesConstants.websiteActionLabel,
              icon: Icons.language_rounded,
              backgroundColor: qa.websiteBackground,
              iconColor: qa.websiteIcon,
              onPressed: () => ExternalLinkLauncher.openWebsite(
                context,
                space.contactWebsite!.trim(),
              ),
            ),
          DetailQuickActionButton(
            tooltip: CreativeSpacesConstants.rateCreativeSpaceActionTooltip,
            icon: Icons.star_rounded,
            backgroundColor: qa.rateBackground,
            iconColor: qa.rateIcon,
            onPressed: () => context
                .read<CreativeSpaceDetailViewModel>()
                .openReviewsOnWeb(context),
          ),
        ],
      ),
    );
  }

  void _openMap(BuildContext context) {
    final lat = space.latitude;
    final lng = space.longitude;
    final fallbackLocation = _getAddressFallback();
    final queryText = lat != null && lng != null
        ? CreativeSpacesConstants.mapCoordinateTemplate
              .replaceAll('{name}', space.name)
              .replaceAll('{lat}', lat.toString())
              .replaceAll('{lng}', lng.toString())
        : fallbackLocation;
    if (queryText.trim().isEmpty) return;

    final encodedQuery = Uri.encodeComponent(queryText);

    final query = encodedQuery;
    final url = '${CreativeSpacesConstants.mapsSearchBaseUrl}$query';
    ExternalLinkLauncher.openRaw(context, url, normalizeHttp: false);
  }

  String _getAddressFallback() {
    final candidates = <String?>[
      space.physicalAddress,
      space.townName,
      space.city,
      space.province,
      space.name,
    ];

    for (final candidate in candidates) {
      if (candidate != null && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }

    return '';
  }
}

class _CreativeSocialSection extends StatelessWidget {
  final CreativeSpaceDetailDto space;

  const _CreativeSocialSection({required this.space});

  @override
  Widget build(BuildContext context) {
    final qa = context.detailQuickActions;
    return DetailSectionShell(
      title: CreativeSpacesConstants.socialTitle,
      icon: Icons.share_outlined,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          if (space.facebookUrl != null &&
              space.facebookUrl!.trim().isNotEmpty)
            DetailSocialIconButton(
              tooltip: 'Facebook',
              icon: FontAwesomeIcons.facebookF,
              backgroundColor: qa.facebookBackground,
              iconColor: qa.facebookIcon,
              onPressed: () => ExternalLinkLauncher.openRaw(
                context,
                space.facebookUrl!.trim(),
              ),
            ),
          if (space.instagramUrl != null &&
              space.instagramUrl!.trim().isNotEmpty)
            DetailSocialIconButton(
              tooltip: 'Instagram',
              icon: FontAwesomeIcons.instagram,
              backgroundColor: qa.instagramBackground,
              iconColor: qa.instagramIcon,
              onPressed: () => ExternalLinkLauncher.openRaw(
                context,
                space.instagramUrl!.trim(),
              ),
            ),
          if (space.twitterUrl != null && space.twitterUrl!.trim().isNotEmpty)
            DetailSocialIconButton(
              tooltip: CreativeSpacesConstants.twitterActionTooltip,
              icon: FontAwesomeIcons.xTwitter,
              backgroundColor: qa.twitterBackground,
              iconColor: qa.twitterIcon,
              onPressed: () => ExternalLinkLauncher.openRaw(
                context,
                space.twitterUrl!.trim(),
              ),
            ),
        ],
      ),
    );
  }
}

class _GalleryStudioSection extends StatelessWidget {
  final CreativeSpaceGalleryStudioDetailDto detail;

  const _GalleryStudioSection({required this.detail});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tileData = _buildGalleryMultiselectTileData(detail);
    final multiselectTiles = tileData.tiles;
    final hasArtFormTiles = tileData.hasArtFormTiles;

    final hasFeaturedArtists = detail.featuredArtists != null &&
        detail.featuredArtists!.trim().isNotEmpty;
    final hasExhibitionFormat = detail.exhibitionFormat != null &&
        detail.exhibitionFormat!.trim().isNotEmpty;
    final hasStudioVisitsChip = detail.offersStudioVisits;
    final hasGalleryNarrativeFooter =
        hasFeaturedArtists || hasExhibitionFormat || hasStudioVisitsChip;
    final hasGalleryIntroText = (detail.galleryType != null &&
            detail.galleryType!.trim().isNotEmpty) ||
        (detail.curatorialTheme != null &&
            detail.curatorialTheme!.trim().isNotEmpty);
    final showTopNarrativeDivider = hasGalleryNarrativeFooter &&
        (multiselectTiles.isNotEmpty || hasGalleryIntroText);

    return DetailSectionShell(
      title: CreativeSpacesConstants.galleryStudioSectionTitle,
      icon: Icons.museum_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detail.galleryType != null &&
              detail.galleryType!.trim().isNotEmpty) ...[
            Text(
              detail.galleryType!.trim(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (detail.curatorialTheme != null &&
              detail.curatorialTheme!.trim().isNotEmpty)
            Text(
              detail.curatorialTheme!.trim(),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          if (detail.curatorialTheme != null &&
              detail.curatorialTheme!.trim().isNotEmpty)
            const SizedBox(height: 10),
          if (hasArtFormTiles) ...[
            Text(
              'Art forms',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
          ],
          if (multiselectTiles.isNotEmpty)
            _useGalleryMultiselectAccordionLayout(context)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < multiselectTiles.length; i++) ...[
                        _GalleryMultiselectAccordionTile(
                          theme: theme,
                          headerLabel: multiselectTiles[i].header,
                          items: multiselectTiles[i].items,
                          toneIndex: multiselectTiles[i].tone,
                          uppercaseHeader: multiselectTiles[i].uppercaseHeader,
                        ),
                        if (i < multiselectTiles.length - 1)
                          const SizedBox(height: 8),
                      ],
                    ],
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      const gap = 6.0;
                      final colW = (constraints.maxWidth - gap) / 2;
                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          for (final tile in multiselectTiles)
                            SizedBox(
                              width: colW,
                              child: _GallerySurfaceCard(
                                theme: theme,
                                headerLabel: tile.header,
                                items: tile.items,
                                toneIndex: tile.tone,
                                compact: true,
                                uppercaseHeader: tile.uppercaseHeader,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          if (showTopNarrativeDivider) ...[
            const SizedBox(height: 20),
            Divider(
              height: 1,
              thickness: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 16),
          ],
          if (hasFeaturedArtists) ...[
            Text(
              'Featured artists',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              detail.featuredArtists!.trim(),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ],
          if (hasFeaturedArtists && hasExhibitionFormat) ...[
            const SizedBox(height: 18),
            Divider(
              height: 1,
              thickness: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.38),
            ),
            const SizedBox(height: 18),
          ],
          if (hasExhibitionFormat) ...[
            Text(
              'Exhibition format',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              detail.exhibitionFormat!.trim(),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ],
          if ((hasFeaturedArtists || hasExhibitionFormat) &&
              hasStudioVisitsChip) ...[
            const SizedBox(height: 18),
            Divider(
              height: 1,
              thickness: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.38),
            ),
            const SizedBox(height: 14),
          ],
          if (hasStudioVisitsChip)
            Chip(
              label: const Text('Studio visits available'),
              avatar: Icon(Icons.meeting_room_rounded, size: 18, color: cs.primary),
            ),
        ],
      ),
    );
  }
}

class _GallerySection extends StatelessWidget {
  final List<CreativeSpaceImageDto> images;

  const _GallerySection({required this.images});

  @override
  Widget build(BuildContext context) {
    final urls = images
        .map((image) => UrlUtils.resolveImageUrl(image.url))
        .where((url) => url.trim().isNotEmpty)
        .toList();
    if (urls.isEmpty) return const SizedBox.shrink();
    final effectiveItemCount = urls.length;

    final colorScheme = Theme.of(context).colorScheme;
    return DetailSectionShell(
      title: CreativeSpacesConstants.galleryTitle,
      icon: Icons.photo_library_outlined,
      child: SizedBox(
        height: 104,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: effectiveItemCount,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final url = urls[index];
            return SizedBox(
              width: 158,
              child: TappableImage(
                imageUrls: urls,
                initialIndex: index,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: colorScheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, _, _) => ColoredBox(
                      color: colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RegularCreativeHoursSection extends StatelessWidget {
  const _RegularCreativeHoursSection({
    required this.title,
    required this.hours,
    this.summary,
  });

  final String title;
  final List<CreativeSpaceOperatingHourDto> hours;
  final String? summary;

  @override
  Widget build(BuildContext context) {
    return DetailSectionShell(
      title: title,
      icon: Icons.schedule,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (summary != null && summary!.trim().isNotEmpty) ...[
            Text(
              summary!.trim(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
          ],
          if (hours.isNotEmpty)
            DetailHoursGrid(rows: detailHoursFromCreativeSpace(hours)),
        ],
      ),
    );
  }
}

class _SpecialCreativeHoursSection extends StatelessWidget {
  const _SpecialCreativeHoursSection({
    required this.title,
    required this.hours,
  });

  final String title;
  final List<CreativeSpaceOperatingHourDto> hours;

  @override
  Widget build(BuildContext context) {
    return DetailSectionShell(
      title: title,
      icon: Icons.event_note_rounded,
      child: Column(
        children: hours
            .map(
              (hour) => DetailHourRow(
                dayOfWeek: hour.dayOfWeek,
                openTime: hour.openTime,
                closeTime: hour.closeTime,
                isOpen: hour.isOpen,
                note: hour.specialHoursNote,
                isSpecial: true,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  final List<ReviewDto> reviews;

  const _ReviewsSection({required this.reviews});

  @override
  Widget build(BuildContext context) {
    final shownReviews = reviews.take(4).toList();
    return DetailSectionShell(
      title: CreativeSpacesConstants.reviewsTitle,
      icon: Icons.rate_review_rounded,
      child: Column(
        children: shownReviews
            .map((review) => DetailReviewTile(review: review))
            .toList(),
      ),
    );
  }
}
