import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../core/config/business_category_config.dart';
import 'business_category_state.dart';
import 'business_category_view_model.dart';
import 'widgets/widgets.dart';

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