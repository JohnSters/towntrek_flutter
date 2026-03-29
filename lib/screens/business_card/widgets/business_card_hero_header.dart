import 'package:flutter/material.dart';
import '../../../core/config/business_category_config.dart';

class BusinessCardHeroHeader extends StatelessWidget {
  final String subCategoryName;
  final String categoryName;
  final String categoryKey;
  final String townName;

  const BusinessCardHeroHeader({
    super.key,
    required this.subCategoryName,
    required this.categoryName,
    required this.categoryKey,
    required this.townName,
  });

  @override
  Widget build(BuildContext context) {
    final icon = BusinessCategoryConfig.getCategoryIcon(categoryKey);
    final subtitleText =
        '${categoryName.toUpperCase()} \u2022 ${townName.toUpperCase()}';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.6, -1.0),
          end: Alignment(0.6, 1.0),
          colors: [
            Color(0xFF0D2D5A),
            Color(0xFF1A4F8F),
            Color(0xFF1D6BB5),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon tile
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
                icon,
                size: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),

            // Subtitle + title
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
