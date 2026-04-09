import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import 'access_code_entry_screen.dart';
import 'parcel_ui.dart';

class ParcelProfileViewModel extends ChangeNotifier {
  ParcelProfileViewModel({required MemberRepository repository})
    : _repository = repository {
    load();
  }

  final MemberRepository _repository;

  bool loading = true;
  String? error;
  MemberProfileDto? profile;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      profile = await _repository.getMyProfile();
    } catch (err) {
      error = err.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ParcelProfileViewModel>();
    final sessionManager = serviceLocator.mobileSessionManager;
    final listing = context.entityListing;

    return Scaffold(
      backgroundColor: listing.pageBg,
      appBar: AppBar(title: const Text('Profile')),
      body: Builder(
        builder: (context) {
          if (viewModel.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null || viewModel.profile == null) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Center(
                child: Text(
                  viewModel.error ?? 'Unable to load profile',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }

          final profile = viewModel.profile!;
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final trustColors = _trustPillColors(profile.trustLevel);

          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primaryContainer.withValues(alpha: 0.72),
                      colorScheme.secondaryContainer.withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      child: Text(
                        profile.displayName.isNotEmpty
                            ? profile.displayName[0].toUpperCase()
                            : 'T',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
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
                          label:
                              '${profile.averageRating.toStringAsFixed(1)} stars',
                          backgroundColor: colorScheme.tertiaryContainer
                              .withValues(alpha: 0.85),
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
                  ],
                ),
              ),
              const SizedBox(height: 12),
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
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.35),
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
                        profile.secondaryTowns.map((t) => t.name).join(', '),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  await sessionManager.signOut();
                  if (!context.mounted) return;
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AccessCodeEntryScreen(),
                    ),
                  );
                  if (context.mounted) {
                    await context.read<ParcelProfileViewModel>().load();
                  }
                },
                child: const Text('Use a different access code'),
              ),
            ],
          );
        },
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
