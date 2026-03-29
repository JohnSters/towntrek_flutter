import 'package:flutter/material.dart';

import '../constants/business_category_constants.dart';

/// Left half of the listing header strip — matches [LiveEventsStripButton] layout
/// (fixed-height [Material] + [InkWell]) so no page background shows through gaps.
class ConnectedWrongTownStripButton extends StatelessWidget {
  const ConnectedWrongTownStripButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final h = BusinessCategoryConstants.connectedButtonHeight;
    final padH = BusinessCategoryConstants.connectedButtonHorizontalPadding;
    final padV = BusinessCategoryConstants.connectedButtonVerticalPadding;
    final iconSize = BusinessCategoryConstants.connectedButtonIconSize;

    return Semantics(
      button: true,
      label: 'Wrong town? Change town',
      child: Material(
        elevation: 2,
        shadowColor: cs.shadow.withValues(alpha: 0.3),
        color: cs.primary,
        child: InkWell(
          onTap: onPressed,
          splashColor: cs.onPrimary.withValues(alpha: 0.12),
          highlightColor: cs.onPrimary.withValues(alpha: 0.08),
          child: SizedBox(
            height: h,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off_rounded,
                    size: iconSize,
                    color: cs.onPrimary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      BusinessCategoryConstants.changeTownText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
