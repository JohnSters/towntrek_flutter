import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../core/constants/forum_constants.dart';
import '../../models/forum_dto.dart';
import 'create_topic_screen.dart';
import 'forum_list_view_model.dart';
import 'forum_topic_screen.dart';

class ForumListScreen extends StatelessWidget {
  final int townId;
  final String townName;

  const ForumListScreen({
    super.key,
    required this.townId,
    required this.townName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForumListViewModel(
        forumRepository: serviceLocator.forumRepository,
        errorHandler: serviceLocator.errorHandler,
        townId: townId,
        townName: townName,
      )..load(),
      child: const _ForumListScreenContent(),
    );
  }
}

class _ForumListScreenContent extends StatefulWidget {
  const _ForumListScreenContent();

  @override
  State<_ForumListScreenContent> createState() => _ForumListScreenContentState();
}

class _ForumListScreenContentState extends State<_ForumListScreenContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openCreateTopic() async {
    final viewModel = context.read<ForumListViewModel>();
    final shouldRefresh = await openCreateTopicFlow(
      context,
      townId: viewModel.townId,
      townName: viewModel.townName,
      categories: viewModel.activeCategories,
      initialCategoryId: viewModel.selectedCategoryId,
    );
    if (shouldRefresh && mounted) {
      await viewModel.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ForumListViewModel>();
    final listing = context.entityListing;

    return ListenableBuilder(
      listenable: serviceLocator.mobileSessionManager,
      builder: (context, _) {
        final isAuthenticated =
            serviceLocator.mobileSessionManager.isAuthenticated;

        if (!isAuthenticated && viewModel.filter == 'MyPosts') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              viewModel.setFilter('Recent');
            }
          });
        }

        return Scaffold(
          backgroundColor: listing.pageBg,
          appBar: AppBar(
            title: Text('${ForumConstants.pageTitle} · ${viewModel.townName}'),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: viewModel.loading ? null : _openCreateTopic,
            icon: const Icon(Icons.add),
            label: const Text(ForumConstants.newTopicCta),
          ),
          body: viewModel.loading
              ? const Center(child: CircularProgressIndicator())
              : viewModel.error != null
                  ? ErrorView(error: viewModel.error!)
                  : RefreshIndicator(
                      onRefresh: viewModel.load,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                        itemCount: _itemCount(viewModel),
                        itemBuilder: (context, index) {
                          return _buildItem(
                            context,
                            viewModel,
                            index,
                            isAuthenticated: isAuthenticated,
                          );
                        },
                      ),
                    ),
        );
      },
    );
  }

  int _itemCount(ForumListViewModel viewModel) {
    // subtitle + guidelines + search + categories + filters + content
    const headerCount = 5;
    if (viewModel.topics.isEmpty) {
      return headerCount + 1;
    }
    return headerCount +
        viewModel.topics.length +
        (viewModel.hasNextPage ? 1 : 0);
  }

  Widget _buildItem(
    BuildContext context,
    ForumListViewModel viewModel,
    int index, {
    required bool isAuthenticated,
  }) {
    final listing = context.entityListing;

    if (index == 0) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          ForumConstants.pageSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: listing.bodyText,
              ),
        ),
      );
    }
    if (index == 1) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: _GuidelinesBanner(),
      );
    }
    if (index == 2) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            filled: true,
            fillColor: listing.cardBg,
            hintText: ForumConstants.searchHint,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                viewModel.setSearchQuery('');
              },
            ),
          ),
          onSubmitted: viewModel.setSearchQuery,
        ),
      );
    }
    if (index == 3) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _CategoryChip(
                label: ForumConstants.allTopicsLabel,
                selected: viewModel.selectedCategoryId == null,
                onTap: () => viewModel.setCategory(null),
              ),
              ...viewModel.activeCategories.map(
                (category) => _CategoryChip(
                  label: category.name,
                  selected: viewModel.selectedCategoryId == category.id,
                  onTap: () => viewModel.setCategory(category.id),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (index == 4) {
      final segments = <ButtonSegment<String>>[
        const ButtonSegment(
          value: 'Recent',
          label: Text(ForumConstants.filterRecent),
        ),
        const ButtonSegment(
          value: 'Unanswered',
          label: Text(ForumConstants.filterUnanswered),
        ),
        const ButtonSegment(
          value: 'Announcements',
          label: Text(ForumConstants.filterAnnouncements),
        ),
        if (isAuthenticated)
          const ButtonSegment(
            value: ForumConstants.filterMyPostsValue,
            label: Text(ForumConstants.filterMyPosts),
          ),
      ];

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SegmentedButton<String>(
          segments: segments,
          selected: {viewModel.filter},
          showSelectedIcon: false,
          onSelectionChanged: (selection) {
            if (selection.isEmpty) return;
            viewModel.setFilter(selection.first);
          },
        ),
      );
    }

    final contentIndex = index - 5;
    if (viewModel.topics.isEmpty) {
      return _EmptyTopics(
        townName: viewModel.townName,
        onStartTopic: _openCreateTopic,
      );
    }

    if (contentIndex < viewModel.topics.length) {
      final topic = viewModel.topics[contentIndex];
      return _TopicCard(
        topic: topic,
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ForumTopicScreen(
                topicId: topic.id,
                townName: viewModel.townName,
              ),
            ),
          );
          if (mounted) {
            await viewModel.load();
          }
        },
      );
    }

    // Sentinel for load-more
    if (viewModel.hasNextPage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          viewModel.loadMore();
        }
      });
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return const SizedBox.shrink();
  }
}

