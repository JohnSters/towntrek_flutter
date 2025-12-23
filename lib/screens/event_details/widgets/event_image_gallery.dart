import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../core/utils/url_utils.dart';

class EventImageGallery extends StatelessWidget {
  final List<EventImageDto> images;

  const EventImageGallery({
    super.key,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    // Sort images with primary first, then by sort order
    final sortedImages = [...images]..sort((a, b) {
      if (a.isPrimary && !b.isPrimary) return -1;
      if (!a.isPrimary && b.isPrimary) return 1;
      return a.sortOrder.compareTo(b.sortOrder);
    });

    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: sortedImages.length == 1
          ? _buildSingleImage(context, sortedImages.first)
          : _buildImageCarousel(context, sortedImages),
    );
  }

  Widget _buildSingleImage(BuildContext context, EventImageDto image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        UrlUtils.resolveImageUrl(image.url),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.image_not_supported,
              size: 64,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageCarousel(BuildContext context, List<EventImageDto> images) {
    return PageView.builder(
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(right: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              UrlUtils.resolveImageUrl(images[index].url),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

