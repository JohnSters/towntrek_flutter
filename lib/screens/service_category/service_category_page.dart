import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../town_selection/town_selection_screen.dart';
import '../town_feature_selection/town_feature_selection_screen.dart';
import '../service_sub_category/service_sub_category_page.dart';
import '../../core/constants/service_category_constants.dart';
import 'service_category_state.dart';
import 'service_category_view_model.dart';
import 'widgets/widgets.dart';

/// Service Category Page - Shows available service categories for a town
/// Uses Provider pattern with ViewModel and sealed classes for clean architecture
class ServiceCategoryPage extends StatelessWidget {
  final TownDto town;

  const ServiceCategoryPage({
    super.key,
    required this.town,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServiceCategoryViewModel(
        town: town,
        serviceRepository: serviceLocator.serviceRepository,
        eventRepository: serviceLocator.eventRepository,
        errorHandler: serviceLocator.errorHandler,
      ),
      child: const _ServiceCategoryPageContent(),
    );
  }
}

class _ServiceCategoryPageContent extends StatelessWidget {
  const _ServiceCategoryPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildContent(),
            ),
            const BackNavigationFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<ServiceCategoryViewModel>(
      builder: (context, viewModel, child) {
        final state = viewModel.state;

        if (state is ServiceCategoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ServiceCategoryError) {
          return ErrorView(error: state.error);
        }

        if (state is ServiceCategorySuccess) {
          return _buildCategoriesView(context, state);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildCategoriesView(
    BuildContext context,
    ServiceCategorySuccess state,
  ) {
    final viewModel = context.read<ServiceCategoryViewModel>();

    return Column(
      children: [
        // Page Header
        PageHeader(
          title: viewModel.town.name,
          subtitle: '${viewModel.town.province} • ${ServiceCategoryConstants.servicesSubtitle}',
          height: ServiceCategoryConstants.pageHeaderHeight,
          headerType: HeaderType.service,
        ),

        // Connected Action Buttons (fills entire width, connects to header)
        _buildConnectedActionButtons(context, viewModel, state),

        // Scrollable content (no top padding since buttons connect to header)
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              ServiceCategoryConstants.pagePadding,
              ServiceCategoryConstants.cardSpacing, // Small top padding for content separation
              ServiceCategoryConstants.pagePadding,
              ServiceCategoryConstants.pagePadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Categories grid
                if (state.categories.isEmpty)
                  const EmptyStateView()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.categories.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final category = state.categories[index];
                      return CategoryCard(
                        category: category,
                        countsAvailable: state.countsAvailable,
                        onTap: () => _navigateToSubCategories(context, category, state.countsAvailable),
                      );
                    },
                  ),

                SizedBox(height: ServiceCategoryConstants.contentBottomSpacing),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectedActionButtons(
    BuildContext context,
    ServiceCategoryViewModel viewModel,
    ServiceCategorySuccess state,
  ) {
    final bool hasEvents = state.currentEventCount > 0;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Change Town Button - Connected design
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _changeTown(context),
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


  void _navigateToSubCategories(
    BuildContext context,
    ServiceCategoryDto category,
    bool countsAvailable,
  ) {
    final viewModel = context.read<ServiceCategoryViewModel>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServiceSubCategoryPage(
          category: category,
          town: viewModel.town,
          countsAvailable: countsAvailable,
        ),
      ),
    );
  }

  void _changeTown(BuildContext context) {
    Navigator.of(context).push<TownDto>(
      MaterialPageRoute(
        builder: (context) => const TownSelectionScreen(),
      ),
    ).then((selectedTown) {
      if (selectedTown != null && context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TownFeatureSelectionScreen(town: selectedTown),
          ),
        );
      }
    });
  }

}

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