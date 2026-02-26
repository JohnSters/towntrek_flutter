import 'package:flutter/material.dart';

/// Named constants to avoid inline magic numbers.
class _ViewerConstants {
  static const double minScale = 0.8;
  static const double maxScale = 4.0;
  static const double closeIconSize = 28.0;
  static const double closeButtonPadding = 8.0;
  static const double indicatorFontSize = 16.0;
  static const double indicatorBottomPadding = 32.0;
  static const double indicatorBackgroundOpacity = 0.55;
  static const double indicatorHorizontalPadding = 14.0;
  static const double indicatorVerticalPadding = 6.0;
  static const double indicatorBorderRadius = 16.0;
  static const double errorIconSize = 56.0;
  static const double errorTextSpacing = 12.0;
  static const double dismissThreshold = 150.0;
  static const double dragOpacityDivisor = 400.0;
  static const double dragOpacityMin = 0.3;
  static const Duration snapBackDuration = Duration(milliseconds: 200);
}

/// A full-screen, production-quality image viewer.
///
/// Supports swiping between multiple images, pinch-to-zoom,
/// Hero animations, and swipe-down-to-dismiss.
class FullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String? heroTag;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.heroTag,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late int _currentIndex;

  // Swipe-down dismiss state
  double _dragOffset = 0.0;
  bool _isDragging = false;
  late final AnimationController _snapBackController;
  late Animation<double> _snapBackAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _snapBackController = AnimationController(
      vsync: this,
      duration: _ViewerConstants.snapBackDuration,
    )..addListener(() {
        setState(() {
          _dragOffset = _snapBackAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _snapBackController.dispose();
    super.dispose();
  }

  double get _backgroundOpacity =>
      (1.0 - (_dragOffset.abs() / _ViewerConstants.dragOpacityDivisor))
          .clamp(_ViewerConstants.dragOpacityMin, 1.0);

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _isDragging = true;
      _dragOffset += details.delta.dy;
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_dragOffset.abs() > _ViewerConstants.dismissThreshold) {
      Navigator.of(context).pop();
    } else {
      _snapBackAnimation = Tween<double>(
        begin: _dragOffset,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _snapBackController,
        curve: Curves.easeOut,
      ));
      _snapBackController.forward(from: 0.0);
      _isDragging = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasMultiple = widget.imageUrls.length > 1;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: _backgroundOpacity),
      body: GestureDetector(
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Stack(
          children: [
            // Image pages
            Transform.translate(
              offset: Offset(0, _dragOffset),
              child: PageView.builder(
                controller: _pageController,
                physics: _isDragging
                    ? const NeverScrollableScrollPhysics()
                    : null,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemCount: widget.imageUrls.length,
                itemBuilder: (context, index) =>
                    _buildPage(index),
              ),
            ),

            // Close button (top-right, safe-area aware)
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(
                    _ViewerConstants.closeButtonPadding,
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: _ViewerConstants.closeIconSize,
                    ),
                  ),
                ),
              ),
            ),

            // Page indicator
            if (hasMultiple)
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: _ViewerConstants.indicatorBottomPadding,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal:
                            _ViewerConstants.indicatorHorizontalPadding,
                        vertical: _ViewerConstants.indicatorVerticalPadding,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(
                          alpha: _ViewerConstants.indicatorBackgroundOpacity,
                        ),
                        borderRadius: BorderRadius.circular(
                          _ViewerConstants.indicatorBorderRadius,
                        ),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${widget.imageUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: _ViewerConstants.indicatorFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    final url = widget.imageUrls[index];
    final isHeroTarget = index == widget.initialIndex && widget.heroTag != null;

    Widget image = Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      },
      errorBuilder: (context, _, _) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.broken_image_outlined,
                size: _ViewerConstants.errorIconSize,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(height: _ViewerConstants.errorTextSpacing),
              Text(
                'Failed to load image',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        );
      },
    );

    // Disable single-finger pan so vertical drag dismiss works;
    // two-finger pan is still available via the scale gesture.
    image = InteractiveViewer(
      panEnabled: false,
      minScale: _ViewerConstants.minScale,
      maxScale: _ViewerConstants.maxScale,
      child: Center(child: image),
    );

    if (isHeroTarget) {
      image = Hero(tag: widget.heroTag!, child: image);
    }

    return image;
  }
}
