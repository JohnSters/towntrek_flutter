import 'package:flutter/material.dart';

/// 56×56 square quick action matching detail-screen design (tooltip + icon or asset image).
class DetailQuickActionButton extends StatelessWidget {
  final String tooltip;
  final IconData? icon;
  final String? assetImagePath;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onPressed;

  const DetailQuickActionButton({
    super.key,
    required this.tooltip,
    this.icon,
    this.assetImagePath,
    required this.backgroundColor,
    required this.iconColor,
    this.onPressed,
  }) : assert(
          (icon != null) != (assetImagePath != null),
          'Provide exactly one of icon or assetImagePath',
        );

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    const double actionSize = 56;

    final Widget iconChild = assetImagePath != null
        ? _TownTrekQuickAsset(
            assetPath: assetImagePath!,
            disabled: disabled,
            size: actionSize,
          )
        : Icon(
            icon!,
            size: 24,
            color: disabled
                ? iconColor.withValues(alpha: 0.38)
                : iconColor,
          );

    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: actionSize,
        height: actionSize,
        child: IconButton(
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          iconSize: actionSize,
          constraints: BoxConstraints.tightFor(
            width: actionSize,
            height: actionSize,
          ),
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: iconChild,
        ),
      ),
    );
  }
}

class _TownTrekQuickAsset extends StatelessWidget {
  final String assetPath;
  final bool disabled;
  final double size;

  const _TownTrekQuickAsset({
    required this.assetPath,
    required this.disabled,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final core = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );

    if (disabled) {
      return Opacity(opacity: 0.38, child: core);
    }

    return core;
  }
}
