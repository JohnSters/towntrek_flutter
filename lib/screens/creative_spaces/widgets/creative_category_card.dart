import 'package:flutter/material.dart';

import '../../../core/constants/creative_spaces_constants.dart';
import '../../../models/models.dart';

/// Card widget for displaying a Creative Space category
class CreativeCategoryCard extends StatelessWidget {
  final CreativeCategoryDto category;
  final bool countsAvailable;
  final VoidCallback? onTap;

  const CreativeCategoryCard({
    super.key,
    required this.category,
    required this.countsAvailable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDisabled = countsAvailable && category.spaceCount == 0;
    final hasDescription =
        category.description != null && category.description!.trim().isNotEmpty;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.66),
            colorScheme.secondaryContainer.withValues(alpha: 0.42),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: OutlinedButton(
        onPressed: isDisabled ? null : onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(14),
          side: BorderSide(
            color: isDisabled
                ? colorScheme.outline.withValues(alpha: 0.25)
                : CreativeSpacesConstants.creativePrimary.withValues(
                    alpha: 0.35,
                  ),
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: isDisabled
              ? colorScheme.surface.withValues(alpha: 0.15)
              : colorScheme.surface.withValues(alpha: 0.25),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDisabled
                    ? colorScheme.surfaceContainerHighest
                    : colorScheme.surface.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDisabled
                      ? colorScheme.outline.withValues(alpha: 0.2)
                      : colorScheme.primary.withValues(alpha: 0.16),
                ),
              ),
              child: Icon(
                Icons.palette_rounded,
                size: 26,
                color: isDisabled
                    ? colorScheme.onSurfaceVariant
                    : CreativeSpacesConstants.creativePrimary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDisabled
                          ? colorScheme.onSurface.withValues(alpha: 0.55)
                          : colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitleText(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isDisabled
                          ? colorScheme.onSurfaceVariant
                          : CreativeSpacesConstants.creativePrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasDescription) ...[
                    const SizedBox(height: 6),
                    Text(
                      category.description!.trim(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.9,
                        ),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right,
              color: isDisabled
                  ? colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                  : CreativeSpacesConstants.creativePrimary,
            ),
          ],
        ),
      ),
    );
  }

  String _subtitleText() {
    if (category.spaceCount == 0) {
      return countsAvailable
          ? CreativeSpacesConstants.noSpacesAvailableLabel
          : CreativeSpacesConstants.exploreCategoryLabel.replaceAll(
              '{name}',
              category.name,
            );
    }
    return '${category.spaceCount} spaces';
  }
}
