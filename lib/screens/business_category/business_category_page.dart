import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import '../../services/services.dart';
import '../../core/config/business_category_config.dart';
import '../town_selection_screen.dart';
import '../current_events_screen.dart';
import '../business_sub_category_page.dart';
import '../town_feature_selection_screen.dart';
import 'widgets/widgets.dart';

/// State classes for Business Category page
sealed class BusinessCategoryState {}

class BusinessCategoryLocationLoading extends BusinessCategoryState {}

class BusinessCategoryTownSelection extends BusinessCategoryState {}

class BusinessCategoryLoading extends BusinessCategoryState {}

class BusinessCategorySuccess extends BusinessCategoryState {
  final TownDto town;
  final List<CategoryWithCountDto> categories;
  final int currentEventCount;
  final bool categoriesLoaded;

  BusinessCategorySuccess({
    required this.town,
    required this.categories,
    this.currentEventCount = 0,
    this.categoriesLoaded = false,
  });

  BusinessCategorySuccess copyWith({
    TownDto? town,
    List<CategoryWithCountDto>? categories,
    int? currentEventCount,
    bool? categoriesLoaded,
  }) {
    return BusinessCategorySuccess(
      town: town ?? this.town,
      categories: categories ?? this.categories,
      currentEventCount: currentEventCount ?? this.currentEventCount,
      categoriesLoaded: categoriesLoaded ?? this.categoriesLoaded,
    );
  }
}

class BusinessCategoryError extends BusinessCategoryState {
  final AppError error;
  BusinessCategoryError(this.error);
}

/// ViewModel for Business Category page business logic
class BusinessCategoryViewModel extends ChangeNotifier {
  final BusinessRepository _businessRepository;
  final TownRepository _townRepository;
  final EventRepository _eventRepository;
  final GeolocationService _geolocationService;
  final ErrorHandler _errorHandler;

  BusinessCategoryState _state = BusinessCategoryLocationLoading();
  BusinessCategoryState get state => _state;

  final TownDto? initialTown;

  BusinessCategoryViewModel({
    required this.initialTown,
    required BusinessRepository businessRepository,
    required TownRepository townRepository,
    required EventRepository eventRepository,
    required GeolocationService geolocationService,
    required ErrorHandler errorHandler,
  })  : _businessRepository = businessRepository,
        _townRepository = townRepository,
        _eventRepository = eventRepository,
        _geolocationService = geolocationService,
        _errorHandler = errorHandler {
    _initializePage();
  }

  Future<void> _initializePage() async {
    if (initialTown != null) {
      await loadCategoriesForTown(initialTown!);
    } else {
      await detectLocationAndLoadTown();
    }
  }

  Future<void> detectLocationAndLoadTown() async {
    _state = BusinessCategoryLocationLoading();
    notifyListeners();

    try {
      // Get all towns first
      final townsResult = await _townRepository.getTowns();

      if (townsResult.isEmpty) {
        final noDataError = AppErrors.noDataAvailable(_initializePage);
        _state = BusinessCategoryError(noDataError);
        notifyListeners();
        return;
      }

      // Try to find nearest town based on location
      final nearestTownResult = await _geolocationService.findNearestTown(townsResult);

      if (nearestTownResult.isSuccess) {
        await loadCategoriesForTown(nearestTownResult.data);
      } else {
        // Location detection failed, show town selection
        _state = BusinessCategoryTownSelection();
        notifyListeners();
      }
    } catch (e) {
      final appError = await _errorHandler.handleError(e, retryAction: _initializePage);
      _state = BusinessCategoryError(appError);
      notifyListeners();
    }
  }

