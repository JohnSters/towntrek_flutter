import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import '../../services/navigation_service.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/navigation_footer.dart';
import '../../core/widgets/page_header.dart';
import '../../core/errors/app_error.dart';
import '../../core/errors/error_handler.dart';
import 'widgets/business_status_indicator.dart';
import 'widgets/business_info_card.dart';
import 'widgets/business_image_gallery.dart';
import 'widgets/business_documents_section.dart';
import 'widgets/operating_hours_section.dart';
import 'widgets/reviews_section.dart';
import 'widgets/contact_actions_section.dart';

/// Comprehensive business details page with gallery, hours, reviews, and contact options
class BusinessDetailsPage extends StatefulWidget {
  final int businessId;
  final String businessName; // For loading state display

  const BusinessDetailsPage({
    super.key,
    required this.businessId,
    required this.businessName,
  });

  @override
  State<BusinessDetailsPage> createState() => _BusinessDetailsPageState();
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage> {
  BusinessDetailDto? _businessDetails;
  bool _isLoading = true;
  AppError? _error;

  final BusinessRepository _businessRepository = serviceLocator.businessRepository;
  final NavigationService _navigationService = serviceLocator.navigationService;
  final ErrorHandler _errorHandler = serviceLocator.errorHandler;

  @override
  void initState() {
    super.initState();
    _loadBusinessDetails();
  }

  Future<void> _loadBusinessDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final details = await _businessRepository.getBusinessDetails(widget.businessId);
      if (mounted) {
        setState(() {
          _businessDetails = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      final appError = await _errorHandler.handleError(
        e,
        retryAction: _loadBusinessDetails,
      );
      if (mounted) {
        setState(() {
          _error = appError;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Main content area
          Expanded(
            child: _buildContent(),
          ),

          // Navigation footer
          if (_businessDetails != null)
            const BackNavigationFooter(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingView();
    }

    if (_error != null) {
      return _buildErrorView();
    }

    if (_businessDetails == null) {
      return _buildErrorView();
    }

    return _buildBusinessDetailsView();
  }

  Widget _buildLoadingView() {
    return Column(
      children: [
        BusinessHeader(
          businessName: widget.businessName,
          tagline: 'Loading business details...',
        ),
        const Expanded(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Column(
      children: [
        BusinessHeader(
          businessName: widget.businessName,
          tagline: 'Unable to load business details',
        ),
        Expanded(
          child: ErrorView(error: _error!),
        ),
      ],
    );
  }

  Widget _buildBusinessDetailsView() {
    final business = _businessDetails!;

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
                    onViewAllPressed: () {
                      // TODO: Navigate to full reviews page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('View all reviews - Coming soon!')),
                      );
                    },
                  ),
                ),

              // Contact & Actions
              SliverToBoxAdapter(
                child: ContactActionsSection(
                  business: business,
                  onTakeMeThere: () => _launchDirections(business),
                  onRateBusiness: () => _rateBusiness(business),
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _launchDirections(BusinessDetailDto business) async {
    try {
      final result = await _navigationService.navigateToBusiness(business);
      if (result.isFailure) {
        // Show error message to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Navigation failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to start navigation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rateBusiness(BusinessDetailDto business) async {
    // TODO: Implement CRM integration for rating
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rate ${business.name} - CRM integration coming soon!'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

