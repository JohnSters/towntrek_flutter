import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/models.dart';

class EventContactSection extends StatelessWidget {
  final EventDetailDto event;

  const EventContactSection({
    super.key,
    required this.event,
  });

  Future<void> _launchExternal(BuildContext context, Uri uri) async {
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch ${uri.toString()}')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid or unsupported link')),
        );
      }
    }
  }

  String? _normalizeWebUrl(String? urlString) {
    if (urlString == null) return null;
    final trimmed = urlString.trim();
    if (trimmed.isEmpty) return null;

    // Already has a scheme (http/https)
    final parsed = Uri.tryParse(trimmed);
    if (parsed != null && parsed.hasScheme) return trimmed;

    // Common user-entered formats (e.g. www.example.com)
    return 'https://$trimmed';
  }

  bool _looksLikeUrl(String value) {
    final v = value.trim().toLowerCase();
    if (v.startsWith('http://') || v.startsWith('https://')) return true;
    if (v.startsWith('www.')) return true;
    // Very small heuristic: "domain.tld/..." or "domain.tld"
    return v.contains('.') && !v.contains(' ');
  }

  Future<void> _openWebsite(BuildContext context, String website) async {
    final normalized = _normalizeWebUrl(website);
    if (normalized == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Website link not available')),
        );
      }
      return;
    }
    await _launchExternal(context, Uri.parse(normalized));
  }

  Future<void> _makeCall(BuildContext context, String phoneNumber) async {
    final trimmed = phoneNumber.trim();
    if (trimmed.isEmpty) return;
    await _launchExternal(context, Uri.parse('tel:$trimmed'));
  }

  Future<void> _sendEmail(BuildContext context, String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return;
    await _launchExternal(context, Uri.parse('mailto:$trimmed'));
  }

  Future<void> _handleGetTickets(BuildContext context) async {
    // Prefer ticketInfo if it looks like a URL; else fall back to website; else show ticketInfo text.
    final ticketInfo = event.ticketInfo?.trim();
    final website = event.website?.trim();

    if (ticketInfo != null && ticketInfo.isNotEmpty && _looksLikeUrl(ticketInfo)) {
      await _openWebsite(context, ticketInfo);
      return;
    }

    if (website != null && website.isNotEmpty) {
      await _openWebsite(context, website);
      return;
    }

    if (ticketInfo != null && ticketInfo.isNotEmpty) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ticket Information'),
          content: Text(ticketInfo),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket link not available')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show section if there is contact info
    if (!_hasContactInfo()) {
      return const SizedBox.shrink();
    }

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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact & Tickets',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              if (event.organizerContact != null)
                 Padding(
                   padding: const EdgeInsets.only(bottom: 12),
                   child: Row(
                    children: [
                      Icon(Icons.person, size: 20, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          event.organizerContact!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                   ),
                 ),

              if (event.phoneNumber != null)
                _buildContactRow(
                  context, 
                  Icons.phone, 
                  event.phoneNumber!, 
                  () => _makeCall(context, event.phoneNumber!),
                ),
                
              if (event.emailAddress != null)
                _buildContactRow(
                  context, 
                  Icons.email, 
                  event.emailAddress!, 
                  () => _sendEmail(context, event.emailAddress!),
                ),
                
              if (event.website != null)
                _buildContactRow(
                  context, 
                  Icons.language, 
                  'Visit Website', 
                  () => _openWebsite(context, event.website!),
                ),

              if (event.requiresTickets) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _handleGetTickets(context),
                    icon: const Icon(Icons.confirmation_number),
                    label: const Text('Get Tickets'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _hasContactInfo() {
    return event.organizerContact != null ||
        event.phoneNumber != null ||
        event.emailAddress != null ||
        event.website != null ||
        (event.ticketInfo?.trim().isNotEmpty ?? false) ||
        event.requiresTickets;
  }

  Widget _buildContactRow(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: theme.colorScheme.outlineVariant),
            ],
          ),
        ),
      ),
    );
  }
}

