import 'package:flutter/material.dart';
import '../core/core.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../services/services.dart';
import '../core/widgets/error_view.dart';
import '../core/errors/app_error.dart';
import '../core/errors/error_handler.dart';
import 'town_selection_screen.dart';

/// Page for displaying business categories for a selected town
class BusinessCategoryPage extends StatefulWidget {
  const BusinessCategoryPage({super.key});

  @override
  State<BusinessCategoryPage> createState() => _BusinessCategoryPageState();
}

class _BusinessCategoryPageState extends State<BusinessCategoryPage> {
  TownDto? _selectedTown;
  List<CategoryWithCountDto> _categories = [];
  bool _isLoading = true;
  AppError? _error;
  bool _isLocationLoading = true;

  final BusinessRepository _businessRepository = serviceLocator.businessRepository;
  final TownRepository _townRepository = serviceLocator.townRepository;
  final GeolocationService _geolocationService = serviceLocator.geolocationService;
  final ErrorHandler _errorHandler = serviceLocator.errorHandler;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _detectLocationAndLoadTown();
  }

  Future<void> _detectLocationAndLoadTown() async {
    setState(() {
      _isLocationLoading = true;
      _error = null;
    });

    try {
      // Get all towns first
      final townsResult = await _townRepository.getTowns();

      if (townsResult.isEmpty) {
        final noDataError = AppErrors.noDataAvailable(_initializePage);
        setState(() {
          _error = noDataError;
          _isLocationLoading = false;
          _isLoading = false;
        });
        return;
      }

      // Try to find nearest town based on location
      final nearestTownResult = await _geolocationService.findNearestTown(townsResult);

      if (nearestTownResult.isSuccess) {
        await _loadCategoriesForTown(nearestTownResult.data);
      } else {
        // Location detection failed, show town selection
        setState(() {
          _isLocationLoading = false;
          _isLoading = false;
        });
        // Navigate to dedicated town selection screen
        if (mounted) {
          Navigator.of(context).push<TownDto>(
            MaterialPageRoute(
              builder: (context) => const TownSelectionScreen(),
            ),
          ).then((selectedTown) {
            // If a town was selected, load its categories
            if (selectedTown != null && mounted) {
              _loadCategoriesForTown(selectedTown);
            }
          });
        }
      }
    } catch (e) {
      final appError = await _errorHandler.handleError(e, retryAction: _initializePage);
      if (mounted) {
        setState(() {
          _error = appError;
          _isLocationLoading = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCategoriesForTown(TownDto town) async {
    setState(() {
      _selectedTown = town;
      _isLoading = true;
      _error = null;
    });

    try {
      final categories = await _businessRepository.getCategoriesWithCounts(town.id);
      setState(() {
        _categories = categories;
        _isLoading = false;
        _isLocationLoading = false;
      });
    } catch (e) {
      final appError = await _errorHandler.handleError(e, retryAction: () => _loadCategoriesForTown(town));
      if (mounted) {
        setState(() {
          _error = appError;
          _isLoading = false;
          _isLocationLoading = false;
        });
      }
    }
  }

  void _changeTown() {
    _initializePage();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(alpha: 0.1),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLocationLoading) {
      return _buildLocationLoadingView();
    }

    if (_selectedTown == null) {
      return _buildTownSelectionView();
    }

    if (_isLoading) {
      return _buildLoadingView();
    }

    if (_error != null) {
      return _buildErrorView();
    }

    return _buildCategoriesView();
  }

  Widget _buildLocationLoadingView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_searching,
              size: 40,
              color: Colors.white,
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
              'We\'re detecting your town to show relevant businesses',
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_city,
              size: 40,
              color: Colors.white,
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
            'Choose your town to explore local businesses',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
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

                // If a town was selected, load its categories
                if (selectedTown != null && mounted) {
                  await _loadCategoriesForTown(selectedTown);
                }
              }
            },
            child: const Text('Select Manually'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorView() {
    if (_error == null) {
      return ErrorView(error: AppErrors.unknown());
    }
    return ErrorView(error: _error!);
  }

  Widget _buildCategoriesView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Header Design
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                // Centered Title with Pill Background
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(25), // Pill shape
                    ),
                    child: Text(
                      'Explore ${_selectedTown!.name}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Full Width Action Button - Larger
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _changeTown,
                    icon: const Icon(Icons.location_on, size: 20),
                    label: const Text('Change Town'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle with Pill Background
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 320), // Prevent excessive width
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20), // Pill shape
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_city,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _selectedTown!.province,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            '${_categories.length} categories',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Categories grid
          if (_categories.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.business,
                    size: 64,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No business categories found',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return _buildCategoryCard(category);
                },
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(CategoryWithCountDto category) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to business list for this category
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening ${category.name} businesses...'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor(category.key, colorScheme),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getCategoryIcon(category.key),
                  size: 24,
                  color: _getCategoryIconColor(category.key, colorScheme),
                ),
              ),

              const SizedBox(width: 16),

              // Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      category.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    // Description
                    Text(
                      '${category.businessCount} businesses',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Arrow Icon
              Icon(
                Icons.chevron_right,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryKey) {
    // Map category keys to appropriate icons
    final iconMap = {
      'restaurants': Icons.restaurant,
      'hotels': Icons.hotel,
      'shopping': Icons.shopping_bag,
      'entertainment': Icons.movie,
      'healthcare': Icons.local_hospital,
      'automotive': Icons.car_repair,
      'finance': Icons.account_balance,
      'education': Icons.school,
      'services': Icons.build,
      'sports': Icons.sports_soccer,
      'food': Icons.restaurant,
      'dining': Icons.restaurant,
      'accommodation': Icons.hotel,
      'retail': Icons.shopping_bag,
      'leisure': Icons.movie,
      'medical': Icons.local_hospital,
      'banking': Icons.account_balance,
      'learning': Icons.school,
      'maintenance': Icons.build,
      'fitness': Icons.sports_soccer,
      'beauty': Icons.spa,
      'travel': Icons.flight,
      'technology': Icons.computer,
      'pets': Icons.pets,
      'real estate': Icons.home,
      'legal': Icons.gavel,
      'transportation': Icons.directions_car,
    };

    return iconMap[categoryKey.toLowerCase()] ?? Icons.business;
  }

  Color _getCategoryColor(String categoryKey, ColorScheme colorScheme) {
    // Material Design 3 color palette for different categories
    final colorMap = {
      'restaurants': colorScheme.primaryContainer,
      'hotels': colorScheme.secondaryContainer,
      'shopping': colorScheme.tertiaryContainer,
      'entertainment': colorScheme.primaryContainer,
      'healthcare': colorScheme.errorContainer,
      'automotive': colorScheme.secondaryContainer,
      'finance': colorScheme.tertiaryContainer,
      'education': colorScheme.primaryContainer,
      'services': colorScheme.secondaryContainer,
      'sports': colorScheme.tertiaryContainer,
      'food': colorScheme.primaryContainer,
      'dining': colorScheme.primaryContainer,
      'accommodation': colorScheme.secondaryContainer,
      'retail': colorScheme.tertiaryContainer,
      'leisure': colorScheme.primaryContainer,
      'medical': colorScheme.errorContainer,
      'banking': colorScheme.tertiaryContainer,
      'learning': colorScheme.primaryContainer,
      'maintenance': colorScheme.secondaryContainer,
      'fitness': colorScheme.tertiaryContainer,
      'beauty': colorScheme.primaryContainer,
      'travel': colorScheme.secondaryContainer,
      'technology': colorScheme.tertiaryContainer,
      'pets': colorScheme.primaryContainer,
      'real estate': colorScheme.secondaryContainer,
      'legal': colorScheme.tertiaryContainer,
      'transportation': colorScheme.secondaryContainer,
    };

    return colorMap[categoryKey.toLowerCase()] ?? colorScheme.surfaceContainerHighest;
  }

  Color _getCategoryIconColor(String categoryKey, ColorScheme colorScheme) {
    // Return appropriate on-color for the container
    final colorMap = {
      'restaurants': colorScheme.onPrimaryContainer,
      'hotels': colorScheme.onSecondaryContainer,
      'shopping': colorScheme.onTertiaryContainer,
      'entertainment': colorScheme.onPrimaryContainer,
      'healthcare': colorScheme.onErrorContainer,
      'automotive': colorScheme.onSecondaryContainer,
      'finance': colorScheme.onTertiaryContainer,
      'education': colorScheme.onPrimaryContainer,
      'services': colorScheme.onSecondaryContainer,
      'sports': colorScheme.onTertiaryContainer,
      'food': colorScheme.onPrimaryContainer,
      'dining': colorScheme.onPrimaryContainer,
      'accommodation': colorScheme.onSecondaryContainer,
      'retail': colorScheme.onTertiaryContainer,
      'leisure': colorScheme.onPrimaryContainer,
      'medical': colorScheme.onErrorContainer,
      'banking': colorScheme.onTertiaryContainer,
      'learning': colorScheme.onPrimaryContainer,
      'maintenance': colorScheme.onSecondaryContainer,
      'fitness': colorScheme.onTertiaryContainer,
      'beauty': colorScheme.onPrimaryContainer,
      'travel': colorScheme.onSecondaryContainer,
      'technology': colorScheme.onTertiaryContainer,
      'pets': colorScheme.onPrimaryContainer,
      'real estate': colorScheme.onSecondaryContainer,
      'legal': colorScheme.onTertiaryContainer,
      'transportation': colorScheme.onSecondaryContainer,
    };

    return colorMap[categoryKey.toLowerCase()] ?? colorScheme.onSurfaceVariant;
  }
}
