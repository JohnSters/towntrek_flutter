import 'package:flutter/material.dart';
import '../../../core/constants/business_category_constants.dart';

/// A pulsating action button that animates when active
class PulsatingActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isActive;

  const PulsatingActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    required this.isActive,
  });

  @override
  State<PulsatingActionButton> createState() => _PulsatingActionButtonState();
}

class _PulsatingActionButtonState extends State<PulsatingActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: BusinessCategoryConstants.pulseAnimationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: BusinessCategoryConstants.pulseScaleBegin,
      end: BusinessCategoryConstants.pulseScaleEnd,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(
      begin: BusinessCategoryConstants.pulseFadeBegin,
      end: BusinessCategoryConstants.pulseFadeEnd,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulsatingActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Active colors (Events found)
    final activeBgColor = Color(BusinessCategoryConstants.activeButtonBgColor).withValues(alpha: BusinessCategoryConstants.highAlpha);
    final activeIconColor = Color(BusinessCategoryConstants.activeIconColor);

    // Inactive colors (No events)
    final inactiveBgColor = theme.colorScheme.surfaceContainerHighest.withValues(alpha: BusinessCategoryConstants.lowAlpha);
    final inactiveIconColor = theme.colorScheme.onSurfaceVariant.withValues(alpha: BusinessCategoryConstants.disabledAlpha);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isActive ? _scaleAnimation.value : 1.0,
          child: Material(
            color: widget.isActive ? activeBgColor : inactiveBgColor,
            borderRadius: BorderRadius.circular(BusinessCategoryConstants.borderRadiusLarge),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(BusinessCategoryConstants.borderRadiusLarge),
              child: Container(
                height: BusinessCategoryConstants.actionButtonHeight,
                padding: EdgeInsets.all(BusinessCategoryConstants.actionButtonPadding),
                decoration: widget.isActive ? BoxDecoration(
                  borderRadius: BorderRadius.circular(BusinessCategoryConstants.borderRadiusLarge),
                  border: Border.all(
                    color: activeIconColor.withValues(alpha: _fadeAnimation.value * BusinessCategoryConstants.mediumOpacity),
                    width: BusinessCategoryConstants.borderWidth,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: activeIconColor.withValues(alpha: BusinessCategoryConstants.highAlpha),
                      blurRadius: BusinessCategoryConstants.shadowBlurRadius * _scaleAnimation.value,
                      spreadRadius: BusinessCategoryConstants.shadowSpreadRadius,
                    )
                  ],
                ) : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.icon,
                      size: BusinessCategoryConstants.actionButtonIconSize,
                      color: widget.isActive ? activeIconColor : inactiveIconColor
                    ),
                    SizedBox(height: BusinessCategoryConstants.tinySpacing),
                    Text(
                      widget.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: widget.isActive ? activeIconColor : inactiveIconColor,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}