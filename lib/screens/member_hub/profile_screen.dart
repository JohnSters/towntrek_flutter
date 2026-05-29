import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import '../../theme/member_level_tier_style.dart';
import 'access_code_entry_screen.dart';
import 'level_badge.dart';
import 'parcel_ui.dart';
import 'progress_screen.dart';
import 'profile_view_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ParcelProfileViewModel(repository: serviceLocator.memberRepository),
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  /// Vertical space between profile “cards” (identity, progress row, towns, CTA).
  static const double _sectionGap = 16;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ParcelProfileViewModel>();
    final sessionManager = serviceLocator.mobileSessionManager;
    final listing = context.entityListing;

    return Scaffold(
      backgroundColor: listing.pageBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EntityListingHeroHeader(
              theme: context.entityListingTheme,
              categoryIcon: Icons.person_outline_rounded,
              subCategoryName: 'Profile',
              categoryName: TownFeatureConstants.parcelsTitle,
              townName: 'Your account',
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (viewModel.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (viewModel.error != null || viewModel.profile == null) {
                    return ErrorStateView(
                      error: viewModel.error ?? 'Unable to load profile',
                      onRetry: viewModel.load,
                    );
                  }

                  final profile = viewModel.profile!;
                  final theme = Theme.of(context);
                  final colorScheme = theme.colorScheme;
                  final trustColors = _trustPillColors(profile.trustLevel);

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
                    children: [
                      _ProfileIdentityCard(
                        profile: profile,
                        sessionManager: sessionManager,
                        listing: listing,
                        theme: theme,
                        colorScheme: colorScheme,
                        trustColors: trustColors,
                      ),
                      const SizedBox(height: _sectionGap),
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tileColor: listing.cardBg,
                        leading: CircleAvatar(
                          backgroundColor: tierStyleForLevel(
                            6,
                          ).accentColor.withValues(alpha: 0.2),
                          child: Icon(
                            Icons.insights_rounded,
                            color: tierStyleForLevel(6).accentColor,
                          ),
                        ),
                        title: Text(
                          'Progress & achievements',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: listing.textTitle,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: colorScheme.primary,
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ProgressScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: _sectionGap),
                      DetailSectionShell(
                        title: 'Towns',
                        icon: Icons.location_city_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Primary',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              profile.primaryTown?.name ?? 'Not set yet',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.35,
                              ),
                            ),
                            if (profile.secondaryTowns.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              Text(
                                'Secondary',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                profile.secondaryTowns
                                    .map((t) => t.name)
                                    .join(', '),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: _sectionGap),
                      _LinkedAccountsCard(
                        sessionManager: sessionManager,
                        onSwitched: () =>
                            context.read<ParcelProfileViewModel>().load(),
                      ),
                      FilledButton(
                        onPressed: () async {
                          // Adds (or re-links) an account via a TREK code, keeping
                          // any other accounts already linked on this device.
                          await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => const AccessCodeEntryScreen(),
                            ),
                          );
                          if (context.mounted) {
                            await context.read<ParcelProfileViewModel>().load();
                          }
                        },
                        child: const Text('Add another account'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          side: BorderSide(
                            color: colorScheme.error.withValues(alpha: 0.55),
                          ),
                        ),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) {
                              return AlertDialog(
                                title: const Text('Disconnect this device?'),
                                content: Text(
                                  'You will need a new TownTrek code from My Devices on '
                                  'towntrek.co.za to use Parcel features on this device. '
                                  'Any unused codes on your account will be cancelled.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.4,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: colorScheme.error,
                                      foregroundColor: colorScheme.onError,
                                    ),
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(true),
                                    child: const Text('Disconnect'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (confirmed != true || !context.mounted) {
                            return;
                          }
                          await serviceLocator.mobileSessionManager.signOut();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Disconnect this device'),
                      ),
                    ],
                  );
                },
              ),
            ),
            const ListingBackFooter(label: 'Back'),
          ],
        ),
      ),
    );
  }
}

Color _onTierAccentFill(Color accent) =>
    accent.computeLuminance() > 0.55 ? const Color(0xFF1C1B1F) : Colors.white;

