import 'package:flutter/material.dart';
import '../../../core/constants/town_feature_constants.dart';
import 'feature_data.dart';

class FeatureCard extends StatelessWidget {
  final FeatureData feature;

  const FeatureCard({
    super.key,
    required this.feature,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: TownFeatureConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TownFeatureConstants.cardBorderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: feature.onTap,
        child: Container(
          height: TownFeatureConstants.cardHeight,
          padding: const EdgeInsets.all(TownFeatureConstants.cardPadding),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: feature.color, width: TownFeatureConstants.borderWidth)),
            gradient: LinearGradient(
              colors: [
                feature.color.withValues(alpha: TownFeatureConstants.iconBackgroundAlpha),
                theme.colorScheme.surface,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(TownFeatureConstants.iconPadding),
                decoration: BoxDecoration(
                  color: feature.color.withValues(alpha: TownFeatureConstants.iconBackgroundAlpha),
                  shape: BoxShape.circle,
                ),
                child: Icon(feature.icon, color: feature.color, size: TownFeatureConstants.iconSize),
              ),
              const SizedBox(width: TownFeatureConstants.cardPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      feature.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: TownFeatureConstants.cardTitleFontWeight,
                      ),
                    ),
                    const SizedBox(height: TownFeatureConstants.titleSpacing),
                    Text(
                      feature.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: TownFeatureConstants.chevronAlpha),
              ),
            ],
          ),
        ),
      ),
    );
  }
}