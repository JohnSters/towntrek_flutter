import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import 'town_loader_state.dart';
import 'town_loader_view_model.dart';

class TownLoaderScreen extends StatelessWidget {
  const TownLoaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TownLoaderViewModel(
        townRepository: serviceLocator.townRepository,
        geolocationService: serviceLocator.geolocationService,
        errorHandler: serviceLocator.errorHandler,
      ),
      child: const _TownLoaderScreenContent(),
    );
  }
}

class _TownLoaderScreenContent extends StatelessWidget {
  const _TownLoaderScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TownLoaderViewModel>();

    return Scaffold(
      body: switch (viewModel.state) {
        TownLoaderLoadingLocation() => _buildLocationLoadingView(context, viewModel),
        TownLoaderLocationSuccess(town: final town) => _buildAutoNavigationHandler(context, viewModel, town),
        TownLoaderLocationError(error: final error) =>
          ErrorView(error: error),
        TownLoaderSelectTown(locationFailureMessage: final message) =>
          _buildTownSelectionView(context, viewModel, message),
      },
    );
  }

  Widget _buildAutoNavigationHandler(BuildContext context, TownLoaderViewModel viewModel, TownDto town) {
    // Auto-navigate when location is successfully detected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.navigateToFeatureSelection(context, town);
    });

    return const SizedBox.shrink();
  }

  Widget _buildLocationLoadingView(BuildContext context, TownLoaderViewModel viewModel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: TownLoaderConstants.logoContainerSize,
            height: TownLoaderConstants.logoContainerSize,
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/icons/android-chrome-192x192.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: TownLoaderConstants.spacingLarge),
          Text(
            TownLoaderConstants.loadingTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: TownLoaderConstants.titleFontWeight,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: TownLoaderConstants.spacingSmall),
          Container(
            constraints: const BoxConstraints(maxWidth: TownLoaderConstants.infoPillMaxWidth),
            padding: const EdgeInsets.symmetric(
              horizontal: TownLoaderConstants.horizontalPadding,
              vertical: TownLoaderConstants.verticalPadding,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: TownLoaderConstants.surfaceContainerAlpha),
              borderRadius: BorderRadius.circular(TownLoaderConstants.borderRadiusMedium),
            ),
            child: Text(
              TownLoaderConstants.loadingDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: TownLoaderConstants.subtitleFontWeight,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: TownLoaderConstants.spacingExtraLarge),
          const CircularProgressIndicator(),
          const SizedBox(height: TownLoaderConstants.spacingLarge),
          TextButton.icon(
            onPressed: viewModel.skipLocationDetection,
            icon: const Icon(Icons.location_off),
            label: const Text(TownLoaderConstants.skipLocationButtonText),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: TownLoaderConstants.textButtonPaddingHorizontal,
                vertical: TownLoaderConstants.textButtonPaddingVertical,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTownSelectionView(BuildContext context, TownLoaderViewModel viewModel, String? locationFailureMessage) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: TownLoaderConstants.logoContainerSize,
            height: TownLoaderConstants.logoContainerSize,
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/icons/android-chrome-192x192.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: TownLoaderConstants.spacingLarge),
          Text(
            TownLoaderConstants.selectTownTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: TownLoaderConstants.titleFontWeight,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: TownLoaderConstants.spacingSmall),
          Text(
            TownLoaderConstants.selectTownDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: TownLoaderConstants.onSurfaceVariantAlpha),
            ),
            textAlign: TextAlign.center,
          ),
          if (locationFailureMessage != null) ...[
            const SizedBox(height: TownLoaderConstants.spacingMedium),
            _buildLocationErrorInfo(context, viewModel, locationFailureMessage),
          ],
          const SizedBox(height: TownLoaderConstants.spacingExtraLarge),
          ElevatedButton.icon(
            onPressed: viewModel.detectLocationAndLoadTown,
            icon: const Icon(Icons.location_on),
            label: const Text(TownLoaderConstants.useLocationButtonText),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: TownLoaderConstants.buttonPaddingHorizontal,
                vertical: TownLoaderConstants.buttonPaddingVertical,
              ),
            ),
          ),
          const SizedBox(height: TownLoaderConstants.spacingMedium),
          TextButton(
            onPressed: () async {
              final selectedTown = await viewModel.selectTownManually(context);
              if (selectedTown != null && context.mounted) {
                viewModel.navigateToFeatureSelection(context, selectedTown);
              }
            },
            child: const Text(TownLoaderConstants.selectManuallyButtonText),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationErrorInfo(BuildContext context, TownLoaderViewModel viewModel, String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: TownLoaderConstants.maxWidthConstraint),
      padding: const EdgeInsets.symmetric(
        horizontal: TownLoaderConstants.horizontalPadding,
        vertical: TownLoaderConstants.verticalPadding,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: TownLoaderConstants.infoContainerAlpha),
        borderRadius: BorderRadius.circular(TownLoaderConstants.borderRadiusSmall),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: TownLoaderConstants.outlineAlpha),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: TownLoaderConstants.infoIconSize,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: TownLoaderConstants.spacingSmall),
              Flexible(
                child: Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: TownLoaderConstants.subtitleFontWeight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: TownLoaderConstants.spacingSmall),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: TownLoaderConstants.spacingSmall,
            children: [
              if (message.toLowerCase().contains('disabled'))
                TextButton(
                  onPressed: viewModel.openLocationSettings,
                  child: const Text(TownLoaderConstants.openLocationSettingsText),
                ),
              if (message.toLowerCase().contains('permanently denied'))
                TextButton(
                  onPressed: viewModel.openAppSettings,
                  child: const Text(TownLoaderConstants.openAppSettingsText),
                ),
            ],
          ),
        ],
      ),
    );
  }
}