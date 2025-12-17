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
import 'town_selection_screen.dart';
import 'current_events_screen.dart';
import 'business_sub_category_page.dart';
import 'town_feature_selection_screen.dart';

/// Page for displaying business categories for a selected town
class BusinessCategoryPage extends StatefulWidget {
  final TownDto? town;
  
  const BusinessCategoryPage({
    super.key,
    this.town,
  });

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
    if (widget.town != null) {
      _isLocationLoading = false;
      await _loadCategoriesForTown(widget.town!);
    } else {
      await _detectLocationAndLoadTown();
    }
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
    // Navigate to town selection screen
    Navigator.of(context).push<TownDto>(
      MaterialPageRoute(
        builder: (context) => const TownSelectionScreen(),
      ),
    ).then((selectedTown) {
      // If a town was selected, navigate to TownFeatureSelectionScreen with new town
      // This resets the flow to the "Hub" for the new town
      if (selectedTown != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TownFeatureSelectionScreen(town: selectedTown),
          ),
        );
      }
    });
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

  void _onEventButtonTap() {
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
                  _loadCategoriesForTown(selectedTown);
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
          title: _selectedTown!.name,
          subtitle: '${_selectedTown!.province} • ${_categories.length} Categories',
          height: 120,
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Action Buttons (Change Town & Events)
                _buildActionButtons(),

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

  Widget _buildActionButtons() {
    final bool hasEvents = _categoriesLoaded && _currentEventCount > 0;

    return Row(
      children: [
        // Change Town Button
        Expanded(
          child: _CategoryActionButton(
            icon: Icons.location_on,
            label: 'Change Town',
            onTap: _changeTown,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        // Events Button
        Expanded(
          child: _PulsatingActionButton(
            icon: Icons.event,
            label: hasEvents ? '$_currentEventCount Events' : 'No Events',
            onTap: hasEvents ? _onEventButtonTap : null,
            isActive: hasEvents,
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

class _CategoryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _CategoryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsatingActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isActive;

  const _PulsatingActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    required this.isActive,
  });

  @override
  State<_PulsatingActionButton> createState() => _PulsatingActionButtonState();
}

class _PulsatingActionButtonState extends State<_PulsatingActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_PulsatingActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // colorScheme was unused
    
    // Active colors (Events found)
    final activeBgColor = const Color(0xFF00E676).withValues(alpha: 0.15); // Light green tint
    final activeIconColor = const Color(0xFF00C853); // Vibrant green
    
    // Inactive colors (No events)
    final inactiveBgColor = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    final inactiveIconColor = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isActive ? _scaleAnimation.value : 1.0,
          child: Material(
            color: widget.isActive ? activeBgColor : inactiveBgColor,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 100,
                padding: const EdgeInsets.all(12),
                decoration: widget.isActive ? BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: activeIconColor.withValues(alpha: _fadeAnimation.value * 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: activeIconColor.withValues(alpha: 0.15),
                      blurRadius: 8 * _scaleAnimation.value,
                      spreadRadius: 1,
                    )
                  ],
                ) : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.icon, 
                      size: 40, 
                      color: widget.isActive ? activeIconColor : inactiveIconColor
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: widget.isActive ? activeIconColor : inactiveIconColor,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