  Future<void> loadCategoriesForTown(TownDto town) async {
    _state = BusinessCategoryLoading();
    notifyListeners();

    try {
      // Step 1: Load categories first
      final categories = await _businessRepository.getCategoriesWithCounts(town.id);

      // Step 2: Update state with categories (marking as loaded)
      _state = BusinessCategorySuccess(
        town: town,
        categories: categories,
        categoriesLoaded: true,
      );
      notifyListeners();

      // Step 3: Wait for UI to settle before checking events
      await Future.delayed(BusinessCategoryConstants.uiSettleDelay);

      // Step 4: Now load events sequentially after categories are done
      if (_state is BusinessCategorySuccess) {
        await _checkCurrentEvents(town.id);
      }
    } catch (e) {
      final appError = await _errorHandler.handleError(e, retryAction: () => loadCategoriesForTown(town));
      _state = BusinessCategoryError(appError);
      notifyListeners();
    }
  }

  Future<void> _checkCurrentEvents(int townId) async {
    if (_state is! BusinessCategorySuccess) return;

    try {
      final eventsResponse = await _eventRepository.getCurrentEvents(
        townId: townId,
        pageSize: BusinessCategoryConstants.eventCheckPageSize, // Just need to know if there are any events
      );

      if (_state is BusinessCategorySuccess) {
        final currentState = _state as BusinessCategorySuccess;
        _state = currentState.copyWith(currentEventCount: eventsResponse.totalCount);
        notifyListeners();
      }
    } catch (e) {
      // Silently fail for event checking - don't show error to user
      // Events are secondary feature, don't interrupt main flow
      if (_state is BusinessCategorySuccess) {
        final currentState = _state as BusinessCategorySuccess;
        _state = currentState.copyWith(currentEventCount: 0);
        notifyListeners();
      }
    }
  }

  Future<void> selectTownManually(BuildContext context) async {
    final selectedTown = await Navigator.of(context).push<TownDto>(
      MaterialPageRoute(
        builder: (context) => const TownSelectionScreen(),
      ),
    );

    // If a town was selected, load its categories
    if (selectedTown != null && context.mounted) {
      await loadCategoriesForTown(selectedTown);
    }
  }

  void changeTown(BuildContext context) {
    // Navigate to town selection screen
    Navigator.of(context).push<TownDto>(
      MaterialPageRoute(
        builder: (context) => const TownSelectionScreen(),
      ),
    ).then((selectedTown) {
      // If a town was selected, navigate to TownFeatureSelectionScreen with new town
      // This resets the flow to the "Hub" for the new town
      if (selectedTown != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TownFeatureSelectionScreen(town: selectedTown),
          ),
        );
      }
    });
  }

  void navigateToEvents(BuildContext context) {
    if (_state is BusinessCategorySuccess) {
      final currentState = _state as BusinessCategorySuccess;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CurrentEventsScreen(
            townId: currentState.town.id,
            townName: currentState.town.name,
          ),
        ),
      );
    }
  }

  void navigateToCategory(BuildContext context, CategoryWithCountDto category) {
    if (_state is BusinessCategorySuccess) {
      final currentState = _state as BusinessCategorySuccess;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BusinessSubCategoryPage(
            category: category,
            town: currentState.town,
          ),
        ),
      );
    }
  }

  void skipLocationDetection() {
    _state = BusinessCategoryTownSelection();
    notifyListeners();
  }
}

/// Page for displaying business categories for a selected town
class BusinessCategoryPage extends StatelessWidget {
  final TownDto? town;

  const BusinessCategoryPage({
    super.key,
    this.town,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BusinessCategoryViewModel(
        initialTown: town,
        businessRepository: serviceLocator.businessRepository,
        townRepository: serviceLocator.townRepository,
        eventRepository: serviceLocator.eventRepository,
        geolocationService: serviceLocator.geolocationService,
        errorHandler: serviceLocator.errorHandler,
      ),
      child: const _BusinessCategoryPageContent(),
    );
  }
}

class _BusinessCategoryPageContent extends StatelessWidget {
  const _BusinessCategoryPageContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BusinessCategoryViewModel>();

