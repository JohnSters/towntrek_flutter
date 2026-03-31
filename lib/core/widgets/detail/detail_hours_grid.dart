import 'package:flutter/material.dart';

/// One cell in [DetailHoursGrid] (Mon–Sun order).
class DetailHoursDayRow {
  final String dayShortLabel;
  final String timeLabel;
  final bool isToday;

  const DetailHoursDayRow({
    required this.dayShortLabel,
    required this.timeLabel,
    required this.isToday,
  });
}

/// Two-column wrap of day/time tiles (Business / Service / Creative regular hours).
class DetailHoursGrid extends StatelessWidget {
  final List<DetailHoursDayRow> rows;

  const DetailHoursGrid({
    super.key,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: rows.map((row) {
            return SizedBox(
              width: tileWidth,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: row.isToday
                      ? colorScheme.primary.withValues(alpha: 0.10)
                      : colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: row.isToday
                        ? colorScheme.primary.withValues(alpha: 0.45)
                        : colorScheme.outline.withValues(alpha: 0.16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        row.dayShortLabel,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: row.isToday ? colorScheme.primary : null,
                            ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        row.timeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
