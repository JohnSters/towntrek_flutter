import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/landing_page_constants.dart';
import '../../../core/constants/request_town_constants.dart';

/// Draggable square control that opens town availability.
///
/// Lives as a [Positioned] child of a [Stack] so empty space does not intercept
/// scrolling or taps on the landing page.
class TownAvailabilityFab extends StatefulWidget {
  const TownAvailabilityFab({
    super.key,
    required this.onPressed,
    required this.bounds,
  });

  static const Key buttonKey = Key('town-availability-fab');

  final VoidCallback onPressed;
  final Size bounds;

  @override
  State<TownAvailabilityFab> createState() => _TownAvailabilityFabState();
}

class _TownAvailabilityFabState extends State<TownAvailabilityFab> {
  static const double _dragScale = 1.06;

  Offset? _offset;
  var _dragging = false;

  Offset _clamped(Offset raw, Size bounds) {
    const margin = LandingScreenConstants.townAvailabilityFabMargin;
    const size = LandingScreenConstants.townAvailabilityFabSize;
    final maxX = (bounds.width - size - margin).clamp(margin, double.infinity);
    final maxY = (bounds.height - size - margin).clamp(margin, double.infinity);
    return Offset(raw.dx.clamp(margin, maxX), raw.dy.clamp(margin, maxY));
  }

  Offset _currentOffset(Size bounds) {
    const margin = LandingScreenConstants.townAvailabilityFabMargin;
    const size = LandingScreenConstants.townAvailabilityFabSize;
    final defaultOffset = Offset(
      bounds.width - size - margin,
      bounds.height - size - margin,
    );
    return _clamped(_offset ?? defaultOffset, bounds);
  }

  void _setDragging(bool dragging) {
    if (!mounted || _dragging == dragging) return;
    setState(() => _dragging = dragging);
  }

  void _onPanStart(DragStartDetails details) {
    HapticFeedback.lightImpact();
    _setDragging(true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _offset = _clamped(
        _currentOffset(widget.bounds) + details.delta,
        widget.bounds,
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _setDragging(false);
  }

  void _onTap() {
    HapticFeedback.selectionClick();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final position = _currentOffset(widget.bounds);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Semantics(
        button: true,
        label: RequestTownConstants.landingCta,
        child: Tooltip(
          message: RequestTownConstants.landingCta,
          excludeFromSemantics: true,
          child: MouseRegion(
            cursor: _dragging
                ? SystemMouseCursors.grabbing
                : SystemMouseCursors.grab,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _onTap,
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              onPanCancel: () => _setDragging(false),
              child: AnimatedScale(
                scale: _dragging ? _dragScale : 1,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: AnimatedContainer(
                  key: TownAvailabilityFab.buttonKey,
                  duration: const Duration(milliseconds: 120),
                  width: LandingScreenConstants.townAvailabilityFabSize,
                  height: LandingScreenConstants.townAvailabilityFabSize,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(
                      LandingScreenConstants.borderRadiusSmall,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(
                          alpha: _dragging ? 0.42 : 0.28,
                        ),
                        blurRadius: _dragging ? 16 : 10,
                        offset: Offset(0, _dragging ? 6 : 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.map_rounded,
                    color: colorScheme.onPrimary,
                    size: LandingScreenConstants.townAvailabilityFabIconSize,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
