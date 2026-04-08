import 'package:flutter/material.dart';
import '../../../core/theme/entity_listing_theme.dart';
import '../../../theme/entity_listing_theme_extension.dart';
import '../../../core/utils/listing_aggregate_rating.dart';
import '../../../core/utils/url_utils.dart';
import '../../../core/widgets/listing_info_chip.dart';
import '../../../models/models.dart';
import '../../service_detail/service_detail_page.dart';

/// Listing card for services (design doc §5, §8 Services).
class ServiceCard extends StatelessWidget {
  final ServiceDto service;
  final EntityListingTheme listingTheme;

  const ServiceCard({
    super.key,
    required this.service,
    required this.listingTheme,
  });

  String get _locationLabel => '${service.townName}, ${service.province}';

  String get _introText {
    final s = service.shortDescription?.trim();
    if (s != null && s.isNotEmpty) return s;
    final sub = service.subCategoryName ?? service.categoryName ?? 'Local service';
    return '$sub in ${service.townName}';
  }

  @override
  Widget build(BuildContext context) {
    final listingColors = context.entityListing;
    final outline = Theme.of(context).colorScheme.outline;
    return GestureDetector(
      onTap: () => _navigateToServiceDetails(context),
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
            _buildBody(context, listingColors),
            _buildFooter(context, listingColors, outline),
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
              child: service.logoUrl != null
                  ? Image.network(
                      UrlUtils.resolveImageUrl(service.logoUrl!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.business_rounded,
                          size: 26,
                          color: listingTheme.accent,
                        );
                      },
                    )
                  : Icon(
                      Icons.business_rounded,
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
                  service.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: listingTheme.textTitle,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: listingColors.cardBg.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              aggregateRatingBadgeLabel(
                rating: service.rating,
                totalReviews: service.totalReviews,
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

  Widget _buildBody(
    BuildContext context,
    EntityListingThemeExtension listingColors,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _introText,
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
              ListingInfoChip(
                icon: Icons.location_on_outlined,
                label: service.townName,
              ),
              ListingOpenClosedChip(isOpen: service.isOpenNow ?? false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
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
            'Tap to view service',
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

  void _navigateToServiceDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServiceDetailPage(
          serviceId: service.id,
          serviceName: service.name,
        ),
      ),
    );
  }
}
