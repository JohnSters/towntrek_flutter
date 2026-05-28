import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/core.dart';
import '../../../models/models.dart';

import 'town_admin_banner.dart' show townAdminInitials;

/// Bottom sheet: Town Admin contact details (email/phone only when present on DTO).
Future<void> showTownAdminDetailSheet(
  BuildContext context, {
  required PublicTownAdminProfileDto profile,
}) async {
  final listing = context.entityListing;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: listing.cardBg,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: _TownAdminDetailBody(profile: profile),
      );
    },
  );
}

class _TownAdminDetailBody extends StatelessWidget {
  const _TownAdminDetailBody({required this.profile});

  final PublicTownAdminProfileDto profile;

  Future<void> _tryLaunch(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = context.entityListing;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final email = profile.email?.trim();
    final phone = profile.phone?.trim();
    final emailUri = email != null && email.isNotEmpty
        ? Uri(scheme: 'mailto', path: email)
        : null;
    final tel = phone != null && phone.isNotEmpty ? phone : null;
    final phoneUri =
        tel != null ? Uri(scheme: 'tel', path: tel.replaceAll(' ', '')) : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                child: Text(
                  townAdminInitials(profile.displayName),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: listing.textTitle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: listing.footerHint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (emailUri != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.email_outlined, color: colorScheme.primary),
              title: Text(email!, style: TextStyle(color: listing.bodyText)),
              onTap: () => _tryLaunch(context, emailUri),
            ),
          if (phoneUri != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.phone_outlined, color: colorScheme.primary),
              title: Text(tel!, style: TextStyle(color: listing.bodyText)),
              onTap: () => _tryLaunch(context, phoneUri),
            ),
          if (emailUri == null && phoneUri == null)
            Text(
              'No public contact details shared for this Town Admin.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: listing.footerHint,
              ),
            ),
        ],
      ),
    );
  }
}
