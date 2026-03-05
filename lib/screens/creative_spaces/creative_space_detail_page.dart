import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../core/errors/app_error.dart';
import '../../core/utils/external_link_launcher.dart';
import '../../core/utils/url_utils.dart';
import '../../models/models.dart';
import '../business_details/widgets/business_documents_section.dart';
import '../../core/widgets/open_closed_status_banner.dart';
import 'creative_space_detail_state.dart';
import 'creative_space_detail_view_model.dart';

class CreativeSpaceDetailPage extends StatelessWidget {
  final int creativeSpaceId;
  final String creativeSpaceName;

  const CreativeSpaceDetailPage({
    super.key,
    required this.creativeSpaceId,
    required this.creativeSpaceName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreativeSpaceDetailViewModel(
        creativeSpaceRepository: serviceLocator.creativeSpaceRepository,
        errorHandler: serviceLocator.errorHandler,
        creativeSpaceId: creativeSpaceId,
        creativeSpaceName: creativeSpaceName,
      ),
      child: const _CreativeSpaceDetailPageContent(),
    );
  }
}

class _CreativeSpaceDetailPageContent extends StatelessWidget {
  const _CreativeSpaceDetailPageContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<CreativeSpaceDetailViewModel>();
    final state = viewModel.state;
    final headerTitle = state is CreativeSpaceDetailSuccess
        ? state.creativeSpace.name
        : viewModel.creativeSpaceName;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: headerTitle,
              subtitle: 'Creative Space Details',
              height: 118,
              headerType: HeaderType.creative,
            ),
            if (state is CreativeSpaceDetailSuccess)
              OpenClosedStatusBanner(
                isOpen: state.creativeSpace.isOpenNow,
                subtitle: state.creativeSpace.openNowText,
              ),
            Expanded(
              child: switch (state) {
                CreativeSpaceDetailLoading() => const _CreativeSpaceLoadingView(),
                CreativeSpaceDetailError(error: final error) =>
                  _buildErrorState(context, error: error, viewModel: viewModel),
                CreativeSpaceDetailSuccess(creativeSpace: final space) => _CreativeSpaceDetailBody(space: space),
              },
            ),
            const BackNavigationFooter(),
          ],
        ),
      ),
    );
  }
}

class _CreativeSpaceLoadingView extends StatelessWidget {
  const _CreativeSpaceLoadingView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
      children: [
        _LoadingBlock(height: 104, color: colorScheme.surfaceContainerHigh),
        const SizedBox(height: 12),
        _LoadingBlock(height: 140, color: colorScheme.surfaceContainerLow),
        const SizedBox(height: 12),
        _LoadingBlock(height: 120, color: colorScheme.surfaceContainerHighest),
        const SizedBox(height: 12),
        _LoadingBlock(height: 84, color: colorScheme.surfaceContainerHigh),
      ],
    );
  }
}

Widget _buildErrorState(
  BuildContext context, {
  required AppError error,
  required CreativeSpaceDetailViewModel viewModel,
}) {
  if (error.actionText != null && error.action != null) {
    return ErrorView(error: error);
  }

  return ListView(
    padding: const EdgeInsets.all(18),
    children: [
      ErrorView(error: error),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: viewModel.retry,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Retry'),
      ),
    ],
  );
}

class _CreativeSpaceDetailBody extends StatelessWidget {
  final CreativeSpaceDetailDto space;

