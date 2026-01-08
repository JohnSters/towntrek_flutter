import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import '../../services/navigation_service.dart';
import '../../core/utils/external_link_launcher.dart';
import 'widgets/business_status_indicator.dart';
import 'widgets/business_info_card.dart';
import 'widgets/business_image_gallery.dart';
import 'widgets/business_documents_section.dart';
import 'widgets/operating_hours_section.dart';
import 'widgets/reviews_section.dart';
import 'widgets/contact_actions_section.dart';

/// State classes for Business Details page
sealed class BusinessDetailsState {}

class BusinessDetailsLoading extends BusinessDetailsState {}

class BusinessDetailsSuccess extends BusinessDetailsState {
  final BusinessDetailDto business;
  BusinessDetailsSuccess(this.business);
}

class BusinessDetailsError extends BusinessDetailsState {
  final AppError error;
  BusinessDetailsError(this.error);
}

/// ViewModel for Business Details page business logic
class BusinessDetailsViewModel extends ChangeNotifier {
  final BusinessRepository _businessRepository;
  final NavigationService _navigationService;
  final ErrorHandler _errorHandler;

  BusinessDetailsState _state = BusinessDetailsLoading();
  BusinessDetailsState get state => _state;

  final int businessId;
  final String businessName;

  BusinessDetailsViewModel({
    required this.businessId,
    required this.businessName,
    required BusinessRepository businessRepository,
    required NavigationService navigationService,
    required ErrorHandler errorHandler,
  })  : _businessRepository = businessRepository,
        _navigationService = navigationService,
        _errorHandler = errorHandler {
    loadBusinessDetails();
  }

  Future<void> loadBusinessDetails() async {
    _state = BusinessDetailsLoading();
    notifyListeners();

    try {
      final details = await _businessRepository.getBusinessDetails(businessId);
      _state = BusinessDetailsSuccess(details);
      notifyListeners();
    } catch (e) {
      final appError = await _errorHandler.handleError(
        e,
        retryAction: loadBusinessDetails,
      );
      _state = BusinessDetailsError(appError);
      notifyListeners();
    }
  }

  Future<void> navigateToBusiness(BuildContext context, BusinessDetailDto business) async {
    try {
      final result = await _navigationService.navigateToBusiness(business);
      if (result.isFailure) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? BusinessDetailsConstants.navigationFailedMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(BusinessDetailsConstants.navigationErrorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void rateBusiness(BuildContext context, BusinessDetailDto business) {
    // Link to web application for reviews as requested
    ExternalLinkLauncher.openWebsite(
      context,
      BusinessDetailsConstants.reviewsUrl,
      failureMessage: 'Unable to open reviews page',
    );
  }
}

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
      body: Column(
        children: [
          // Main content area
          Expanded(
            child: _buildContent(context, viewModel),
          ),

          // Navigation footer - only show when we have business data
          if (viewModel.state is BusinessDetailsSuccess)
            const BackNavigationFooter(),
        ],
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

    return Column(
      children: [
        // Business Header with status
        BusinessHeader(
          businessName: business.name,
          statusIndicator: BusinessStatusIndicator(business: business),
        ),

        // Scrollable content
        Expanded(
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
        ),
      ],
    );
  }
}

