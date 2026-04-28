import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../core/utils/external_link_launcher.dart';
import '../../core/utils/url_utils.dart';
import '../../models/models.dart';
import '../shared/detail_widgets/detail_widgets.dart';
import 'business_details_state.dart';
import 'business_details_view_model.dart';
import 'widgets/equipment_hire_rates_section.dart';

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
      backgroundColor: context.entityListing.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _BusinessDetailHero(state: state, viewModel: viewModel),
            if (state is BusinessDetailsSuccess) ...[
              _BusinessOpenClosedBanner(business: state.business),
              _BusinessSpecialClosedHint(business: state.business),
            ],
            Expanded(
              child: _BusinessDetailStateBody(state: state, viewModel: viewModel),
            ),
            const ListingBackFooter(label: 'Back'),
          ],
        ),
      ),
    );
  }
}

class _BusinessDetailHero extends StatelessWidget {
  const _BusinessDetailHero({
    required this.state,
    required this.viewModel,
  });

  final BusinessDetailsState state;
  final BusinessDetailsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final title = switch (state) {
      BusinessDetailsSuccess(:final business) => business.name,
      _ => viewModel.businessName,
    };
    final categoryLine = switch (state) {
      BusinessDetailsSuccess(:final business) => business.category,
      _ => 'Business',
    };
    return EntityListingHeroHeader(
      theme: context.entityListingTheme,
      categoryIcon: Icons.storefront_outlined,
      subCategoryName: title,
      categoryName: categoryLine,
      townName: 'Details',
    );
  }
}

class _BusinessDetailStateBody extends StatelessWidget {
  const _BusinessDetailStateBody({
    required this.state,
    required this.viewModel,
  });

  final BusinessDetailsState state;
  final BusinessDetailsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
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
        DetailLoadingBlock(height: 112, color: colorScheme.surfaceContainerHigh),
        const SizedBox(height: 12),
        DetailLoadingBlock(height: 84, color: colorScheme.surfaceContainerLow),
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

    final isEquipmentRental = business.category.toLowerCase() ==
        TownFeatureConstants.equipmentRentalsCategoryKey.toLowerCase();
    final hasSocial = business.facebook != null ||
        business.instagram != null ||
        business.whatsApp != null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
      children: [
        CollapsibleGradientDescriptionCard(
          bodyText: business.description.trim(),
          headerLabel: 'About',
          gradientColors: [
            colorScheme.primaryContainer.withValues(alpha: 0.72),
            colorScheme.secondaryContainer.withValues(alpha: 0.50),
          ],
        ),
        const SizedBox(height: 12),
        _BusinessDetailQuickActionsSection(
          business: business,
          viewModel: viewModel,
        ),
        if (isEquipmentRental) ...[
          const SizedBox(height: 12),
          DetailSectionShell(
            title: 'Hire rates',
            icon: Icons.construction_rounded,
            child: EquipmentHireRatesSection(business: business),
          ),
        ],
        if (business.images.isNotEmpty) ...[
          const SizedBox(height: 12),
          DetailSectionShell(
            title: 'Gallery',
            icon: Icons.photo_library_outlined,
            child: SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: business.images.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final allUrls = business.images
                      .map((img) => UrlUtils.resolveImageUrl(img.url))
                      .toList();
                  return _GalleryTile(
                    image: business.images[index],
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
          _BusinessDetailSocialSection(business: business),
        ],
        if (availableServices.isNotEmpty) ...[
          const SizedBox(height: 12),
          DetailSectionShell(
            title: 'Services & Features',
            icon: Icons.grid_view_rounded,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableServices
                  .take(8)
                  .map((serviceType) => DetailMetadataTag(label: serviceType))
                  .toList(),
            ),
          ),
        ],
        const SizedBox(height: 12),
        DetailSectionShell(
          title: 'Operating Hours',
          icon: Icons.schedule,
          child: DetailHoursGrid(
            rows: detailHoursFromBusiness(business.operatingHours),
          ),
        ),
      ],
    );
  }
}

class _BusinessDetailQuickActionsSection extends StatelessWidget {
  const _BusinessDetailQuickActionsSection({
    required this.business,
    required this.viewModel,
  });

