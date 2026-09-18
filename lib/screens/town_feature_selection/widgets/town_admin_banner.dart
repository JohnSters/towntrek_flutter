import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../../../models/models.dart';
import 'town_hub_action_tile.dart';

String townAdminInitials(String displayName) {
  final parts = displayName
      .trim()
      .split(RegExp(r'\s+'))
      .where((s) => s.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'TA';
  if (parts.length == 1) {
    final s = parts.first;
    return s.length >= 2
        ? '${s[0]}${s[1]}'.toUpperCase()
        : s[0].toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

/// Compact tappable row for the assigned Town Admin on the town hub.
///
/// One admin: the whole row opens the contact sheet.
/// Several admins: two equal trailing buttons — switch person, or open details.
class TownAdminBanner extends StatelessWidget {
  const TownAdminBanner({
    super.key,
    required this.profile,
    required this.onOpenDetail,
    this.profiles = const [],
    this.onSelect,
  });

  static const Key switchButtonKey = Key('town-admin-switch');
  static const Key detailsButtonKey = Key('town-admin-details');

  final PublicTownAdminProfileDto profile;
  final List<PublicTownAdminProfileDto> profiles;
  final ValueChanged<PublicTownAdminProfileDto>? onSelect;
  final VoidCallback onOpenDetail;

  bool get _hasPicker => profiles.length > 1 && onSelect != null;

  @override
  Widget build(BuildContext context) {
    final accent = const Color(TownFeatureConstants.adminAccent);
    final border = accent.withValues(alpha: 0.28);

    return TownHubActionTile(
      title: profile.displayName,
      subtitle: profile.title,
      onTap: _hasPicker ? null : onOpenDetail,
      accentColor: accent,
      tintColor: accent,
      leading: _AdminLeading(
        initials: townAdminInitials(profile.displayName),
        accentColor: accent,
      ),
      showChevron: !_hasPicker,
      trailing: _hasPicker
          ? _TrailingActions(
              profile: profile,
              profiles: profiles,
              onSelect: onSelect!,
              onOpenDetail: onOpenDetail,
              dividerColor: border,
            )
          : null,
    );
  }
}

class _AdminLeading extends StatelessWidget {
  const _AdminLeading({required this.initials, required this.accentColor});

  final String initials;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor,
            Color.lerp(accentColor, Colors.black, 0.22)!,
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

class _TrailingActions extends StatelessWidget {
  const _TrailingActions({
    required this.profile,
    required this.profiles,
    required this.onSelect,
    required this.onOpenDetail,
    required this.dividerColor,
  });

  final PublicTownAdminProfileDto profile;
  final List<PublicTownAdminProfileDto> profiles;
  final ValueChanged<PublicTownAdminProfileDto> onSelect;
  final VoidCallback onOpenDetail;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VerticalDivider(width: 1, thickness: 1, color: dividerColor),
        PopupMenuButton<int>(
          key: TownAdminBanner.switchButtonKey,
          tooltip: 'Choose Town Admin',
          padding: EdgeInsets.zero,
          position: PopupMenuPosition.under,
          offset: const Offset(0, 6),
          borderRadius: BorderRadius.circular(12),
          constraints: const BoxConstraints(minWidth: 220),
          initialValue: profile.id,
          onSelected: (id) {
            for (final admin in profiles) {
              if (admin.id == id) {
                onSelect(admin);
                return;
              }
            }
          },
          itemBuilder: (context) => [
            for (final admin in profiles)
              PopupMenuItem<int>(
                value: admin.id,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        admin.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (admin.id == profile.id)
                      Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  ],
                ),
              ),
          ],
          child: const _SideSlot(
            icon: Icons.keyboard_arrow_down_rounded,
          ),
        ),
        VerticalDivider(width: 1, thickness: 1, color: dividerColor),
        Tooltip(
          message: 'Town Admin details',
          child: InkWell(
            key: TownAdminBanner.detailsButtonKey,
            onTap: onOpenDetail,
            child: const _SideSlot(
              icon: Icons.chevron_right_rounded,
            ),
          ),
        ),
      ],
    );
  }
}

class _SideSlot extends StatelessWidget {
  const _SideSlot({required this.icon});

  final IconData icon;

  static const double _width = 52;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      height: double.infinity,
      child: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
