import 'package:flutter/material.dart';

import 'package:towntrek_flutter/theme/entity_listing_theme_extension.dart';

/// Pinned pill footer for listing screens (design doc §6).
class ListingBackFooter extends StatelessWidget {
  final String label;

  const ListingBackFooter({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final listing = context.entityListing;
    final outline = Theme.of(context).colorScheme.outline;
    return Container(
      width: double.infinity,
      color: listing.pageBg,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: SafeArea(
        top: false,
        child: Center(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              decoration: BoxDecoration(
                color: listing.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: outline.withValues(alpha: 0.22),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back,
                    size: 13,
                    color: listing.backFooterLabel,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: listing.backFooterLabel,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
