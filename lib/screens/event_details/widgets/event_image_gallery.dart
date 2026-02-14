import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../core/utils/url_utils.dart';
import '../../../core/constants/event_details_constants.dart';

/// Image preview gallery for events - shows thumbnails that open full-screen viewer
class EventImageGallery extends StatelessWidget {
  final List<EventImageDto> images;

  const EventImageGallery({
    super.key,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    // Sort images with primary first, then by sort order
    final sortedImages = [...images]..sort((a, b) {
      if (a.isPrimary && !b.isPrimary) return -1;
      if (!a.isPrimary && b.isPrimary) return 1;
      return a.sortOrder.compareTo(b.sortOrder);
    });

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: EventDetailsConstants.contentHorizontalPadding,
        vertical: EventDetailsConstants.sectionSpacing,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.only(
              left: EventDetailsConstants.contentHorizontalPadding,
              bottom: EventDetailsConstants.sectionTitleSpacing,
            ),
            child: Text(
              'Event Images',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: EventDetailsConstants.sectionTitleFontWeight,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          // Image previews
          SizedBox(
            height: EventDetailsConstants.imagePreviewSize,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: EventDetailsConstants.contentHorizontalPadding,
              ),
              itemCount: sortedImages.length,
              itemBuilder: (context, index) {
                return _buildImagePreview(context, sortedImages[index], sortedImages, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(
    BuildContext context,
    EventImageDto image,
    List<EventImageDto> allImages,
    int index,
  ) {
    return GestureDetector(
      onTap: () => _showFullScreenImageViewer(context, allImages, index),
      child: Container(
        width: EventDetailsConstants.imagePreviewSize,
        height: EventDetailsConstants.imagePreviewSize,
        margin: EdgeInsets.only(right: EventDetailsConstants.imagePreviewSpacing),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(EventDetailsConstants.cardBorderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                UrlUtils.resolveImageUrl(image.url),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 32,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
              // Overlay with tap indicator
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(EventDetailsConstants.cardBorderRadius),
                    onTap: () => _showFullScreenImageViewer(context, allImages, index),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(EventDetailsConstants.cardBorderRadius),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withValues(
                            alpha: EventDetailsConstants.outlineOpacity,
                          ),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Primary indicator
              if (image.isPrimary)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      EventDetailsConstants.starIcon,
                      size: 12,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreenImageViewer(BuildContext context, List<EventImageDto> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventFullScreenImageViewer(
          images: images,
          initialIndex: initialIndex,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}

/// Full-screen image viewer for event images
class EventFullScreenImageViewer extends StatefulWidget {
  final List<EventImageDto> images;
  final int initialIndex;

  const EventFullScreenImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<EventFullScreenImageViewer> createState() => _EventFullScreenImageViewerState();
}

class _EventFullScreenImageViewerState extends State<EventFullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '${_currentIndex + 1} of ${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          final image = widget.images[index];
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Hero(
                tag: 'event_image_${image.id}',
                child: Image.network(
                  UrlUtils.resolveImageUrl(image.url),
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

