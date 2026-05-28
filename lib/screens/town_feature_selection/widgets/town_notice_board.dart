import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/core.dart';
import '../../../core/utils/url_utils.dart';
import '../../../models/models.dart';

class _NoticeConstants {
  static const double outerRadius = 12.0;
  static const double headerPaddingH = 12.0;
  static const double headerPaddingV = 8.0;
  static const double dividerWidth = 1.0;
  static const double borderOpacity = 0.14;
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
      duration: const Duration(milliseconds: 1500),
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

    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = colorScheme.outline.withValues(
      alpha: _NoticeConstants.borderOpacity,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(_NoticeConstants.outerRadius),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: dividerColor),
          borderRadius: BorderRadius.circular(_NoticeConstants.outerRadius),
          color: colorScheme.surfaceContainerLow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NoticeHeader(
              count: widget.notices.length,
              expanded: _expanded,
              pulseController: _pulseController,
              shouldPulse: _shouldPulse,
              onTap: _toggleExpanded,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _expanded
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: _NoticeConstants.dividerWidth,
                          color: dividerColor,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              for (final notice in widget.notices)
                                _NoticeCard(notice: notice),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoticeHeader extends StatelessWidget {
  const _NoticeHeader({
    required this.count,
    required this.expanded,
    required this.pulseController,
    required this.shouldPulse,
    required this.onTap,
  });

  final int count;
  final bool expanded;
  final AnimationController pulseController;
  final bool shouldPulse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final t = shouldPulse
            ? CurvedAnimation(
                parent: pulseController,
                curve: Curves.easeInOut,
              ).value
            : 0.0;
        return DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              if (shouldPulse)
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.10 + 0.10 * t),
                  blurRadius: 8 + 8 * t,
                  spreadRadius: 0.5 * t,
                ),
            ],
          ),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _NoticeConstants.headerPaddingH,
              vertical: _NoticeConstants.headerPaddingV,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.campaign_rounded,
                  size: 15,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 5),
                Text(
                  'Town Notices',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.15,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$count',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