  const _CreativeSpaceDetailBody({
    required this.space,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
      children: [
        _InfoSection(space: space),
        const SizedBox(height: CreativeSpacesConstants.sectionSpacing),
        _QuickActionsSection(space: space),
        if (space.images.isNotEmpty) ...[
          const SizedBox(height: CreativeSpacesConstants.sectionSpacing),
          _GallerySection(images: space.images),
        ],
        if (space.operatingHours.isNotEmpty || space.bestVisitWindow != null) ...[
          const SizedBox(height: CreativeSpacesConstants.sectionSpacing),
          _HoursSection(
            title: CreativeSpacesConstants.operatingHoursTitle,
            icon: Icons.schedule_rounded,
            hours: space.operatingHours,
            summary: space.bestVisitWindow,
          ),
        ],
        if (space.specialOperatingHours.isNotEmpty) ...[
          const SizedBox(height: CreativeSpacesConstants.sectionSpacing),
          _HoursSection(
            title: CreativeSpacesConstants.specialHoursTitle,
            icon: Icons.event_note_rounded,
            hours: space.specialOperatingHours,
            isSpecial: true,
          ),
        ],
        if (space.contactPhone != null ||
            space.contactEmail != null ||
            space.contactWebsite != null ||
            space.physicalAddress != null) ...[
          const SizedBox(height: CreativeSpacesConstants.sectionSpacing),
          _ContactSection(space: space),
        ],
        if (space.reviews.isNotEmpty) ...[
          const SizedBox(height: CreativeSpacesConstants.sectionSpacing),
          _ReviewsSection(reviews: space.reviews),
        ],
        if (space.documents.isNotEmpty) ...[
          const SizedBox(height: CreativeSpacesConstants.sectionSpacing),
          BusinessDocumentsSection(documents: space.documents),
        ],
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final CreativeSpaceDetailDto space;

  const _InfoSection({required this.space});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final location = _buildLocationText();
    final rating = space.rating;
    final description = space.description.trim().isEmpty ? CreativeSpacesConstants.noDescriptionText : space.description.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CreativeSpacesConstants.sectionRadius),
        gradient: LinearGradient(
          colors: [
            colorScheme.secondaryContainer.withValues(alpha: 0.55),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (space.categoryName != null || space.subCategoryName != null || space.visitType != null) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (space.categoryName != null && space.categoryName!.trim().isNotEmpty)
                  _Pill(
                    icon: Icons.category_rounded,
                    text: space.categoryName!.trim(),
                  ),
                if (space.subCategoryName != null && space.subCategoryName!.trim().isNotEmpty)
                  _Pill(
                    icon: Icons.layers_rounded,
                    text: space.subCategoryName!.trim(),
                  ),
                if (space.visitType != null && space.visitType!.trim().isNotEmpty)
                  _Pill(
                    icon: Icons.schedule_rounded,
                    text: space.visitType!.trim(),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (location.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.place_rounded, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    location,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Text(
            description,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          if (rating != null)
            Row(
              children: [
                ...List.generate(
                  5,
                  (index) {
                    final starIndex = index + 1;
                    final isFilled = starIndex <= rating;
                    final isHalf = starIndex - 0.5 <= rating && starIndex > rating;
                    return Icon(
                      isFilled
                          ? Icons.star_rounded
                          : isHalf
                              ? Icons.star_half_rounded
                              : Icons.star_border_rounded,
                      size: 14,
                      color: isFilled || isHalf ? Colors.amber.shade700 : colorScheme.onSurfaceVariant,
                    );
                  },
                ),
                const SizedBox(width: 6),
                Text(
                  '${rating.toStringAsFixed(1)} (${space.totalReviews})',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
          if ((space.craftType?.trim() ?? '').isNotEmpty ||
              (space.materials?.trim() ?? '').isNotEmpty ||
              (space.languages?.trim() ?? '').isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (space.craftType != null && space.craftType!.trim().isNotEmpty)
                  _InfoChip(text: space.craftType!.trim(), icon: Icons.brush_rounded),
                if (space.materials != null && space.materials!.trim().isNotEmpty)
                  _InfoChip(text: space.materials!.trim(), icon: Icons.foundation_rounded),
                if (space.languages != null && space.languages!.trim().isNotEmpty)
                  _InfoChip(text: space.languages!.trim(), icon: Icons.translate_rounded),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _buildLocationText() {
    return [
      if (space.physicalAddress != null && space.physicalAddress!.trim().isNotEmpty) space.physicalAddress!.trim(),
      if (space.city != null && space.city!.trim().isNotEmpty) space.city!.trim(),
      if (space.province != null && space.province!.trim().isNotEmpty) space.province!.trim(),
      if (space.postalCode != null && space.postalCode!.trim().isNotEmpty) space.postalCode!.trim(),
    ].join(' • ');
  }
}

class _QuickActionsSection extends StatelessWidget {
  final CreativeSpaceDetailDto space;

  const _QuickActionsSection({required this.space});

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: 'Quick Actions',
      icon: Icons.bolt,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          if ((space.latitude != null && space.longitude != null) ||
              (space.physicalAddress != null && space.physicalAddress!.trim().isNotEmpty))
            _QuickActionButton(
              label: CreativeSpacesConstants.mapActionLabel,
              icon: Icons.map_rounded,
              onTap: () => _openMap(context),
              backgroundColor: const Color(0xFFF3F4FF),
              iconColor: const Color(0xFF3F51B5),
            ),
          if (space.contactPhone != null && space.contactPhone!.trim().isNotEmpty)
            _QuickActionButton(
              label: CreativeSpacesConstants.callActionLabel,
              icon: Icons.call_rounded,
              onTap: () => ExternalLinkLauncher.callPhone(context, space.contactPhone!.trim()),
              backgroundColor: const Color(0xFFE8F5E9),
              iconColor: const Color(0xFF2E7D32),
            ),
          if (space.contactEmail != null && space.contactEmail!.trim().isNotEmpty)
            _QuickActionButton(
              label: CreativeSpacesConstants.emailActionLabel,
              icon: Icons.mail_rounded,
              onTap: () => ExternalLinkLauncher.sendEmail(context, space.contactEmail!.trim()),
              backgroundColor: const Color(0xFFFCE4EC),
              iconColor: const Color(0xFFC2185B),
            ),
          if (space.contactWebsite != null && space.contactWebsite!.trim().isNotEmpty)
            _QuickActionButton(
              label: CreativeSpacesConstants.websiteActionLabel,
              icon: Icons.language_rounded,
              onTap: () => ExternalLinkLauncher.openWebsite(context, space.contactWebsite!.trim()),
              backgroundColor: const Color(0xFFFFF3E0),
              iconColor: const Color(0xFFE65100),
            ),
        ],
      ),
    );
  }

  void _openMap(BuildContext context) {
    final lat = space.latitude;
    final lng = space.longitude;
    final encodedQuery = Uri.encodeComponent(
      lat != null && lng != null
          ? '${space.name}, ${lat}, ${lng}'
          : (space.physicalAddress ?? space.townName ?? space.name),
    );
    if (encodedQuery.trim().isEmpty) return;

    final query = encodedQuery;
    final url = 'https://www.google.com/maps/search/?api=1&query=$query';
    ExternalLinkLauncher.openRaw(context, url, normalizeHttp: false);
  }
}

class _GallerySection extends StatelessWidget {
  final List<CreativeSpaceImageDto> images;

  const _GallerySection({required this.images});

  @override
  Widget build(BuildContext context) {
    final urls = images
        .map((image) => UrlUtils.resolveImageUrl(image.url))
        .where((url) => url.trim().isNotEmpty)
        .toList();
    if (urls.isEmpty) return const SizedBox.shrink();
    final effectiveItemCount = urls.length;

    return _SectionShell(
      title: CreativeSpacesConstants.galleryTitle,
      icon: Icons.photo_library_outlined,
      child: SizedBox(
        height: 98,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: effectiveItemCount,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final url = urls[index];
            return SizedBox(
              width: 132,
              child: TappableImage(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const ColoredBox(
                      color: Colors.black12,
                      child: Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
                imageUrls: urls,
                initialIndex: index,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HoursSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<CreativeSpaceOperatingHourDto> hours;
  final bool isSpecial;
  final String? summary;

  const _HoursSection({
    required this.title,
    required this.icon,
    required this.hours,
    this.isSpecial = false,
    this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: title,
      icon: icon,
      child: Column(
        children: [
          if (summary != null && summary!.trim().isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                summary!.trim(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          if (summary != null && summary!.trim().isNotEmpty) const SizedBox(height: 8),
          ...hours
              .map(
                (hour) => _HourRow(
                  dayOfWeek: hour.dayOfWeek,
                  openTime: hour.openTime,
                  closeTime: hour.closeTime,
                  isOpen: hour.isOpen,
                  note: isSpecial ? hour.specialHoursNote : null,
                  isSpecial: isSpecial,
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  final CreativeSpaceDetailDto space;

  const _ContactSection({
    required this.space,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: CreativeSpacesConstants.contactTitle,
      icon: Icons.contact_mail_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (space.contactPhone != null && space.contactPhone!.trim().isNotEmpty)
            _SimpleListRow(
              icon: Icons.call_rounded,
              label: CreativeSpacesConstants.callActionLabel,
              value: space.contactPhone!.trim(),
            ),
          if (space.contactEmail != null && space.contactEmail!.trim().isNotEmpty)
            _SimpleListRow(
              icon: Icons.mail_rounded,
              label: CreativeSpacesConstants.emailActionLabel,
              value: space.contactEmail!.trim(),
            ),
          if (space.contactWebsite != null && space.contactWebsite!.trim().isNotEmpty)
            _SimpleListRow(
              icon: Icons.language_rounded,
              label: CreativeSpacesConstants.websiteActionLabel,
              value: space.contactWebsite!.trim(),
            ),
          if (space.physicalAddress != null && space.physicalAddress!.trim().isNotEmpty)
            _SimpleListRow(
              icon: Icons.location_on_rounded,
              label: 'Address',
              value: space.physicalAddress!.trim(),
            ),
          if (space.contactMessage != null && space.contactMessage!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                space.contactMessage!.trim(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  final List<ReviewDto> reviews;

  const _ReviewsSection({required this.reviews});

  @override
  Widget build(BuildContext context) {
    final shownReviews = reviews.take(4).toList();
    return _SectionShell(
      title: CreativeSpacesConstants.reviewsTitle,
      icon: Icons.rate_review_rounded,
      child: Column(
        children: shownReviews
            .map(
              (review) => _ReviewTile(review: review),
            )
            .toList(),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ReviewDto review;

  const _ReviewTile({
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                review.userName,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (review.isVerified) ...[
                const SizedBox(width: 6),
                const Icon(Icons.verified_rounded, size: 14),
              ],
              const Spacer(),
              Text(
                '${review.rating.toStringAsFixed(1)} ★',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (review.comment != null && review.comment!.trim().isNotEmpty)
            Text(
              review.comment!.trim(),
              style: theme.textTheme.bodySmall,
            ),
          const SizedBox(height: 8),
          Text(
            '${review.createdAt.year}-${review.createdAt.month.toString().padLeft(2, '0')}-${review.createdAt.day.toString().padLeft(2, '0')}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CreativeSpacesConstants.sectionRadius),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
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

class _HourRow extends StatelessWidget {
  final String dayOfWeek;
  final String? openTime;
  final String? closeTime;
  final bool isOpen;
  final bool isSpecial;
  final String? note;

  const _HourRow({
    required this.dayOfWeek,
    this.openTime,
    this.closeTime,
    required this.isOpen,
    this.note,
    this.isSpecial = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeText = openTime == null || closeTime == null || openTime!.trim().isEmpty || closeTime!.trim().isEmpty
        ? (isOpen ? 'Open' : 'Closed')
        : '${openTime!.trim()} - ${closeTime!.trim()}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dayOfWeek,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          if (isSpecial && isOpen == false)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Special',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          Text(
            timeText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isOpen ? Colors.green.shade700 : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (note != null && note!.trim().isNotEmpty) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                note!.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleListRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SimpleListRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Pill({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;
  final IconData icon;

  const _InfoChip({
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(CreativeSpacesConstants.sectionRadius),
      child: Container(
        height: height,
        color: color,
      ),
    );
  }
}
