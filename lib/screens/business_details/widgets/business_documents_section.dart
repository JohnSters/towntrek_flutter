import 'package:flutter/material.dart';

import '../../../core/utils/external_link_launcher.dart';
import '../../../core/utils/url_utils.dart';
import '../../../models/models.dart';

class BusinessDocumentsSection extends StatelessWidget {
  final List<DocumentDto> documents;

  const BusinessDocumentsSection({
    super.key,
    required this.documents,
  });

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.description, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Documents',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Menus, brochures, and other files provided by the business.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              ...documents.map((doc) => _DocumentTile(document: doc)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final DocumentDto document;

  const _DocumentTile({required this.document});

  IconData _iconFor(DocumentDto doc) {
    final ct = doc.contentType.toLowerCase();
    if (ct.contains('pdf')) return Icons.picture_as_pdf;
    if (ct.contains('word') || doc.originalFileName.toLowerCase().endsWith('.doc') || doc.originalFileName.toLowerCase().endsWith('.docx')) {
      return Icons.description;
    }
    return Icons.insert_drive_file;
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '';
    const kb = 1024;
    const mb = 1024 * 1024;
    if (bytes >= mb) {
      final v = bytes / mb;
      return '${v.toStringAsFixed(v >= 10 ? 0 : 1)} MB';
    }
    return '${(bytes / kb).toStringAsFixed(0)} KB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sizeText = _formatSize(document.fileSize);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Icon(_iconFor(document), color: colorScheme.primary),
        title: Text(
          document.originalFileName.isNotEmpty ? document.originalFileName : 'Document',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          [
            if (document.documentType.isNotEmpty) document.documentType,
            if (sizeText.isNotEmpty) sizeText,
          ].join(' • '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: TextButton.icon(
          onPressed: document.downloadUrl.trim().isEmpty
              ? null
              : () async {
                  final url = UrlUtils.resolveApiUrl(document.downloadUrl);
                  await ExternalLinkLauncher.openRaw(
                    context,
                    url,
                    normalizeHttp: false,
                    failureMessage: 'Unable to open document',
                  );
                },
          icon: const Icon(Icons.download),
          label: const Text('Download'),
        ),
      ),
    );
  }
}

