import 'package:flutter/material.dart';
import '../../../core/constants/town_feature_constants.dart';
import 'feature_data.dart';

/// Full-width hero card with a bold gradient background.
/// Used for a single featured category (e.g. Creative Spaces).
class FeatureHeroCard extends StatelessWidget {
  final FeatureData feature;

  const FeatureHeroCard({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = feature.color;

    return Material(
      borderRadius: BorderRadius.circular(TownFeatureConstants.heroRadius),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: InkWell(
        onTap: feature.onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, Color.lerp(color, Colors.black, 0.15)!],
            ),
            borderRadius:
                BorderRadius.circular(TownFeatureConstants.heroRadius),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -24,
                top: -24,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Positioned(
                right: 30,
                bottom: -18,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  children: [
                    Container(
                      width: TownFeatureConstants.heroIconSize,
                      height: TownFeatureConstants.heroIconSize,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(
                          TownFeatureConstants.iconRadius,
                        ),
                      ),
                      child: Icon(
                        feature.icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            feature.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact vertical card for the 2-column feature grid.
class FeatureGridCard extends StatelessWidget {
  final FeatureData feature;

  const FeatureGridCard({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = feature.color;

    return Material(
      borderRadius: BorderRadius.circular(TownFeatureConstants.gridRadius),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: InkWell(
        onTap: feature.onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius:
                BorderRadius.circular(TownFeatureConstants.gridRadius),
            border: Border.all(
              color: color.withValues(alpha: 0.18),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: TownFeatureConstants.gridIconSize,
                      height: TownFeatureConstants.gridIconSize,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color,
                            Color.lerp(color, Colors.black, 0.12)!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          TownFeatureConstants.gridIconRadius,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        feature.icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  feature.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kept for backward compat — delegates to [FeatureGridCard].
typedef FeatureCard = FeatureGridCard;