  final BusinessDetailDto business;
  final BusinessDetailsViewModel viewModel;

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
            onPressed: () =>
                viewModel.openFullBusinessDetails(context, business),
          ),
          if (business.latitude != null && business.longitude != null)
            DetailQuickActionButton(
              tooltip: 'Take Me There',
              icon: Icons.directions_rounded,
              backgroundColor: qa.directionsBackground,
              iconColor: qa.directionsIcon,
              onPressed: () => viewModel.navigateToBusiness(context, business),
            ),
          if (business.phoneNumber != null)
            DetailQuickActionButton(
              tooltip: 'Call',
              icon: Icons.call_rounded,
              backgroundColor: qa.callBackground,
              iconColor: qa.callIcon,
              onPressed: () => ExternalLinkLauncher.callPhone(
                context,
                business.phoneNumber!,
              ),
            ),
          if (business.emailAddress != null)
            DetailQuickActionButton(
              tooltip: 'Email',
              icon: Icons.mail_rounded,
              backgroundColor: qa.emailBackground,
              iconColor: qa.emailIcon,
              onPressed: () => ExternalLinkLauncher.sendEmail(
                context,
                business.emailAddress!,
              ),
            ),
          if (business.website != null)
            DetailQuickActionButton(
              tooltip: 'Website',
              icon: Icons.language_rounded,
              backgroundColor: qa.websiteBackground,
              iconColor: qa.websiteIcon,
              onPressed: () => ExternalLinkLauncher.openWebsite(
                context,
                business.website!,
              ),
            ),
          DetailQuickActionButton(
            tooltip: 'Rate Business',
            icon: Icons.star_rounded,
            backgroundColor: qa.rateBackground,
            iconColor: qa.rateIcon,
            onPressed: () => viewModel.rateBusiness(context, business),
          ),
        ],
      ),
    );
  }
}

class _BusinessDetailSocialSection extends StatelessWidget {
  const _BusinessDetailSocialSection({required this.business});

  final BusinessDetailDto business;

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
          if (business.facebook != null)
            DetailSocialIconButton(
              tooltip: 'Facebook',
              icon: FontAwesomeIcons.facebookF,
              backgroundColor: qa.facebookBackground,
              iconColor: qa.facebookIcon,
              onPressed: () =>
                  ExternalLinkLauncher.openRaw(context, business.facebook!),
            ),
          if (business.instagram != null)
            DetailSocialIconButton(
              tooltip: 'Instagram',
              icon: FontAwesomeIcons.instagram,
              backgroundColor: qa.instagramBackground,
              iconColor: qa.instagramIcon,
              onPressed: () =>
                  ExternalLinkLauncher.openRaw(context, business.instagram!),
            ),
          if (business.whatsApp != null)
            DetailSocialIconButton(
              tooltip: 'WhatsApp',
              icon: FontAwesomeIcons.whatsapp,
              backgroundColor: qa.whatsappBackground,
              iconColor: qa.whatsappIcon,
              onPressed: () =>
                  ExternalLinkLauncher.openRaw(context, business.whatsApp!),
            ),
        ],
      ),
    );
  }
}

class _BusinessOpenClosedBanner extends StatelessWidget {
  final BusinessDetailDto business;

  const _BusinessOpenClosedBanner({required this.business});

  @override
  Widget build(BuildContext context) {
    final openNow = business.isOpenNow ??
        OperatingHoursOpenCalc.businessIsOpenNow(
          business.operatingHours,
          business.specialOperatingHours,
        );

    return EntityOpenClosedBanner(
      isOpen: openNow,
      viewCount: business.viewCount,
    );
  }
}

/// Explains “Closed” when [specialOperatingHours] has a **closed** entry for today (SAST).
class _BusinessSpecialClosedHint extends StatelessWidget {
  final BusinessDetailDto business;

  const _BusinessSpecialClosedHint({required this.business});

  static String _messageFor(SpecialOperatingHourDto s) {
    final reason = s.reason?.trim();
    if (reason != null && reason.isNotEmpty) {
      return 'Closed today — special hours: $reason';
    }
    final notes = s.notes?.trim();
    if (notes != null && notes.isNotEmpty) {
      return 'Closed today — special hours: $notes';
    }
    return 'Closed today — special hours are in effect.';
  }

  @override
  Widget build(BuildContext context) {
    final special =
        OperatingHoursOpenCalc.todaysClosedSpecialEntry(business.specialOperatingHours);
    if (special == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 18,
            color: colorScheme.tertiary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _messageFor(special),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.86),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  final BusinessImageDto image;
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
      heroTag: 'business_gallery_$index',
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


