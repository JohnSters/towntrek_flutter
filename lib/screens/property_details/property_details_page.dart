import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../core/utils/external_link_launcher.dart';
import '../../core/utils/property_listing_format.dart';
import '../../core/utils/url_utils.dart';
import '../../models/models.dart';
import 'property_details_state.dart';
import 'property_details_view_model.dart';

class PropertyDetailsPage extends StatelessWidget {
  final int listingId;
  final String titleFallback;

  const PropertyDetailsPage({
    super.key,
    required this.listingId,
    required this.titleFallback,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PropertyDetailsViewModel(
        listingId: listingId,
        titleFallback: titleFallback,
        propertyRepository: serviceLocator.propertyRepository,
        navigationService: serviceLocator.navigationService,
        errorHandler: serviceLocator.errorHandler,
      ),
      child: const _PropertyDetailsPageContent(),
    );
  }
}

class _PropertyDetailsPageContent extends StatelessWidget {
  const _PropertyDetailsPageContent();

  String _listingTitle(PropertyDetailsState state, PropertyDetailsViewModel viewModel) {
    if (state is PropertyDetailsSuccess) {
      final a = state.listing.address.trim();
      return a.isNotEmpty ? a : state.listing.ownerName;
    }
    return viewModel.titleFallback;
  }

