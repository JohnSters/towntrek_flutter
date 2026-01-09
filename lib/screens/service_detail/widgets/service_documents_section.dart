import 'package:flutter/material.dart';
import '../../../core/utils/external_link_launcher.dart';
import '../../../core/utils/url_utils.dart';
import '../../../models/models.dart';
import '../../../core/constants/service_detail_constants.dart';

/// Documents section for service details
class ServiceDocumentsSection extends StatelessWidget {
  final List<DocumentDto> documents;

  const ServiceDocumentsSection({
    super.key,
    required this.documents,
  });

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: ServiceDetailConstants.contentPadding,
        vertical: ServiceDetailConstants.sectionSpacing,
      ),
      child: Card(
        elevation: ServiceDetailConstants.cardElevation,
        shadowColor: colorScheme.shadow.withValues(alpha: ServiceDetailConstants.shadowOpacity),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ServiceDetailConstants.cardBorderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(ServiceDetailConstants.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.description,
                    size: ServiceDetailConstants.contactIconSize,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Documents & Certifications',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: ServiceDetailConstants.titleFontWeight,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...documents.map((document) => _buildDocumentItem(context, document)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentItem(BuildContext context, DocumentDto document) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openDocument(context, document),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getDocumentColor(document.documentType).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getDocumentIcon(document.documentType),
                  color: _getDocumentColor(document.documentType),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.originalFileName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (document.description != null && document.description!.isNotEmpty)
                      Text(
                        document.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDocument(BuildContext context, DocumentDto document) {
    final url = UrlUtils.resolveApiUrl(document.downloadUrl);
    ExternalLinkLauncher.openWebsite(context, url);
  }

  IconData _getDocumentIcon(String documentType) {
    switch (documentType.toLowerCase()) {
      case 'license':
      case 'certification':
        return Icons.verified;
      case 'insurance':
        return Icons.security;
      case 'contract':
      case 'agreement':
        return Icons.assignment;
      case 'manual':
      case 'guide':
        return Icons.book;
      default:
        return Icons.description;
    }
  }

  Color _getDocumentColor(String documentType) {
    switch (documentType.toLowerCase()) {
      case 'license':
        return Colors.green;
      case 'certification':
        return Colors.blue;
      case 'insurance':
        return Colors.orange;
      case 'contract':
        return Colors.purple;
      case 'manual':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}