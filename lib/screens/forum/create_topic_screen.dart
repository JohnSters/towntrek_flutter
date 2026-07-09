import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../core/constants/forum_constants.dart';
import '../../models/forum_dto.dart';
import '../member_hub/connect_device_sheet.dart';
import 'create_topic_view_model.dart';
import 'forum_topic_screen.dart';

class CreateTopicScreen extends StatelessWidget {
  final int townId;
  final String townName;
  final List<ForumCategoryDto> categories;
  final int? initialCategoryId;

  const CreateTopicScreen({
    super.key,
    required this.townId,
    required this.townName,
    required this.categories,
    this.initialCategoryId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateTopicViewModel(
        forumRepository: serviceLocator.forumRepository,
        townId: townId,
        townName: townName,
        categories: categories,
        initialCategoryId: initialCategoryId,
      ),
      child: const _CreateTopicBody(),
    );
  }
}

class _CreateTopicBody extends StatefulWidget {
  const _CreateTopicBody();

  @override
  State<_CreateTopicBody> createState() => _CreateTopicBodyState();
}

class _CreateTopicBodyState extends State<_CreateTopicBody> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final viewModel = context.read<CreateTopicViewModel>();
    await runWithParcelSession(context, () async {
      final created = await viewModel.submit(
        title: _titleController.text,
        body: _bodyController.text,
      );
      if (!mounted) return;
      if (created == null) {
        if (viewModel.validationError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(viewModel.validationError!)),
          );
        }
        return;
      }
      Navigator.of(context).pop(created);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateTopicViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(ForumConstants.newTopicCta),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                viewModel.townName,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(
                ForumConstants.guidelinesText,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              if (viewModel.categories.isEmpty)
                const Text('No categories available for this town yet.')
              else
                DropdownButtonFormField<int>(
                  initialValue: viewModel.selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: viewModel.categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      )
                      .toList(),
                  onChanged: viewModel.submitting
                      ? null
                      : (value) => viewModel.setCategory(value),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                enabled: !viewModel.submitting,
                maxLength: ForumConstants.titleMaxLength,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: ForumConstants.newTopicTitleHint,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bodyController,
                enabled: !viewModel.submitting,
                maxLength: ForumConstants.bodyMaxLength,
                minLines: 5,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: ForumConstants.newTopicBodyHint,
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: viewModel.submitting || viewModel.categories.isEmpty
                    ? null
                    : _submit,
                icon: viewModel.submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  viewModel.submitting ? 'Posting…' : 'Post topic',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens create-topic after auth, then navigates to the new topic and returns
/// whether the list should refresh.
Future<bool> openCreateTopicFlow(
  BuildContext context, {
  required int townId,
  required String townName,
  required List<ForumCategoryDto> categories,
  int? initialCategoryId,
}) async {
  ForumTopicDetailDto? created;
  await runWithParcelSession(context, () async {
    if (!context.mounted) return;
    created = await Navigator.of(context).push<ForumTopicDetailDto>(
      MaterialPageRoute(
        builder: (_) => CreateTopicScreen(
          townId: townId,
          townName: townName,
          categories: categories,
          initialCategoryId: initialCategoryId,
        ),
      ),
    );
  });

  if (!context.mounted || created == null) return false;

  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ForumTopicScreen(
        topicId: created!.id,
        townName: townName,
      ),
    ),
  );
  return true;
}
