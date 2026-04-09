import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import 'level_badge.dart';

Color parcelStatusColor(BuildContext context, ParcelStatus status) {
  final scheme = Theme.of(context).colorScheme;
  return switch (status) {
    ParcelStatus.open => scheme.primaryContainer,
    ParcelStatus.claimed => const Color(0xFFFFF4D6),
    ParcelStatus.pickedUp => scheme.secondaryContainer,
    ParcelStatus.delivered => const Color(0xFFFFE8D6),
    ParcelStatus.confirmed => scheme.tertiaryContainer,
    ParcelStatus.cancelled => scheme.errorContainer,
    ParcelStatus.expired => scheme.surfaceContainerHighest,
  };
}

Color parcelStatusOnColor(BuildContext context, ParcelStatus status) {
  final scheme = Theme.of(context).colorScheme;
  return switch (status) {
    ParcelStatus.open => scheme.onPrimaryContainer,
    ParcelStatus.claimed => const Color(0xFF7C5A00),
    ParcelStatus.pickedUp => scheme.onSecondaryContainer,
    ParcelStatus.delivered => const Color(0xFF8B4510),
    ParcelStatus.confirmed => scheme.onTertiaryContainer,
    ParcelStatus.cancelled => scheme.onErrorContainer,
    ParcelStatus.expired => scheme.onSurfaceVariant,
  };
}

(String bgHex, String fgHex) _urgencyHex(UrgencyLevel urgency) =>
    switch (urgency) {
      UrgencyLevel.flexible => ('E8F0FE', '1A4F8F'),
      UrgencyLevel.today => ('FFF0E0', 'B35A00'),
      UrgencyLevel.urgent => ('FFE8EC', '9B1B30'),
    };

Color _hexBg(String hex) => Color(int.parse('FF$hex', radix: 16));

(String bgHex, String fgHex) _sizeHex(ParcelSize size) => switch (size) {
  ParcelSize.small => ('EEF2F7', '3D5068'),
  ParcelSize.medium => ('E3EDFA', '2A5580'),
  ParcelSize.large => ('DDE7F5', '0D2D5A'),
};

String parcelStatusLabel(ParcelStatus status) => switch (status) {
  ParcelStatus.open => 'Open',
  ParcelStatus.claimed => 'Claimed',
  ParcelStatus.pickedUp => 'Picked up',
  ParcelStatus.delivered => 'Delivered',
  ParcelStatus.confirmed => 'Confirmed',
  ParcelStatus.cancelled => 'Cancelled',
  ParcelStatus.expired => 'Expired',
};

String urgencyLabel(UrgencyLevel urgency) => switch (urgency) {
  UrgencyLevel.flexible => 'Flexible',
  UrgencyLevel.today => 'Today',
  UrgencyLevel.urgent => 'Urgent',
};

String parcelSizeLabel(ParcelSize size) => switch (size) {
  ParcelSize.small => 'Small',
  ParcelSize.medium => 'Medium',
  ParcelSize.large => 'Large',
};

String requestTypeLabel(ParcelRequestType type) => switch (type) {
  ParcelRequestType.standardParcel => 'Parcel',
  ParcelRequestType.routeRequest => 'Route',
};

String trustLevelLabel(MemberTrustLevel level) => switch (level) {
  MemberTrustLevel.newMember => 'New',
  MemberTrustLevel.community => 'Community',
  MemberTrustLevel.trusted => 'Trusted',
};

