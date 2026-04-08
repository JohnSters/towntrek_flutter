import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import 'business_category_state.dart';
import 'business_category_view_model.dart';
import 'widgets/widgets.dart';

/// Page for displaying business categories for a selected town
class BusinessCategoryPage extends StatelessWidget {
  final TownDto? town;

  /// When set, after categories load the matching category (by [CategoryWithCountDto.key], case-insensitive) opens immediately.
  final String? openCategoryKey;

  const BusinessCategoryPage({
    super.key,
    this.town,
    this.openCategoryKey,
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
      child: _BusinessCategoryPageContent(openCategoryKey: openCategoryKey),
    );
  }
}

class _BusinessCategoryPageContent extends StatefulWidget {
  final String? openCategoryKey;

  const _BusinessCategoryPageContent({this.openCategoryKey});

  @override
  State<_BusinessCategoryPageContent> createState() => _BusinessCategoryPageContentState();
}

class _BusinessCategoryPageContentState extends State<_BusinessCategoryPageContent> {
  bool _didOpenInitialCategory = false;

  void _tryOpenInitialCategory(
    BuildContext context,
    BusinessCategoryViewModel viewModel,
    BusinessCategorySuccess state,
  ) {
    final key = widget.openCategoryKey;
    if (key == null || _didOpenInitialCategory || !context.mounted) return;

    CategoryWithCountDto? match;
    final normalized = key.toLowerCase();
    for (final c in state.categories) {
      if (c.key.toLowerCase() == normalized) {
        match = c;
        break;
      }
    }

    _didOpenInitialCategory = true;
    if (match == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      viewModel.navigateToCategory(context, match!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BusinessCategoryViewModel>();
    final state = viewModel.state;
    if (state is BusinessCategorySuccess) {
      _tryOpenInitialCategory(context, viewModel, state);
    }

    return Scaffold(
      backgroundColor: context.entityListing.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildContent(context, viewModel),
            ),
            const ListingBackFooter(label: 'Back'),
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
      return _buildErrorState(
        context,
        viewModel: viewModel,
        error: state.error,
      );
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
              color: colorScheme.onPrimary,
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
              color: colorScheme.onPrimary,
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

  Widget _buildErrorState(
    BuildContext context, {
    required AppError error,
    required BusinessCategoryViewModel viewModel,
  }) {
    if (error.actionText != null && error.action != null) {
      return ErrorView(error: error);
    }

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        ErrorView(error: error),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: viewModel.retry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry'),
        ),
      ],
    );
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
        // Pillar • TOWN • PROVINCE (design system browse convention)
        EntityListingHeroHeader(
          theme: context.entityListingTheme,
          categoryIcon: Icons.store_mall_directory_rounded,
          subCategoryName: TownFeatureConstants.businessesTitle,
          categoryName: state.town.name,
          townName: state.town.province,
        ),
        _buildConnectedActionButtons(context, viewModel, state),
        ListingResultsBand(
          count: state.categories.length,
          categoryName: state.town.name,
          bandColor: context.entityListingTheme.resultsBand,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              BusinessCategoryConstants.horizontalPadding,
              0,
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

    return SizedBox(
      height: BusinessCategoryConstants.connectedButtonHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Change Town Button - Connected design
          Expanded(
            child: ConnectedWrongTownStripButton(
              onPressed: () => viewModel.changeTown(context),
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
      ),
    );
  }

  Widget _buildConnectedEventsButton({
    required BuildContext context,
    required bool hasEvents,
    required int eventCount,
    required VoidCallback? onPressed,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!hasEvents) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.event),
        label: const Text('No Events'),
        style: BusinessCategoryConstants.connectedHeaderButtonStyle(
          theme,
          backgroundColor: colorScheme.surfaceContainerHighest,
          foregroundColor: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return LiveEventsStripButton(
      eventCount: eventCount,
      onPressed: onPressed!,
    );
  }

}