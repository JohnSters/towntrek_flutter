import 'package:flutter/material.dart';

import '../../../core/theme/entity_listing_theme.dart';
import '../../../core/utils/property_listing_format.dart';
import '../../../core/utils/url_utils.dart';
import '../../../core/widgets/listing_info_chip.dart';
import '../../../models/models.dart';

/// Property listing card (design doc §5, §8 Properties).
class PropertyListingCardWidget extends StatelessWidget {
  final PropertyListingCardDto listing;
  final EntityListingTheme listingTheme;
  final VoidCallback? onTap;

  const PropertyListingCardWidget({
    super.key,
    required this.listing,
    required this.listingTheme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final raw = listing.primaryImageUrl?.trim();
    final imageUrl =
        raw != null && raw.isNotEmpty ? UrlUtils.resolveImageUrl(raw) : null;
    final title = listing.address.trim().isNotEmpty
        ? listing.address.trim()
        : listing.ownerName;
    final locationLine = [
      listing.townName.trim(),
      listing.province.trim(),
    ].where((s) => s.isNotEmpty).join(', ');
    final introText = listing.summary?.trim().isNotEmpty == true
        ? listing.summary!.trim()
        : '${propertyListingTypeLabel(listing.listingType)} · ${listing.townName.trim().isNotEmpty ? listing.townName : listing.province}';

    final priceLabel = listing.price > 0
        ? formatPropertyListingPrice(
            listingType: listing.listingType,
            price: listing.price,
          )
        : null;

    return GestureDetector(
      onTap: onTap,
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
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderBand(
                  context,
                  imageUrl: imageUrl,
                  title: title,
                  locationLine: locationLine,
                ),
                _buildBody(introText, priceLabel),
                _buildFooter(),
              ],
            ),
            if (listing.isFeatured)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Featured',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBand(
    BuildContext context, {
    required String? imageUrl,
    required String title,
    required String locationLine,
  }) {
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
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.home_work_rounded,
                          size: 26,
                          color: listingTheme.accent,
                        );
                      },
                    )
                  : Icon(
                      Icons.home_work_rounded,
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
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: listingTheme.textTitle,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (locationLine.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    locationLine,
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
              propertyListingTypeLabel(listing.listingType),
              style: const TextStyle(
                fontSize: 11,
                color: EntityListingTheme.badgeText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(String introText, String? priceLabel) {
    final chips = <Widget>[
      if (listing.townName.trim().isNotEmpty)
        ListingInfoChip(
          icon: Icons.location_on_outlined,
          label: listing.townName.trim(),
        ),
      if (priceLabel != null)
        ListingInfoChip(
          icon: Icons.payments_outlined,
          label: priceLabel,
        ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            introText,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontSize: 13,
              color: EntityListingTheme.bodyText,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.start,
              children: chips,
            ),
          ],
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
            'Tap to view listing',
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
}
