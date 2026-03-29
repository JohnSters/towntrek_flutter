import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../models/models.dart';
import '../../../core/utils/url_utils.dart';
import 'event_detail_ui.dart';

/// Horizontal gallery matching [business_details_page] gallery (TappableImage, 158×104, radius 10).
class EventImageGallery extends StatelessWidget {
  final List<EventImageDto> images;

  const EventImageGallery({
    super.key,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    final sortedImages = [...images]..sort((a, b) {
          if (a.isPrimary && !b.isPrimary) return -1;
          if (!a.isPrimary && b.isPrimary) return 1;
          return a.sortOrder.compareTo(b.sortOrder);
        });

    final allUrls = sortedImages
        .map((img) => UrlUtils.resolveImageUrl(img.url))
        .toList();

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: EventDetailSectionShell(
        title: 'Gallery',
        icon: Icons.photo_library_outlined,
        child: SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sortedImages.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final image = sortedImages[index];
              final resolvedUrl = allUrls[index];
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  TappableImage(
                    imageUrls: allUrls,
                    initialIndex: index,
                    heroTag: 'event_gallery_$index',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 158,
                        height: 104,
                        color: colorScheme.surfaceContainerHighest,
                        child: Image.network(
                          resolvedUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: colorScheme.surfaceContainerHighest,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Loading image...',
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            );
                          },
                          errorBuilder: (context, _, _) {
                            return Container(
                              color: colorScheme.surfaceContainerHighest,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  if (image.isPrimary)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
