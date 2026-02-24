import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../core/constants/service_list_constants.dart';
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
      body: Column(
        children: [
          PageHeader(
            title: viewModel.subCategory.name,
            subtitle: '${ServiceListConstants.servicesSubtitle} in ${viewModel.town.name}',
            height: ServiceListConstants.pageHeaderHeight,
            headerType: HeaderType.service,
          ),
          _ListInfoBar(
            icon: Icons.handyman_rounded,
            text: '${viewModel.subCategory.serviceCount} services \u2022 ${viewModel.subCategory.name}',
            backgroundColor: const Color(0xFFE3F2FD),
            textColor: const Color(0xFF0D47A1),
            borderColor: const Color(0xFFBBDEFB),
          ),
          Expanded(
            child: _buildContent(context, viewModel),
          ),
          const BackNavigationFooter(),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ServiceListViewModel viewModel) {
    return switch (viewModel.state) {
      ServiceListLoading() => const Center(child: CircularProgressIndicator()),
      ServiceListSuccess(services: final services, hasNextPage: final hasNextPage, isLoadingMore: final isLoadingMore) =>
        _buildServicesList(context, services, hasNextPage, isLoadingMore, viewModel),
      ServiceListLoadingMore(services: final services, currentPage: _) =>
        _buildServicesList(context, services, true, true, viewModel),
      ServiceListError(title: final title, message: final message) =>
        _buildErrorView(title, message),
    };
  }

  Widget _buildErrorView(String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesList(
    BuildContext context,
    List<ServiceDto> services,
    bool hasMorePages,
    bool isLoadingMore,
    ServiceListViewModel viewModel,
  ) {
    if (services.isEmpty) {
      return const Center(
        child: Text('No services found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length + (hasMorePages ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == services.length) {
          // Load more indicator
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

        final service = services[index];
          return Column(
            children: [
              ServiceCard(service: service),
              if (index < services.length - 1) const SizedBox(height: 16),
            ],
          );
      },
    );
  }
}

class _ListInfoBar extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const _ListInfoBar({
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}