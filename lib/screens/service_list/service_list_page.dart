import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/service_list_constants.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import 'service_list_state.dart';
import 'service_list_view_model.dart';
import 'widgets/widgets.dart';

/// Service List Page - Shows paginated list of services for a specific sub-category
class ServiceListPage extends StatelessWidget {
  final ServiceCategoryDto category;
  final ServiceSubCategoryDto subCategory;
  final TownDto town;

  const ServiceListPage({
    super.key,
    required this.category,
    required this.subCategory,
    required this.town,
  });

  static final EntityListingTheme _theme = EntityListingTheme.services;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServiceListViewModel(
        serviceRepository: serviceLocator.serviceRepository,
        errorHandler: serviceLocator.errorHandler,
        category: category,
        subCategory: subCategory,
        town: town,
      ),
      child: const _ServiceListPageContent(),
    );
  }
}

class _ServiceListPageContent extends StatefulWidget {
  const _ServiceListPageContent();

  @override
  State<_ServiceListPageContent> createState() => _ServiceListPageContentState();
}

class _ServiceListPageContentState extends State<_ServiceListPageContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(ServiceListViewModel viewModel) {
    viewModel.search(_searchController.text);
  }

  void _clearSearch(ServiceListViewModel viewModel) {
    _searchController.clear();
    viewModel.search(null);
  }

  Widget _searchBar(ServiceListViewModel viewModel) {
    return EntityListingSearchBar(
      controller: _searchController,
      theme: ServiceListPage._theme,
      hintText: ServiceListConstants.searchHint,
      onSubmitted: () => _submitSearch(viewModel),
      onClear: () => _clearSearch(viewModel),
    );
  }

  Widget _serviceHero(ServiceListViewModel viewModel) {
    return EntityListingHeroHeader(
      theme: ServiceListPage._theme,
      categoryIcon: Icons.handyman_rounded,
      subCategoryName: viewModel.subCategory.name,
      categoryName: viewModel.category.name,
      townName: viewModel.town.name,
    );
  }

  Widget _resultsBand(ServiceListViewModel viewModel) {
    return ListingResultsBand(
      count: viewModel.bandCount,
      categoryName: viewModel.subCategory.name,
      bandColor: ServiceListPage._theme.resultsBand,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ServiceListViewModel>();

    return Scaffold(
      backgroundColor: EntityListingTheme.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildContent(context, viewModel),
            ),
            const ListingBackFooter(label: 'Back to services'),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ServiceListViewModel viewModel) {
    return switch (viewModel.state) {
      ServiceListLoading() => _buildLoadingLayout(viewModel),
      ServiceListSuccess(
        services: final services,
        hasNextPage: final hasNextPage,
        isLoadingMore: final isLoadingMore,
      ) =>
        services.isEmpty
            ? _buildEmptyLayout(context, viewModel)
            : _buildSuccessLayout(
                context,
                viewModel,
                services,
                hasNextPage,
                isLoadingMore,
              ),
      ServiceListLoadingMore(services: final services, currentPage: _) =>
        _buildSuccessLayout(context, viewModel, services, true, true),
      ServiceListError(error: final error) =>
        _buildErrorLayout(context, error: error, viewModel: viewModel),
    };
  }

  Widget _searchPadding(Widget child) {
    return Padding(
      padding: EntityListingConstants.searchBarSectionPadding,
      child: child,
    );
  }

  Widget _buildLoadingLayout(ServiceListViewModel viewModel) {
    return Column(
      children: [
        _serviceHero(viewModel),
        _resultsBand(viewModel),
        _searchPadding(_searchBar(viewModel)),
        const Expanded(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  Widget _buildEmptyLayout(
    BuildContext context,
    ServiceListViewModel viewModel,
  ) {
    final hasSearch = _searchController.text.trim().isNotEmpty;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        _serviceHero(viewModel),
        _resultsBand(viewModel),
        _searchPadding(_searchBar(viewModel)),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasSearch
                        ? Icons.search_off_rounded
                        : ServiceListConstants.emptyIcon,
                    size: ServiceListConstants.errorIconSize,
                    color: colorScheme.onSurface.withValues(
                      alpha: hasSearch
                          ? 0.45
                          : ServiceListConstants.emptyStateIconOpacity,
                    ),
                  ),
                  SizedBox(height: ServiceListConstants.errorSpacing),
                  Text(
                    hasSearch
                        ? ServiceListConstants.emptySearchTitle
                        : ServiceListConstants.emptyStateTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface.withValues(
                        alpha: ServiceListConstants.emptyStateTextOpacity,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ServiceListConstants.errorSpacing * 0.5),
                  Text(
                    hasSearch
                        ? EntityListingConstants.searchNoMatchesHint
                        : ServiceListConstants.emptyStateMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (hasSearch) ...[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => _clearSearch(viewModel),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text(EntityListingConstants.clearSearchLabel),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessLayout(
    BuildContext context,
    ServiceListViewModel viewModel,
    List<ServiceDto> services,
    bool hasMorePages,
    bool isLoadingMore,
  ) {
    return Column(
      children: [
        _serviceHero(viewModel),
        _resultsBand(viewModel),
        _searchPadding(_searchBar(viewModel)),
        Expanded(
          child: _buildServicesList(
            context,
            services,
            hasMorePages,
            isLoadingMore,
            viewModel,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorLayout(
    BuildContext context, {
    required AppError error,
    required ServiceListViewModel viewModel,
  }) {
    if (error.actionText != null && error.action != null) {
      return Column(
        children: [
          _serviceHero(viewModel),
          _resultsBand(viewModel),
          _searchPadding(_searchBar(viewModel)),
          Expanded(child: ErrorView(error: error)),
        ],
      );
    }

    return Column(
      children: [
        _serviceHero(viewModel),
        _resultsBand(viewModel),
        _searchPadding(_searchBar(viewModel)),
        Expanded(
          child: ListView(
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
          ),
        ),
      ],
    );
  }

  Widget _buildServicesList(
    BuildContext context,
    List<ServiceDto> services,
    bool hasMorePages,
    bool isLoadingMore,
    ServiceListViewModel viewModel,
  ) {
    return ListView.separated(
      padding: EntityListingConstants.cardListScrollPadding,
      itemCount: services.length + (hasMorePages ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index == services.length) {
          if (!isLoadingMore) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              viewModel.loadMore();
            });
          }
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return ServiceCard(
          service: services[index],
          listingTheme: ServiceListPage._theme,
        );
      },
    );
  }
}
