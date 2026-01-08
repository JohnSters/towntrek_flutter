import 'package:flutter/material.dart';
import '../../../core/config/api_config.dart';
import '../../../models/models.dart';
import '../../event_details/event_details_screen.dart';
import '../../../core/constants/current_events_constants.dart';
import 'info_pill.dart';
import 'price_pill.dart';

/// Card widget for displaying event information with navigation
class EventCard extends StatelessWidget {
  final EventDto event;

  const EventCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Construct image URL if available
    ImageProvider? logoImage;
    if (event.logoUrl != null && event.logoUrl!.isNotEmpty) {
      if (event.logoUrl!.startsWith('http')) {
        logoImage = NetworkImage(event.logoUrl!);
      } else {
        logoImage = NetworkImage('${ApiConfig.baseUrl}${event.logoUrl}');
      }
    }

    return Container(
      margin: const EdgeInsets.only(
        bottom: CurrentEventsConstants.cardMarginBottom,
      ),
      child: Card(
        elevation: CurrentEventsConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            CurrentEventsConstants.cardBorderRadius,
          ),
          side: BorderSide(
            color: colorScheme.outline.withValues(
              alpha: CurrentEventsConstants.cardBorderOpacity,
            ),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: event.shouldGreyOut ? null : () => _navigateToEventDetails(context),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(CurrentEventsConstants.cardPaddingAll),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo/Image (Left Side)
                    _buildEventLogo(logoImage, colorScheme),

                    const SizedBox(width: CurrentEventsConstants.logoMarginRight),

                    // Content (Right Side)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row: Title and Price
                          _buildHeaderRow(),

                          // Short Description
                          if (event.shortDescription != null && event.shortDescription!.isNotEmpty) ...[
                            const SizedBox(height: CurrentEventsConstants.shortDescriptionSpacing),
                            _buildShortDescription(theme, colorScheme),
                          ],

                          const SizedBox(height: CurrentEventsConstants.metadataSpacing),

                          // Metadata Row (Type | Date)
                          _buildMetadataRow(colorScheme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Priority/Featured Badge (Top Left)
              if (event.isPriorityListing && !event.shouldGreyOut)
                _buildFeaturedBadge(colorScheme, theme),

              // Finished Overlay
              if (event.shouldGreyOut)
                _buildFinishedOverlay(colorScheme, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventLogo(ImageProvider? logoImage, ColorScheme colorScheme) {
    if (logoImage != null) {
      return Container(
        width: CurrentEventsConstants.logoSize,
        height: CurrentEventsConstants.logoSize,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(
            CurrentEventsConstants.logoBorderRadius,
          ),
          image: DecorationImage(
            image: logoImage,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        width: CurrentEventsConstants.logoSize,
        height: CurrentEventsConstants.logoSize,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(
            alpha: CurrentEventsConstants.primaryPillBackgroundOpacity,
          ),
          borderRadius: BorderRadius.circular(
            CurrentEventsConstants.logoBorderRadius,
          ),
        ),
        child: Icon(
          CurrentEventsConstants.defaultEventIcon,
          size: CurrentEventsConstants.defaultIconSize,
          color: colorScheme.primary,
        ),
      );
    }
  }

  Widget _buildHeaderRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            event.name,
            style: TextStyle(
              fontWeight: CurrentEventsConstants.titleFontWeight,
              height: CurrentEventsConstants.titleHeight,
              color: event.shouldGreyOut
                  ? Colors.black.withValues(alpha: CurrentEventsConstants.disabledTextOpacity)
                  : null,
            ),
            maxLines: CurrentEventsConstants.maxTitleLines,
            overflow: CurrentEventsConstants.textOverflow,
          ),
        ),
        const SizedBox(width: CurrentEventsConstants.headerRowSpacing),
        PricePill(event: event),
      ],
    );
  }

  Widget _buildShortDescription(ThemeData theme, ColorScheme colorScheme) {
    return Text(
      event.shortDescription!,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: event.shouldGreyOut
            ? colorScheme.onSurfaceVariant.withValues(
                alpha: CurrentEventsConstants.disabledTextOpacity,
              )
            : colorScheme.onSurfaceVariant,
        height: CurrentEventsConstants.descriptionHeight,
      ),
      maxLines: CurrentEventsConstants.maxDescriptionLines,
      overflow: CurrentEventsConstants.textOverflow,
    );
  }

  Widget _buildMetadataRow(ColorScheme colorScheme) {
    return Wrap(
      spacing: CurrentEventsConstants.wrapSpacing,
      runSpacing: CurrentEventsConstants.wrapRunSpacing,
      children: [
        InfoPill(
          text: event.eventType,
          backgroundColor: colorScheme.secondaryContainer,
          textColor: colorScheme.onSecondaryContainer,
        ),
        InfoPill(
          text: event.displayDate,
          backgroundColor: colorScheme.tertiaryContainer,
          textColor: colorScheme.onTertiaryContainer,
        ),
      ],
    );
  }

  Widget _buildFeaturedBadge(ColorScheme colorScheme, ThemeData theme) {
    return Positioned(
      top: 0,
      left: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: CurrentEventsConstants.featuredBadgePaddingHorizontal,
          vertical: CurrentEventsConstants.featuredBadgePaddingVertical,
        ),
        decoration: BoxDecoration(
          color: colorScheme.tertiary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(CurrentEventsConstants.featuredBadgeBorderRadius),
            bottomRight: Radius.circular(CurrentEventsConstants.featuredBadgeBorderRadius),
          ),
        ),
        child: Text(
          CurrentEventsConstants.featuredBadgeText,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onTertiary,
            fontWeight: CurrentEventsConstants.featuredBadgeFontWeight,
          ),
        ),
      ),
    );
  }

  Widget _buildFinishedOverlay(ColorScheme colorScheme, ThemeData theme) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(
            alpha: CurrentEventsConstants.finishedOverlayOpacity,
          ),
          borderRadius: BorderRadius.circular(
            CurrentEventsConstants.cardBorderRadius,
          ),
        ),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: CurrentEventsConstants.finishedOverlayPaddingHorizontal,
            vertical: CurrentEventsConstants.finishedOverlayPaddingVertical,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(
              alpha: CurrentEventsConstants.finishedTextBackgroundOpacity,
            ),
            borderRadius: BorderRadius.circular(
              CurrentEventsConstants.finishedOverlayBorderRadius,
            ),
          ),
          child: Text(
            CurrentEventsConstants.finishedBadgeText,
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: CurrentEventsConstants.finishedBadgeFontWeight,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToEventDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(
          eventId: event.id,
          eventName: event.name,
          eventType: event.eventType,
          initialImageUrl: event.logoUrl,
        ),
      ),
    );
  }
}