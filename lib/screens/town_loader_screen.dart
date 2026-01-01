import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../core/core.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../services/services.dart';
import '../core/widgets/error_view.dart';
import '../core/errors/app_error.dart';
import '../core/errors/error_handler.dart';
import 'town_selection_screen.dart';
import 'town_feature_selection_screen.dart';

class TownLoaderScreen extends StatefulWidget {
  const TownLoaderScreen({super.key});

  @override
  State<TownLoaderScreen> createState() => _TownLoaderScreenState();
}

class _TownLoaderScreenState extends State<TownLoaderScreen> {
  final TownRepository _townRepository = serviceLocator.townRepository;
  final GeolocationService _geolocationService = serviceLocator.geolocationService;
  final ErrorHandler _errorHandler = serviceLocator.errorHandler;

  bool _isLocationLoading = true;
  AppError? _error;
  String? _locationFailureMessage;

  @override
  void initState() {
    super.initState();
    _detectLocationAndLoadTown();
  }

  Future<void> _detectLocationAndLoadTown() async {
    setState(() {
      _isLocationLoading = true;
      _error = null;
      _locationFailureMessage = null;
    });

    try {
      // Get all towns first
      final townsResult = await _townRepository.getTowns();

      if (townsResult.isEmpty) {
        final noDataError = AppErrors.noDataAvailable(_detectLocationAndLoadTown);
        if (mounted) {
          setState(() {
            _error = noDataError;
            _isLocationLoading = false;
          });
        }
        return;
      }

      // Try to find nearest town based on location
      final nearestTownResult = await _geolocationService.findNearestTown(townsResult);

      if (nearestTownResult.isSuccess) {
        _navigateToFeatureSelection(nearestTownResult.data);
      } else {
        // Location detection failed, show town selection
        if (mounted) {
          setState(() {
            _isLocationLoading = false;
            _locationFailureMessage = nearestTownResult.error;
          });
        }
      }
    } catch (e) {
      final appError = await _errorHandler.handleError(e, retryAction: _detectLocationAndLoadTown);
      if (mounted) {
        setState(() {
          _error = appError;
          _isLocationLoading = false;
        });
      }
    }
  }

  void _navigateToFeatureSelection(TownDto town) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TownFeatureSelectionScreen(town: town),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocationLoading) {
      return Scaffold(body: _buildLocationLoadingView());
    }

    if (_error != null) {
      return Scaffold(body: ErrorView(error: _error!));
    }

    return Scaffold(body: _buildTownSelectionView());
  }

  Widget _buildLocationLoadingView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/icons/android-chrome-192x192.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Finding your location...',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(25), // Pill shape
            ),
            child: Text(
              'We\'re detecting your town to show relevant content',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () {
              // Skip location detection and show town selection
              setState(() {
                _isLocationLoading = false;
              });
            },
            icon: const Icon(Icons.location_off),
            label: const Text('Skip Location Detection'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTownSelectionView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/icons/android-chrome-192x192.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Select Your Town',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your town to explore',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (_locationFailureMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(maxWidth: 320),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _locationFailureMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: [
                      if (_locationFailureMessage!.toLowerCase().contains('disabled'))
                        TextButton(
                          onPressed: () async {
                            await Geolocator.openLocationSettings();
                          },
                          child: const Text('Open Location Settings'),
                        ),
                      if (_locationFailureMessage!.toLowerCase().contains('permanently denied'))
                        TextButton(
                          onPressed: () async {
                            await Geolocator.openAppSettings();
                          },
                          child: const Text('Open App Settings'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _detectLocationAndLoadTown,
            icon: const Icon(Icons.location_on),
            label: const Text('Use My Location'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () async {
              // Navigate to dedicated town selection screen
              if (mounted) {
                final selectedTown = await Navigator.of(context).push<TownDto>(
                  MaterialPageRoute(
                    builder: (context) => const TownSelectionScreen(),
                  ),
                );

                if (selectedTown != null) {
                  _navigateToFeatureSelection(selectedTown);
                }
              }
            },
            child: const Text('Select Manually'),
          ),
        ],
      ),
    );
  }
}

