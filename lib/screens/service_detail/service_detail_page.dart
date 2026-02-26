import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../core/utils/external_link_launcher.dart';
import '../../core/utils/service_utils.dart';
import '../../core/utils/url_utils.dart';
import '../../models/models.dart';
import 'service_detail_state.dart';
import 'service_detail_view_model.dart';

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
    final state = viewModel.state;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: state is ServiceDetailSuccess
                  ? state.serviceDetails.name
                  : viewModel.serviceName,
              subtitle: 'Service Details',
              height: 112.0,
              headerType: HeaderType.service,
            ),
            if (state is ServiceDetailSuccess)
              _TopStatusBar(service: state.serviceDetails),
            Expanded(
              child: _buildContent(context, state, viewModel),
            ),
            const BackNavigationFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ServiceDetailState state,
    ServiceDetailViewModel viewModel,
  ) {
    return switch (state) {
      ServiceDetailLoading() => const _ServiceDetailsLoadingView(),
      ServiceDetailSuccess(serviceDetails: final serviceDetails) => _ServiceDetailBody(
        service: serviceDetails,
        viewModel: viewModel,
      ),
      ServiceDetailError(title: final title, message: final message) => _ErrorStateView(
        title: title,
        message: message,
      ),
    };
  }
}

class _ErrorStateView extends StatelessWidget {
  final String title;
  final String message;

  const _ErrorStateView({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
}

class _ServiceDetailsLoadingView extends StatelessWidget {
  const _ServiceDetailsLoadingView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
      children: [
        _LoadingBlock(height: 106, color: colorScheme.surfaceContainerHigh),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, _) => SizedBox(
              width: 142,
              child: _LoadingBlock(
                height: 96,
                color: colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _LoadingBlock(height: 160, color: colorScheme.surfaceContainerLow),
      ],
    );
  }
}

class _ServiceDetailBody extends StatelessWidget {
  final ServiceDetailDto service;
  final ServiceDetailViewModel viewModel;

  const _ServiceDetailBody({
    required this.service,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final description = (service.shortDescription?.trim().isNotEmpty == true)
        ? service.shortDescription!.trim()
        : service.description.trim();

    final serviceTags = <String>[
      if (service.serviceArea?.trim().isNotEmpty == true) service.serviceArea!.trim(),
      if (service.priceRange?.trim().isNotEmpty == true) service.priceRange!.trim(),
      if (service.hourlyRate != null) 'R${service.hourlyRate!.toStringAsFixed(0)}/hr',
      if (service.offersQuotes) 'Quotes',
      if (service.mobileService) 'Mobile',
      if (service.onSiteService) 'On-site',
      if (service.availableWeekends) 'Weekends',
      if (service.availableAfterHours) 'After Hours',
      if (service.emergencyService) 'Emergency',
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer.withValues(alpha: 0.72),
                colorScheme.tertiaryContainer.withValues(alpha: 0.45),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Text(
            description.isEmpty ? 'No description available yet.' : description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                  color: colorScheme.onSurface.withValues(alpha: 0.88),
                ),
          ),
        ),
        if (service.images.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SectionShell(
            title: 'Gallery',
            icon: Icons.photo_library_outlined,
            child: SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: service.images.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final allUrls = service.images
                      .map((img) => UrlUtils.resolveImageUrl(img.url))
                      .toList();
                  return _GalleryTile(
                    image: service.images[index],
                    allImageUrls: allUrls,
                    index: index,
                  );
                },
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        _SectionShell(
          title: 'Operating Hours',
          icon: Icons.schedule,
          child: _ServiceHoursGrid(operatingHours: service.operatingHours),
        ),
        const SizedBox(height: 12),
        _SectionShell(
          title: 'Quick Actions',
          icon: Icons.bolt_rounded,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _QuickActionIconButton(
                tooltip: 'Call',
                icon: Icons.call_rounded,
                color: const Color(0xFFE8F5E9),
                iconColor: const Color(0xFF2E7D32),
                onPressed: () => ExternalLinkLauncher.callPhone(context, service.phoneNumber),
              ),
              if (service.phoneNumber2?.trim().isNotEmpty == true)
                _QuickActionIconButton(
                  tooltip: 'Call Alternative',
                  icon: Icons.call_split_rounded,
                  color: const Color(0xFFDDEEE0),
                  iconColor: const Color(0xFF1B5E20),
                  onPressed: () => ExternalLinkLauncher.callPhone(
                    context,
                    service.phoneNumber2!,
                  ),
                ),
              if (service.emailAddress?.trim().isNotEmpty == true)
                _QuickActionIconButton(
                  tooltip: 'Email',
                  icon: Icons.mail_rounded,
                  color: const Color(0xFFE3F2FD),
                  iconColor: const Color(0xFF1565C0),
                  onPressed: () =>
                      ExternalLinkLauncher.sendEmail(context, service.emailAddress!),
                ),
              if (service.website?.trim().isNotEmpty == true)
                _QuickActionIconButton(
                  tooltip: 'Website',
                  icon: Icons.language_rounded,
                  color: const Color(0xFFF3E5F5),
                  iconColor: const Color(0xFF6A1B9A),
                  onPressed: () =>
                      ExternalLinkLauncher.openWebsite(context, service.website!),
                ),
              if (service.latitude != null && service.longitude != null)
                _QuickActionIconButton(
                  tooltip: 'Take Me There',
                  icon: Icons.directions_rounded,
                  color: const Color(0xFFE0F2F1),
                  iconColor: const Color(0xFF00695C),
                  onPressed: () => _openMaps(context),
                ),
              _QuickActionIconButton(
                tooltip: 'Rate Service',
                icon: Icons.star_rounded,
                color: const Color(0xFFFFF3E0),
                iconColor: const Color(0xFFEF6C00),
                onPressed: () => viewModel.rateService(context, service),
              ),
            ],
          ),
        ),
        if (service.facebook?.trim().isNotEmpty == true ||
            service.instagram?.trim().isNotEmpty == true ||
            service.whatsApp?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 12),
          _SectionShell(
            title: 'Social',
            icon: Icons.share_outlined,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (service.facebook?.trim().isNotEmpty == true)
                  _SocialIconButton(
                    icon: FontAwesomeIcons.facebookF,
                    color: const Color(0xFF1877F2),
                    onPressed: () =>
                        ExternalLinkLauncher.openRaw(context, service.facebook!),
                  ),
                if (service.instagram?.trim().isNotEmpty == true)
                  _SocialIconButton(
                    icon: FontAwesomeIcons.instagram,
                    color: const Color(0xFFC13584),
                    onPressed: () =>
                        ExternalLinkLauncher.openRaw(context, service.instagram!),
                  ),
                if (service.whatsApp?.trim().isNotEmpty == true)
                  _SocialIconButton(
                    icon: FontAwesomeIcons.whatsapp,
                    color: const Color(0xFF25D366),
                    onPressed: () =>
                        ExternalLinkLauncher.openRaw(context, service.whatsApp!),
                  ),
              ],
            ),
          ),
        ],
        if (serviceTags.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SectionShell(
            title: 'Services & Features',
            icon: Icons.grid_view_rounded,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: serviceTags
                  .take(9)
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => viewModel.openFullServiceDetails(context, service),
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('View full details and reviews on web'),
          ),
        ),
      ],
    );
  }

  Future<void> _openMaps(BuildContext context) async {
    if (service.latitude == null || service.longitude == null) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${service.latitude},${service.longitude}',
    );
    await ExternalLinkLauncher.openUri(
      context,
      uri,
      failureMessage: 'Unable to open maps',
    );
  }
}

