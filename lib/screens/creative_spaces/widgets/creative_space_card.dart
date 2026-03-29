import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../core/utils/url_utils.dart';
import '../../../models/models.dart';
import '../creative_space_detail_page.dart';

class CreativeSpaceCard extends StatelessWidget {
  final CreativeSpaceDto space;

  const CreativeSpaceCard({super.key, required this.space});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final imageUrl = _resolveImageUrl();
    final description = _buildDescriptionText();
    final location = _buildLocationText();
    final isOpen = space.isOpenNow;
    final statusText = _buildStatusText();
    final infoPills = <Widget>[
      if (space.categoryName != null && space.categoryName!.trim().isNotEmpty)
        _buildInfoPill(
          icon: Icons.category_rounded,
          text: space.categoryName!.trim(),
          iconColor: CreativeSpacesConstants.categoryPillTextColor,
          background: CreativeSpacesConstants.categoryPillBackgroundColor,
        ),
      if (space.subCategoryName != null &&
          space.subCategoryName!.trim().isNotEmpty)
        _buildInfoPill(
          icon: Icons.layers_rounded,
          text: space.subCategoryName!.trim(),
          iconColor: CreativeSpacesConstants.subCategoryPillTextColor,
          background: CreativeSpacesConstants.subCategoryPillBackgroundColor,
        ),
      if (space.allowsPurchase)
        _buildInfoPill(
          icon: Icons.shopping_bag_rounded,
          text: CreativeSpacesConstants.purchasesLabel,
          iconColor: Colors.orange.shade700,
          background: Colors.orange.shade50,
        ),
      if (space.offersWorkshops)
        _buildInfoPill(
          icon: Icons.chair_rounded,
          text: CreativeSpacesConstants.workshopsLabel,
          iconColor: Colors.teal.shade700,
          background: Colors.teal.shade50,
        ),
      if (space.priceRange != null && space.priceRange!.trim().isNotEmpty)
        _buildInfoPill(
          icon: Icons.price_change_rounded,
          text: space.priceRange!.trim(),
          iconColor: Colors.green.shade700,
          background: Colors.green.shade50,
        ),
    ];

    return OutlinedButton(
      onPressed: () => _navigateToDetail(context),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(14),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.22),
          width: 1.2,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(imageUrl, colorScheme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            space.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildStatusPill(text: statusText, isOpen: isOpen),
                        if (space.isFeatured)
                          _buildInfoPill(
                            icon: Icons.auto_awesome_rounded,
                            text: CreativeSpacesConstants.featuredBadge,
                            iconColor: CreativeSpacesConstants.creativePrimary,
                            background: CreativeSpacesConstants.creativeTint,
                          ),
                        if (space.isVerified)
                          _buildInfoPill(
                            icon: Icons.verified_rounded,
                            text: CreativeSpacesConstants.verifiedBadge,
                            iconColor: Colors.blue.shade700,
                            background: Colors.blue.shade50,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (location.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.place_rounded,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    location,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (infoPills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: infoPills),
          ],
          const SizedBox(height: 12),
          _buildRatingRow(colorScheme),
        ],
      ),
    );
  }

  String _buildDescriptionText() {
    return space.shortDescription?.trim() ?? '';
  }

  String _buildLocationText() {
    final parts = <String>[];

    void addPart(String? value) {
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty) {
        return;
      }

      final exists = parts.any(
        (existing) => existing.toLowerCase() == trimmed.toLowerCase(),
      );
      if (!exists) {
        parts.add(trimmed);
      }
    }

    addPart(space.city);
    addPart(space.townName);

    return parts.join(CreativeSpacesConstants.itemInfoDivider);
  }

  String _buildStatusText() {
    final fallback = space.isOpenNow
        ? CreativeSpacesConstants.openBadge
        : CreativeSpacesConstants.closedBadge;
    final detail = space.openNowText?.trim();
    if (detail == null || detail.isEmpty) {
      return fallback;
    }

    if (_startsWithIgnoreCase(detail, 'open') ||
        _startsWithIgnoreCase(detail, 'closed') ||
        _startsWithIgnoreCase(detail, 'currently open') ||
        _startsWithIgnoreCase(detail, 'currently closed')) {
      return detail;
    }

    return '$fallback${CreativeSpacesConstants.closedStatusSuffixDivider}$detail';
  }

  bool _startsWithIgnoreCase(String value, String prefix) {
    return value.toLowerCase().startsWith(prefix.toLowerCase());
  }

  String? _resolveImageUrl() {
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

  Widget _buildImage(String? imageUrl, ColorScheme colorScheme) {
    return Container(
      width: CreativeSpacesConstants.cardImageSize,
      height: CreativeSpacesConstants.cardImageSize,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: imageUrl == null
          ? Icon(
              Icons.palette_rounded,
              size: 32,
              color: colorScheme.onSurfaceVariant,
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.palette_rounded,
                    size: 32,
                    color: colorScheme.onSurfaceVariant,
                  );
                },
              ),
            ),
    );
  }

  Widget _buildStatusPill({required String text, required bool isOpen}) {
    final accent = isOpen ? Colors.green.shade700 : Colors.red.shade700;
    final background = isOpen ? Colors.green.shade50 : Colors.red.shade50;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: accent,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildInfoPill({
    required IconData icon,
    required String text,
    required Color iconColor,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: iconColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(ColorScheme colorScheme) {
    final rating = space.rating ?? 0.0;
    return Row(
      children: [
        ...List.generate(5, (index) {
          final starValue = index + 1;
          final icon = starValue <= rating
              ? Icons.star_rounded
              : starValue - 0.5 <= rating
              ? Icons.star_half_rounded
              : Icons.star_border_rounded;
          final isActive = starValue <= rating + 0.5;
          return Icon(
            icon,
            size: 14,
            color: isActive
                ? Colors.amber.shade700
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          );
        }),
        const SizedBox(width: 6),
        Text(
          space.rating != null
              ? CreativeSpacesConstants.ratingSummaryTemplate
                    .replaceAll('{rating}', space.rating!.toStringAsFixed(1))
                    .replaceAll('{reviews}', space.totalReviews.toString())
              : CreativeSpacesConstants.noReviewsLabel,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