class _GuidelinesBanner extends StatelessWidget {
  const _GuidelinesBanner();

  @override
  Widget build(BuildContext context) {
    final listing = context.entityListing;
    final outline = Theme.of(context).colorScheme.outline;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: listing.cardBg,
        borderRadius: BorderRadius.circular(ForumConstants.guidelinesRadius),
        border: Border.all(
          color: outline.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 18,
            color: listing.accent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ForumConstants.guidelinesText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: listing.bodyText,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final listing = context.entityListing;
    final borderColor = selected
        ? colorScheme.primary
        : colorScheme.outline.withValues(alpha: 0.38);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: true,
        checkmarkColor: colorScheme.onPrimary,
        selectedColor: colorScheme.primary,
        backgroundColor: listing.cardBg,
        side: BorderSide(color: borderColor, width: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _EmptyTopics extends StatelessWidget {
  final String townName;
  final VoidCallback onStartTopic;

  const _EmptyTopics({
    required this.townName,
    required this.onStartTopic,
  });

  @override
  Widget build(BuildContext context) {
    final listing = context.entityListing;
    final outline = Theme.of(context).colorScheme.outline;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: listing.cardBg,
        borderRadius: BorderRadius.circular(ForumConstants.cardRadius),
        border: Border.all(
          color: outline.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.forum_outlined,
            size: 40,
            color: listing.accent,
          ),
          const SizedBox(height: 12),
          Text(
            ForumConstants.emptyTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: listing.textTitle,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${ForumConstants.emptyDescription} ($townName).',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: listing.bodyText,
                ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onStartTopic,
            icon: const Icon(Icons.add),
            label: const Text(ForumConstants.startTopicCta),
          ),
        ],
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final ForumTopicSummaryDto topic;
  final VoidCallback onTap;

  const _TopicCard({required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final listing = context.entityListing;
    final outline = Theme.of(context).colorScheme.outline;

    return Padding(
      padding: const EdgeInsets.only(bottom: ForumConstants.cardSpacing),
      child: Material(
        color: listing.cardBg,
        borderRadius: BorderRadius.circular(ForumConstants.cardRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ForumConstants.cardRadius),
              border: Border.all(
                color: outline.withValues(alpha: 0.25),
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (topic.isAnnouncement || topic.isPinned || topic.isLocked)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (topic.isAnnouncement)
                          const _StatusPill(
                            label: ForumConstants.badgeAnnouncement,
                            kind: _StatusKind.announcement,
                          ),
                        if (topic.isPinned)
                          const _StatusPill(
                            label: ForumConstants.badgePinned,
                            kind: _StatusKind.pinned,
                          ),
                        if (topic.isLocked)
                          const _StatusPill(
                            label: ForumConstants.badgeLocked,
                            kind: _StatusKind.locked,
                          ),
                      ],
                    ),
                  ),
                Text(
                  topic.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: listing.textTitle,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (topic.bodyPreview.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    topic.bodyPreview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: listing.bodyText,
                        ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    ListingInfoChip(
                      icon: Icons.person_outline,
                      label: topic.authorDisplayName,
                    ),
                    ListingInfoChip(
                      icon: Icons.chat_bubble_outline,
                      label: '${topic.replyCount} replies',
                    ),
                    ListingInfoChip(
                      icon: Icons.thumb_up_outlined,
                      label: '${topic.reactionCount} likes',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _StatusKind { announcement, pinned, locked }

class _StatusPill extends StatelessWidget {
  final String label;
  final _StatusKind kind;

  const _StatusPill({required this.label, required this.kind});

  @override
  Widget build(BuildContext context) {
    final listing = context.entityListing;
    final colorScheme = Theme.of(context).colorScheme;

    final Color bg;
    final Color fg;
    final IconData icon;

    switch (kind) {
      case _StatusKind.announcement:
        bg = colorScheme.tertiaryContainer.withValues(alpha: 0.65);
        fg = colorScheme.onTertiaryContainer;
        icon = Icons.campaign_outlined;
      case _StatusKind.pinned:
        bg = listing.chipBg;
        fg = listing.accent;
        icon = Icons.push_pin_outlined;
      case _StatusKind.locked:
        bg = colorScheme.surfaceContainerHighest;
        fg = listing.footerHint;
        icon = Icons.lock_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
