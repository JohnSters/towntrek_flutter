import 'package:flutter/material.dart';

import '../constants/entity_listing_constants.dart';
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

/// Hours-style open/closed pill for listing cards: green when open, grey when closed.
class ListingOpenClosedChip extends StatelessWidget {
  final bool isOpen;
  /// When closed, shown instead of [EntityListingConstants.listingCardClosed].
  final String? closedLabel;

  const ListingOpenClosedChip({
    super.key,
    required this.isOpen,
    this.closedLabel,
  });

  static const Color _openBg = Color(0xFFE8F5E9);
  static const Color _openFg = Color(0xFF2E7D32);
  static const Color _openBorder = Color(0xFFC8E6C9);
  static const Color _closedBg = Color(0xFFECEFF1);
  static const Color _closedFg = Color(0xFF546E7A);
  static const Color _closedBorder = Color(0xFFB0BEC5);

  @override
  Widget build(BuildContext context) {
    final bg = isOpen ? _openBg : _closedBg;
    final fg = isOpen ? _openFg : _closedFg;
    final border = isOpen ? _openBorder : _closedBorder;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 13, color: fg),
          const SizedBox(width: 5),
          Text(
            isOpen
                ? EntityListingConstants.listingCardOpenNow
                : (closedLabel ?? EntityListingConstants.listingCardClosed),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
