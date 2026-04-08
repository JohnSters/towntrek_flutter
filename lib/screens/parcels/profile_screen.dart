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
      create: (_) => ParcelProfileViewModel(
        repository: serviceLocator.memberRepository,
      ),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Builder(
        builder: (context) {
          if (viewModel.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null || viewModel.profile == null) {
            return Center(child: Text(viewModel.error ?? 'Unable to load profile'));
          }

          final profile = viewModel.profile!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CircleAvatar(
                radius: 36,
                child: Text(
                  profile.displayName.isNotEmpty
                      ? profile.displayName[0].toUpperCase()
                      : 'T',
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  profile.displayName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  Chip(label: Text(trustLevelLabel(profile.trustLevel))),
                  Chip(label: Text('${profile.averageRating.toStringAsFixed(1)} stars')),
                  Chip(label: Text('${profile.completedDeliveries} deliveries')),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Towns'),
                      const SizedBox(height: 8),
                      Text(
                        'Primary: ${profile.primaryTown?.name ?? 'Not set yet'}',
                      ),
                      if (profile.secondaryTowns.isNotEmpty)
                        Text(
                          'Secondary: ${profile.secondaryTowns.map((t) => t.name).join(', ')}',
                        ),
                    ],
                  ),
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