/// Web stores paths like `/uploads/profiles/...`; mobile API base supplies the host.
String? _resolvedMemberAvatarUrl(String? raw) {
  final t = raw?.trim();
  if (t == null || t.isEmpty) return null;
  final lower = t.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) return t;
  final base = ApiConfig.baseUrl.trim();
  final path = t.startsWith('/') ? t : '/$t';
  return '$base$path';
}

class _ProfilePhotoAvatar extends StatelessWidget {
  const _ProfilePhotoAvatar({
    required this.profile,
    required this.tierStyle,
    required this.theme,
    required this.onLetterColor,
  });

  final MemberProfileDto profile;
  final TierStyle tierStyle;
  final ThemeData theme;
  final Color onLetterColor;

  static const double _diameter = 76;

  @override
  Widget build(BuildContext context) {
    final url = _resolvedMemberAvatarUrl(profile.avatarUrl);
    final letter = profile.displayName.isNotEmpty
        ? profile.displayName[0].toUpperCase()
        : 'T';

    Widget letterFallback() {
      return Container(
        width: _diameter,
        height: _diameter,
        color: tierStyle.accentColor,
        alignment: Alignment.center,
        child: Text(
          letter,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: onLetterColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return ClipOval(
      child: url != null
          ? CachedNetworkImage(
              imageUrl: url,
              width: _diameter,
              height: _diameter,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 200),
              memCacheWidth: 256,
              placeholder: (context, _) => Container(
                width: _diameter,
                height: _diameter,
                color: tierStyle.accentColor,
                alignment: Alignment.center,
                child: SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: onLetterColor,
                  ),
                ),
              ),
              errorWidget: (context, url, err) => letterFallback(),
            )
          : letterFallback(),
    );
  }
}

class _ProfileIdentityCard extends StatelessWidget {
  const _ProfileIdentityCard({
    required this.profile,
    required this.sessionManager,
    required this.listing,
    required this.theme,
    required this.colorScheme,
    required this.trustColors,
  });

  final MemberProfileDto profile;
  final MobileSessionManager sessionManager;
  final EntityListingThemeExtension listing;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final (Color, Color) trustColors;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sessionManager,
      builder: (context, _) {
        final prog = sessionManager.memberProgression;
        final tierLevel = prog?.currentLevel ?? 1;
        final tierStyle = tierStyleForLevel(tierLevel);
        final isDark = theme.brightness == Brightness.dark;
        final onAvatar = _onTierAccentFill(tierStyle.accentColor);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: tierStyle.ringColor.withValues(alpha: 0.5),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tierStyle.accentColor.withValues(alpha: isDark ? 0.28 : 0.13),
                isDark
                    ? colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.92,
                      )
                    : Colors.white.withValues(alpha: 0.58),
                listing.cardBg,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: tierStyle.accentColor.withValues(alpha: 0.15),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: tierStyle.ringColor, width: 2.5),
                ),
                child: _ProfilePhotoAvatar(
                  profile: profile,
                  tierStyle: tierStyle,
                  theme: theme,
                  onLetterColor: onAvatar,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                profile.displayName,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: listing.textTitle,
                  height: 1.2,
                ),
              ),
              if (profile.primaryTown != null) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 16,
                      color: tierStyle.accentColor,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        profile.primaryTown!.name,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: listing.bodyText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (profile.email != null &&
                  profile.email!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  profile.email!.trim(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: listing.bodyText.withValues(alpha: 0.85),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  ParcelPill(
                    label: trustLevelLabel(profile.trustLevel),
                    backgroundColor: trustColors.$1,
                    foregroundColor: trustColors.$2,
                    icon: Icons.verified_user_outlined,
                  ),
                  ParcelPill(
                    label: '${profile.averageRating.toStringAsFixed(1)} stars',
                    backgroundColor: colorScheme.tertiaryContainer.withValues(
                      alpha: 0.85,
                    ),
                    foregroundColor: colorScheme.onTertiaryContainer,
                    icon: Icons.star_outline_rounded,
                  ),
                  ParcelPill(
                    label: '${profile.completedDeliveries} deliveries',
                    backgroundColor: listing.chipBg,
                    foregroundColor: listing.chipIconAndLabel,
                    icon: Icons.local_shipping_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _ProfileTierPlaque(
                prog: prog,
                tierStyle: tierStyle,
                listing: listing,
                theme: theme,
                colorScheme: colorScheme,
                onRefresh: sessionManager.loadProgression,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileTierPlaque extends StatelessWidget {
  const _ProfileTierPlaque({
    required this.prog,
    required this.tierStyle,
    required this.listing,
    required this.theme,
    required this.colorScheme,
    required this.onRefresh,
  });

  final MemberProgressionDto? prog;
  final TierStyle tierStyle;
  final EntityListingThemeExtension listing;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (prog == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              'Level and XP will load from your account.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: listing.bodyText,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.tonalIcon(
              onPressed: () => onRefresh(),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Refresh progression'),
            ),
          ],
        ),
      );
    }

    final p = prog!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tierStyle.ringColor.withValues(alpha: 0.55)),
        color: tierStyle.accentColor.withValues(alpha: 0.09),
        boxShadow: [
          BoxShadow(
            color: tierStyle.accentColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'YOUR LEVEL',
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 0.6,
              fontWeight: FontWeight.w700,
              color: tierStyle.accentColor,
            ),
          ),
          const SizedBox(height: 8),
          LevelBadge(
            level: p.currentLevel,
            title: p.currentLevelTitle,
            full: true,
            prominent: true,
          ),
          const SizedBox(height: 12),
          Text(
            '${p.totalXp} total XP',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: listing.textTitle,
            ),
          ),
          const SizedBox(height: 8),
          if (p.xpForNext > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: p.xpIntoLevel / (p.xpIntoLevel + p.xpForNext),
                minHeight: 8,
                color: tierStyle.accentColor,
                backgroundColor: tierStyle.accentColor.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${p.xpIntoLevel} XP this tier · '
              '${p.xpForNext} XP to ${tierStyleForLevel(p.currentLevel + 1).title}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: listing.bodyText,
                height: 1.35,
              ),
            ),
          ] else
            Text(
              'Max tier (${tierStyleForLevel(12).title}) — keep earning XP for '
              'seasonal standings.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: listing.bodyText,
                height: 1.35,
              ),
            ),
        ],
      ),
    );
  }
}

