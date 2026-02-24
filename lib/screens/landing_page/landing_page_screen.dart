import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import 'landing_page_state.dart';
import 'landing_page_view_model.dart';
import '../town_loader/town_loader_screen.dart';
import '../town_feature_selection/town_feature_selection_screen.dart';
import 'widgets/widgets.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  TownDto? _favouriteTown;

  @override
  void initState() {
    super.initState();
    _loadFavouriteTown();
  }

  Future<void> _loadFavouriteTown() async {
    final favouriteTown = await FavouriteTownStorage.getFavouriteTown();
    if (!mounted) return;
    setState(() {
      _favouriteTown = favouriteTown;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          LandingViewModel(statsRepository: serviceLocator.statsRepository),
      child: _LandingPageContent(
        favouriteTown: _favouriteTown,
        onRefreshFavouriteTown: _loadFavouriteTown,
      ),
    );
  }
}

class _LandingPageContent extends StatelessWidget {
  final TownDto? favouriteTown;
  final Future<void> Function() onRefreshFavouriteTown;

  const _LandingPageContent({
    required this.favouriteTown,
    required this.onRefreshFavouriteTown,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewModel = context.watch<LandingViewModel>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(LandingPageConstants.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              const AppLogo(),
              const SizedBox(height: 16),
              Text(
                LandingPageConstants.subtitleText,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Text(
                LandingPageConstants.descriptionText,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ActionButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TownLoaderScreen(),
                    ),
                  );
                  await onRefreshFavouriteTown();
                },
                buttonText: 'Explore Now!',
                compact: true,
              ),
              const SizedBox(height: 10),
              BusinessOwnerCTA(
                onTap: () => viewModel.launchOwnerUrl(context),
                buttonText: 'Business Not Listed!',
                compact: true,
              ),
              if (favouriteTown != null) ...[
                const SizedBox(height: 10),
                ActionButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TownFeatureSelectionScreen(
                          town: favouriteTown!,
                        ),
                      ),
                    );
                    await onRefreshFavouriteTown();
                  },
                  buttonText: 'Favourite Town: ${favouriteTown!.name}',
                  leadingIcon: Icons.star_rounded,
                  backgroundColor: const Color(0xFF1E88E5),
                  compact: true,
                ),
              ],
              const SizedBox(height: 14),
              _buildFeatureGrid(viewModel.state),
              const SizedBox(height: 10),
              Text(
                LandingPageConstants.appTagline,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: LandingPageConstants.verticalSpacingSmall,
              ),
              TextButton.icon(
                onPressed: () => viewModel.launchFeedbackEmail(context),
                icon: const Icon(Icons.mail_outline, size: 18),
                label: const Text(
                  LandingPageConstants.feedbackButtonText,
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: Size.zero,
                  foregroundColor: colorScheme.primary,
                  textStyle: theme.textTheme.labelLarge,
                ),
              ),
            ],
          ),
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
      LandingPageError() =>
        const FeatureGrid(), // Show with null counts on error
    };
  }
}
