import 'package:flutter/material.dart';

import '../../constants/entity_listing_constants.dart';

/// Strip under the detail hero: open/closed (green / grey) and/or a views pill.
///
/// - When [isOpen] is non-null: shows **Open** or **Closed** only (no duplicate subtitle).
/// - When [isOpen] is null: neutral bar with views pill only when [viewCount] is non-null
///   (callers pass null to hide the bar, e.g. property with zero views).
class EntityOpenClosedBanner extends StatelessWidget {
  /// `true` / `false` = green / grey open-closed bar; `null` = views-only neutral bar.
  final bool? isOpen;

  /// When non-null, shown as a trailing pill (including **0**). Use null to omit the pill
  /// (e.g. property/event neutral bar hidden when there are no views to show).
  final int? viewCount;

  const EntityOpenClosedBanner({
    super.key,
    this.isOpen,
    this.viewCount,
  });

  bool get _showViewsPill => viewCount != null;

  @override
  Widget build(BuildContext context) {
    if (isOpen == null && !_showViewsPill) {
      return const SizedBox.shrink();
    }

    if (isOpen == null) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EEF3),
          border: Border.all(color: const Color(0xFFD0D8E0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _ViewsPill(
              count: viewCount ?? 0,
              variant: _ViewsPillVariant.neutral,
            ),
          ],
        ),
      );
    }

    final open = isOpen!;
    final bg = open ? const Color(0xFFE9F7EF) : const Color(0xFF3A3A3A);
    final fg = open ? const Color(0xFF1D7A38) : Colors.white;
    final border = open ? const Color(0xFFBFE5CB) : const Color(0xFF4A4A4A);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: border),
      ),
      child: _showViewsPill
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    open
                        ? EntityListingConstants.listingCardOpenNow
                        : EntityListingConstants.listingCardClosed,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: fg,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                _ViewsPill(
                  count: viewCount ?? 0,
                  variant: open
                      ? _ViewsPillVariant.onOpenBar
                      : _ViewsPillVariant.onClosedBar,
                ),
              ],
            )
          : Center(
              child: Text(
                open
                    ? EntityListingConstants.listingCardOpenNow
                    : EntityListingConstants.listingCardClosed,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
    );
  }
}

enum _ViewsPillVariant { neutral, onOpenBar, onClosedBar }

class _ViewsPill extends StatelessWidget {
  final int count;
  final _ViewsPillVariant variant;

  const _ViewsPill({
    required this.count,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final Color borderColor;

    switch (variant) {
      case _ViewsPillVariant.neutral:
        bg = Colors.white;
        fg = const Color(0xFF3D5068);
        borderColor = Colors.black.withValues(alpha: 0.1);
      case _ViewsPillVariant.onOpenBar:
        bg = Colors.white.withValues(alpha: 0.95);
        fg = const Color(0xFF146C2E);
        borderColor = const Color(0xFFBFE5CB);
      case _ViewsPillVariant.onClosedBar:
        bg = Colors.white.withValues(alpha: 0.14);
        fg = Colors.white;
        borderColor = Colors.white.withValues(alpha: 0.35);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.visibility_outlined,
            size: 15,
            color: fg,
          ),
          const SizedBox(width: 6),
          Text(
            'Views $count',
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
