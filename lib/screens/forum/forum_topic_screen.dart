import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/core.dart';
import '../../core/constants/forum_constants.dart';
import '../member_hub/connect_device_sheet.dart';
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

  Future<String?> _askForReportReason(String title) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: ForumConstants.reportReasonLabel,
          ),
          maxLines: 3,
          maxLength: ForumConstants.reportReasonMaxLength,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null || reason.isEmpty) return null;
    return reason;
  }

  Future<void> _reportTopic() async {
    final viewModel = context.read<ForumTopicViewModel>();
    await runWithParcelSession(context, () async {
      final reason = await _askForReportReason(ForumConstants.reportTopicTitle);
      if (reason == null || !mounted) return;
      await viewModel.reportTopic(reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(ForumConstants.reportThanks)),
      );
    });
  }

  Future<void> _reportPost(int postId) async {
    final viewModel = context.read<ForumTopicViewModel>();
    await runWithParcelSession(context, () async {
      final reason = await _askForReportReason(ForumConstants.reportPostTitle);
      if (reason == null || !mounted) return;
      await viewModel.reportPost(postId, reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(ForumConstants.reportThanks)),
      );
    });
  }

  Future<void> _toggleSubscription() async {
    final viewModel = context.read<ForumTopicViewModel>();
    await runWithParcelSession(context, () => viewModel.toggleSubscription());
  }

  Future<void> _toggleReaction(int postId) async {
    final viewModel = context.read<ForumTopicViewModel>();
    await runWithParcelSession(context, () => viewModel.toggleReaction(postId));
  }

  Future<void> _submitReply() async {
    final viewModel = context.read<ForumTopicViewModel>();
    final text = _replyController.text;
    await runWithParcelSession(context, () async {
      await viewModel.submitReply(text);
      if (mounted) {
        _replyController.clear();
      }
    });
  }

  Future<void> _loadMoreReplies() async {
    final viewModel = context.read<ForumTopicViewModel>();
    try {
      await viewModel.loadMoreReplies();
    } catch (error) {
      if (mounted) {
        showErrorSnack(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ForumTopicViewModel>();
    final topic = viewModel.topic;

    return ListenableBuilder(
      listenable: serviceLocator.mobileSessionManager,
      builder: (context, _) {
        final isAuthenticated =
            serviceLocator.mobileSessionManager.isAuthenticated;

        return Scaffold(
          appBar: AppBar(
            title: Text(topic?.title ?? 'Topic'),
            actions: [
              if (topic != null) ...[
                IconButton(
                  tooltip: !isAuthenticated
                      ? ForumConstants.connectToFollow
                      : (topic.isSubscribedByCurrentUser
                          ? 'Unfollow topic'
                          : 'Follow topic'),
                  icon: Icon(
                    topic.isSubscribedByCurrentUser
                        ? Icons.notifications_off
                        : Icons.notifications_outlined,
                  ),
                  onPressed: _toggleSubscription,
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'report') {
                      _reportTopic();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'report',
                      child: Text('Report topic'),
                    ),
                  ],
                ),
              ],
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
                                    Text(
                                      widget.townName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                    if (topic.categoryName.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(topic.categoryName),
                                    ],
                                    if (topic.isAnnouncement ||
                                        topic.isPinned ||
                                        topic.isLocked) ...[
                                      const SizedBox(height: 8),
                                      Wrap(
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
                                    ],
                                    if (topic.isLocked) ...[
                                      const SizedBox(height: 12),
                                      const _LockedBanner(),
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
                                        isModeratedHidden:
                                            post.isModeratedHidden,
                                        reactionCount: post.reactionCount,
                                        reacted: post.reactedByCurrentUser,
                                        onLike: post.isModeratedHidden
                                            ? null
                                            : () => _toggleReaction(post.id),
                                        onReport: () => _reportPost(post.id),
                                      ),
                                    ),
                                    if (viewModel.hasMoreReplies) ...[
                                      const SizedBox(height: 8),
                                      Center(
                                        child: viewModel.loadingMoreReplies
                                            ? const Padding(
                                                padding: EdgeInsets.all(12),
                                                child:
                                                    CircularProgressIndicator(),
                                              )
                                            : TextButton(
                                                onPressed: _loadMoreReplies,
                                                child: const Text(
                                                  ForumConstants.loadMoreReplies,
                                                ),
                                              ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            if (topic.isLocked)
                              const SizedBox.shrink()
                            else if (!isAuthenticated)
                              SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        showConnectDeviceSheet(context),
                                    icon: const Icon(Icons.link),
                                    label: const Text(
                                      ForumConstants.connectToReply,
                                    ),
                                  ),
                                ),
                              )
                            else
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
                                          maxLength:
                                              ForumConstants.bodyMaxLength,
                                          decoration: const InputDecoration(
                                            hintText: ForumConstants.replyHint,
                                            counterText: '',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: viewModel.submitting
                                            ? null
                                            : _submitReply,
                                        icon: viewModel.submitting
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
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
      },
    );
  }
}

class _LockedBanner extends StatelessWidget {
  const _LockedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock, size: 18),
          SizedBox(width: 8),
          Expanded(child: Text(ForumConstants.lockedTopicBanner)),
        ],
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

class _PostBlock extends StatelessWidget {
  final String author;
  final String badge;
  final String body;
  final DateTime createdAt;
  final bool isOriginalPost;
  final bool isModeratedHidden;
  final int? reactionCount;
  final bool reacted;
  final VoidCallback? onLike;
  final VoidCallback? onReport;

  const _PostBlock({
    required this.author,
    required this.badge,
    required this.body,
    required this.createdAt,
    this.isOriginalPost = false,
    this.isModeratedHidden = false,
    this.reactionCount,
    this.reacted = false,
    this.onLike,
    this.onReport,
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
                    Text(
                      author,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$badge · ${_formatDate(createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (onReport != null && !isOriginalPost)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'report') {
                      onReport!();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'report',
                      child: Text('Report reply'),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (isModeratedHidden)
            Text(
              ForumConstants.hiddenPostPlaceholder,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
            )
          else
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
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }
}
