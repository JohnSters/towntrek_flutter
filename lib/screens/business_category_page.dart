import 'package:flutter/material.dart';
import '../core/core.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../services/services.dart';
import '../core/widgets/error_view.dart';
import '../core/widgets/navigation_footer.dart';
import '../core/widgets/page_header.dart';
import '../core/errors/app_error.dart';
import '../core/errors/error_handler.dart';
import '../core/config/business_category_config.dart';
import '../core/widgets/event_notification_banner.dart';
import 'town_selection_screen.dart';
import 'current_events_screen.dart';
import 'business_sub_category_page.dart';

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

  // Event-related state
  int _currentEventCount = 0;
  bool _categoriesLoaded = false; // Flag to ensure categories are fully loaded before checking events

  final BusinessRepository _businessRepository = serviceLocator.businessRepository;
  final TownRepository _townRepository = serviceLocator.townRepository;
  final EventRepository _eventRepository = serviceLocator.eventRepository;
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
      _currentEventCount = 0; // Reset event count when changing towns
      _categoriesLoaded = false; // Reset categories loaded flag
    });

    try {
      // Step 1: Load categories first
      final categories = await _businessRepository.getCategoriesWithCounts(town.id);

      // Step 2: Update UI with categories and mark as loaded
      if (mounted) {
        setState(() {
          _categories = categories;
          _categoriesLoaded = true; // Mark categories as loaded
        });
      }

      // Step 3: Wait for UI to settle before checking events
      // This ensures the categories view is fully rendered before starting event loading
      await Future.delayed(const Duration(milliseconds: 100));

      // Step 4: Now load events sequentially after categories are done
      if (mounted && _categoriesLoaded) {
        await _checkCurrentEvents(town.id);
      }

      // Step 5: Mark loading as complete
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLocationLoading = false;
        });
      }
    } catch (e) {
      final appError = await _errorHandler.handleError(e, retryAction: () => _loadCategoriesForTown(town));
      if (mounted) {
        setState(() {
          _error = appError;
          _isLoading = false;
          _isLocationLoading = false;
          _categoriesLoaded = false;
        });
      }
    }
  }

  void _changeTown() {
    _initializePage();
  }

  Future<void> _checkCurrentEvents(int townId) async {
    if (!mounted || !_categoriesLoaded) return;

    try {
      final eventsResponse = await _eventRepository.getCurrentEvents(
        townId: townId,
        pageSize: 1, // Just need to know if there are any events
      );

      if (mounted && _categoriesLoaded) {
        setState(() {
          _currentEventCount = eventsResponse.totalCount;
        });
      }
    } catch (e) {
      // Silently fail for event checking - don't show error to user
      // Events are secondary feature, don't interrupt main flow
      if (mounted) {
        setState(() {
          _currentEventCount = 0;
        });
      }
    }
  }

  void _onEventBannerTap() {
    if (_selectedTown != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CurrentEventsScreen(
            townId: _selectedTown!.id,
            townName: _selectedTown!.name,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Main content area
          Expanded(
            child: _buildContent(),
          ),

          // Navigation footer (only show when we have content to navigate back from)
          if (_selectedTown != null && !_isLoading)
            BackNavigationFooter(),
        ],
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

    return Column(
      children: [
        // Page Header
        PageHeader(
          title: 'Explore ${_selectedTown!.name}',
          subtitle: 'Discover amazing businesses in your area',
          height: 140,
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Change Town Button
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
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

                // Province and category count info
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

                const SizedBox(height: 24),

                // Event notification banner (only show when categories are loaded and there are current events)
                if (_categoriesLoaded && _currentEventCount > 0 && !_isLoading)
                  EventNotificationBanner(
                    eventCount: _currentEventCount,
                    onTap: _onEventBannerTap,
                    townName: _selectedTown!.name,
                  ),

                const SizedBox(height: 24),

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
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(CategoryWithCountDto category) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDisabled = category.businessCount == 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1.0,
        child: InkWell(
          onTap: isDisabled ? null : () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BusinessSubCategoryPage(
                  category: category,
                  town: _selectedTown!,
                ),
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
                    color: BusinessCategoryConfig.getCategoryColor(category.key, colorScheme),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    BusinessCategoryConfig.getCategoryIcon(category.key),
                    size: 24,
                    color: BusinessCategoryConfig.getCategoryIconColor(category.key, colorScheme),
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
                          color: isDisabled
                              ? colorScheme.onSurface.withValues(alpha: 0.5)
                              : colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 2),

                      // Description
                      Text(
                        category.businessCount == 0
                            ? 'No businesses yet'
                            : '${category.businessCount} businesses',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDisabled
                              ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                              : colorScheme.onSurfaceVariant,
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
                  color: isDisabled
                      ? colorScheme.onSurfaceVariant.withValues(alpha: 0.3)
                      : colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
