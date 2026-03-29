import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class _ServiceListPageContent extends StatelessWidget {
  const _ServiceListPageContent();

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
        _buildSuccessLayout(
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
      count: viewModel.subCategory.serviceCount,
      categoryName: viewModel.subCategory.name,
      bandColor: ServiceListPage._theme.resultsBand,
    );
  }

  Widget _buildLoadingLayout(ServiceListViewModel viewModel) {
    return Column(
      children: [
        _serviceHero(viewModel),
        _resultsBand(viewModel),
        const Expanded(
          child: Center(child: CircularProgressIndicator()),
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
    if (services.isEmpty) {
      return ServiceListEmptyStateView(
        category: viewModel.category,
        subCategory: viewModel.subCategory,
        town: viewModel.town,
      );
    }

    return Column(
      children: [
        _serviceHero(viewModel),
        _resultsBand(viewModel),
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
          Expanded(child: ErrorView(error: error)),
        ],
      );
    }

    return Column(
      children: [
        _serviceHero(viewModel),
        _resultsBand(viewModel),
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
      padding: const EdgeInsets.all(16),
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
