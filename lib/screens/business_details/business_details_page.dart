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

  static const EntityListingTheme _theme = EntityListingTheme.business;

  Widget _detailHero(BusinessDetailsState state, BusinessDetailsViewModel viewModel) {
    final title = state is BusinessDetailsSuccess
        ? state.business.name
        : viewModel.businessName;
    final categoryLine =
        state is BusinessDetailsSuccess ? state.business.category : 'Business';
    return EntityListingHeroHeader(
      theme: _theme,
      categoryIcon: Icons.storefront_outlined,
      subCategoryName: title,
      categoryName: categoryLine,
      townName: 'Details',
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BusinessDetailsViewModel>();
    final state = viewModel.state;

    return Scaffold(
      backgroundColor: EntityListingTheme.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _detailHero(state, viewModel),
            if (state is BusinessDetailsSuccess)
              _BusinessOpenClosedBanner(business: state.business),
            Expanded(
              child: _buildContent(context, state, viewModel),
            ),
            const ListingBackFooter(label: 'Back'),
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
        const SizedBox(height: 12),
        DetailSectionShell(
          title: 'Operating Hours',
          icon: Icons.schedule,
          child: DetailHoursGrid(
            rows: detailHoursFromBusiness(business.operatingHours),
          ),
        ),
        if (business.category.toLowerCase() ==
            TownFeatureConstants.equipmentRentalsCategoryKey.toLowerCase()) ...[
          const SizedBox(height: 12),
          DetailSectionShell(
            title: 'Hire rates',
            icon: Icons.payments_outlined,
            child: _EquipmentHireRatesContent(business: business),
          ),
        ],
        const SizedBox(height: 12),
        DetailSectionShell(
          title: 'Quick Actions',
          icon: Icons.bolt_rounded,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (business.latitude != null && business.longitude != null)
                DetailQuickActionButton(
                  tooltip: 'Take Me There',
                  icon: Icons.directions_rounded,
                  backgroundColor: DetailQuickActionColors.directionsBackground,
                  iconColor: DetailQuickActionColors.directionsIcon,
                  onPressed: () => viewModel.navigateToBusiness(context, business),
                ),
              if (business.phoneNumber != null)
                DetailQuickActionButton(
                  tooltip: 'Call',
                  icon: Icons.call_rounded,
                  backgroundColor: DetailQuickActionColors.callBackground,
                  iconColor: DetailQuickActionColors.callIcon,
                  onPressed: () => ExternalLinkLauncher.callPhone(context, business.phoneNumber!),
                ),
              if (business.emailAddress != null)
                DetailQuickActionButton(
                  tooltip: 'Email',
                  icon: Icons.mail_rounded,
                  backgroundColor: DetailQuickActionColors.emailBackground,
                  iconColor: DetailQuickActionColors.emailIcon,
                  onPressed: () => ExternalLinkLauncher.sendEmail(context, business.emailAddress!),
                ),
              if (business.website != null)
                DetailQuickActionButton(
                  tooltip: 'Website',
                  icon: Icons.language_rounded,
                  backgroundColor: DetailQuickActionColors.websiteBackground,
                  iconColor: DetailQuickActionColors.websiteIcon,
                  onPressed: () => ExternalLinkLauncher.openWebsite(context, business.website!),
                ),
              DetailQuickActionButton(
                tooltip: 'Rate Business',
                icon: Icons.star_rounded,
                backgroundColor: DetailQuickActionColors.rateBackground,
                iconColor: DetailQuickActionColors.rateIcon,
                onPressed: () => viewModel.rateBusiness(context, business),
              ),
            ],
          ),
        ),
        if (business.facebook != null || business.instagram != null || business.whatsApp != null) ...[
          const SizedBox(height: 12),
          DetailSectionShell(
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
                    backgroundColor: DetailSocialColors.facebookBackground,
                    iconColor: DetailSocialColors.facebookIcon,
                    onPressed: () => ExternalLinkLauncher.openRaw(context, business.facebook!),
                  ),
                if (business.instagram != null)
                  DetailSocialIconButton(
                    tooltip: 'Instagram',
                    icon: FontAwesomeIcons.instagram,
                    backgroundColor: DetailSocialColors.instagramBackground,
                    iconColor: DetailSocialColors.instagramIcon,
                    onPressed: () => ExternalLinkLauncher.openRaw(context, business.instagram!),
                  ),
                if (business.whatsApp != null)
                  DetailSocialIconButton(
                    tooltip: 'WhatsApp',
                    icon: FontAwesomeIcons.whatsapp,
                    backgroundColor: DetailSocialColors.whatsappBackground,
                    iconColor: DetailSocialColors.whatsappIcon,
                    onPressed: () => ExternalLinkLauncher.openRaw(context, business.whatsApp!),
                  ),
              ],
            ),
          ),
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

class _EquipmentHireRatesContent extends StatelessWidget {
  final BusinessDetailDto business;

  const _EquipmentHireRatesContent({required this.business});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final h = business.hourlyRate;
    final d = business.dailyRate;
    final hasHourly = h != null && h > 0;
    final hasDaily = d != null && d > 0;

    if (!hasHourly && !hasDaily) {
      return Text(
        'Ask the business for current hire rates.',
        style: theme.textTheme.bodyMedium?.copyWith(
          height: 1.35,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.82),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasHourly)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'Hourly: R${h.toStringAsFixed(2)} / hour',
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        if (hasDaily)
          Text(
            'Daily (full day): R${d.toStringAsFixed(2)} / day',
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
      ],
    );
  }
}

class _BusinessOpenClosedBanner extends StatelessWidget {
  final BusinessDetailDto business;

  const _BusinessOpenClosedBanner({required this.business});

  @override
  Widget build(BuildContext context) {
    final openNow =
        business.isOpenNow ?? BusinessUtils.isBusinessCurrentlyOpen(business.operatingHours);
    final secondary = business.openNowText?.trim().isNotEmpty == true
        ? business.openNowText!
        : (openNow ? BusinessUtils.getClosingTime(business.operatingHours) : 'Currently closed');

    return EntityOpenClosedBanner(
      isOpen: openNow,
      secondaryText: secondary,
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

