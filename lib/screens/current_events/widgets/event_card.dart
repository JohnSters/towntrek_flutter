import 'package:flutter/material.dart';
import '../../../core/config/api_config.dart';
import '../../../core/theme/entity_listing_theme.dart';
import '../../../core/widgets/listing_info_chip.dart';
import '../../../models/models.dart';
import '../../event_details/event_details_screen.dart';
import '../../../core/constants/current_events_constants.dart';

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

    return GestureDetector(
      onTap: canTap ? () => _navigateToEventDetails(context) : null,
      child: Container(
        decoration: BoxDecoration(
          color: EntityListingTheme.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.1),
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
                _buildHeaderBand(grey),
                _buildBody(grey),
                _buildFooter(),
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

  Widget _buildHeaderBand(bool grey) {
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.08),
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
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              event.displayPrice,
              style: TextStyle(
                fontSize: 11,
                color: grey
                    ? EntityListingTheme.badgeText.withValues(
                        alpha: CurrentEventsConstants.disabledTextOpacity,
                      )
                    : EntityListingTheme.badgeText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool grey) {
    final desc = _introText;
    final bodyColor = grey
        ? EntityListingTheme.bodyText.withValues(
            alpha: CurrentEventsConstants.disabledTextOpacity,
          )
        : EntityListingTheme.bodyText;

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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.07),
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Tap to view event',
            style: TextStyle(
              fontSize: 12,
              color: EntityListingTheme.footerHint,
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
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Container(
          color: Theme.of(context).colorScheme.surface.withValues(
                alpha: CurrentEventsConstants.finishedOverlayOpacity,
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
