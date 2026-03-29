import 'package:flutter/material.dart';

import '../theme/entity_listing_theme.dart';

/// Info chip for listing card bodies (design doc §5b).
class ListingInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const ListingInfoChip({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: EntityListingTheme.chipBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: EntityListingTheme.chipIconAndLabel,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: EntityListingTheme.chipIconAndLabel,
            ),
          ),
        ],
      ),
    );
  }
}
