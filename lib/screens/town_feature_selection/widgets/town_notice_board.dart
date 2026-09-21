import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/core.dart';
import '../../../core/utils/url_utils.dart';
import '../../../models/models.dart';
import 'town_hub_action_tile.dart';

class _NoticeConstants {
  static const Duration pulseDuration = Duration(milliseconds: 2000);
}

String _formatNoticeTimestamp(DateTime publishedAtUtc) {
  final local = publishedAtUtc.toLocal();
  final now = DateTime.now();
  final diff = now.difference(local);
  if (diff.isNegative) return DateFormat.yMMMd().format(local);
  if (diff.inDays >= 7) return DateFormat.yMMMd().format(local);
  if (diff.inDays >= 1) return '${diff.inDays}d ago';
  if (diff.inHours >= 1) return '${diff.inHours}h ago';
  if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
  return 'Just now';
}

String _formatEventDate(PublicTownNoticeDto notice) {
  final start = notice.eventStartDate;
  if (start == null) return '';

  final end = notice.eventEndDate;
  if (end == null ||
      (end.year == start.year &&
          end.month == start.month &&
          end.day == start.day)) {
    return DateFormat('EEEE, d MMMM').format(start);
  }

  if (start.year == end.year && start.month == end.month) {
    return '${DateFormat('d').format(start)}–${DateFormat('d MMMM').format(end)}';
  }

  return '${DateFormat('d MMMM').format(start)}–${DateFormat('d MMMM').format(end)}';
}

String _excerpt(String body, {int maxLen = 140}) {
  final t = body.trim();
  if (t.length <= maxLen) return t;
  return '${t.substring(0, maxLen).trim()}…';
}

String _noticeSubtitle(List<PublicTownNoticeDto> notices) {
  if (notices.length == 1) {
    final title = notices.first.title.trim();
    return title.isEmpty
        ? TownFeatureConstants.noticesSubtitle(1)
        : title;
  }
  return TownFeatureConstants.noticesSubtitle(notices.length);
}

/// Read-only list of published town notices for the hub.
class TownNoticeBoard extends StatefulWidget {
  const TownNoticeBoard({super.key, required this.notices});

  final List<PublicTownNoticeDto> notices;

  @override
  State<TownNoticeBoard> createState() => _TownNoticeBoardState();
}

class _TownNoticeBoardState extends State<TownNoticeBoard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _expanded = false;
  bool _hasBeenExpanded = false;

  bool get _shouldPulse =>
      widget.notices.isNotEmpty && !_expanded && !_hasBeenExpanded;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: _NoticeConstants.pulseDuration,
    );
    if (_shouldPulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant TownNoticeBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _hasBeenExpanded = true;
      }
    });
    _syncPulse();
  }

  void _syncPulse() {
    if (_shouldPulse) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notices.isEmpty) return const SizedBox.shrink();

    final accent = const Color(TownFeatureConstants.noticesAccent);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TownHubActionTile(
          title: TownFeatureConstants.noticesTitle,
          subtitle: _noticeSubtitle(widget.notices),
          onTap: _toggleExpanded,
          compact: true,
          accentColor: accent,
          tintColor: accent,
          tintStrength: TownFeatureConstants.hubActionNoticeTintStrength,
          pulse: _shouldPulse ? _pulseController : null,
          expanded: _expanded,
          leading: TownHubIconLead(
            icon: Icons.campaign_rounded,
            accentColor: accent,
            iconSize: TownFeatureConstants.hubActionUtilityIconSize,
          ),
          showChevron: false,
          trailing: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      for (final notice in widget.notices)
                        _NoticeCard(notice: notice),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.notice});

  final PublicTownNoticeDto notice;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final listing = context.entityListing;
    final border = colorScheme.outline.withValues(alpha: 0.18);
    final image = notice.imageUrl?.trim();
    final address = notice.physicalAddress?.trim();
    final eventDate = _formatEventDate(notice);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (image != null && image.isNotEmpty)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    UrlUtils.resolveImageUrl(image),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      notice.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: listing.textTitle,
                      ),
                    ),
                    if (eventDate.isNotEmpty ||
                        (address?.isNotEmpty ?? false)) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 5,
                        children: [
                          if (eventDate.isNotEmpty)
                            _MetaChip(
                              icon: Icons.calendar_today_rounded,
                              label: eventDate,
                            ),
                          if (address != null && address.isNotEmpty)
                            _MetaChip(
                              icon: Icons.place_outlined,
                              label: address,
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      _excerpt(notice.body),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: listing.bodyText,
                        height: 1.35,
                      ),
                    ),
                    if ((notice.contactEmail != null &&
                            notice.contactEmail!.trim().isNotEmpty) ||
                        (notice.contactPhone != null &&
                            notice.contactPhone!.trim().isNotEmpty)) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (notice.contactEmail != null &&
                              notice.contactEmail!.trim().isNotEmpty)
                            _ContactChip(
                              icon: Icons.email_outlined,
                              label: notice.contactEmail!.trim(),
                            ),
                          if (notice.contactPhone != null &&
                              notice.contactPhone!.trim().isNotEmpty)
                            _ContactChip(
                              icon: Icons.phone_outlined,
                              label: notice.contactPhone!.trim(),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      _formatNoticeTimestamp(notice.publishedAtUtc),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: listing.footerHint,
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.primary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactChip extends StatelessWidget {
  const _ContactChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.primary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
