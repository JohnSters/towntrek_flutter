import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/core.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../core/widgets/error_view.dart';
import '../core/errors/app_error.dart';
import '../core/errors/error_handler.dart';
import '../core/utils/url_utils.dart';

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

    if (_businessDetails == null) {
      return _buildErrorView();
    }

    return _buildBusinessDetailsView();
  }

  Widget _buildLoadingView() {
    return Column(
      children: [
        _buildHeader(title: widget.businessName),
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
        _buildHeader(title: widget.businessName),
        Expanded(
          child: ErrorView(error: _error!),
        ),
      ],
    );
  }

  Widget _buildHeader({required String title}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Row(
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
            child: Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessDetailsView() {
    final business = _businessDetails!;

    return CustomScrollView(
      slivers: [
        // Header with business name and status
        SliverToBoxAdapter(
          child: _buildBusinessHeader(business),
        ),

        // Image Gallery
        if (business.images.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildImageGallery(business.images),
          ),

        // Operating Hours
        SliverToBoxAdapter(
          child: _buildOperatingHoursSection(business.operatingHours),
        ),

        // Reviews Section
        if (business.reviews.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildReviewsSection(business.reviews),
          ),

        // Contact & Actions
        SliverToBoxAdapter(
          child: _buildContactActionsSection(business),
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  Widget _buildBusinessHeader(BusinessDetailDto business) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCurrentlyOpen = _isBusinessCurrentlyOpen(business.operatingHours);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business Name
          Text(
            business.name,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 12),

          // Status Pill and Rating Row
          Row(
            children: [
              // Open/Closed Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isCurrentlyOpen
                      ? const Color(0xFFE8F5E8) // Light green
                      : const Color(0xFFFFEBEE), // Light red
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCurrentlyOpen
                        ? const Color(0xFF4CAF50) // Green
                        : const Color(0xFFF44336), // Red
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCurrentlyOpen ? Icons.circle : Icons.circle,
                      size: 8,
                      color: isCurrentlyOpen
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFF44336),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isCurrentlyOpen ? 'Open' : 'Closed',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isCurrentlyOpen
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Rating
              if (business.rating != null) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 18,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${business.rating!.toStringAsFixed(1)} (${business.totalReviews})',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Description
          if (business.description.isNotEmpty)
            Text(
              business.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),

          const SizedBox(height: 16),

          // Address
          if (business.physicalAddress != null)
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    business.physicalAddress!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(List<BusinessImageDto> images) {
    // Sort images with primary first, then by sort order
    final sortedImages = [...images]..sort((a, b) {
      if (a.isPrimary && !b.isPrimary) return -1;
      if (!a.isPrimary && b.isPrimary) return 1;
      return (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0);
    });

    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: sortedImages.length == 1
          ? _buildSingleImage(sortedImages.first)
          : _buildImageCarousel(sortedImages),
    );
  }

  Widget _buildSingleImage(BusinessImageDto image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        UrlUtils.resolveImageUrl(image.url),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.image_not_supported,
              size: 64,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageCarousel(List<BusinessImageDto> images) {
    return PageView.builder(
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(right: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              UrlUtils.resolveImageUrl(images[index].url),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildOperatingHoursSection(List<OperatingHourDto> operatingHours) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Group hours by regular and special
    final regularHours = operatingHours.where((h) => !h.isSpecialHours).toList();
    final specialHours = operatingHours.where((h) => h.isSpecialHours).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Operating Hours',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 16),

          // Regular Hours
          if (regularHours.isNotEmpty) ...[
            ...regularHours.map((hour) => _buildHourRow(hour)),
            const SizedBox(height: 16),
          ],

          // Special Hours
          if (specialHours.isNotEmpty) ...[
            Text(
              'Special Hours',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            ...specialHours.map((hour) => _buildHourRow(hour, isSpecial: true)),
          ],
        ],
      ),
    );
  }

  Widget _buildHourRow(OperatingHourDto hour, {bool isSpecial = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final dayName = _formatDayOfWeek(hour.dayOfWeek);
    final timeDisplay = hour.isOpen && hour.openTime != null && hour.closeTime != null
        ? '${_formatTime(hour.openTime!)} - ${_formatTime(hour.closeTime!)}'
        : 'Closed';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              dayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isSpecial ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Text(
              hour.isSpecialHours && hour.specialHoursNote != null
                  ? hour.specialHoursNote!
                  : timeDisplay,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: hour.isOpen ? colorScheme.onSurfaceVariant : colorScheme.error,
                fontStyle: hour.isSpecialHours ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(List<ReviewDto> reviews) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Text(
                'Reviews',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${reviews.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Reviews List
          ...reviews.take(3).map((review) => _buildReviewCard(review)),

          // Show more button if there are more reviews
          if (reviews.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to full reviews page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('View all reviews - Coming soon!')),
                  );
                },
                child: const Text('View All Reviews'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewDto review) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reviewer info and rating
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    review.userName.isNotEmpty ? review.userName[0].toUpperCase() : '?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (review.isVerified)
                        Text(
                          'Verified Review',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                // Star rating
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      size: 16,
                      color: index < review.rating ? Colors.amber : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    );
                  }),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Review comment
            if (review.comment != null && review.comment!.isNotEmpty)
              Text(
                review.comment!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),

            const SizedBox(height: 8),

            // Review date
            Text(
              _formatReviewDate(review.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactActionsSection(BusinessDetailDto business) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Contact & Actions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // Take Me There Button
              if (business.latitude != null && business.longitude != null)
                _buildActionButton(
                  icon: Icons.directions,
                  label: 'Take Me There',
                  onPressed: () => _launchDirections(business),
                ),

              // Contact Us Button
              if (business.phoneNumber != null)
                _buildActionButton(
                  icon: Icons.phone,
                  label: 'Call',
                  onPressed: () => _launchPhone(business.phoneNumber!),
                ),

              // Email Us Button
              if (business.emailAddress != null)
                _buildActionButton(
                  icon: Icons.email,
                  label: 'Email',
                  onPressed: () => _launchEmail(business.emailAddress!),
                ),

              // Website Button
              if (business.website != null)
                _buildActionButton(
                  icon: Icons.web,
                  label: 'Website',
                  onPressed: () => _launchWebsite(business.website!),
                ),

              // Rate Business Button
              _buildActionButton(
                icon: Icons.star_border,
                label: 'Rate Business',
                onPressed: () => _rateBusiness(business),
              ),
            ],
          ),

          // Social Media Links
          if (_hasSocialMedia(business)) ...[
            const SizedBox(height: 24),
            Text(
              'Follow Us',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                if (business.facebook != null)
                  _buildSocialButton(
                    icon: Icons.facebook,
                    onPressed: () => _launchUrl(business.facebook!),
                  ),
                if (business.instagram != null)
                  _buildSocialButton(
                    icon: Icons.camera_alt, // Instagram-like icon
                    onPressed: () => _launchUrl(business.instagram!),
                  ),
                if (business.whatsApp != null)
                  _buildSocialButton(
                    icon: Icons.message,
                    onPressed: () => _launchUrl(business.whatsApp!),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surfaceContainerHighest,
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  // ===== UTILITY METHODS =====

  bool _isBusinessCurrentlyOpen(List<OperatingHourDto> operatingHours) {
    final now = DateTime.now();
    final currentDay = DateFormat('EEEE').format(now); // Monday, Tuesday, etc.
    final currentTime = DateFormat('HH:mm').format(now);

    // Find today's operating hours
    final todayHours = operatingHours.firstWhere(
      (hour) => _formatDayOfWeek(hour.dayOfWeek) == currentDay && !hour.isSpecialHours,
      orElse: () => OperatingHourDto(
        dayOfWeek: currentDay,
        isOpen: false,
        isSpecialHours: false,
      ),
    );

    if (!todayHours.isOpen || todayHours.openTime == null || todayHours.closeTime == null) {
      return false;
    }

    // Check if current time is within operating hours
    return currentTime.compareTo(todayHours.openTime!) >= 0 &&
           currentTime.compareTo(todayHours.closeTime!) <= 0;
  }

  String _formatDayOfWeek(String dayOfWeek) {
    // Handle numeric day values (1-7) from API
    final dayNames = [
      '', // 0-indexed, not used
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    // If it's a numeric string, convert to day name
    final dayNumber = int.tryParse(dayOfWeek);
    if (dayNumber != null && dayNumber >= 1 && dayNumber <= 7) {
      return dayNames[dayNumber];
    }

    // Fallback: if it's already a full day name, just capitalize first letter
    if (dayOfWeek.length > 3) {
      return dayOfWeek.substring(0, 1).toUpperCase() + dayOfWeek.substring(1).toLowerCase();
    }

    // Unknown format, return as-is
    return dayOfWeek;
  }

  String _formatTime(String time) {
    // Assuming time is in HH:mm format, convert to 12-hour format
    try {
      final timeParts = time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = timeParts[1];

      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

      return '$displayHour:$minute $period';
    } catch (e) {
      return time;
    }
  }

  String _formatReviewDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  bool _hasSocialMedia(BusinessDetailDto business) {
    return business.facebook != null ||
           business.instagram != null ||
           business.whatsApp != null;
  }

  // ===== ACTION METHODS =====

  Future<void> _launchDirections(BusinessDetailDto business) async {
    if (business.latitude == null || business.longitude == null) return;

    // TODO: Implement Mapbox integration
    // For now, use Google Maps as fallback
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${business.latitude},${business.longitude}';
    await _launchUrl(url);
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    await _launchUrl(url);
  }

  Future<void> _launchEmail(String email) async {
    final url = 'mailto:$email';
    await _launchUrl(url);
  }

  Future<void> _launchWebsite(String website) async {
    final url = website.startsWith('http') ? website : 'https://$website';
    await _launchUrl(url);
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

  Future<void> _launchUrl(String urlString) async {
    try {
      final url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch $urlString')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid URL format')),
        );
      }
    }
  }
}
