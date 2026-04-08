import 'package:flutter/material.dart';

import '../../models/models.dart';

Color parcelStatusColor(BuildContext context, ParcelStatus status) {
  final scheme = Theme.of(context).colorScheme;
  return switch (status) {
    ParcelStatus.open => scheme.surfaceContainerHighest,
    ParcelStatus.claimed => const Color(0xFFF9C74F),
    ParcelStatus.pickedUp => const Color(0xFF4D96FF),
    ParcelStatus.delivered => const Color(0xFFFFA94D),
    ParcelStatus.confirmed => const Color(0xFF51CF66),
    ParcelStatus.cancelled => scheme.errorContainer,
    ParcelStatus.expired => scheme.surfaceContainerLow,
  };
}

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

class ParcelCard extends StatelessWidget {
  const ParcelCard({
    super.key,
    required this.parcel,
    this.onTap,
    this.trailing,
  });

  final ParcelSummaryDto parcel;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = parcelStatusColor(context, parcel.status);
    return Card(
      color: statusColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Chip(label: Text(parcelStatusLabel(parcel.status))),
                  const SizedBox(width: 8),
                  Chip(label: Text(parcelSizeLabel(parcel.parcelSize))),
                  const Spacer(),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: 8),
              Text(
                parcel.requestType == ParcelRequestType.routeRequest
                    ? (parcel.routeSummary?.isNotEmpty == true
                          ? parcel.routeSummary!
                          : '${parcel.pickupLocation} to ${parcel.dropoffLocation}')
                    : '${parcel.pickupLocation} to ${parcel.dropoffLocation}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                parcel.note?.isNotEmpty == true
                    ? parcel.note!
                    : parcel.requestType == ParcelRequestType.routeRequest
                    ? (parcel.routeTravelNote ?? 'Looking for help on this route.')
                    : 'A neighbour needs help with a local parcel run.',
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(urgencyLabel(parcel.urgencyLevel))),
                  Chip(label: Text(parcel.requestedByDisplayName)),
                  if (parcel.thankYouOffer?.isNotEmpty == true)
                    Chip(label: Text(parcel.thankYouOffer!)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
