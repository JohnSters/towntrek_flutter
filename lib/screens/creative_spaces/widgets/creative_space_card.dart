import 'package:flutter/material.dart';
import '../../../core/utils/url_utils.dart';
import '../../../core/constants/creative_spaces_constants.dart';
import '../../../models/models.dart';
import '../creative_space_detail_page.dart';

/// Card widget for displaying a creative space in list view
class CreativeSpaceCard extends StatelessWidget {
  final CreativeSpaceDto space;

  const CreativeSpaceCard({
    super.key,
    required this.space,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final imageUrl = _resolveImageUrl();
    final intro = _buildIntroText();
    final isOpen = space.isOpenNow;
    final statusText = isOpen
        ? CreativeSpacesConstants.openBadge
        : CreativeSpacesConstants.closedBadge +
            (space.openNowText != null && space.openNowText!.trim().isNotEmpty
                ? '${CreativeSpacesConstants.closedStatusSuffixDivider}${space.openNowText!.trim()}'
                : '');

    return OutlinedButton(
      onPressed: () => _navigateToDetail(context),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(12),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        backgroundColor: colorScheme.primary.withValues(alpha: 0.02),
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
                        if (space.isFeatured)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: CreativeSpacesConstants.creativePrimary.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              CreativeSpacesConstants.featuredBadge,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      statusText,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isOpen ? Colors.green.shade700 : colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            intro,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (space.isVerified)
                _buildPill(Icons.verified_rounded, CreativeSpacesConstants.verifiedBadge, Colors.blue.shade700, Colors.blue.shade50),
              if (space.categoryName != null && space.categoryName!.trim().isNotEmpty)
                _buildPill(
                  Icons.category_rounded,
                  space.categoryName!.trim(),
                  CreativeSpacesConstants.categoryPillTextColor,
                  CreativeSpacesConstants.categoryPillBackgroundColor,
                ),
              if (space.subCategoryName != null && space.subCategoryName!.trim().isNotEmpty)
                _buildPill(
                  Icons.layers_rounded,
                  space.subCategoryName!.trim(),
                  CreativeSpacesConstants.subCategoryPillTextColor,
                  CreativeSpacesConstants.subCategoryPillBackgroundColor,
                ),
              if (space.allowsPurchase)
                _buildPill(Icons.shopping_bag_rounded, CreativeSpacesConstants.purchasesLabel, Colors.orange.shade700, Colors.orange.shade50),
              if (space.offersWorkshops)
                _buildPill(Icons.chair_rounded, CreativeSpacesConstants.workshopsLabel, Colors.teal.shade700, Colors.teal.shade50),
              if (space.priceRange != null && space.priceRange!.trim().isNotEmpty)
                _buildPill(
                  Icons.price_change_rounded,
                  space.priceRange!.trim(),
                  Colors.green.shade700,
                  Colors.green.shade50,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildRatingRow(colorScheme),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _navigateToDetail(context),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text(CreativeSpacesConstants.viewDetailsLabel),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _buildIntroText() {
    final location =
        [space.townName?.trim(), space.city?.trim()]
            .where((value) => value != null && value.isNotEmpty)
            .join(CreativeSpacesConstants.itemInfoDivider);
    return [
      if (space.shortDescription != null && space.shortDescription!.trim().isNotEmpty) space.shortDescription!.trim(),
      if (location.isNotEmpty) location,
    ].join(CreativeSpacesConstants.itemInfoDivider);
  }

  String? _resolveImageUrl() {
    if (space.thumbnailImage != null && space.thumbnailImage!.url.trim().isNotEmpty) {
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
      width: 86,
      height: 86,
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

  Widget _buildPill(
    IconData icon,
    String text,
    Color iconColor,
    Color background,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: iconColor,
          ),
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
        ...List.generate(
          5,
          (index) {
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
              color: isActive ? Colors.amber.shade700 : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            );
          },
        ),
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreativeSpaceDetailPage(
          creativeSpaceId: space.id,
          creativeSpaceName: space.name,
        ),
      ),
    );
  }
}