/// Lists accounts linked on this device and lets the user switch between them.
/// Hidden unless more than one account is linked.
class _LinkedAccountsCard extends StatelessWidget {
  const _LinkedAccountsCard({
    required this.sessionManager,
    required this.onSwitched,
  });

  final MobileSessionManager sessionManager;
  final Future<void> Function() onSwitched;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sessionManager,
      builder: (context, _) {
        final accounts = sessionManager.accounts;
        if (accounts.length <= 1) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final activeId = sessionManager.activeUserId;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DetailSectionShell(
            title: 'Linked accounts',
            icon: Icons.switch_account_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final account in accounts)
                  _LinkedAccountTile(
                    label: (account.displayName?.trim().isNotEmpty ?? false)
                        ? account.displayName!.trim()
                        : 'TownTrek account',
                    isActive: account.userId == activeId,
                    isBusy: sessionManager.isBusy,
                    onTap: account.userId == activeId
                        ? null
                        : () async {
                            final ok = await sessionManager
                                .switchAccount(account.userId);
                            if (!context.mounted) return;
                            if (ok) {
                              await onSwitched();
                            } else {
                              showErrorSnack(
                                context,
                                'Unable to switch to that account.',
                              );
                            }
                          },
                  ),
                const SizedBox(height: 4),
                Text(
                  'Switching changes which account posts and earns XP on this device.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LinkedAccountTile extends StatelessWidget {
  const _LinkedAccountTile({
    required this.label,
    required this.isActive,
    required this.isBusy,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final bool isBusy;
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: isActive
            ? colorScheme.primaryContainer.withValues(alpha: 0.4)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: (isActive || isBusy) ? null : () => onTap?.call(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isActive
                      ? Icons.check_circle_rounded
                      : Icons.account_circle_outlined,
                  color: isActive
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isActive)
                  Text(
                    'Active',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

(Color, Color) _trustPillColors(MemberTrustLevel level) => switch (level) {
  MemberTrustLevel.newMember => (
    const Color(0xFFE8F0FE),
    const Color(0xFF1A4F8F),
  ),
  MemberTrustLevel.community => (
    const Color(0xFFE6F4EA),
    const Color(0xFF1E5F32),
  ),
  MemberTrustLevel.trusted => (
    const Color(0xFFFFF4D6),
    const Color(0xFF7C5A00),
  ),
};
