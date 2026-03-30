import 'package:flutter/material.dart';
import '../../../core/theme/entity_listing_theme.dart';
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
    return GestureDetector(
      onTap: () => _navigateToServiceDetails(context),
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
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              service.rating != null
                  ? '${service.rating!.toStringAsFixed(1)} (${service.totalReviews})'
                  : 'No reviews',
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            'Tap to view service',
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
