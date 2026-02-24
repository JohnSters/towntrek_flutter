import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import 'business_category_state.dart';
import 'business_category_view_model.dart';
import 'widgets/widgets.dart';

/// Animated Connected Events Button that pulses when events are available
class _AnimatedConnectedEventsButton extends StatefulWidget {
  final bool hasEvents;
  final int eventCount;
  final VoidCallback? onPressed;

  const _AnimatedConnectedEventsButton({
    required this.hasEvents,
    required this.eventCount,
    this.onPressed,
  });

  @override
  State<_AnimatedConnectedEventsButton> createState() => _AnimatedConnectedEventsButtonState();
}

class _AnimatedConnectedEventsButtonState extends State<_AnimatedConnectedEventsButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.hasEvents) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_AnimatedConnectedEventsButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasEvents != oldWidget.hasEvents) {
      if (widget.hasEvents) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!widget.hasEvents) {
      return FilledButton.icon(
        onPressed: widget.onPressed,
        icon: const Icon(Icons.event),
        label: const Text('No Events'),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(64), // Larger square buttons
          elevation: 0,
          backgroundColor: colorScheme.surfaceContainerHighest,
          foregroundColor: colorScheme.onSurfaceVariant,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(0),
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(8),
            ),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.zero, // No rounded borders
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: _glowAnimation.value * 0.3),
                blurRadius: 12 + (_glowAnimation.value * 8),
                spreadRadius: _glowAnimation.value * 2,
              ),
            ],
          ),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: FilledButton.icon(
              onPressed: widget.onPressed,
              icon: Icon(
                Icons.event,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Color.fromRGBO(0, 128, 0, 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
              label: Text(
                '${widget.eventCount} Events',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Color.fromRGBO(0, 128, 0, 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              style: FilledButton.styleFrom(
                minimumSize: Size.fromHeight(BusinessCategoryConstants.connectedButtonHeight),
                elevation: 4 + (_glowAnimation.value * 2),
                shadowColor: Colors.green.withValues(alpha: 0.4),
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // No rounded borders
                ),
              ),
            ),
          ),
        );
      },
    );
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
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
            onPressed: () => viewModel.detectLocationAndLoadTown(userInitiatedRetry: true),
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
          headerType: HeaderType.business,
        ),

        // Connected Action Buttons (fills entire width, connects to header)
        _buildConnectedActionButtons(context, viewModel, state),

        // Scrollable content (no top padding since buttons connect to header)
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              BusinessCategoryConstants.horizontalPadding,
              BusinessCategoryConstants.smallSpacing, // Small top padding for content separation
              BusinessCategoryConstants.horizontalPadding,
              BusinessCategoryConstants.horizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.categories.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final category = state.categories[index];
                      return BusinessCategoryCard(
                        category: category,
                        onTap: () => viewModel.navigateToCategory(context, category),
                      );
                    },
                  ),

                SizedBox(height: BusinessCategoryConstants.largeSpacing),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectedActionButtons(
    BuildContext context,
    BusinessCategoryViewModel viewModel,
    BusinessCategorySuccess state,
  ) {
    final bool hasEvents = state.categoriesLoaded && state.currentEventCount > 0;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Change Town Button - Connected design
        Expanded(
          child: FilledButton.icon(
            onPressed: () => viewModel.changeTown(context),
            icon: const Icon(Icons.location_city),
            label: const Text('Wrong Town?'),
            style: FilledButton.styleFrom(
              minimumSize: Size.fromHeight(BusinessCategoryConstants.connectedButtonHeight),
              elevation: 2,
              shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // No rounded borders
              ),
            ),
          ),
        ),
        // Events Button - Connected design (no gap between buttons)
        Expanded(
          child: _buildConnectedEventsButton(
            context: context,
            hasEvents: hasEvents,
            eventCount: state.currentEventCount,
            onPressed: hasEvents ? () => viewModel.navigateToEvents(context) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectedEventsButton({
    required BuildContext context,
    required bool hasEvents,
    required int eventCount,
    required VoidCallback? onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!hasEvents) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.event),
        label: const Text('No Events'),
        style: FilledButton.styleFrom(
          minimumSize: Size.fromHeight(BusinessCategoryConstants.connectedButtonHeight),
          elevation: 0,
          backgroundColor: colorScheme.surfaceContainerHighest,
          foregroundColor: colorScheme.onSurfaceVariant,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // No rounded borders
          ),
        ),
      );
    }

    return _AnimatedConnectedEventsButton(
      hasEvents: hasEvents,
      eventCount: eventCount,
      onPressed: onPressed,
    );
  }

}