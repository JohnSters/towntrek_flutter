import 'package:flutter/material.dart';
import '../../../core/config/api_config.dart';
import '../../../core/theme/entity_listing_theme.dart';
import '../../../theme/entity_listing_theme_extension.dart';
import '../../../core/widgets/listing_info_chip.dart';
import '../../../models/models.dart';
import '../../event_details/event_details_screen.dart';
import '../../../core/constants/current_events_constants.dart';

DateTime _eventListingStartDateTime(EventDto event) {
  final d = event.startDate;
  final ts = event.startTime;
  if (ts != null && ts.trim().isNotEmpty) {
    final parts = ts.split(':');
    final h = int.tryParse(parts[0].trim()) ?? 0;
    final m = parts.length > 1 ? int.tryParse(parts[1].trim()) ?? 0 : 0;
    return DateTime(d.year, d.month, d.day, h, m);
  }
  return DateTime(d.year, d.month, d.day);
}

bool _eventListingHasStarted(EventDto event) {
  return !DateTime.now().isBefore(_eventListingStartDateTime(event));
}

bool _eventListingShowsOpenClosedChip(EventDto event) {
  return event.isFinished || _eventListingHasStarted(event);
}

bool _eventListingChipIsOpen(EventDto event) {
  return !event.isFinished && _eventListingHasStarted(event);
}

/// Listing card for events — price in header band (design doc §5, §8 Events).
class EventCard extends StatelessWidget {
  final EventDto event;
  final String townName;
  final EntityListingTheme listingTheme;

  const EventCard({
    super.key,
    required this.event,
    required this.townName,
    required this.listingTheme,
  });

  ImageProvider? get _logoImage {
    if (event.logoUrl == null || event.logoUrl!.isEmpty) return null;
    if (event.logoUrl!.startsWith('http')) {
      return NetworkImage(event.logoUrl!);
    }
    return NetworkImage('${ApiConfig.baseUrl}${event.logoUrl}');
  }

  String? get _introText {
    final s = event.shortDescription?.trim();
    if (s != null && s.isNotEmpty) return s;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final grey = event.shouldGreyOut;
    final canTap = !grey;
    final listingColors = context.entityListing;
    final outline = Theme.of(context).colorScheme.outline;

    return GestureDetector(
      onTap: canTap ? () => _navigateToEventDetails(context) : null,
      child: Container(
        decoration: BoxDecoration(
          color: listingColors.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: outline.withValues(alpha: 0.25),
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderBand(context, listingColors, grey),
                _buildBody(grey, listingColors),
                _buildFooter(listingColors, outline),
              ],
            ),
            if (event.isPriorityListing && !grey)
              Positioned(
                top: 0,
                left: 0,
                child: _featuredBadge(context),
              ),
            if (grey) _finishedOverlay(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBand(
    BuildContext context,
    EntityListingThemeExtension listingColors,
    bool grey,
  ) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: listingTheme.cardHeaderGradient,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: listingColors.cardBg,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.5),
              child: _logoImage != null
                  ? Image(
                      image: _logoImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          CurrentEventsConstants.defaultEventIcon,
                          size: 26,
                          color: listingTheme.accent,
                        );
                      },
                    )
                  : Icon(
                      CurrentEventsConstants.defaultEventIcon,
                      size: 26,
                      color: listingTheme.accent,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: grey
                        ? listingTheme.textTitle.withValues(
                            alpha: CurrentEventsConstants.disabledTextOpacity,
                          )
                        : listingTheme.textTitle,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: listingColors.cardBg.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              event.displayPrice,
              style: TextStyle(
                fontSize: 11,
                color: grey
                    ? listingColors.badgeText.withValues(
                        alpha: CurrentEventsConstants.disabledTextOpacity,
                      )
                    : listingColors.badgeText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool grey, EntityListingThemeExtension listingColors) {
    final desc = _introText;
    final bodyColor = grey
        ? listingColors.bodyText.withValues(
            alpha: CurrentEventsConstants.disabledTextOpacity,
          )
        : listingColors.bodyText;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (desc != null) ...[
            Text(
              desc,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 13,
                color: bodyColor,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: [
              ListingInfoChip(
                icon: Icons.location_on_outlined,
                label: townName,
              ),
              ListingInfoChip(
                icon: Icons.calendar_today_outlined,
                label: event.displayDate,
              ),
              if (_eventListingShowsOpenClosedChip(event))
                ListingOpenClosedChip(
                  isOpen: _eventListingChipIsOpen(event),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
    EntityListingThemeExtension listingColors,
    Color outline,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: outline.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tap to view event',
            style: TextStyle(
              fontSize: 12,
              color: listingColors.footerHint,
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: listingTheme.accent,
          ),
        ],
      ),
    );
  }

  Widget _featuredBadge(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CurrentEventsConstants.featuredBadgePaddingHorizontal,
        vertical: CurrentEventsConstants.featuredBadgePaddingVertical,
      ),
      decoration: BoxDecoration(
        color: colorScheme.tertiary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
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
    );
  }

  Widget _finishedOverlay(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Container(
          color: colorScheme.surface.withValues(
                alpha: CurrentEventsConstants.finishedOverlayOpacity,
              ),
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: CurrentEventsConstants.finishedOverlayPaddingHorizontal,
              vertical: CurrentEventsConstants.finishedOverlayPaddingVertical,
            ),
            decoration: BoxDecoration(
              color: colorScheme.inverseSurface.withValues(
                alpha: CurrentEventsConstants.finishedTextBackgroundOpacity,
              ),
              borderRadius: BorderRadius.circular(
                CurrentEventsConstants.finishedOverlayBorderRadius,
              ),
            ),
            child: Text(
              CurrentEventsConstants.finishedBadgeText,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onInverseSurface,
                fontWeight: CurrentEventsConstants.finishedBadgeFontWeight,
              ),
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
