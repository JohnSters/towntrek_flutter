import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../core/utils/external_link_launcher.dart';
import '../../../models/models.dart';

class EventContactSection extends StatelessWidget {
  final EventDetailDto event;

  const EventContactSection({
    super.key,
    required this.event,
  });

  bool _looksLikeUrl(String value) {
    final v = value.trim().toLowerCase();
    if (v.startsWith('http://') || v.startsWith('https://')) return true;
    if (v.startsWith('www.')) return true;
    return v.contains('.') && !v.contains(' ');
  }

  Future<void> _openWebsite(BuildContext context, String website) async {
    await ExternalLinkLauncher.openWebsite(context, website);
  }

  Future<void> _handleGetTickets(BuildContext context) async {
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

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;

  bool _hasContactInfo() {
    return event.organizerContact != null ||
        _hasValue(event.phoneNumber) ||
        _hasValue(event.emailAddress) ||
        _hasValue(event.website) ||
        event.requiresTickets;
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasContactInfo()) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final actions = <Widget>[
      if (_hasValue(event.phoneNumber))
        DetailQuickActionButton(
          tooltip: 'Call',
          icon: Icons.call_rounded,
          backgroundColor: DetailQuickActionColors.callBackground,
          iconColor: DetailQuickActionColors.callIcon,
          onPressed: () => ExternalLinkLauncher.callPhone(context, event.phoneNumber!),
        ),
      if (_hasValue(event.emailAddress))
        DetailQuickActionButton(
          tooltip: 'Email',
          icon: Icons.mail_rounded,
          backgroundColor: DetailQuickActionColors.emailBackground,
          iconColor: DetailQuickActionColors.emailIcon,
          onPressed: () => ExternalLinkLauncher.sendEmail(context, event.emailAddress!),
        ),
      if (_hasValue(event.website))
        DetailQuickActionButton(
          tooltip: 'Website',
          icon: Icons.language_rounded,
          backgroundColor: DetailQuickActionColors.websiteBackground,
          iconColor: DetailQuickActionColors.websiteIcon,
          onPressed: () => _openWebsite(context, event.website!),
        ),
      if (event.requiresTickets)
        DetailQuickActionButton(
          tooltip: 'Get tickets',
          icon: Icons.confirmation_number_rounded,
          backgroundColor: DetailQuickActionColors.ticketsBackground,
          iconColor: DetailQuickActionColors.ticketsIcon,
          onPressed: () => _handleGetTickets(context),
        ),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DetailSectionShell(
        expandTitle: true,
        title: 'Contact & tickets',
        icon: Icons.contact_mail_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.organizerContact != null && event.organizerContact!.trim().isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.person_outline_rounded, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      event.organizerContact!.trim(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.35,
                        color: colorScheme.onSurface.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
              if (actions.isNotEmpty) const SizedBox(height: 12),
            ],
            if (actions.isNotEmpty)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: actions,
              ),
          ],
        ),
      ),
    );
  }
}
