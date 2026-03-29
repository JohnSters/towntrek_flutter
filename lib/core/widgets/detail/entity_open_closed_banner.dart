import 'package:flutter/material.dart';

/// Open/closed strip under the page header — matches Business/Service detail styling.
class EntityOpenClosedBanner extends StatelessWidget {
  final bool isOpen;
  final String secondaryText;

  const EntityOpenClosedBanner({
    super.key,
    required this.isOpen,
    required this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isOpen ? const Color(0xFFE9F7EF) : const Color(0xFF3A3A3A);
    final fg = isOpen ? const Color(0xFF1D7A38) : Colors.white;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: isOpen ? const Color(0xFFBFE5CB) : const Color(0xFF4A4A4A),
        ),
      ),
      child: Column(
        children: [
          Text(
            isOpen ? 'Open Now' : 'Closed',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (secondaryText.isNotEmpty) ...[
            Text(
              secondaryText,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: fg.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
