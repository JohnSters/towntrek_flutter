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
    if (index == 0) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          ForumConstants.pageSubtitle,
          style: Theme.of(context).textTheme.bodyMedium,
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
                label: 'All topics',
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
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'Recent',
                selected: viewModel.filter == 'Recent',
                onTap: () => viewModel.setFilter('Recent'),
              ),
              _FilterChip(
                label: 'Unanswered',
                selected: viewModel.filter == 'Unanswered',
                onTap: () => viewModel.setFilter('Unanswered'),
              ),
              _FilterChip(
                label: 'Announcements',
                selected: viewModel.filter == 'Announcements',
                onTap: () => viewModel.setFilter('Announcements'),
              ),
              if (isAuthenticated)
                _FilterChip(
                  label: 'My posts',
                  selected: viewModel.filter == 'MyPosts',
                  onTap: () => viewModel.setFilter('MyPosts'),
                ),
            ],
          ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ForumConstants.guidelinesText,
              style: Theme.of(context).textTheme.bodySmall,
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
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.forum_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              ForumConstants.emptyTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('${ForumConstants.emptyDescription} ($townName).'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onStartTopic,
              icon: const Icon(Icons.add),
              label: const Text(ForumConstants.startTopicCta),
            ),
          ],
        ),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (topic.isAnnouncement || topic.isPinned || topic.isLocked)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (topic.isAnnouncement)
                        const _StatusBadge(
                          label: 'Announcement',
                          color: Colors.orange,
                        ),
                      if (topic.isPinned)
                        const _StatusBadge(
                          label: 'Pinned',
                          color: Colors.blueGrey,
                        ),
                      if (topic.isLocked)
                        const _StatusBadge(
                          label: 'Locked',
                          color: Colors.grey,
                        ),
                    ],
                  ),
                ),
              Text(topic.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                topic.bodyPreview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  Text(topic.authorDisplayName),
                  Text('${topic.replyCount} replies'),
                  Text('${topic.reactionCount} likes'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }
}