    return Scaffold(
      body: Column(
        children: [
          // Main content area
          Expanded(
            child: _buildContent(context, viewModel),
          ),

          // Navigation footer (only show when we have content to navigate back from)
          if (viewModel.state is BusinessCategorySuccess)
            const BackNavigationFooter(),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, BusinessCategoryViewModel viewModel) {
    final state = viewModel.state;

    if (state is BusinessCategoryLocationLoading) {
      return _buildLocationLoadingView(context, viewModel);
    }

    if (state is BusinessCategoryTownSelection) {
      return _buildTownSelectionView(context, viewModel);
    }

    if (state is BusinessCategoryLoading) {
      return _buildLoadingView();
    }

    if (state is BusinessCategoryError) {
      return _buildErrorView(state);
    }

    if (state is BusinessCategorySuccess) {
      return _buildCategoriesView(context, viewModel, state);
    }

    return const SizedBox();
  }

  Widget _buildLocationLoadingView(BuildContext context, BusinessCategoryViewModel viewModel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: BusinessCategoryConstants.locationContainerSize,
            height: BusinessCategoryConstants.locationContainerSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_searching,
              size: BusinessCategoryConstants.iconSizeLarge,
              color: Colors.white,
            ),
          ),
          SizedBox(height: BusinessCategoryConstants.extraLargeSpacing),
          Text(
            BusinessCategoryConstants.locationLoadingText,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: BusinessCategoryConstants.tinySpacing),
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: EdgeInsets.symmetric(
              horizontal: BusinessCategoryConstants.horizontalPadding,
              vertical: BusinessCategoryConstants.verticalPadding,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: BusinessCategoryConstants.mediumAlpha),
              borderRadius: BorderRadius.circular(BusinessCategoryConstants.pillBorderRadius),
            ),
            child: Text(
              BusinessCategoryConstants.locationLoadingSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: BusinessCategoryConstants.largeSpacing),
          const CircularProgressIndicator(),
          SizedBox(height: BusinessCategoryConstants.extraLargeSpacing),
          TextButton.icon(
            onPressed: () => viewModel.skipLocationDetection(),
            icon: const Icon(Icons.location_off),
            label: Text(BusinessCategoryConstants.skipLocationText),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: BusinessCategoryConstants.smallSpacing,
                vertical: BusinessCategoryConstants.tinySpacing,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTownSelectionView(BuildContext context, BusinessCategoryViewModel viewModel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: BusinessCategoryConstants.townContainerSize,
            height: BusinessCategoryConstants.townContainerSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_city,
              size: BusinessCategoryConstants.iconSizeLarge,
              color: Colors.white,
            ),
          ),
          SizedBox(height: BusinessCategoryConstants.extraLargeSpacing),
          Text(
            BusinessCategoryConstants.townSelectionTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: BusinessCategoryConstants.tinySpacing),
          Text(
            BusinessCategoryConstants.townSelectionSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: BusinessCategoryConstants.mediumAlpha),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: BusinessCategoryConstants.largeSpacing),
          ElevatedButton.icon(
            onPressed: () => viewModel.detectLocationAndLoadTown(),
            icon: const Icon(Icons.location_on),
            label: Text(BusinessCategoryConstants.useMyLocationText),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: BusinessCategoryConstants.horizontalPadding,
                vertical: BusinessCategoryConstants.verticalPadding,
              ),
            ),
          ),
          SizedBox(height: BusinessCategoryConstants.smallSpacing),
          TextButton(
            onPressed: () => viewModel.selectTownManually(context),
            child: Text(BusinessCategoryConstants.selectManuallyText),
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

  Widget _buildErrorView(BusinessCategoryError state) {
    return ErrorView(error: state.error);
  }

  Widget _buildCategoriesView(
    BuildContext context,
    BusinessCategoryViewModel viewModel,
    BusinessCategorySuccess state,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Page Header
        PageHeader(
          title: state.town.name,
          subtitle: '${state.town.province} • ${state.categories.length} Categories',
          height: BusinessCategoryConstants.headerHeight,
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(BusinessCategoryConstants.horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Action Buttons (Change Town & Events)
                _buildActionButtons(context, viewModel, state),

                SizedBox(height: BusinessCategoryConstants.extraLargeSpacing),

                // Categories grid
                if (state.categories.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.business,
                          size: BusinessCategoryConstants.iconSizeExtraLarge,
                          color: colorScheme.onSurface.withValues(alpha: BusinessCategoryConstants.lowAlpha),
                        ),
                        SizedBox(height: BusinessCategoryConstants.smallSpacing),
                        Text(
                          BusinessCategoryConstants.noCategoriesText,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: BusinessCategoryConstants.mediumAlpha),
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
                      itemCount: state.categories.length,
                      itemBuilder: (context, index) {
                        final category = state.categories[index];
                        return _buildCategoryCard(context, viewModel, category);
                      },
                    ),
                  ),

                SizedBox(height: BusinessCategoryConstants.largeSpacing),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    BusinessCategoryViewModel viewModel,
    BusinessCategorySuccess state,
  ) {
    final bool hasEvents = state.categoriesLoaded && state.currentEventCount > 0;

    return Row(
      children: [
        // Change Town Button
        Expanded(
          child: CategoryActionButton(
            icon: Icons.location_on,
            label: BusinessCategoryConstants.changeTownText,
            onTap: () => viewModel.changeTown(context),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(width: BusinessCategoryConstants.smallSpacing),
        // Events Button
        Expanded(
          child: PulsatingActionButton(
            icon: Icons.event,
            label: hasEvents
                ? '${state.currentEventCount} ${BusinessCategoryConstants.eventsText}'
                : BusinessCategoryConstants.noEventsText,
            onTap: hasEvents ? () => viewModel.navigateToEvents(context) : null,
            isActive: hasEvents,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    BusinessCategoryViewModel viewModel,
    CategoryWithCountDto category,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDisabled = category.businessCount == 0;

    return Card(
      margin: EdgeInsets.only(bottom: BusinessCategoryConstants.cardMarginBottom),
      elevation: BusinessCategoryConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BusinessCategoryConstants.borderRadiusMedium),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: BusinessCategoryConstants.cardBorderAlpha),
        ),
      ),
      child: Opacity(
        opacity: isDisabled ? BusinessCategoryConstants.disabledOpacity : 1.0,
        child: InkWell(
          onTap: isDisabled ? null : () => viewModel.navigateToCategory(context, category),
          borderRadius: BorderRadius.circular(BusinessCategoryConstants.borderRadiusMedium),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: BusinessCategoryConstants.cardHorizontalPadding,
              vertical: BusinessCategoryConstants.cardVerticalPadding,
            ),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: BusinessCategoryConstants.categoryIconContainerSize,
                  height: BusinessCategoryConstants.categoryIconContainerSize,
                  decoration: BoxDecoration(
                    color: BusinessCategoryConfig.getCategoryColor(category.key, colorScheme),
                    borderRadius: BorderRadius.circular(BusinessCategoryConstants.borderRadiusSmall),
                  ),
                  child: Icon(
                    BusinessCategoryConfig.getCategoryIcon(category.key),
                    size: BusinessCategoryConstants.iconSizeMedium,
                    color: BusinessCategoryConfig.getCategoryIconColor(category.key, colorScheme),
                  ),
                ),

                SizedBox(width: BusinessCategoryConstants.smallSpacing),

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
                              ? colorScheme.onSurface.withValues(alpha: BusinessCategoryConstants.disabledAlpha)
                              : colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: BusinessCategoryConstants.tinySpacing),

                      // Description
                      Text(
                        category.businessCount == 0
                            ? BusinessCategoryConstants.noBusinessesText
                            : '${category.businessCount} businesses',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDisabled
                              ? colorScheme.onSurfaceVariant.withValues(alpha: BusinessCategoryConstants.disabledAlpha)
                              : colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                SizedBox(width: BusinessCategoryConstants.smallSpacing),

                // Arrow Icon
                Icon(
                  Icons.chevron_right,
                  size: BusinessCategoryConstants.iconSizeSmall,
                  color: isDisabled
                      ? colorScheme.onSurfaceVariant.withValues(alpha: BusinessCategoryConstants.lowAlpha)
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