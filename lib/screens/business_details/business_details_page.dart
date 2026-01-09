import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import 'business_details_state.dart';
import 'business_details_view_model.dart';
import 'widgets/business_status_indicator.dart';
import 'widgets/business_info_card.dart';
import 'widgets/business_image_gallery.dart';
import 'widgets/business_documents_section.dart';
import 'widgets/operating_hours_section.dart';
import 'widgets/reviews_section.dart';
import 'widgets/contact_actions_section.dart';

/// Comprehensive business details page with gallery, hours, reviews, and contact options
class BusinessDetailsPage extends StatelessWidget {
  final int businessId;
  final String businessName; // For loading state display

  const BusinessDetailsPage({
    super.key,
    required this.businessId,
    required this.businessName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BusinessDetailsViewModel(
        businessId: businessId,
        businessName: businessName,
        businessRepository: serviceLocator.businessRepository,
        navigationService: serviceLocator.navigationService,
        errorHandler: serviceLocator.errorHandler,
      ),
      child: const _BusinessDetailsPageContent(),
    );
  }
}

class _BusinessDetailsPageContent extends StatelessWidget {
  const _BusinessDetailsPageContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BusinessDetailsViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: viewModel.businessName,
              subtitle: 'Business Details',
              height: 120.0,
              headerType: HeaderType.business,
            ),
            // Main content area
            Expanded(
              child: _buildContent(context, viewModel),
            ),

            // Navigation footer - only show when we have business data
            if (viewModel.state is BusinessDetailsSuccess)
              const BackNavigationFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BusinessDetailsViewModel viewModel) {
    final state = viewModel.state;

    if (state is BusinessDetailsLoading) {
      return _buildLoadingView(viewModel);
    }

    if (state is BusinessDetailsError) {
      return _buildErrorView(viewModel, state);
    }

    if (state is BusinessDetailsSuccess) {
      return _buildBusinessDetailsView(context, viewModel, state);
    }

    return const SizedBox();
  }

  Widget _buildLoadingView(BusinessDetailsViewModel viewModel) {
    return Column(
      children: [
        BusinessHeader(
          businessName: viewModel.businessName,
          tagline: BusinessDetailsConstants.loadingTagline,
        ),
        const Expanded(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(BusinessDetailsViewModel viewModel, BusinessDetailsError state) {
    return Column(
      children: [
        BusinessHeader(
          businessName: viewModel.businessName,
          tagline: BusinessDetailsConstants.errorTagline,
        ),
        Expanded(
          child: ErrorView(error: state.error),
        ),
      ],
    );
  }

  Widget _buildBusinessDetailsView(
    BuildContext context,
    BusinessDetailsViewModel viewModel,
    BusinessDetailsSuccess state,
  ) {
    final business = state.business;

    return Expanded(
      child: CustomScrollView(
        slivers: [
              // Business Info Card (Description and Address)
              SliverToBoxAdapter(
                child: BusinessInfoCard(business: business),
              ),

              // Image Gallery
              if (business.images.isNotEmpty)
                SliverToBoxAdapter(
                  child: BusinessImageGallery(images: business.images),
                ),

              // Documents
              if (business.documents.isNotEmpty)
                SliverToBoxAdapter(
                  child: BusinessDocumentsSection(documents: business.documents),
                ),

              // Operating Hours
              SliverToBoxAdapter(
                child: OperatingHoursSection(
                  operatingHours: business.operatingHours,
                  specialOperatingHours: business.specialOperatingHours,
                ),
              ),

              // Reviews Section
              if (business.reviews.isNotEmpty)
                SliverToBoxAdapter(
                  child: ReviewsSection(
                    reviews: business.reviews,
                    onViewAllPressed: () => viewModel.rateBusiness(context, business),
                  ),
                ),

              // Contact & Actions
              SliverToBoxAdapter(
                child: ContactActionsSection(
                  business: business,
                  onTakeMeThere: () => viewModel.navigateToBusiness(context, business),
                  onRateBusiness: () => viewModel.rateBusiness(context, business),
                ),
              ),

              // Bottom padding
              SliverToBoxAdapter(
                child: SizedBox(height: BusinessDetailsConstants.bottomPadding),
              ),
            ],
          ),
        );
  }
}

