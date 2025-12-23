import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/core.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../core/widgets/error_view.dart';
import '../core/widgets/navigation_footer.dart';
import '../core/widgets/page_header.dart';
import '../core/errors/app_error.dart';
import '../core/errors/error_handler.dart';
import '../core/utils/url_utils.dart';

class ServiceDetailPage extends StatefulWidget {
  final int serviceId;
  final String serviceName;

  const ServiceDetailPage({
    super.key,
    required this.serviceId,
    required this.serviceName,
  });

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  ServiceDetailDto? _serviceDetails;
  bool _isLoading = true;
  AppError? _error;

  final ServiceRepository _serviceRepository = serviceLocator.serviceRepository;
  final ErrorHandler _errorHandler = serviceLocator.errorHandler;

  @override
  void initState() {
    super.initState();
    _loadServiceDetails();
  }

  Future<void> _loadServiceDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final details = await _serviceRepository.getServiceDetails(widget.serviceId);
      if (mounted) {
        setState(() {
          _serviceDetails = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      final appError = await _errorHandler.handleError(
        e,
        retryAction: _loadServiceDetails,
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
          Expanded(
            child: _buildContent(),
          ),
          if (_serviceDetails != null)
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

    if (_serviceDetails == null) {
      return _buildErrorView();
    }

    return _buildServiceDetailsView();
  }

  Widget _buildLoadingView() {
    return Column(
      children: [
        PageHeader(
          title: widget.serviceName,
          subtitle: 'Loading details...',
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
          title: widget.serviceName,
          subtitle: 'Unable to load details',
          height: 120,
        ),
        Expanded(
          child: ErrorView(error: _error!),
        ),
      ],
    );
  }

  Widget _buildServiceDetailsView() {
    final service = _serviceDetails!;

    return Column(
      children: [
        // Using PageHeader instead of custom BusinessHeader for consistency or custom header?
        // Let's use PageHeader but customized or similar structure.
        // BusinessDetailsPage used BusinessHeader. I'll stick to PageHeader for now or create a ServiceHeader if needed.
        // PageHeader doesn't support status indicator easily. I'll recreate the header part manually or reuse PageHeader and add content below.
        
        BusinessHeader(
          businessName: service.name,
          tagline: service.townName,
          statusIndicator: _buildStatusIndicator(service),
        ),

        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildServiceInfoCard(service),
              ),

              if (service.images.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildImageGallery(service.images),
                ),

              SliverToBoxAdapter(
                child: _buildOperatingHoursSection(service.operatingHours),
              ),

              SliverToBoxAdapter(
                child: _buildAttributesSection(service),
              ),

              SliverToBoxAdapter(
                child: _buildContactActionsSection(service),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(ServiceDetailDto service) {
    final theme = Theme.of(context);
    final isCurrentlyOpen = _isServiceCurrentlyOpen(service.operatingHours);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      color: isCurrentlyOpen 
          ? const Color(0xFFE8F5E9) 
          : const Color(0xFFFFEBEE),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.access_time_filled,
            size: 18,
            color: isCurrentlyOpen
                ? const Color(0xFF2E7D32)
                : const Color(0xFFC62828),
          ),
          const SizedBox(width: 8),
          Text(
            isCurrentlyOpen ? 'Open Now' : 'Closed',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isCurrentlyOpen
                  ? const Color(0xFF1B5E20)
                  : const Color(0xFFB71C1C),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceInfoCard(ServiceDetailDto service) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (service.description.isNotEmpty)
                Text(
                  service.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              
              if (service.serviceArea != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.map, size: 20, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Service Area: ${service.serviceArea}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttributesSection(ServiceDetailDto service) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final attributes = [
      if (service.emergencyService) 'Emergency Service Available',
      if (service.mobileService) 'Mobile Service',
      if (service.onSiteService) 'On-Site Service',
      if (service.offersQuotes) 'Free Quotes',
      if (service.availableWeekends) 'Weekend Availability',
      if (service.availableAfterHours) 'After Hours Availability',
    ];

    if (attributes.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: attributes.map((attr) => Chip(
          label: Text(attr),
          backgroundColor: colorScheme.surfaceContainerHighest,
          labelStyle: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide.none,
        )).toList(),
      ),
    );
  }

  Widget _buildImageGallery(List<ServiceImageDto> images) {
     final sortedImages = [...images]..sort((a, b) {
      return (a.sortOrder).compareTo(b.sortOrder);
    });

    return Container(
      height: 250,
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: PageView.builder(
        itemCount: sortedImages.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                UrlUtils.resolveImageUrl(sortedImages[index].url),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOperatingHoursSection(List<ServiceOperatingHourDto> operatingHours) {
    // Reuse similar logic to BusinessDetailsPage but adapted for ServiceOperatingHourDto
    // Implementation omitted for brevity, similar structure
    // But I will implement a simple version
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (operatingHours.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                children: [
                  Icon(Icons.access_time, size: 24, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Operating Hours',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...operatingHours.map((hour) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        _formatDayOfWeek(hour.dayOfWeek),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        hour.isAvailable && hour.startTime != null && hour.endTime != null
                            ? '${_formatTime(hour.startTime!)} - ${_formatTime(hour.endTime!)}'
                            : 'Closed',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: hour.isAvailable ? colorScheme.onSurfaceVariant : colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactActionsSection(ServiceDetailDto service) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        children: [
          if (service.phoneNumber.isNotEmpty)
            _buildFullWidthActionButton(
              icon: Icons.phone,
              label: 'Call',
              onPressed: () => _launchUrl('tel:${service.phoneNumber}'),
              color: Colors.green,
            ),
          if (service.phoneNumber2 != null && service.phoneNumber2!.isNotEmpty)
             _buildFullWidthActionButton(
              icon: Icons.phone,
              label: 'Call Alternative',
              onPressed: () => _launchUrl('tel:${service.phoneNumber2}'),
              color: Colors.green.shade700,
            ),
          if (service.emailAddress != null)
            _buildFullWidthActionButton(
              icon: Icons.email,
              label: 'Email',
              onPressed: () => _launchUrl('mailto:${service.emailAddress}'),
              color: Colors.blue,
            ),
          if (service.website != null)
            _buildFullWidthActionButton(
              icon: Icons.language,
              label: 'Visit Website',
              onPressed: () => _launchUrl(service.website!),
              color: Colors.purple,
            ),
        ],
      ),
    );
  }

  Widget _buildFullWidthActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    // Basic implementation
    try {
      final url = Uri.parse(urlString.startsWith('http') || urlString.startsWith('tel') || urlString.startsWith('mailto') 
          ? urlString 
          : 'https://$urlString');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } catch (_) {}
  }

  bool _isServiceCurrentlyOpen(List<ServiceOperatingHourDto> hours) {
    // Simplified logic
    return false; // Placeholder
  }

  String _formatDayOfWeek(int day) {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    if (day >= 0 && day < days.length) return days[day];
    return '';
  }

  String _formatTime(String time) {
    // Basic formatting
    return time;
  }
}

