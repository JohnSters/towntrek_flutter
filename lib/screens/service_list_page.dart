import 'package:flutter/material.dart';
import '../core/core.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../core/widgets/error_view.dart';
import '../core/widgets/navigation_footer.dart';
import '../core/widgets/page_header.dart';
import '../core/errors/app_error.dart';
import '../core/errors/error_handler.dart';
import '../core/utils/url_utils.dart';
import 'service_detail_page.dart';

class ServiceListPage extends StatefulWidget {
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
  State<ServiceListPage> createState() => _ServiceListPageState();
}

class _ServiceListPageState extends State<ServiceListPage> {
  List<ServiceDto> _services = [];
  bool _isLoading = true;
  AppError? _error;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMorePages = true;
  final int _pageSize = 20;

  final ServiceRepository _serviceRepository = serviceLocator.serviceRepository;
  final ErrorHandler _errorHandler = serviceLocator.errorHandler;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices({bool loadMore = false}) async {
    if (loadMore && !_hasMorePages) return;

    setState(() {
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
        _error = null;
        _currentPage = 1;
        _services = [];
      }
    });

    try {
      final response = await _serviceRepository.getServices(
        townId: widget.town.id,
        categoryId: widget.category.id,
        subCategoryId: widget.subCategory.id,
        page: loadMore ? _currentPage + 1 : 1,
        pageSize: _pageSize,
      );

      if (mounted) {
        setState(() {
          if (loadMore) {
            _services.addAll(response.services);
            _currentPage++;
          } else {
            _services = response.services;
          }
          _hasMorePages = response.services.length == _pageSize;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      final appError = await _errorHandler.handleError(
        e,
        retryAction: () => _loadServices(loadMore: loadMore),
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
    if (_isLoading) {
      return _buildLoadingView();
    }

    if (_error != null) {
      return _buildErrorView();
    }

    return _buildServicesView();
  }

  Widget _buildLoadingView() {
    return Column(
      children: [
        PageHeader(
          title: widget.subCategory.name,
          subtitle: '${widget.category.name} in ${widget.town.name}',
          height: 120,
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
        PageHeader(
          title: widget.subCategory.name,
          subtitle: '${widget.category.name} in ${widget.town.name}',
          height: 120,
        ),
        Expanded(
          child: ErrorView(error: _error!),
        ),
      ],
    );
  }

  Widget _buildServicesView() {
    return Column(
      children: [
        PageHeader(
          title: widget.subCategory.name,
          subtitle: '${widget.category.name} in ${widget.town.name}',
          height: 140,
        ),
        Expanded(
          child: _services.isEmpty
              ? _buildEmptyView()
              : _buildServicesList(),
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
          Icon(
            Icons.handyman,
            size: 64,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No services found',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no service providers in this category yet',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            !_isLoadingMore &&
            _hasMorePages) {
          _loadServices(loadMore: true);
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(24.0),
        itemCount: _services.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _services.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          final service = _services[index];
          return _buildServiceCard(service);
        },
      ),
    );
  }

  Widget _buildServiceCard(ServiceDto service) {
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
        onTap: () => _onServiceDetailsTap(service),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: colorScheme.surfaceContainerHighest,
                    ),
                    child: service.logoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              UrlUtils.resolveImageUrl(service.logoUrl!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.handyman,
                                  size: 30,
                                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.handyman,
                            size: 30,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Rating or Verified status
                        Row(
                          children: [
                             if (service.isVerified) ...[
                               Icon(Icons.verified, size: 16, color: Colors.blue),
                               const SizedBox(width: 4),
                               Text(
                                 'Verified',
                                 style: theme.textTheme.bodySmall?.copyWith(
                                   color: Colors.blue,
                                   fontWeight: FontWeight.bold,
                                 ),
                               ),
                               const SizedBox(width: 8),
                             ],
                             
                             // Rating Row
                            Row(
                              children: List.generate(5, (starIndex) {
                                final rating = service.rating ?? 0.0;
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
                              service.rating != null
                                  ? '${service.rating!.toStringAsFixed(1)} (${service.totalReviews})'
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
              if (service.shortDescription != null && service.shortDescription!.isNotEmpty)
                Text(
                  service.shortDescription!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _onServiceDetailsTap(service),
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Service Details'),
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

  void _onServiceDetailsTap(ServiceDto service) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServiceDetailPage(
          serviceId: service.id,
          serviceName: service.name,
        ),
      ),
    );
  }
}

