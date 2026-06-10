import 'package:flutter/material.dart';

import '../../constants/entity_listing_constants.dart';
import '../../../theme/entity_listing_theme_extension.dart';
import '../../../theme/listing_status_colors.dart';

/// Info chip for listing card bodies (design doc §5b).
class ListingInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const ListingInfoChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.entityListing.chipBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: context.entityListing.chipIconAndLabel),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: context.entityListing.chipIconAndLabel,
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

  static const Color _openBg = ListingStatusColors.chipOpenBg;
  static const Color _openFg = ListingStatusColors.chipOpenFg;
  static const Color _openBorder = ListingStatusColors.chipOpenBorder;
  static const Color _closedBg = ListingStatusColors.chipClosedBg;
  static const Color _closedFg = ListingStatusColors.chipClosedFg;
  static const Color _closedBorder = ListingStatusColors.chipClosedBorder;

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
