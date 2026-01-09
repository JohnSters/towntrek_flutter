import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../core/core.dart';
import '../repositories/repositories.dart';
import 'landing_page/widgets/widgets.dart';
import 'town_loader/town_loader_screen.dart';

// State classes for type-safe state management
sealed class LandingPageState {}

class LandingPageLoading extends LandingPageState {}

class LandingPageSuccess extends LandingPageState {
  final int businessCount;
  final int serviceCount;
  final int eventCount;

  LandingPageSuccess({
    required this.businessCount,
    required this.serviceCount,
    required this.eventCount,
  });
}

class LandingPageError extends LandingPageState {
  final String message;

  LandingPageError(this.message);
}

// ViewModel for business logic separation
class LandingViewModel extends ChangeNotifier {
  LandingPageState _state = LandingPageLoading();
  LandingPageState get state => _state;

  final StatsRepository _statsRepository;

  LandingViewModel({required StatsRepository statsRepository})
      : _statsRepository = statsRepository {
    loadStats();
  }

  Future<void> loadStats() async {
    _state = LandingPageLoading();
    notifyListeners();

    try {
      final stats = await _statsRepository.getLandingStats();
      _state = LandingPageSuccess(
        businessCount: stats.businessCount,
        serviceCount: stats.serviceCount,
        eventCount: stats.eventCount,
      );
      notifyListeners();
    } catch (e) {
      _state = LandingPageError(e.toString());
      notifyListeners();
    }
  }

  Future<void> launchOwnerUrl(BuildContext context) async {
    final Uri url = Uri.parse(LandingPageConstants.ownerWebsiteUrl);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(LandingPageConstants.launchUrlErrorMessage)),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LandingViewModel(statsRepository: serviceLocator.statsRepository),
      child: const _LandingPageContent(),
    );
  }
}

class _LandingPageContent extends StatelessWidget {
  const _LandingPageContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewModel = context.watch<LandingViewModel>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: LandingPageConstants.horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: LandingPageConstants.verticalSpacingLarge),

                    // App Logo
                    const AppLogo(),

                    const SizedBox(height: LandingPageConstants.verticalSpacingLarge),

                    // Subtitle
                    Text(
                      LandingPageConstants.subtitleText,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: LandingPageConstants.verticalSpacingSmall),

                    Text(
                      LandingPageConstants.descriptionText,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: LandingPageConstants.verticalSpacingLarge),

                    // Business Owner CTA
                    BusinessOwnerCTA(
                      onTap: () => viewModel.launchOwnerUrl(context),
                    ),

                    const SizedBox(height: LandingPageConstants.verticalSpacingMedium),

                    // Feature Grid
                    _buildFeatureGrid(viewModel.state),

                    const SizedBox(height: LandingPageConstants.verticalSpacingLarge * 1.2),
                  ],
                ),
              ),
            ),

            // Bottom Action Section
            Padding(
              padding: const EdgeInsets.all(LandingPageConstants.horizontalPadding),
              child: Column(
                children: [
                  ActionButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TownLoaderScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: LandingPageConstants.verticalSpacingMedium),
                  Text(
                    LandingPageConstants.appTagline,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(LandingPageState state) {
    return switch (state) {
      LandingPageLoading() => const FeatureGrid(isLoading: true),
      LandingPageSuccess(
        businessCount: final businessCount,
        serviceCount: final serviceCount,
        eventCount: final eventCount,
      ) =>
        FeatureGrid(
          businessCount: businessCount,
          serviceCount: serviceCount,
          eventCount: eventCount,
        ),
      LandingPageError() => const FeatureGrid(), // Show with null counts on error
    };
  }
}