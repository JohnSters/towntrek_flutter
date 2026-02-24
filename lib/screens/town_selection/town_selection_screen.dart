import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../core/utils/external_link_launcher.dart';
import '../../models/models.dart';
import 'town_selection_state.dart';
import 'town_selection_view_model.dart';

class TownSelectionScreen extends StatelessWidget {
  const TownSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TownSelectionViewModel(
        townRepository: serviceLocator.townRepository,
        errorHandler: serviceLocator.errorHandler,
      ),
      child: const _TownSelectionScreenContent(),
    );
  }
}

class _TownSelectionScreenContent extends StatelessWidget {
  const _TownSelectionScreenContent();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final viewModel = context.watch<TownSelectionViewModel>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(context, viewModel),
            Expanded(
              child: _buildTownList(context, viewModel.state, viewModel),
            ),
            _buildRequestTownButton(context, viewModel),
          ],
        ),
      ),
    );
  }

  void _selectTown(BuildContext context, TownDto town) {
    Navigator.of(context).pop(town);
  }

  // Build search bar widget inline
  Widget _buildSearchBar(BuildContext context, TownSelectionViewModel viewModel) {
    final theme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(TownSelectionConstants.borderRadiusLarge),
          bottomRight: Radius.circular(TownSelectionConstants.borderRadiusLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadow.withValues(alpha: TownSelectionConstants.shadowAlpha),
            blurRadius: TownSelectionConstants.shadowBlurRadius,
            offset: const Offset(0, TownSelectionConstants.shadowOffsetY),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row with Back Button and Title
          Padding(
            padding: const EdgeInsets.fromLTRB(
              TownSelectionConstants.horizontalPadding,
              TownSelectionConstants.headerTopPadding,
              TownSelectionConstants.horizontalPadding,
              0,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: theme.onSurface,
                    size: TownSelectionConstants.backIconSize,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.surfaceContainerHighest.withValues(alpha: TownSelectionConstants.iconButtonBackgroundAlpha),
                    padding: const EdgeInsets.all(TownSelectionConstants.backButtonPadding),
                  ),
                ),
                const SizedBox(width: TownSelectionConstants.mediumSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TownSelectionConstants.screenTitle,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.onSurface,
                          letterSpacing: TownSelectionConstants.titleLetterSpacing,
                        ),
                      ),
                      Text(
                        TownSelectionConstants.screenSubtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: theme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: TownSelectionConstants.verticalSpacingLarge),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TownSelectionConstants.horizontalPadding),
            child: Container(
              decoration: BoxDecoration(
                color: theme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(TownSelectionConstants.borderRadiusMedium),
                border: Border.all(
                  color: theme.outline.withValues(alpha: TownSelectionConstants.searchBorderAlpha),
                  width: TownSelectionConstants.searchBorderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadow.withValues(alpha: TownSelectionConstants.searchShadowAlpha),
                    blurRadius: TownSelectionConstants.shadowBlurRadius,
                    offset: const Offset(0, TownSelectionConstants.searchShadowOffsetY),
                  ),
                ],
              ),
              child: TextField(
                controller: viewModel.searchController,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: TownSelectionConstants.searchHint,
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: theme.onSurfaceVariant.withValues(alpha: TownSelectionConstants.searchHintAlpha),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: theme.primary,
                    size: TownSelectionConstants.searchIconSize,
                  ),
                  suffixIcon: viewModel.searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: theme.onSurfaceVariant,
                            size: TownSelectionConstants.closeIconSize,
                          ),
                          onPressed: viewModel.clearSearch,
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: TownSelectionConstants.searchFieldPaddingHorizontal,
                    vertical: TownSelectionConstants.searchFieldPaddingVertical,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: TownSelectionConstants.verticalSpacingSmall),

          // Results Count / Status
          Padding(
            padding: const EdgeInsets.fromLTRB(
              TownSelectionConstants.horizontalPadding,
              0,
              TownSelectionConstants.horizontalPadding,
              TownSelectionConstants.searchBarBottomPadding,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: TownSelectionConstants.locationIconSize,
                  color: theme.primary,
                ),
                const SizedBox(width: TownSelectionConstants.smallSpacing),
                Text(
                  _getResultsText(viewModel.state),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: theme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTownList(BuildContext context, TownSelectionState state, TownSelectionViewModel viewModel) {
    return switch (state) {
      TownSelectionLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
      TownSelectionError(error: final error) => ErrorView(
          error: error,
          showIcon: true,
          padding: const EdgeInsets.all(TownSelectionConstants.horizontalPadding),
        ),
      TownSelectionSuccess(filteredTowns: final filteredTowns) =>
        filteredTowns.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(TownSelectionConstants.verticalPadding),
              itemCount: filteredTowns.length,
              itemBuilder: (context, index) {
                final town = filteredTowns[index];
                return _buildTownCard(context, town);
              },
            ),
      TownSelectionEmpty() => _buildEmptyState(),
    };
  }

  Widget _buildRequestTownButton(BuildContext context, TownSelectionViewModel viewModel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        TownSelectionConstants.horizontalPadding,
        0,
        TownSelectionConstants.horizontalPadding,
        TownSelectionConstants.verticalPadding,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: TownSelectionConstants.shadowAlpha),
            blurRadius: TownSelectionConstants.shadowBlurRadius,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => _requestTownByEmail(context, viewModel.searchController.text),
          icon: const Icon(
            Icons.email_outlined,
            size: TownSelectionConstants.emailButtonIconSize,
          ),
          label: Text(
            TownSelectionConstants.requestTownButtonLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: TownSelectionConstants.emailButtonVerticalPadding,
            ),
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TownSelectionConstants.borderRadiusMedium),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _requestTownByEmail(BuildContext context, String searchQuery) async {
    final trimmedQuery = searchQuery.trim();
    final bodyTownLine = trimmedQuery.isEmpty ? '[Add town name here]' : trimmedQuery;
    final body = [
      TownSelectionConstants.requestTownEmailBodyIntro,
      '',
      TownSelectionConstants.requestTownEmailBodyPrompt,
      bodyTownLine,
      '',
      'Thanks!',
    ].join('\n');

    final uri = Uri(
      scheme: 'mailto',
      path: TownSelectionConstants.requestTownEmail,
      queryParameters: {
        'subject': TownSelectionConstants.requestTownEmailSubject,
        'body': body,
      },
    );

    await ExternalLinkLauncher.openUri(
      context,
      uri,
      failureMessage: 'Unable to open email app',
    );
  }

  Widget _buildTownCard(BuildContext context, TownDto town) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: TownSelectionConstants.verticalSpacingSmall),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TownSelectionConstants.borderRadiusMedium),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: TownSelectionConstants.cardBorderAlpha),
        ),
      ),
      child: InkWell(
        onTap: () => _selectTown(context, town),
        borderRadius: BorderRadius.circular(TownSelectionConstants.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(TownSelectionConstants.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Town icon with background
                  Container(
                    width: TownSelectionConstants.townIconContainerSize,
                    height: TownSelectionConstants.townIconContainerSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(TownSelectionConstants.borderRadiusMedium),
                    ),
                    child: const Icon(
                      Icons.location_city,
                      color: Colors.white,
                      size: TownSelectionConstants.townIconSize,
                    ),
                  ),

                  const SizedBox(width: TownSelectionConstants.verticalSpacingSmall),

                  // Town details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Town name
                        Text(
                          town.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),

                        const SizedBox(height: TownSelectionConstants.smallSpacing),

                        // Province and postal code
                        Row(
                          children: [
                            Icon(
                              Icons.map,
                              size: TownSelectionConstants.locationIconSize,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: TownSelectionConstants.smallSpacing),
                            Text(
                              town.province,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (town.postalCode != null) ...[
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: TownSelectionConstants.smallSpacing),
                                width: TownSelectionConstants.dividerDotSize,
                                height: TownSelectionConstants.dividerDotSize,
                                decoration: BoxDecoration(
                                  color: colorScheme.onSurfaceVariant.withValues(alpha: TownSelectionConstants.dividerDotAlpha),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                town.postalCode!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arrow indicator
                  Padding(
                    padding: const EdgeInsets.only(left: TownSelectionConstants.verticalSpacingSmall),
                    child: Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant,
                      size: TownSelectionConstants.chevronIconSize,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: TownSelectionConstants.verticalSpacingMedium),

              // Stats Pills - Full width below
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCountPill(
                      context,
                      Icons.business_rounded,
                      '${town.businessCount}',
                      TownSelectionConstants.businessLabel,
                      colorScheme.primary,
                    ),
                    const SizedBox(width: TownSelectionConstants.verticalSpacingSmall),
                    _buildCountPill(
                      context,
                      Icons.handyman_rounded,
                      '${town.servicesCount}',
                      TownSelectionConstants.servicesLabel,
                      colorScheme.secondary,
                    ),
                    const SizedBox(width: TownSelectionConstants.verticalSpacingSmall),
                    _buildCountPill(
                      context,
                      Icons.event_rounded,
                      '${town.eventsCount}',
                      TownSelectionConstants.eventsLabel,
                      colorScheme.tertiary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_city,
                size: TownSelectionConstants.emptyStateIconSize,
                color: colorScheme.onSurface.withValues(alpha: TownSelectionConstants.emptyStateIconAlpha),
              ),
              const SizedBox(height: TownSelectionConstants.verticalSpacingMedium),
              Text(
                TownSelectionConstants.noTownsAvailable,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: TownSelectionConstants.verticalSpacingSmall),
              Text(
                TownSelectionConstants.noTownsAvailableDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  String _getResultsText(TownSelectionState state) {
    return switch (state) {
      TownSelectionSuccess(filteredTowns: final filteredTowns) =>
        '${filteredTowns.length} ${TownSelectionConstants.locationsAvailableText}',
      _ => '0 ${TownSelectionConstants.locationsAvailableText}',
    };
  }

  Widget _buildCountPill(
    BuildContext context,
    IconData icon,
    String count,
    String label,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TownSelectionConstants.pillPaddingHorizontal,
        vertical: TownSelectionConstants.pillPaddingVertical,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: TownSelectionConstants.pillBackgroundAlpha),
        borderRadius: BorderRadius.circular(TownSelectionConstants.borderRadiusLarge),
        border: Border.all(
          color: color.withValues(alpha: TownSelectionConstants.pillBorderAlpha),
          width: TownSelectionConstants.pillBorderWidth,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: TownSelectionConstants.countPillIconSize,
            color: color,
          ),
          const SizedBox(width: TownSelectionConstants.smallSpacing),
          Text(
            count,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: TownSelectionConstants.smallSpacing - 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color.withValues(alpha: TownSelectionConstants.pillLabelAlpha),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}