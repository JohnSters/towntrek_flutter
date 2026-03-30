import 'package:flutter/material.dart';

import '../constants/entity_listing_constants.dart';

/// Dark strip below hero (design doc §4).
class ListingResultsBand extends StatelessWidget {
  final int count;
  final String categoryName;
  final Color bandColor;

  const ListingResultsBand({
    super.key,
    required this.count,
    required this.categoryName,
    required this.bandColor,
  });

  @override
  Widget build(BuildContext context) {
    final resultText = count == 1 ? '1 result' : '$count results';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: bandColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                resultText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
              Flexible(
                child: Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: EntityListingConstants.contentBelowResultsBand),
      ],
    );
  }
}
