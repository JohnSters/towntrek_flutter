import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../core/utils/business_utils.dart';
import '../../core/utils/external_link_launcher.dart';
import '../../core/utils/url_utils.dart';
import '../../models/models.dart';
import 'business_details_state.dart';
import 'business_details_view_model.dart';

class BusinessDetailsPage extends StatelessWidget {
  final int businessId;
  final String businessName;

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
    final state = viewModel.state;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: state is BusinessDetailsSuccess
                  ? state.business.name
                  : viewModel.businessName,
              subtitle: 'Business Details',
              height: 112.0,
              headerType: HeaderType.business,
            ),
            if (state is BusinessDetailsSuccess)
              _TopStatusBar(business: state.business),
            Expanded(
              child: _buildContent(context, state, viewModel),
            ),
            if (state is BusinessDetailsSuccess) const BackNavigationFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    BusinessDetailsState state,
    BusinessDetailsViewModel viewModel,
  ) {
    return switch (state) {
      BusinessDetailsLoading() => const _BusinessDetailsLoadingView(),
      BusinessDetailsError(error: final error) => ErrorView(error: error),
      BusinessDetailsSuccess(business: final business) => _BusinessDetailsBody(
        business: business,
        viewModel: viewModel,
      ),
    };
  }
}

class _BusinessDetailsLoadingView extends StatelessWidget {
  const _BusinessDetailsLoadingView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
      children: [
        _LoadingBlock(height: 112, color: colorScheme.surfaceContainerHigh),
        const SizedBox(height: 12),
        _LoadingBlock(height: 84, color: colorScheme.surfaceContainerLow),
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

class _BusinessDetailsBody extends StatelessWidget {
  final BusinessDetailDto business;
  final BusinessDetailsViewModel viewModel;

  const _BusinessDetailsBody({
    required this.business,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final availableServices = business.services
        .where((service) => service.isAvailable)
        .map((service) => service.serviceType)
        .toList();

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
                colorScheme.secondaryContainer.withValues(alpha: 0.50),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                business.description.trim().isEmpty
                    ? 'No description available yet.'
                    : business.description.trim(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color: colorScheme.onSurface.withValues(alpha: 0.88),
                    ),
              ),
            ],
          ),
        ),
        if (business.images.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SectionShell(
            title: 'Gallery',
            icon: Icons.photo_library_outlined,
            child: SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: business.images.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return _GalleryTile(image: business.images[index]);
                },
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        _SectionShell(
          title: 'Operating Hours',
          icon: Icons.schedule,
          child: _HoursGrid(operatingHours: business.operatingHours),
        ),
        const SizedBox(height: 12),
        _SectionShell(
          title: 'Quick Actions',
          icon: Icons.bolt_rounded,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (business.latitude != null && business.longitude != null)
                _QuickActionIconButton(
                  tooltip: 'Take Me There',
                  icon: Icons.directions_rounded,
                  color: const Color(0xFFE0F2F1),
                  iconColor: const Color(0xFF00695C),
                  onPressed: () => viewModel.navigateToBusiness(context, business),
                ),
              if (business.phoneNumber != null)
                _QuickActionIconButton(
                  tooltip: 'Call',
                  icon: Icons.call_rounded,
                  color: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF2E7D32),
                  onPressed: () => ExternalLinkLauncher.callPhone(context, business.phoneNumber!),
                ),
              if (business.emailAddress != null)
                _QuickActionIconButton(
                  tooltip: 'Email',
                  icon: Icons.mail_rounded,
                  color: const Color(0xFFE3F2FD),
                  iconColor: const Color(0xFF1565C0),
                  onPressed: () => ExternalLinkLauncher.sendEmail(context, business.emailAddress!),
                ),
              if (business.website != null)
                _QuickActionIconButton(
                  tooltip: 'Website',
                  icon: Icons.language_rounded,
                  color: const Color(0xFFF3E5F5),
                  iconColor: const Color(0xFF6A1B9A),
                  onPressed: () => ExternalLinkLauncher.openWebsite(context, business.website!),
                ),
              _QuickActionIconButton(
                tooltip: 'Rate Business',
                icon: Icons.star_rounded,
                color: const Color(0xFFFFF3E0),
                iconColor: const Color(0xFFEF6C00),
                onPressed: () => viewModel.rateBusiness(context, business),
              ),
            ],
          ),
        ),
        if (business.facebook != null || business.instagram != null || business.whatsApp != null) ...[
          const SizedBox(height: 12),
          _SectionShell(
            title: 'Social',
            icon: Icons.share_outlined,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (business.facebook != null)
                  _SocialIconButton(
                    icon: FontAwesomeIcons.facebookF,
                    color: const Color(0xFF1877F2),
                    onPressed: () => ExternalLinkLauncher.openRaw(context, business.facebook!),
                  ),
                if (business.instagram != null)
                  _SocialIconButton(
                    icon: FontAwesomeIcons.instagram,
                    color: const Color(0xFFC13584),
                    onPressed: () => ExternalLinkLauncher.openRaw(context, business.instagram!),
                  ),
                if (business.whatsApp != null)
                  _SocialIconButton(
                    icon: FontAwesomeIcons.whatsapp,
                    color: const Color(0xFF25D366),
                    onPressed: () => ExternalLinkLauncher.openRaw(context, business.whatsApp!),
                  ),
              ],
            ),
          ),
        ],
        if (availableServices.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SectionShell(
            title: 'Services & Features',
            icon: Icons.grid_view_rounded,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableServices
                  .take(8)
                  .map(
                    (serviceType) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Text(
                        serviceType,
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
            onPressed: () => viewModel.openFullBusinessDetails(context, business),
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('View full details and reviews on web'),
          ),
        ),
      ],
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

class _TopStatusBar extends StatelessWidget {
  final BusinessDetailDto business;

  const _TopStatusBar({required this.business});

  @override
  Widget build(BuildContext context) {
    final openNow =
        business.isOpenNow ?? BusinessUtils.isBusinessCurrentlyOpen(business.operatingHours);
    final bg = openNow ? const Color(0xFFE9F7EF) : const Color(0xFF3A3A3A);
    final fg = openNow ? const Color(0xFF1D7A38) : Colors.white;
    final secondary = business.openNowText?.trim().isNotEmpty == true
        ? business.openNowText!
        : (openNow ? BusinessUtils.getClosingTime(business.operatingHours) : 'Currently closed');

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

class _GalleryTile extends StatelessWidget {
  final BusinessImageDto image;

  const _GalleryTile({required this.image});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedUrl = UrlUtils.resolveImageUrl(image.url);

    return ClipRRect(
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
    );
  }
}

class _HoursGrid extends StatelessWidget {
  final List<OperatingHourDto> operatingHours;

  const _HoursGrid({required this.operatingHours});

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

    final normalized = operatingHours
        .where((hour) => !hour.isSpecialHours)
        .map(
          (hour) => MapEntry(
            BusinessUtils.formatDayOfWeek(hour.dayOfWeek),
            hour,
          ),
        )
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: orderedDays.map((day) {
            final match = normalized
                .where((entry) => entry.key == day)
                .map((entry) => entry.value)
                .cast<OperatingHourDto?>()
                .firstWhere((_) => true, orElse: () => null);

            final isOpen = match?.isOpen == true &&
                match?.openTime != null &&
                match?.closeTime != null;
            final timeLabel = isOpen
                ? '${BusinessUtils.formatTime(match!.openTime!)} - ${BusinessUtils.formatTime(match.closeTime!)}'
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

