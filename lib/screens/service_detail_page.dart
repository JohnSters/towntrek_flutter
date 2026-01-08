import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/core.dart';
import '../models/models.dart';
import '../core/constants/service_detail_constants.dart';
import 'service_detail/service_detail_state.dart';
import 'service_detail/service_detail_view_model.dart';
import 'service_detail/widgets/widgets.dart';

/// Service Detail Page - Shows comprehensive service information
/// Uses Provider pattern with ViewModel and sealed classes for clean architecture
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
    return Consumer<ServiceDetailViewModel>(
      builder: (context, viewModel, child) {
        final state = viewModel.state;

        if (state is ServiceDetailLoading) {
          return ServiceDetailLoadingView(serviceName: viewModel.serviceName);
        }

        if (state is ServiceDetailError) {
          return ServiceDetailErrorView(
            serviceName: viewModel.serviceName,
            error: state.message,
          );
        }

        if (state is ServiceDetailSuccess) {
          return _buildServiceDetailsView(context, state);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildServiceDetailsView(
    BuildContext context,
    ServiceDetailSuccess state,
  ) {
    final service = state.serviceDetails;

    return Column(
      children: [
        // Service header with status indicator
        BusinessHeader(
          businessName: service.name,
          tagline: service.townName,
          statusIndicator: _buildStatusIndicator(service),
        ),

        // Scrollable content
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ServiceInfoCard(service: service),
              ),

              if (service.images.isNotEmpty)
                SliverToBoxAdapter(
                  child: ServiceImageGallery(images: service.images),
                ),

              SliverToBoxAdapter(
                child: OperatingHoursSection(operatingHours: service.operatingHours),
              ),

              SliverToBoxAdapter(
                child: ContactActionsSection(service: service),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: ServiceDetailConstants.bottomSpacing),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(ServiceDetailDto service) {
    final isCurrentlyOpen = _isServiceCurrentlyOpen(service.operatingHours);
    final closingText = isCurrentlyOpen ? _getServiceClosingTimeText(service.operatingHours) : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: ServiceDetailConstants.statusIndicatorPaddingVertical,
        horizontal: ServiceDetailConstants.statusIndicatorPaddingHorizontal,
      ),
      color: isCurrentlyOpen
          ? ServiceDetailConstants.openBackgroundColor
          : ServiceDetailConstants.closedBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            ServiceDetailConstants.statusIcon,
            size: ServiceDetailConstants.statusIconSize,
            color: isCurrentlyOpen
                ? ServiceDetailConstants.openIconColor
                : ServiceDetailConstants.closedIconColor,
          ),
          const SizedBox(width: ServiceDetailConstants.iconSpacing),
          Text(
            isCurrentlyOpen ? ServiceDetailConstants.openNowText : ServiceDetailConstants.closedText,
            style: TextStyle(
              fontWeight: ServiceDetailConstants.statusFontWeight,
              color: isCurrentlyOpen
                  ? ServiceDetailConstants.openTextColor
                  : ServiceDetailConstants.closedTextColor,
              letterSpacing: ServiceDetailConstants.letterSpacing,
            ),
          ),
          if (isCurrentlyOpen && closingText.isNotEmpty) ...[
            const SizedBox(width: ServiceDetailConstants.iconSpacing),
            Container(
              width: ServiceDetailConstants.statusDotSize,
              height: ServiceDetailConstants.statusDotSize,
              decoration: BoxDecoration(
                color: ServiceDetailConstants.dotColor.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: ServiceDetailConstants.iconSpacing),
            Text(
              closingText,
              style: TextStyle(
                fontWeight: ServiceDetailConstants.closingTimeFontWeight,
                color: ServiceDetailConstants.openIconColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isServiceCurrentlyOpen(List<ServiceOperatingHourDto> operatingHours) {
    final now = DateTime.now();
    final today = now.weekday; // 1 = Monday, 7 = Sunday

    final todayHours = operatingHours.where((h) => h.dayOfWeek == today).toList();
    if (todayHours.isEmpty) return false;

    final hour = todayHours.first;
    if (!hour.isAvailable || hour.startTime == null || hour.endTime == null) {
      return false;
    }

    final startTime = _parseTime(hour.startTime!);
    final endTime = _parseTime(hour.endTime!);

    final currentTime = TimeOfDay.fromDateTime(now);
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
  }

  String _getServiceClosingTimeText(List<ServiceOperatingHourDto> operatingHours) {
    final now = DateTime.now();
    final today = now.weekday;

    final todayHours = operatingHours.where((h) => h.dayOfWeek == today).toList();
    if (todayHours.isEmpty || !todayHours.first.isAvailable) return '';

    final hour = todayHours.first;
    if (hour.endTime == null) return '';

    return '${ServiceDetailConstants.closingTimePrefix} ${hour.endTime}';
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}