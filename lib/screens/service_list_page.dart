import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/core.dart';
import '../models/models.dart';
import '../core/constants/service_list_constants.dart';
import 'service_list/service_list_state.dart';
import 'service_list/service_list_view_model.dart';
import 'service_list/widgets/widgets.dart';

/// Service List Page - Shows paginated list of services for a specific sub-category
/// Uses Provider pattern with ViewModel and sealed classes for clean architecture
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
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _buildContent(),
          ),
          const BackNavigationFooter(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<ServiceListViewModel>(
      builder: (context, viewModel, child) {
        final state = viewModel.state;

        if (state is ServiceListLoading) {
          return ServiceListLoadingView(
            category: viewModel.category,
            subCategory: viewModel.subCategory,
            town: viewModel.town,
          );
        }

        if (state is ServiceListError) {
          return ServiceListErrorView(
            category: viewModel.category,
            subCategory: viewModel.subCategory,
            town: viewModel.town,
            title: state.title,
            message: state.message,
            onRetry: viewModel.retry,
          );
        }

        if (state is ServiceListSuccess) {
          return _buildServicesList(context, state, viewModel);
        }

        if (state is ServiceListLoadingMore) {
          return _buildServicesList(context, state, viewModel);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildServicesList(
    BuildContext context,
    dynamic state,
    ServiceListViewModel viewModel,
  ) {
    final services = state.services;
    final hasNextPage = state is ServiceListSuccess ? state.hasNextPage : false;
    final isLoadingMore = state is ServiceListLoadingMore;

    if (services.isEmpty) {
      return ServiceListEmptyStateView(
        category: viewModel.category,
        subCategory: viewModel.subCategory,
        town: viewModel.town,
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            !isLoadingMore &&
            hasNextPage) {
          viewModel.loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: viewModel.refresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(ServiceListConstants.contentPadding),
          itemCount: services.length + (hasNextPage ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == services.length) {
              // Load more indicator
              return const Padding(
                padding: EdgeInsets.all(ServiceListConstants.loadMorePaddingVertical),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final service = services[index];
            return ServiceCard(service: service);
          },
        ),
      ),
    );
  }
}