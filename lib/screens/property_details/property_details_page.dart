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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PropertyDetailsViewModel>();
    final state = viewModel.state;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: state is PropertyDetailsSuccess
                  ? (state.listing.address.trim().isNotEmpty
                        ? state.listing.address
                        : state.listing.ownerName)
                  : viewModel.titleFallback,
              subtitle: 'Property listing',
              height: 112.0,
              headerType: HeaderType.business,
            ),
            if (state is PropertyDetailsSuccess && state.listing.isFeatured)
              const _FeaturedBar(),
            Expanded(
              child: _buildContent(context, state, viewModel),
            ),
            if (state is PropertyDetailsSuccess) const BackNavigationFooter(),
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

  String get _blurb {
    final short = listing.shortDescription?.trim();
    if (short != null && short.isNotEmpty) return short;
    final long = listing.description?.trim();
    if (long != null && long.isNotEmpty) return long;
    return 'No description available yet.';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
              Text(
                _blurb,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color: colorScheme.onSurface.withValues(alpha: 0.88),
                    ),
              ),
            ],
          ),
        ),
        if (listing.ownerName.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          _SectionShell(
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
          _SectionShell(
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
        _SectionShell(
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
        _SectionShell(
          title: 'Quick actions',
          icon: Icons.bolt_rounded,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (listing.latitude != null && listing.longitude != null)
                _QuickActionIconButton(
                  tooltip: 'Take me there',
                  icon: Icons.directions_rounded,
                  color: const Color(0xFFE0F2F1),
                  iconColor: const Color(0xFF00695C),
                  onPressed: () => viewModel.openDirections(context, listing),
                ),
              if (listing.telephoneNumber.trim().isNotEmpty)
                _QuickActionIconButton(
                  tooltip: 'Call',
                  icon: Icons.call_rounded,
                  color: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF2E7D32),
                  onPressed: () => ExternalLinkLauncher.callPhone(
                    context,
                    listing.telephoneNumber.trim(),
                  ),
                ),
            ],
          ),
        ),
        if (listing.viewCount > 0) ...[
          const SizedBox(height: 10),
          Text(
            '${listing.viewCount} views',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => viewModel.openFullListingOnWeb(context),
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('View full listing on web'),
          ),
        ),
      ],
    );
  }
}

class _SectionShell extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionShell({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
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

class _QuickActionIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onPressed;

  const _QuickActionIconButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 56,
        height: 56,
        child: IconButton(
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: Icon(icon, size: 24, color: iconColor),
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
