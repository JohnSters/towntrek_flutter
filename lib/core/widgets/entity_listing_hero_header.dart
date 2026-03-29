import 'package:flutter/material.dart';

import '../theme/entity_listing_theme.dart';

/// Listing-screen hero (design doc §3). Page-level [SafeArea] wraps the screen body.
class EntityListingHeroHeader extends StatelessWidget {
  final EntityListingTheme theme;
  final IconData categoryIcon;
  final String subCategoryName;
  final String categoryName;
  final String townName;

  const EntityListingHeroHeader({
    super.key,
    required this.theme,
    required this.categoryIcon,
    required this.subCategoryName,
    required this.categoryName,
    required this.townName,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleText =
        '${categoryName.toUpperCase()} \u2022 ${townName.toUpperCase()}';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: theme.heroGradient),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                categoryIcon,
                size: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    subtitleText,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.75),
                      letterSpacing: 0.07 * 11,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subCategoryName,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
