import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import 'what_to_do_state.dart';
import 'what_to_do_view_model.dart';

class WhatToDoScreen extends StatelessWidget {
  final TownDto town;

  const WhatToDoScreen({super.key, required this.town});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WhatToDoViewModel(
        businessRepository: serviceLocator.businessRepository,
        errorHandler: serviceLocator.errorHandler,
        town: town,
      ),
      child: const _WhatToDoScreenContent(),
    );
  }
}

class _WhatToDoScreenContent extends StatelessWidget {
  const _WhatToDoScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WhatToDoViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildContent(context, viewModel)),
            const BackNavigationFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WhatToDoViewModel viewModel) {
    final state = viewModel.state;

    return switch (state) {
      WhatToDoLoading() => const Center(child: CircularProgressIndicator()),
      WhatToDoError(error: final error) => ErrorView(error: error),
      WhatToDoSuccess(town: final town, sections: final sections) => Column(
        children: [
          PageHeader(
            title: '${WhatToDoConstants.titlePrefix} ${town.name}',
            subtitle: WhatToDoConstants.subtitle,
            height: WhatToDoConstants.headerHeight,
            headerType: HeaderType.business,
          ),
          Expanded(
            child: sections.isEmpty
                ? _buildEmptyState(context)
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(
                      WhatToDoConstants.pagePadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < sections.length; i++) ...[
                          _buildSection(context, sections[i], viewModel),
                          if (i < sections.length - 1)
                            const SizedBox(
                              height: WhatToDoConstants.sectionSpacing,
                            ),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    };
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(WhatToDoConstants.pagePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              WhatToDoConstants.emptyIcon,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 16),
            Text(
              WhatToDoConstants.emptyTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              WhatToDoConstants.emptyDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    WhatToDoSection section,
    WhatToDoViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: section.businesses.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: WhatToDoConstants.tileSpacing),
          itemBuilder: (context, index) {
            final business = section.businesses[index];
            return OutlinedButton(
              onPressed: () => viewModel.openBusinessDetails(context, business),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                side: BorderSide(
                  color: colorScheme.primary.withValues(alpha: 0.25),
                  width: 1.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: colorScheme.primary.withValues(alpha: 0.05),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      WhatToDoConstants.sectionIcon,
                      size: 24,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          business.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          business.shortDescription?.trim().isNotEmpty == true
                              ? business.shortDescription!
                              : business.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.primary.withValues(alpha: 0.6),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
