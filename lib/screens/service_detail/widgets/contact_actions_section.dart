import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../models/models.dart';
import '../../../core/constants/service_detail_constants.dart';
import '../../../core/utils/external_link_launcher.dart';

/// Contact and action buttons section for service details
class ContactActionsSection extends StatelessWidget {
  final ServiceDetailDto service;
  final VoidCallback onRateService;

  const ContactActionsSection({
    super.key,
    required this.service,
    required this.onRateService,
  });

  @override
  Widget build(BuildContext context) {
    final actions = _buildActions(context);

    if (actions.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: ServiceDetailConstants.contentPadding,
        vertical: ServiceDetailConstants.sectionSpacing,
      ),
      padding: const EdgeInsets.all(ServiceDetailConstants.cardPadding),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(
          alpha: ServiceDetailConstants.cardBackgroundOpacity,
        ),
        borderRadius: BorderRadius.circular(
          ServiceDetailConstants.cardBorderRadius,
        ),
        border: Border.all(
          color: colorScheme.primary.withValues(
            alpha: ServiceDetailConstants.cardBorderOpacity,
          ),
          width: ServiceDetailConstants.cardBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Centered pill-shaped title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.phone,
                  size: ServiceDetailConstants.contactIconSize,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  ServiceDetailConstants.contactInfoTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: ServiceDetailConstants.titleFontWeight,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...actions,
          if (_hasSocialMediaLinks()) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.share,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Follow Us',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_hasValue(service.facebook))
                  _buildSocialButton(
                    icon: FontAwesomeIcons.facebookF,
                    backgroundColor: const Color(0xFF1877F2),
                    onPressed: () => _launchUrl(context, service.facebook!),
                  ),
                if (_hasValue(service.facebook) && _hasValue(service.instagram))
                  const SizedBox(width: 12),
                if (_hasValue(service.instagram))
                  _buildSocialButton(
                    icon: FontAwesomeIcons.instagram,
                    backgroundColor: const Color(0xFFC13584),
                    onPressed: () => _launchUrl(context, service.instagram!),
                  ),
                if ((_hasValue(service.facebook) ||
                        _hasValue(service.instagram)) &&
                    _hasValue(service.whatsApp))
                  const SizedBox(width: 12),
                if (_hasValue(service.whatsApp))
                  _buildSocialButton(
                    icon: FontAwesomeIcons.whatsapp,
                    backgroundColor: const Color(0xFF25D366),
                    onPressed: () => _launchUrl(context, service.whatsApp!),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final actions = <Widget>[];

    if (service.phoneNumber.isNotEmpty) {
      actions.add(
        _buildActionButton(
          icon: ServiceDetailConstants.callIcon,
          label: ServiceDetailConstants.callAction,
          onPressed: () =>
              ExternalLinkLauncher.callPhone(context, service.phoneNumber),
          color: Colors.green,
        ),
      );
    }

    if (service.phoneNumber2 != null && service.phoneNumber2!.isNotEmpty) {
      actions.add(
        _buildActionButton(
          icon: ServiceDetailConstants.callIcon,
          label: 'Call Alternative',
          onPressed: () =>
              ExternalLinkLauncher.callPhone(context, service.phoneNumber2!),
          color: Colors.green.shade700,
        ),
      );
    }

    if (service.emailAddress != null && service.emailAddress!.isNotEmpty) {
      actions.add(
        _buildActionButton(
          icon: Icons.email,
          label: 'Email',
          onPressed: () =>
              ExternalLinkLauncher.sendEmail(context, service.emailAddress!),
          color: Colors.blue,
        ),
      );
    }

    if (service.website != null && service.website!.isNotEmpty) {
      actions.add(
        _buildActionButton(
          icon: ServiceDetailConstants.websiteIcon,
          label: ServiceDetailConstants.websiteAction,
          onPressed: () =>
              ExternalLinkLauncher.openWebsite(context, service.website!),
          color: Colors.purple,
        ),
      );
    }

    actions.add(
      _buildActionButton(
        icon: Icons.star_border,
        label: ServiceDetailConstants.rateServiceAction,
        onPressed: onRateService,
        color: Colors.orange,
      ),
    );

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
      margin: const EdgeInsets.only(
        bottom: ServiceDetailConstants.contactButtonSpacing,
      ),
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
            borderRadius: BorderRadius.circular(
              ServiceDetailConstants.contactButtonBorderRadius,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 64,
      height: 64,
      child: IconButton(
        onPressed: onPressed,
        icon: FaIcon(icon, color: Colors.white, size: 28),
        style: IconButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  bool _hasSocialMediaLinks() {
    return _hasValue(service.facebook) ||
        _hasValue(service.instagram) ||
        _hasValue(service.whatsApp);
  }

  bool _hasValue(String? value) => value != null && value.isNotEmpty;

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    await ExternalLinkLauncher.openRaw(context, urlString);
  }
}
