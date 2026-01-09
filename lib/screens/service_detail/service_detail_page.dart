import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import 'service_detail_state.dart';
import 'service_detail_view_model.dart';
import 'widgets/widgets.dart';
import 'widgets/service_logo_section.dart';


/// Service Detail Page - Shows comprehensive service information
class ServiceDetailPage extends StatelessWidget {
  final int serviceId;
  final String serviceName;

  const ServiceDetailPage({
    super.key,
    required this.serviceId,
    required this.serviceName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServiceDetailViewModel(
        serviceRepository: serviceLocator.serviceRepository,
        errorHandler: serviceLocator.errorHandler,
        serviceId: serviceId,
        serviceName: serviceName,
      ),
      child: const _ServiceDetailPageContent(),
    );
  }
}

class _ServiceDetailPageContent extends StatelessWidget {
  const _ServiceDetailPageContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ServiceDetailViewModel>();

    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: viewModel.serviceName,
            subtitle: 'Service Details',
            height: 120.0,
            headerType: HeaderType.service,
          ),
          Expanded(
            child: _buildContent(context, viewModel),
          ),
          const BackNavigationFooter(),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ServiceDetailViewModel viewModel) {
    return switch (viewModel.state) {
      ServiceDetailLoading() => const Center(child: CircularProgressIndicator()),
      ServiceDetailSuccess(serviceDetails: final serviceDetails) =>
        _buildServiceDetail(context, serviceDetails, viewModel),
      ServiceDetailError(title: final title, message: final message) =>
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

  Widget _buildServiceDetail(
    BuildContext context,
    ServiceDetailDto serviceDetails,
    ServiceDetailViewModel viewModel,
  ) {
    return CustomScrollView(
      slivers: [
        // Service Logo (moved to top right)
        SliverToBoxAdapter(
          child: ServiceLogoSection(service: serviceDetails),
        ),

        // Service Info Card (Description and Service Area)
        SliverToBoxAdapter(
          child: ServiceInfoCard(service: serviceDetails),
        ),

        // Service Features (Pricing, availability, etc.)
        SliverToBoxAdapter(
          child: ServiceFeaturesSection(service: serviceDetails),
        ),

        // Image Gallery
        if (serviceDetails.images.isNotEmpty)
          SliverToBoxAdapter(
            child: ServiceImageGallery(images: serviceDetails.images),
          ),

        // Documents
        if (serviceDetails.documents.isNotEmpty)
          SliverToBoxAdapter(
            child: ServiceDocumentsSection(documents: serviceDetails.documents),
          ),

        // Operating Hours
        SliverToBoxAdapter(
          child: OperatingHoursSection(
            operatingHours: serviceDetails.operatingHours,
          ),
        ),

        // Contact & Actions
        SliverToBoxAdapter(
          child: ContactActionsSection(service: serviceDetails),
        ),

        // Bottom spacing for proper Material 3 layout
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }
}