import 'package:flutter/material.dart';
import '../../../core/config/api_config.dart';
import '../../../models/models.dart';
import '../../event_details/event_details_screen.dart';
import '../../../core/constants/current_events_constants.dart';
import 'info_pill.dart';

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

    return OutlinedButton(
      onPressed: event.shouldGreyOut ? null : () => _navigateToEventDetails(context),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.primary.withValues(alpha: 0.02),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo/Image (Left Side) - Centered vertically
              Container(
                alignment: Alignment.center,
                height: 80, // Fixed height to center within
                child: _buildEventLogo(logoImage, colorScheme),
              ),

              const SizedBox(width: 16),

              // Content (Right Side)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row: Title and compact Price
                    _buildHeaderRow(),

                    // Short Description (closer to title)
                    if (event.shortDescription != null && event.shortDescription!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildShortDescription(theme, colorScheme),
                    ],

                    const SizedBox(height: 16),

                    // Metadata Row (Type | Date)
                    _buildMetadataRow(colorScheme),
                  ],
                ),
              ),
            ],
          ),

          // Priority/Featured Badge (Top Left)
          if (event.isPriorityListing && !event.shouldGreyOut)
            _buildFeaturedBadge(colorScheme, theme),

          // Finished Overlay
          if (event.shouldGreyOut)
            _buildFinishedOverlay(colorScheme, theme),
        ],
      ),
    );
  }

  Widget _buildEventLogo(ImageProvider? logoImage, ColorScheme colorScheme) {
    return Container(
      width: CurrentEventsConstants.logoSize,
      height: CurrentEventsConstants.logoSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          CurrentEventsConstants.logoBorderRadius,
        ),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.4), // More visible primary border
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        color: colorScheme.surface, // Add background for better contrast
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          CurrentEventsConstants.logoBorderRadius - 1, // Account for border width
        ),
        child: logoImage != null
            ? Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: logoImage,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : Container(
                color: colorScheme.primaryContainer.withValues(
                  alpha: CurrentEventsConstants.primaryPillBackgroundOpacity,
                ),
                child: Icon(
                  CurrentEventsConstants.defaultEventIcon,
                  size: CurrentEventsConstants.defaultIconSize,
                  color: colorScheme.primary,
                ),
              ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            event.name,
            style: TextStyle(
              fontSize: 18, // Made bigger
              fontWeight: FontWeight.w700, // Bolder weight
              height: CurrentEventsConstants.titleHeight,
              color: event.shouldGreyOut
                  ? Colors.black.withValues(alpha: CurrentEventsConstants.disabledTextOpacity)
                  : null,
            ),
            maxLines: CurrentEventsConstants.maxTitleLines,
            overflow: CurrentEventsConstants.textOverflow,
          ),
        ),
        const SizedBox(width: 8),
        // Compact price pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: event.isFreeEvent
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: event.isFreeEvent
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.blue.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            event.displayPrice,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: event.isFreeEvent ? Colors.green.shade700 : Colors.blue.shade700,
            ),
          ),
        ),
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