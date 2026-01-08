import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../core/constants/service_detail_constants.dart';
import '../../../core/utils/external_link_launcher.dart';

/// Contact and action buttons section for service details
class ContactActionsSection extends StatelessWidget {
  final ServiceDetailDto service;

  const ContactActionsSection({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final actions = _buildActions(context);

    if (actions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: ServiceDetailConstants.contentPadding,
        vertical: ServiceDetailConstants.sectionSpacing,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ServiceDetailConstants.contactInfoTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: ServiceDetailConstants.titleFontWeight,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: ServiceDetailConstants.sectionSpacing),
          ...actions,
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final actions = <Widget>[];

    if (service.phoneNumber.isNotEmpty) {
      actions.add(_buildActionButton(
        icon: ServiceDetailConstants.callIcon,
        label: ServiceDetailConstants.callAction,
        onPressed: () => ExternalLinkLauncher.callPhone(context, service.phoneNumber),
        color: Colors.green,
      ));
    }

    if (service.phoneNumber2 != null && service.phoneNumber2!.isNotEmpty) {
      actions.add(_buildActionButton(
        icon: ServiceDetailConstants.callIcon,
        label: 'Call Alternative',
        onPressed: () => ExternalLinkLauncher.callPhone(context, service.phoneNumber2!),
        color: Colors.green.shade700,
      ));
    }

    if (service.emailAddress != null && service.emailAddress!.isNotEmpty) {
      actions.add(_buildActionButton(
        icon: Icons.email,
        label: 'Email',
        onPressed: () => ExternalLinkLauncher.sendEmail(context, service.emailAddress!),
        color: Colors.blue,
      ));
    }

    if (service.website != null && service.website!.isNotEmpty) {
      actions.add(_buildActionButton(
        icon: ServiceDetailConstants.websiteIcon,
        label: ServiceDetailConstants.websiteAction,
        onPressed: () => ExternalLinkLauncher.openWebsite(context, service.website!),
        color: Colors.purple,
      ));
    }

    return actions;
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: ServiceDetailConstants.contactButtonSpacing),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ServiceDetailConstants.contactButtonBorderRadius),
          ),
        ),
      ),
    );
  }
}