class _TopStatusBar extends StatelessWidget {
  final ServiceDetailDto service;

  const _TopStatusBar({required this.service});

  @override
  Widget build(BuildContext context) {
    final openNow = ServiceUtils.isServiceCurrentlyOpen(service.operatingHours);
    final bg = openNow ? const Color(0xFFE9F7EF) : const Color(0xFF3A3A3A);
    final fg = openNow ? const Color(0xFF1D7A38) : Colors.white;
    final secondary = openNow
        ? ServiceUtils.getClosingTimeText(service.operatingHours)
        : 'Currently closed';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: openNow ? const Color(0xFFBFE5CB) : const Color(0xFF4A4A4A),
        ),
      ),
      child: Column(
        children: [
          Text(
            openNow ? 'Open Now' : 'Closed',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (secondary.isNotEmpty)
            Text(
              secondary,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: fg.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w600,
                  ),
            ),
        ],
      ),
    );
  }
}

class _SectionShell extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionShell({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  final ServiceImageDto image;
  final List<String> allImageUrls;
  final int index;

  const _GalleryTile({
    required this.image,
    required this.allImageUrls,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedUrl = UrlUtils.resolveImageUrl(image.url);

    return TappableImage(
      imageUrls: allImageUrls,
      initialIndex: index,
      heroTag: 'service_gallery_$index',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 158,
          color: colorScheme.surfaceContainerHighest,
          child: Image.network(
            resolvedUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: colorScheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Loading image...',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              );
            },
            errorBuilder: (context, _, _) {
              return Container(
                color: colorScheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ServiceHoursGrid extends StatelessWidget {
  final List<ServiceOperatingHourDto> operatingHours;

  const _ServiceHoursGrid({required this.operatingHours});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const orderedDays = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final today = orderedDays[DateTime.now().weekday - 1];

    final byDay = <String, ServiceOperatingHourDto>{
      for (final hour in operatingHours)
        ServiceUtils.formatDayOfWeek(hour.dayOfWeek): hour,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: orderedDays.map((day) {
            final match = byDay[day];
            final isAvailable = match?.isAvailable == true &&
                match?.startTime != null &&
                match?.endTime != null;
            final timeLabel = isAvailable
                ? '${ServiceUtils.formatTime24(match!.startTime!)} - ${ServiceUtils.formatTime24(match.endTime!)}'
                : 'Closed';
            final isToday = day == today;

            return SizedBox(
              width: tileWidth,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isToday
                      ? colorScheme.primary.withValues(alpha: 0.10)
                      : colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isToday
                        ? colorScheme.primary.withValues(alpha: 0.45)
                        : colorScheme.outline.withValues(alpha: 0.16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        day.substring(0, 3),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isToday ? colorScheme.primary : null,
                            ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        timeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _QuickActionIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onPressed;

  const _QuickActionIconButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 56,
        height: 56,
        child: IconButton(
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: Icon(icon, size: 24, color: iconColor),
        ),
      ),
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _SocialIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: IconButton(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: FaIcon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  final double height;
  final Color color;

  const _LoadingBlock({
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}