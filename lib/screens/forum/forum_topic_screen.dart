import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/core.dart';
import '../../core/constants/forum_constants.dart';
import 'forum_topic_view_model.dart';

class ForumTopicScreen extends StatelessWidget {
  final int topicId;
  final String townName;

  const ForumTopicScreen({
    super.key,
    required this.topicId,
    required this.townName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForumTopicViewModel(
        forumRepository: serviceLocator.forumRepository,
        errorHandler: serviceLocator.errorHandler,
        topicId: topicId,
      )..load(),
      child: _ForumTopicScreenContent(townName: townName),
    );
  }
}

class _ForumTopicScreenContent extends StatefulWidget {
  final String townName;

  const _ForumTopicScreenContent({required this.townName});

  @override
  State<_ForumTopicScreenContent> createState() => _ForumTopicScreenContentState();
}

class _ForumTopicScreenContentState extends State<_ForumTopicScreenContent> {
  final TextEditingController _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ForumTopicViewModel>();
    final topic = viewModel.topic;

    return Scaffold(
      appBar: AppBar(
        title: Text(topic?.title ?? 'Topic'),
        actions: [
          if (topic != null)
            IconButton(
              tooltip: topic.isSubscribedByCurrentUser ? 'Unfollow topic' : 'Follow topic',
              icon: Icon(topic.isSubscribedByCurrentUser ? Icons.notifications_off : Icons.notifications),
              onPressed: viewModel.toggleSubscription,
            ),
        ],
      ),
      body: viewModel.loading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.error != null && topic == null
              ? ErrorView(error: viewModel.error!)
              : topic == null
                  ? const SizedBox.shrink()
                  : Column(
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: viewModel.load,
                            child: ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                Text(widget.townName, style: Theme.of(context).textTheme.labelLarge),
                                if (topic.categoryName.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(topic.categoryName),
                                ],
                                const SizedBox(height: 12),
                                _PostBlock(
                                  author: topic.authorDisplayName,
                                  badge: topic.authorRoleBadge,
                                  body: topic.body,
                                  createdAt: topic.createdAt,
                                  isOriginalPost: true,
                                ),
                                const Divider(height: 32),
                                ...topic.posts.map(
                                  (post) => _PostBlock(
                                    author: post.authorDisplayName,
                                    badge: post.authorRoleBadge,
                                    body: post.body,
                                    createdAt: post.createdAt,
                                    reactionCount: post.reactionCount,
                                    reacted: post.reactedByCurrentUser,
                                    onLike: () => viewModel.toggleReaction(post.id),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!topic.isLocked)
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _replyController,
                                      minLines: 1,
                                      maxLines: 4,
                                      decoration: const InputDecoration(
                                        hintText: ForumConstants.replyHint,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: viewModel.submitting
                                        ? null
                                        : () async {
                                            final ok = await viewModel.submitReply(_replyController.text);
                                            if (ok && mounted) {
                                              _replyController.clear();
                                            }
                                          },
                                    icon: viewModel.submitting
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Icon(Icons.send),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
    );
  }
}

class _PostBlock extends StatelessWidget {
  final String author;
  final String badge;
  final String body;
  final DateTime createdAt;
  final bool isOriginalPost;
  final int? reactionCount;
  final bool reacted;
  final VoidCallback? onLike;

  const _PostBlock({
    required this.author,
    required this.badge,
    required this.body,
    required this.createdAt,
    this.isOriginalPost = false,
    this.reactionCount,
    this.reacted = false,
    this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isOriginalPost ? 0 : 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOriginalPost ? const Color(0xFFFFF8E8) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                child: Text(author.isNotEmpty ? author[0].toUpperCase() : '?'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(author, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('$badge · ${_formatDate(createdAt)}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MarkdownBody(
            data: body,
            selectable: true,
            onTapLink: (text, href, title) {
              if (href == null) {
                return;
              }
              launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
            },
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              p: Theme.of(context).textTheme.bodyMedium,
              blockquote: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
              a: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
            ),
          ),
          if (onLike != null) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onLike,
              icon: Icon(reacted ? Icons.thumb_up : Icons.thumb_up_outlined),
              label: Text('Like (${reactionCount ?? 0})'),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    return '${value.day} ${_month(value.month)} ${value.year}';
  }

  String _month(int month) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[month - 1];
  }
}
