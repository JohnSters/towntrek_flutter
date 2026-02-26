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
  @override
  void initState() {
    super.initState();
    FavouriteTownStorage.ensureInitialized();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          LandingViewModel(statsRepository: serviceLocator.statsRepository),
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
                      },
                      buttonText: 'Explore Now!',
                      compact: true,
                    ),
                    const SizedBox(height: 10),
                    BusinessOwnerCTA(
                      onTap: () => viewModel.launchOwnerUrl(context),
                      buttonText: 'Add your business!',
                      compact: true,
                    ),
                    ValueListenableBuilder<TownDto?>(
                      valueListenable: FavouriteTownStorage.favouriteTownNotifier,
                      builder: (context, favouriteTown, _) {
                        if (favouriteTown == null) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ActionButton(
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => TownFeatureSelectionScreen(
                                    town: favouriteTown,
                                  ),
                                ),
                              );
                            },
                            buttonText: 'Favourite Town: ${favouriteTown.name}',
                            leadingIcon: Icons.star_rounded,
                            backgroundColor: const Color(0xFF1E88E5),
                            compact: true,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                LandingPageConstants.horizontalPadding,
                10,
                LandingPageConstants.horizontalPadding,
                8,
              ),
              child: _buildPlatformStats(viewModel.state),
            ),
            _LandingFooter(
              onSendFeedback: () => viewModel.launchFeedbackEmail(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformStats(LandingPageState state) {
    return switch (state) {
      LandingPageLoading() => const PlatformStatsCard(isLoading: true),
      LandingPageSuccess(
        businessCount: final businessCount,
        serviceCount: final serviceCount,
        eventCount: final eventCount,
      ) =>
        PlatformStatsCard(
          businessCount: businessCount,
          serviceCount: serviceCount,
          eventCount: eventCount,
        ),
      LandingPageError() => const PlatformStatsCard(),
    };
  }
}

class _LandingFooter extends StatelessWidget {
  final VoidCallback onSendFeedback;

  const _LandingFooter({required this.onSendFeedback});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            LandingPageConstants.appTagline,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: onSendFeedback,
            icon: const Icon(Icons.mail_outline, size: 18),
            label: const Text(
              LandingPageConstants.feedbackButtonText,
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: Size.zero,
              foregroundColor: colorScheme.primary,
              textStyle: theme.textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}
