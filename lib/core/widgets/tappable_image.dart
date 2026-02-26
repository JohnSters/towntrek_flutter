import 'package:flutter/material.dart';
import 'full_screen_image_viewer.dart';

/// Named constants to avoid inline magic numbers.
class _TappableImageConstants {
  static const double overlayIconSize = 16.0;
  static const double overlayPadding = 4.0;
  static const double overlayBorderRadius = 4.0;
  static const double overlayBackgroundOpacity = 0.45;
  static const double overlayOffset = 6.0;
}

/// A drop-in wrapper that makes any image widget tappable to open a
/// [FullScreenImageViewer].
///
/// Adds a [GestureDetector], a [Hero] animation tag, and a subtle
/// expand-icon overlay in the bottom-right corner.
///
/// Does not alter the child's existing size, fit, or border-radius behaviour.
class TappableImage extends StatelessWidget {
  /// The image widget to wrap (unchanged visually).
  final Widget child;

  /// Ordered list of all image URLs in the gallery.
  final List<String> imageUrls;

  /// Index of *this* image in [imageUrls].
  final int initialIndex;

  /// Optional Hero animation tag. Falls back to the image URL.
  final String? heroTag;

  const TappableImage({
    super.key,
    required this.child,
    required this.imageUrls,
    this.initialIndex = 0,
    this.heroTag,
  });

  String get _resolvedTag => heroTag ?? imageUrls[initialIndex];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openViewer(context),
      child: Hero(
        tag: _resolvedTag,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            child,
            Positioned(
              bottom: _TappableImageConstants.overlayOffset,
              right: _TappableImageConstants.overlayOffset,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.all(
                    _TappableImageConstants.overlayPadding,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(
                      alpha: _TappableImageConstants.overlayBackgroundOpacity,
                    ),
                    borderRadius: BorderRadius.circular(
                      _TappableImageConstants.overlayBorderRadius,
                    ),
                  ),
                  child: const Icon(
                    Icons.fullscreen_rounded,
                    size: _TappableImageConstants.overlayIconSize,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openViewer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
          heroTag: _resolvedTag,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}
