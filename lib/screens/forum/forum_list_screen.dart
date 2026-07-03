import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../core/constants/forum_constants.dart';
import '../../models/forum_dto.dart';
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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ForumListViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('${ForumConstants.pageTitle} · ${viewModel.townName}'),
      ),
      body: viewModel.loading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.error != null
              ? ErrorView(error: viewModel.error!)
              : RefreshIndicator(
                  onRefresh: viewModel.load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        ForumConstants.pageSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      TextField(
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
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _CategoryChip(
                              label: 'All topics',
                              selected: viewModel.selectedCategoryId == null,
                              onTap: () => viewModel.setCategory(null),
                            ),
                            ...viewModel.categories.map(
                              (category) => _CategoryChip(
                                label: category.name,
                                selected: viewModel.selectedCategoryId == category.id,
                                onTap: () => viewModel.setCategory(category.id),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (viewModel.topics.isEmpty)
                        _EmptyTopics(townName: viewModel.townName)
                      else
                        ...viewModel.topics.map(
                          (topic) => _TopicCard(
                            topic: topic,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ForumTopicScreen(
                                    topicId: topic.id,
                                    townName: viewModel.townName,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
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

class _EmptyTopics extends StatelessWidget {
  final String townName;

  const _EmptyTopics({required this.townName});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.forum_outlined, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(ForumConstants.emptyTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('${ForumConstants.emptyDescription} ($townName).'),
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
              if (topic.isAnnouncement)
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text('Announcement', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                ),
              Text(topic.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(topic.bodyPreview, maxLines: 2, overflow: TextOverflow.ellipsis),
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
