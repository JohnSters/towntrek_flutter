import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../core/utils/url_utils.dart';
import '../../../core/constants/service_detail_constants.dart';

/// Image gallery widget for service images
class ServiceImageGallery extends StatelessWidget {
  final List<ServiceImageDto> images;

  const ServiceImageGallery({
    super.key,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    final sortedImages = [...images]..sort((a, b) {
      return (a.sortOrder).compareTo(b.sortOrder);
    });

    return Container(
      height: 250,
      margin: const EdgeInsets.symmetric(
        horizontal: ServiceDetailConstants.contentPadding,
        vertical: ServiceDetailConstants.sectionSpacing,
      ),
      child: PageView.builder(
        itemCount: sortedImages.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: ServiceDetailConstants.gallerySpacing),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ServiceDetailConstants.galleryBorderRadius),
              child: Image.network(
                UrlUtils.resolveImageUrl(sortedImages[index].url),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}