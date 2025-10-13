import 'package:flutter/material.dart';
import '../core/core.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../core/widgets/error_view.dart';
import '../core/errors/app_error.dart';
import '../core/errors/error_handler.dart';
import '../core/config/business_category_config.dart';
import '../core/utils/url_utils.dart';
import 'business_details_page.dart';

/// Page for displaying businesses in a beautiful card layout for a selected sub-category
class BusinessCardPage extends StatefulWidget {
  final CategoryWithCountDto category;
  final SubCategoryWithCountDto subCategory;
  final TownDto town;

  const BusinessCardPage({
    super.key,
    required this.category,
    required this.subCategory,
    required this.town,
  });

  @override
  State<BusinessCardPage> createState() => _BusinessCardPageState();
}

class _BusinessCardPageState extends State<BusinessCardPage> {
  List<BusinessDto> _businesses = [];
  bool _isLoading = true;
  AppError? _error;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMorePages = true;
  final int _pageSize = 20;

  final BusinessRepository _businessRepository = serviceLocator.businessRepository;
  final ErrorHandler _errorHandler = serviceLocator.errorHandler;

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  Future<void> _loadBusinesses({bool loadMore = false}) async {
    if (loadMore && !_hasMorePages) return;

    setState(() {
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
        _error = null;
        _currentPage = 1;
        _businesses = [];
      }
    });

    try {
      final response = await _businessRepository.getBusinesses(
        townId: widget.town.id,
        category: widget.category.key,
        subCategory: widget.subCategory.key,
        page: loadMore ? _currentPage + 1 : 1,
        pageSize: _pageSize,
      );

      if (mounted) {
        setState(() {
          if (loadMore) {
            _businesses.addAll(response.businesses);
            _currentPage++;
          } else {
            _businesses = response.businesses;
          }
          _hasMorePages = response.businesses.length == _pageSize;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      final appError = await _errorHandler.handleError(
        e,
        retryAction: () => _loadBusinesses(loadMore: loadMore),
      );
      if (mounted) {
        setState(() {
          _error = appError;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(alpha: 0.1),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: _buildContent(),
        ),
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

    return _buildBusinessesView();
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorView() {
    return Column(
      children: [
        // Header with back button
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ErrorView(error: _error!),
        ),
      ],
    );
  }

  Widget _buildBusinessesView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Modern Header Design
        Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Back button and title
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.subCategory.name,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          widget.town.name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Subtitle with category info
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 320),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        BusinessCategoryConfig.getCategoryIcon(widget.category.key),
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '${widget.subCategory.businessCount} businesses • ${widget.category.name}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Businesses Grid/List
        Expanded(
          child: _businesses.isEmpty
              ? _buildEmptyView()
              : _buildBusinessesList(),
        ),
      ],
    );
  }

  Widget _buildEmptyView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              BusinessCategoryConfig.getCategoryIcon(widget.category.key),
              size: 40,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No businesses found',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no businesses in this category yet',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessesList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            !_isLoadingMore &&
            _hasMorePages) {
          _loadBusinesses(loadMore: true);
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(24.0),
        itemCount: _businesses.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _businesses.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          final business = _businesses[index];
          return _buildBusinessCard(business);
        },
      ),
    );
  }

  Widget _buildBusinessCard(BusinessDto business) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _onBusinessDetailsTap(business),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Business Header Row
              Row(
                children: [
                  // Logo
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: colorScheme.surfaceContainerHighest,
                    ),
                    child: business.logoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              UrlUtils.resolveImageUrl(business.logoUrl!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.business,
                                  size: 30,
                                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.business,
                            size: 30,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                  ),

                  const SizedBox(width: 16),

                  // Business Name and Rating
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Business Name
                        Text(
                          business.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Rating Row
                        Row(
                          children: [
                            // Stars
                            Row(
                              children: List.generate(5, (starIndex) {
                                final rating = business.rating ?? 0.0;
                                final starValue = starIndex + 1;
                                return Icon(
                                  starValue <= rating
                                      ? Icons.star
                                      : starValue - 0.5 <= rating
                                          ? Icons.star_half
                                          : Icons.star_outline,
                                  size: 16,
                                  color: starValue <= rating + 0.5
                                      ? Colors.amber
                                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                                );
                              }),
                            ),

                            const SizedBox(width: 6),

                            // Rating Text
                            Text(
                              business.rating != null
                                  ? '${business.rating!.toStringAsFixed(1)} (${business.totalReviews})'
                                  : 'No reviews',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Short Description
              if (business.shortDescription != null && business.shortDescription!.isNotEmpty)
                Text(
                  business.shortDescription!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 20),

              // Business Details Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _onBusinessDetailsTap(business),
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Business Details'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onBusinessDetailsTap(BusinessDto business) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BusinessDetailsPage(
          businessId: business.id,
          businessName: business.name,
        ),
      ),
    );
  }
}
