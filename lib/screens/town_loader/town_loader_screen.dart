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
        TownLoaderConfirmTown(detectedTown: final town) => _buildTownConfirmationDialog(context, viewModel, town),
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

  Widget _buildTownConfirmationDialog(BuildContext context, TownLoaderViewModel viewModel, TownDto detectedTown) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Show confirmation dialog after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      _showTownConfirmationDialog(context, viewModel, detectedTown);
    });

    // While showing the dialog, display the detected town info
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
            'Town Detected!',
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
            child: Column(
              children: [
                Text(
                  'We detected you might be in:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: TownLoaderConstants.subtitleFontWeight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TownLoaderConstants.spacingSmall),
                Text(
                  detectedTown.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '${detectedTown.province} • ${detectedTown.businessCount} businesses',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: TownLoaderConstants.spacingExtraLarge),
          const CircularProgressIndicator(),
        ],
      ),
    );
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

  Future<void> _showTownConfirmationDialog(BuildContext context, TownLoaderViewModel viewModel, TownDto detectedTown) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: colorScheme.surfaceContainerHigh,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TownLoaderConstants.borderRadiusMedium),
          ),
          title: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(TownLoaderConstants.borderRadiusSmall),
                ),
                child: Icon(
                  Icons.location_on,
                  color: colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(height: TownLoaderConstants.spacingMedium),
              Text(
                'Confirm Your Town',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'We detected you might be in:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TownLoaderConstants.spacingMedium),
              Container(
                padding: const EdgeInsets.all(TownLoaderConstants.verticalPadding),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(TownLoaderConstants.borderRadiusSmall),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: TownLoaderConstants.outlineAlpha),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      detectedTown.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: TownLoaderConstants.spacingSmall),
                    Text(
                      '${detectedTown.province} • ${detectedTown.businessCount} businesses',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TownLoaderConstants.spacingMedium),
              Text(
                'Is this the correct town?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TownLoaderConstants.buttonPaddingHorizontal,
                        vertical: TownLoaderConstants.buttonPaddingVertical,
                      ),
                    ),
                    child: Text(
                      'Choose Manually',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: TownLoaderConstants.spacingSmall),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TownLoaderConstants.buttonPaddingHorizontal,
                        vertical: TownLoaderConstants.buttonPaddingVertical,
                      ),
                    ),
                    child: const Text('Yes, Correct'),
                  ),
                ),
              ],
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(
            TownLoaderConstants.horizontalPadding,
            0,
            TownLoaderConstants.horizontalPadding,
            TownLoaderConstants.verticalPadding,
          ),
        );
      },
    );

    // Handle the result
    if (!context.mounted) return;

    if (result == true) {
      // User confirmed the town is correct
      viewModel.confirmDetectedTown(detectedTown);
    } else {
      // User wants to choose manually or dismissed dialog
      viewModel.rejectDetectedTown();
    }
  }
}