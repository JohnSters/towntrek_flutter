import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../core/utils/external_link_launcher.dart';
import '../../core/utils/service_utils.dart';
import '../../core/utils/url_utils.dart';
import '../../models/models.dart';
import '../shared/detail_widgets/detail_widgets.dart';
import 'service_detail_state.dart';
import 'service_detail_view_model.dart';

/// Short summary plus full description when both exist and differ.
String _combinedServiceDescription(ServiceDetailDto service) {
  final short = service.shortDescription?.trim();
  final long = service.description.trim();
  if (long.isNotEmpty) {
    if (short != null && short.isNotEmpty && short != long) {
      return '$short\n\n$long';
    }
    return long;
  }
  if (short != null && short.isNotEmpty) return short;
  return '';
}

List<String> _serviceFeatureTagList(ServiceDetailDto service) {
  return [
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
}

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
      backgroundColor: context.entityListing.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _ServiceDetailHero(state: state, viewModel: viewModel),
            if (state is ServiceDetailSuccess)
              _ServiceOpenClosedBanner(service: state.serviceDetails),
            Expanded(
              child: _ServiceDetailStateBody(state: state, viewModel: viewModel),
            ),
            const ListingBackFooter(label: 'Back'),
          ],
        ),
      ),
    );
  }
}

class _ServiceDetailHero extends StatelessWidget {
  const _ServiceDetailHero({
    required this.state,
    required this.viewModel,
  });

  final ServiceDetailState state;
  final ServiceDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final title = switch (state) {
      ServiceDetailSuccess(:final serviceDetails) => serviceDetails.name,
      _ => viewModel.serviceName,
    };
    final categoryLine = switch (state) {
      ServiceDetailSuccess(:final serviceDetails) =>
        serviceDetails.categoryName ?? 'Service',
      _ => 'Service',
    };
    final townLine = switch (state) {
      ServiceDetailSuccess(:final serviceDetails) => serviceDetails.townName,
      _ => 'Details',
    };
    return EntityListingHeroHeader(
      theme: context.entityListingTheme,
      categoryIcon: Icons.handyman_rounded,
      subCategoryName: title,
      categoryName: categoryLine,
      townName: townLine,
    );
  }
}

class _ServiceDetailStateBody extends StatelessWidget {
  const _ServiceDetailStateBody({
    required this.state,
    required this.viewModel,
  });

  final ServiceDetailState state;
  final ServiceDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
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
        DetailLoadingBlock(height: 106, color: colorScheme.surfaceContainerHigh),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, _) => SizedBox(
              width: 142,
              child: DetailLoadingBlock(
                height: 96,
                color: colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        DetailLoadingBlock(height: 160, color: colorScheme.surfaceContainerLow),
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
    final description = _combinedServiceDescription(service);
    final serviceTags = _serviceFeatureTagList(service);
    final hasSocial = service.facebook?.trim().isNotEmpty == true ||
        service.instagram?.trim().isNotEmpty == true ||
        service.whatsApp?.trim().isNotEmpty == true;

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
      children: [
        CollapsibleGradientDescriptionCard(
          bodyText: description,
          headerLabel: 'About',
          gradientColors: [
            colorScheme.primaryContainer.withValues(alpha: 0.72),
            colorScheme.tertiaryContainer.withValues(alpha: 0.45),
          ],
        ),
        const SizedBox(height: 12),
        _ServiceDetailQuickActionsSection(
          service: service,
          viewModel: viewModel,
        ),
        if (serviceTags.isNotEmpty) ...[
          const SizedBox(height: 12),
          DetailSectionShell(
            title: 'Services & Features',
            icon: Icons.grid_view_rounded,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: serviceTags
                  .take(9)
                  .map((tag) => DetailMetadataTag(label: tag))
                  .toList(),
            ),
          ),
        ],
        if (service.images.isNotEmpty) ...[
          const SizedBox(height: 12),
          DetailSectionShell(
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
        if (hasSocial) ...[
          const SizedBox(height: 12),
          _ServiceDetailSocialSection(service: service),
        ],
        const SizedBox(height: 12),
        DetailSectionShell(
          title: 'Operating Hours',
          icon: Icons.schedule,
          child: DetailHoursGrid(
            rows: detailHoursFromService(service.operatingHours),
          ),
        ),
      ],
    );
  }
}

class _ServiceDetailQuickActionsSection extends StatelessWidget {
  const _ServiceDetailQuickActionsSection({
    required this.service,
    required this.viewModel,
  });

  final ServiceDetailDto service;
  final ServiceDetailViewModel viewModel;

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

