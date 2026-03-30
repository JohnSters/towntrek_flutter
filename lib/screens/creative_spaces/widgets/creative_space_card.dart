import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../core/utils/url_utils.dart';
import '../../../models/models.dart';
import '../creative_space_detail_page.dart';

/// Listing card for creative spaces (design doc §5, §8).
class CreativeSpaceCard extends StatelessWidget {
  final CreativeSpaceDto space;
  final EntityListingTheme listingTheme;

  const CreativeSpaceCard({
    super.key,
    required this.space,
    required this.listingTheme,
  });

  String? get _imageUrl {
    if (space.thumbnailImage != null &&
        space.thumbnailImage!.url.trim().isNotEmpty) {
      return UrlUtils.resolveImageUrl(space.thumbnailImage!.url.trim());
    }
    if (space.logoUrl != null && space.logoUrl!.trim().isNotEmpty) {
      return UrlUtils.resolveImageUrl(space.logoUrl!.trim());
    }
    if (space.coverImageUrl != null && space.coverImageUrl!.trim().isNotEmpty) {
      return UrlUtils.resolveImageUrl(space.coverImageUrl!.trim());
    }
    return null;
  }

  String get _headerLocation {
    final city = space.city?.trim();
    final town = space.townName?.trim();
    final prov = space.province?.trim() ?? '';
    final line1 = (city != null && city.isNotEmpty)
        ? city
        : (town != null && town.isNotEmpty)
            ? town
            : '';
    if (line1.isNotEmpty && prov.isNotEmpty) return '$line1, $prov';
    if (line1.isNotEmpty) return line1;
    return prov;
  }

  String get _locationChipLabel {
    final city = space.city?.trim();
    final town = space.townName?.trim();
    if (city != null && city.isNotEmpty) return city;
    if (town != null && town.isNotEmpty) return town;
    return _headerLocation;
  }

  String get _introText => space.shortDescription?.trim() ?? '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: EntityListingTheme.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderBand(),
            _buildBody(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBand() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: listingTheme.cardHeaderGradient,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.08),
                width: 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.5),
              child: _imageUrl != null
                  ? Image.network(
                      _imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.palette_rounded,
                          size: 26,
                          color: listingTheme.accent,
                        );
                      },
                    )
                  : Icon(
                      Icons.palette_rounded,
                      size: 26,
                      color: listingTheme.accent,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  space.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: listingTheme.textTitle,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_headerLocation.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _headerLocation,
                    style: TextStyle(
                      fontSize: 12,
                      color: listingTheme.textLocation,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              space.rating != null
                  ? '${space.rating!.toStringAsFixed(1)} (${space.totalReviews})'
                  : CreativeSpacesConstants.noReviewsLabel,
              style: const TextStyle(
                fontSize: 11,
                color: EntityListingTheme.badgeText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final chips = <Widget>[
      if (_locationChipLabel.isNotEmpty)
        ListingInfoChip(
          icon: Icons.location_on_outlined,
          label: _locationChipLabel,
        ),
      ListingOpenClosedChip(isOpen: space.isOpenNow),
      if (space.allowsPurchase)
        const ListingInfoChip(
          icon: Icons.shopping_bag_outlined,
          label: CreativeSpacesConstants.purchasesLabel,
        ),
      if (space.offersWorkshops)
        const ListingInfoChip(
          icon: Icons.chair_outlined,
          label: CreativeSpacesConstants.workshopsLabel,
        ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_introText.isNotEmpty) ...[
            Text(
              _introText,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 13,
                color: EntityListingTheme.bodyText,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: chips,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.07),
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Tap to view space',
            style: TextStyle(
              fontSize: 12,
              color: EntityListingTheme.footerHint,
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: listingTheme.accent,
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    CreativeSpacesNavigation.pushDetailPage(
      context,
      pageBuilder: (_) => CreativeSpaceDetailPage(
        creativeSpaceId: space.id,
        creativeSpaceName: space.name,
      ),
    );
  }
}