  Widget _detailHero(
    BuildContext context,
    PropertyDetailsState state,
    PropertyDetailsViewModel viewModel,
  ) {
    final typeLabel = state is PropertyDetailsSuccess
        ? (state.listing.listingType == 0 ? 'For rent' : 'For sale')
        : 'Property';
    final townLine =
        state is PropertyDetailsSuccess ? state.listing.townName : 'Details';
    return EntityListingHeroHeader(
      theme: context.entityListingTheme,
      categoryIcon: Icons.home_work_rounded,
      subCategoryName: _listingTitle(state, viewModel),
      categoryName: typeLabel,
      townName: townLine,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PropertyDetailsViewModel>();
    final state = viewModel.state;

    return Scaffold(
      backgroundColor: context.entityListing.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _detailHero(context, state, viewModel),
            if (state is PropertyDetailsSuccess && state.listing.isFeatured)
              const _FeaturedBar(),
            if (state is PropertyDetailsSuccess)
              EntityOpenClosedBanner(
                isOpen: null,
                viewCount: state.listing.viewCount > 0
                    ? state.listing.viewCount
                    : null,
              ),
            Expanded(
              child: _buildContent(context, state, viewModel),
            ),
            const ListingBackFooter(label: 'Back'),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    PropertyDetailsState state,
    PropertyDetailsViewModel viewModel,
  ) {
    return switch (state) {
      PropertyDetailsLoading() => const _PropertyDetailsLoadingView(),
      PropertyDetailsError(error: final error) => ErrorView(error: error),
      PropertyDetailsSuccess(listing: final listing) => _PropertyDetailsBody(
        listing: listing,
        viewModel: viewModel,
      ),
    };
  }
}

class _FeaturedBar extends StatelessWidget {
  const _FeaturedBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.zero,
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Text(
        'Featured listing',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFFF57F17),
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _PropertyDetailsLoadingView extends StatelessWidget {
  const _PropertyDetailsLoadingView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
      children: [
        _LoadingBlock(height: 112, color: colorScheme.surfaceContainerHigh),
        const SizedBox(height: 12),
        _LoadingBlock(height: 84, color: colorScheme.surfaceContainerLow),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, _) => SizedBox(
              width: 142,
              child: _LoadingBlock(
                height: 96,
                color: colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PropertyDetailsBody extends StatelessWidget {
  final PropertyListingDetailDto listing;
  final PropertyDetailsViewModel viewModel;

  const _PropertyDetailsBody({
    required this.listing,
    required this.viewModel,
  });

  String _combinedDescriptionText() {
    final short = listing.shortDescription?.trim();
    final long = listing.description?.trim();
    if ((short == null || short.isEmpty) &&
        (long == null || long.isEmpty)) {
      return '';
    }
    if (short != null &&
        short.isNotEmpty &&
        long != null &&
        long.isNotEmpty &&
        short != long) {
      return '$short\n\n$long';
    }
    if (long != null && long.isNotEmpty) return long;
    if (short != null && short.isNotEmpty) return short;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final qa = context.detailQuickActions;
    final sortedImages = [...listing.images]..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    final galleryPairs = <({PropertyListingImageDto img, String url})>[];
    for (final img in sortedImages) {
      final primary = img.imageUrl.trim();
      if (primary.isNotEmpty) {
        galleryPairs.add((img: img, url: UrlUtils.resolveImageUrl(primary)));
        continue;
      }
      final thumb = img.thumbnailUrl?.trim();
      if (thumb != null && thumb.isNotEmpty) {
        galleryPairs.add((img: img, url: UrlUtils.resolveImageUrl(thumb)));
      }
    }
    final galleryUrls = galleryPairs.map((p) => p.url).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer.withValues(alpha: 0.72),
                colorScheme.secondaryContainer.withValues(alpha: 0.50),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    formatPropertyListingPrice(
                      listingType: listing.listingType,
                      price: listing.price,
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      propertyListingTypeLabel(listing.listingType),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CollapsibleDetailTextBlock(
                text: _combinedDescriptionText(),
                headerLabel: 'Description',
                textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color: colorScheme.onSurface.withValues(alpha: 0.88),
                    ),
              ),
            ],
          ),
        ),
        if (listing.ownerName.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          DetailSectionShell(
            title: 'Listed by',
            icon: Icons.person_outline_rounded,
            child: Text(
              listing.ownerName.trim(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
        if (galleryPairs.isNotEmpty) ...[
          const SizedBox(height: 12),
          DetailSectionShell(
            title: 'Gallery',
            icon: Icons.photo_library_outlined,
            child: SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: galleryPairs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return _GalleryTile(
                    imageUrl: galleryPairs[index].url,
                    allImageUrls: galleryUrls,
                    index: index,
                  );
                },
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        DetailSectionShell(
          title: 'Location',
          icon: Icons.place_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (listing.townName.trim().isNotEmpty)
                Text(
                  listing.townName.trim(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              if (listing.address.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  listing.address.trim(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.35,
                      ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        DetailSectionShell(
          title: 'Quick Actions',
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
                onPressed: () => viewModel.openFullListingOnWeb(context),
              ),
              if (listing.latitude != null && listing.longitude != null)
                DetailQuickActionButton(
                  tooltip: 'Take Me There',
                  icon: Icons.directions_rounded,
                  backgroundColor: qa.directionsBackground,
                  iconColor: qa.directionsIcon,
                  onPressed: () => viewModel.openDirections(context, listing),
                ),
              if (listing.telephoneNumber.trim().isNotEmpty)
                DetailQuickActionButton(
                  tooltip: 'Call',
                  icon: Icons.call_rounded,
                  backgroundColor: qa.callBackground,
                  iconColor: qa.callIcon,
                  onPressed: () => ExternalLinkLauncher.callPhone(
                    context,
                    listing.telephoneNumber.trim(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GalleryTile extends StatelessWidget {
  final String imageUrl;
  final List<String> allImageUrls;
  final int index;

  const _GalleryTile({
    required this.imageUrl,
    required this.allImageUrls,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TappableImage(
      imageUrls: allImageUrls,
      initialIndex: index,
      heroTag: 'property_gallery_$index',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 158,
          color: colorScheme.surfaceContainerHighest,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: colorScheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
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
                    const SizedBox(height: 8),
                    Text(
                      'Loading image...',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              );
            },
            errorBuilder: (context, _, _) {
              return Container(
                color: colorScheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  final double height;
  final Color color;

  const _LoadingBlock({
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
