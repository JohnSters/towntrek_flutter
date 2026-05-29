import 'package:flutter/material.dart';

import '../../core/widgets/listing_info_chip.dart';
import '../../models/models.dart';

/// Meta chips aligned with What-To-Do list cards.
List<Widget> discoveryDetailQuickFactChips(TownDiscoveryDetailDto d) {
  final chips = <Widget>[
    ListingInfoChip(icon: Icons.sell_outlined, label: d.categoryName),
  ];
  if (d.difficulty != null && d.difficulty!.trim().isNotEmpty) {
    chips.add(
      ListingInfoChip(icon: Icons.terrain_outlined, label: d.difficulty!.trim()),
    );
  }
  if (d.duration != null && d.duration!.trim().isNotEmpty) {
    chips.add(
      ListingInfoChip(icon: Icons.schedule_outlined, label: d.duration!.trim()),
    );
  }
  chips.add(
    ListingInfoChip(
      icon: d.isFreeAccess ? Icons.money_off_outlined : Icons.payments_outlined,
      label: d.isFreeAccess ? 'Free' : 'Paid',
    ),
  );
  return chips;
}

/// Gallery from API images, with cover fallback.
List<DiscoveryImageDto> galleryImagesForDetail(TownDiscoveryDetailDto d) {
  if (d.images.isNotEmpty) return d.images;
  final raw = d.coverImageUrl ?? d.thumbnailUrl;
  if (raw != null && raw.trim().isNotEmpty) {
    return [
      DiscoveryImageDto(
        url: raw.trim(),
        thumbnailUrl: d.thumbnailUrl?.trim().isNotEmpty == true
            ? d.thumbnailUrl!.trim()
            : null,
        sortOrder: 0,
      ),
    ];
  }
  return const [];
}
