import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../../../models/models.dart';

/// Market stall rows from `typeDetails` on event detail responses.
class EventMarketStallsSection extends StatelessWidget {
  final List<EventTypeDetailDto> stalls;

  const EventMarketStallsSection({super.key, required this.stalls});

  @override
  Widget build(BuildContext context) {
    if (stalls.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        DetailSectionShell(
          expandTitle: true,
          title: 'Market stalls',
          icon: Icons.storefront_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < stalls.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _StallTile(
                  stall: stalls[i],
                  colorScheme: colorScheme,
                  theme: theme,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StallTile extends StatelessWidget {
  final EventTypeDetailDto stall;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _StallTile({
    required this.stall,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final description = stall.description?.trim();
    final category = stall.category;
    final priceRange = stall.priceRange;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stall.name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (category != null || priceRange != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (category != null)
                  DetailMetadataTag(
                    label: category,
                    icon: Icons.category_outlined,
                  ),
                if (priceRange != null)
                  DetailMetadataTag(
                    label: priceRange,
                    icon: Icons.payments_outlined,
                  ),
              ],
            ),
          ],
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.45,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