/// Compact pill used on parcel cards and profile.
class ParcelPill extends StatelessWidget {
  const ParcelPill({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.icon,
    this.compact = true,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final fontSize = compact ? 12.0 : 13.0;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: foregroundColor.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 14 : 16, color: foregroundColor),
            SizedBox(width: compact ? 4 : 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: foregroundColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class ParcelCard extends StatelessWidget {
  const ParcelCard({
    super.key,
    required this.parcel,
    this.onTap,
    this.trailing,
    this.dense = false,
  });

  final ParcelSummaryDto parcel;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final listing = context.entityListing;
    final listingGrad = context.entityListingTheme;
    final outline = colorScheme.outline.withValues(alpha: 0.18);

    final statusBg = parcelStatusColor(context, parcel.status);
    final statusFg = parcelStatusOnColor(context, parcel.status);
    final urg = _urgencyHex(parcel.urgencyLevel);
    final sz = _sizeHex(parcel.parcelSize);

    final titleText = parcel.requestType == ParcelRequestType.routeRequest
        ? (parcel.routeSummary?.isNotEmpty == true
              ? parcel.routeSummary!
              : '${parcel.pickupLocation} → ${parcel.dropoffLocation}')
        : '${parcel.pickupLocation} → ${parcel.dropoffLocation}';

    final noteText = parcel.note?.isNotEmpty == true
        ? parcel.note!
        : parcel.requestType == ParcelRequestType.routeRequest
        ? (parcel.routeTravelNote ?? 'Looking for help on this route.')
        : 'A neighbour needs help with a local parcel run.';

    final inner = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            12,
            dense ? 10 : 12,
            12,
            dense ? 10 : 12,
          ),
          decoration: BoxDecoration(
            gradient: listingGrad.cardHeaderGradient,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            border: Border(
              bottom: BorderSide(color: outline.withValues(alpha: 0.35)),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ParcelPill(
                      label: parcelStatusLabel(parcel.status),
                      backgroundColor: statusBg,
                      foregroundColor: statusFg,
                      icon: Icons.flag_outlined,
                    ),
                    ParcelPill(
                      label: parcelSizeLabel(parcel.parcelSize),
                      backgroundColor: _hexBg(sz.$1),
                      foregroundColor: _hexBg(sz.$2),
                      icon: Icons.inventory_2_outlined,
                    ),
                    ParcelPill(
                      label: requestTypeLabel(parcel.requestType),
                      backgroundColor: colorScheme.surface.withValues(
                        alpha: 0.92,
                      ),
                      foregroundColor: listing.textTitle,
                      icon: parcel.requestType == ParcelRequestType.routeRequest
                          ? Icons.alt_route_rounded
                          : Icons.local_shipping_outlined,
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 6),
                IconTheme(
                  data: IconThemeData(
                    color: listing.textTitle.withValues(alpha: 0.45),
                    size: 16,
                  ),
                  child: trailing!,
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            14,
            dense ? 12 : 14,
            14,
            dense ? 12 : 14,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: listing.textTitle,
                  height: 1.25,
                ),
              ),
              SizedBox(height: dense ? 6 : 8),
              Text(
                noteText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: listing.bodyText,
                  height: 1.45,
                ),
                maxLines: dense ? 2 : 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (parcel.claimerLevel != null &&
                  parcel.claimerLevel! > 0 &&
                  (parcel.status == ParcelStatus.claimed ||
                      parcel.status == ParcelStatus.pickedUp ||
                      parcel.status == ParcelStatus.delivered)) ...[
                SizedBox(height: dense ? 8 : 10),
                Row(
                  children: [
                    Text(
                      'Claimer ',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: listing.bodyText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    LevelBadge(level: parcel.claimerLevel),
                    if (parcel.claimerLevelTitle?.isNotEmpty == true) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          parcel.claimerLevelTitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: listing.bodyText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              SizedBox(height: dense ? 10 : 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ParcelPill(
                    label: urgencyLabel(parcel.urgencyLevel),
                    backgroundColor: _hexBg(urg.$1),
                    foregroundColor: _hexBg(urg.$2),
                    icon: Icons.schedule_rounded,
                  ),
                  ParcelPill(
                    label: parcel.requestedByDisplayName,
                    backgroundColor: listing.chipBg,
                    foregroundColor: listing.chipIconAndLabel,
                    icon: Icons.person_outline_rounded,
                  ),
                  if (parcel.thankYouOffer?.isNotEmpty == true)
                    ParcelPill(
                      label: parcel.thankYouOffer!,
                      backgroundColor: colorScheme.primaryContainer.withValues(
                        alpha: 0.65,
                      ),
                      foregroundColor: colorScheme.onPrimaryContainer,
                      icon: Icons.card_giftcard_outlined,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    final radius = BorderRadius.circular(14);
    final decorated = Container(
      decoration: BoxDecoration(
        color: listing.cardBg,
        borderRadius: radius,
        border: Border.all(color: outline),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: radius, child: inner),
    );

    if (onTap == null) {
      return decorated;
    }

    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: InkWell(onTap: onTap, borderRadius: radius, child: decorated),
    );
  }
}