  @override
  Widget build(BuildContext context) {
    final qa = context.detailQuickActions;
    return DetailSectionShell(
      title: 'Quick Actions',
      icon: Icons.bolt_rounded,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          DetailQuickActionButton(
            tooltip: DetailTownTrekWebAction.tooltip,
            assetImagePath: DetailTownTrekWebAction.assetPath,
            backgroundColor: qa.towntrekWebBackground,
            iconColor: qa.websiteIcon,
            onPressed: () => viewModel.openFullServiceDetails(context, service),
          ),
          if (service.latitude != null && service.longitude != null)
            DetailQuickActionButton(
              tooltip: 'Take Me There',
              icon: Icons.directions_rounded,
              backgroundColor: qa.directionsBackground,
              iconColor: qa.directionsIcon,
              onPressed: () => _openMaps(context),
            ),
          if (service.phoneNumber.trim().isNotEmpty)
            DetailQuickActionButton(
              tooltip: 'Call',
              icon: Icons.call_rounded,
              backgroundColor: qa.callBackground,
              iconColor: qa.callIcon,
              onPressed: () =>
                  ExternalLinkLauncher.callPhone(context, service.phoneNumber),
            ),
          if (service.phoneNumber2?.trim().isNotEmpty == true)
            DetailQuickActionButton(
              tooltip: 'Call Alternative',
              icon: Icons.call_split_rounded,
              backgroundColor: qa.callAltBackground,
              iconColor: qa.callAltIcon,
              onPressed: () => ExternalLinkLauncher.callPhone(
                context,
                service.phoneNumber2!,
              ),
            ),
          if (service.emailAddress?.trim().isNotEmpty == true)
            DetailQuickActionButton(
              tooltip: 'Email',
              icon: Icons.mail_rounded,
              backgroundColor: qa.emailBackground,
              iconColor: qa.emailIcon,
              onPressed: () =>
                  ExternalLinkLauncher.sendEmail(context, service.emailAddress!),
            ),
          if (service.website?.trim().isNotEmpty == true)
            DetailQuickActionButton(
              tooltip: 'Website',
              icon: Icons.language_rounded,
              backgroundColor: qa.websiteBackground,
              iconColor: qa.websiteIcon,
              onPressed: () =>
                  ExternalLinkLauncher.openWebsite(context, service.website!),
            ),
          DetailQuickActionButton(
            tooltip: 'Rate Service',
            icon: Icons.star_rounded,
            backgroundColor: qa.rateBackground,
            iconColor: qa.rateIcon,
            onPressed: () => viewModel.rateService(context, service),
          ),
        ],
      ),
    );
  }
}

class _ServiceDetailSocialSection extends StatelessWidget {
  const _ServiceDetailSocialSection({required this.service});

  final ServiceDetailDto service;

  @override
  Widget build(BuildContext context) {
    final qa = context.detailQuickActions;
    return DetailSectionShell(
      title: 'Social',
      icon: Icons.share_outlined,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          if (service.facebook?.trim().isNotEmpty == true)
            DetailSocialIconButton(
              tooltip: 'Facebook',
              icon: FontAwesomeIcons.facebookF,
              backgroundColor: qa.facebookBackground,
              iconColor: qa.facebookIcon,
              onPressed: () =>
                  ExternalLinkLauncher.openRaw(context, service.facebook!),
            ),
          if (service.instagram?.trim().isNotEmpty == true)
            DetailSocialIconButton(
              tooltip: 'Instagram',
              icon: FontAwesomeIcons.instagram,
              backgroundColor: qa.instagramBackground,
              iconColor: qa.instagramIcon,
              onPressed: () =>
                  ExternalLinkLauncher.openRaw(context, service.instagram!),
            ),
          if (service.whatsApp?.trim().isNotEmpty == true)
            DetailSocialIconButton(
              tooltip: 'WhatsApp',
              icon: FontAwesomeIcons.whatsapp,
              backgroundColor: qa.whatsappBackground,
              iconColor: qa.whatsappIcon,
              onPressed: () =>
                  ExternalLinkLauncher.openRaw(context, service.whatsApp!),
            ),
        ],
      ),
    );
  }
}

class _ServiceOpenClosedBanner extends StatelessWidget {
  final ServiceDetailDto service;

  const _ServiceOpenClosedBanner({required this.service});

  @override
  Widget build(BuildContext context) {
    final openNow = ServiceUtils.isServiceCurrentlyOpen(service.operatingHours);

    return EntityOpenClosedBanner(
      isOpen: openNow,
      viewCount: service.viewCount,
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
