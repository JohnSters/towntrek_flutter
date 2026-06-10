import 'package:flutter/material.dart';

import '../constants/business_category_constants.dart';

/// Shared compact [FilledButton] style for the Wrong Town / Events header row.
ButtonStyle connectedHeaderButtonStyle(
  ThemeData theme, {
  Color? backgroundColor,
  Color? foregroundColor,
  double elevation = 0,
  Color? shadowColor,
  OutlinedBorder? shape,
}) {
  return FilledButton.styleFrom(
    minimumSize: const Size(0, BusinessCategoryConstants.connectedButtonHeight),
    maximumSize: const Size(
      double.infinity,
      BusinessCategoryConstants.connectedButtonHeight,
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: BusinessCategoryConstants.connectedButtonHorizontalPadding,
      vertical: BusinessCategoryConstants.connectedButtonVerticalPadding,
    ),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    iconSize: BusinessCategoryConstants.connectedButtonIconSize,
    textStyle: theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
    ),
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    elevation: elevation,
    shadowColor: shadowColor,
    shape:
        shape ??
        const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
  );
}
