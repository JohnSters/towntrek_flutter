import 'package:flutter/material.dart';
import '../../../core/constants/town_feature_constants.dart';
import '../../../core/theme/entity_listing_theme.dart';
import '../../../theme/entity_listing_theme_extension.dart';
import '../../../core/utils/business_utils.dart';
import '../../../core/utils/listing_aggregate_rating.dart';
import '../../../core/utils/url_utils.dart';
import '../../../core/widgets/listing_info_chip.dart';
import '../../../models/business_dto.dart';

class BusinessCardWidget extends StatelessWidget {
  final BusinessDto business;
  final VoidCallback? onTap;
  final String? categoryKey;
  final EntityListingTheme listingTheme;
  final String? townName;
  final String? provinceName;

  const BusinessCardWidget({
    super.key,
    required this.business,
    required this.listingTheme,
    this.onTap,
    this.categoryKey,
    this.townName,
    this.provinceName,
  });

  bool get _isEquipmentRentalsCategory {
    final k = categoryKey?.trim().toLowerCase();
    return k == TownFeatureConstants.equipmentRentalsCategoryKey.toLowerCase();
  }

  IconData get _fallbackIcon =>
      _isEquipmentRentalsCategory ? Icons.construction_rounded : Icons.storefront_outlined;

  String get _locationLabel {
    if (townName != null && provinceName != null) {
      return '$townName, $provinceName';
    }
    if (townName != null) return townName!;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final listingColors = context.entityListing;
    final outline = Theme.of(context).colorScheme.outline;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: listingColors.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: outline.withValues(alpha: 0.25),
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderBand(context, listingColors),
            _buildBody(listingColors),
            _buildFooter(listingColors, outline),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBand(
    BuildContext context,
    EntityListingThemeExtension listingColors,
  ) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: listingTheme.cardHeaderGradient,
      ),
      child: Row(
        children: [
          // Logo tile
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: listingColors.cardBg,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.5),
              child: business.logoUrl != null
                  ? Image.network(
                      UrlUtils.resolveImageUrl(business.logoUrl!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          _fallbackIcon,
                          size: 26,
                          color: listingTheme.accent,
                        );
                      },
                    )
                  : Icon(
                      _fallbackIcon,
                      size: 26,
                      color: listingTheme.accent,
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Business info
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  business.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: listingTheme.textTitle,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_locationLabel.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _locationLabel,
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

          // Review badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: listingColors.cardBg.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              aggregateRatingBadgeLabel(
                rating: business.rating,
                totalReviews: business.totalReviews,
                noReviewsLabel: 'No reviews',
              ),
              style: TextStyle(
                fontSize: 11,
                color: listingColors.badgeText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(EntityListingThemeExtension listingColors) {
    final introText = business.shortDescription?.trim().isNotEmpty == true
        ? business.shortDescription!.trim()
        : (business.description.trim().isNotEmpty
              ? business.description.trim()
              : '${business.category}${business.subCategory != null ? ' · ${business.subCategory}' : ''}');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            introText,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 13,
              color: listingColors.bodyText,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: [
              if (townName != null)
                ListingInfoChip(
                  icon: Icons.location_on_outlined,
                  label: townName!,
                ),
              ListingOpenClosedChip(
                isOpen: BusinessUtils.isBusinessOpenForListingCard(business),
                closedLabel: BusinessUtils.businessListingClosedChipLabel(business),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
    EntityListingThemeExtension listingColors,
    Color outline,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: outline.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _isEquipmentRentalsCategory ? 'Tap to view rental details' : 'Tap to view details',
            style: TextStyle(
              fontSize: 12,
              color: listingColors.footerHint,
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
