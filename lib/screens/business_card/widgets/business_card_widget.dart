import 'package:flutter/material.dart';
import '../../../core/constants/town_feature_constants.dart';
import '../../../core/utils/url_utils.dart';
import '../../../models/business_dto.dart';

class BusinessCardWidget extends StatelessWidget {
  final BusinessDto business;
  final VoidCallback? onTap;
  final String? categoryKey;
  final String? townName;
  final String? provinceName;

  const BusinessCardWidget({
    super.key,
    required this.business,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDDEAF9), Color(0xFFC8DDF5)],
        ),
      ),
      child: Row(
        children: [
          // Logo tile
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
              child: business.logoUrl != null
                  ? Image.network(
                      UrlUtils.resolveImageUrl(business.logoUrl!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          _fallbackIcon,
                          size: 26,
                          color: const Color(0xFF1A4F8F),
                        );
                      },
                    )
                  : Icon(
                      _fallbackIcon,
                      size: 26,
                      color: const Color(0xFF1A4F8F),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0D2D5A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_locationLabel.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _locationLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF3D6A9E),
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
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              business.rating != null
                  ? '${business.rating!.toStringAsFixed(1)} (${business.totalReviews})'
                  : 'No reviews',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF3D5068),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
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
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF3D5068),
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
                _InfoChip(
                  icon: Icons.location_on_outlined,
                  label: townName!,
                ),
              const _InfoChip(
                icon: Icons.calendar_today_outlined,
                label: 'Open today',
              ),
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
          Text(
            _isEquipmentRentalsCategory ? 'Tap to view rental details' : 'Tap to view details',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7A90A4),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Color(0xFF1A4F8F),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: const Color(0xFF3D5068),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF3D5068),
            ),
          ),
        ],
      ),
    );
  }
}
