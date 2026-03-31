import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../models/models.dart';
import '../../../core/utils/external_link_launcher.dart';
import '../../../core/utils/business_utils.dart';

class ContactActionsSection extends StatelessWidget {
  final BusinessDetailDto business;
  final VoidCallback onTakeMeThere;
  final VoidCallback onRateBusiness;

  const ContactActionsSection({
    super.key,
    required this.business,
    required this.onTakeMeThere,
    required this.onRateBusiness,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: OutlinedButton(
        onPressed: null, // Not clickable, just for styling
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(20),
          side: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.1),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: colorScheme.primary.withValues(alpha: 0.02),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Pill-shaped title
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
                    Icons.contact_phone,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Contact & Actions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons - Full Width Rows
            Column(
              children: [
                // Take Me There Button
                if (business.latitude != null && business.longitude != null)
                  _buildFullWidthActionButton(
                    context,
                    icon: Icons.directions,
                    label: 'Take Me There',
                    onPressed: onTakeMeThere,
                    backgroundColor: Colors.teal,
                  ),

                // Contact Us Button
                if (business.phoneNumber != null)
                  _buildFullWidthActionButton(
                    context,
                    icon: Icons.phone,
                    label: 'Call',
                    onPressed: () =>
                        _launchPhone(context, business.phoneNumber!),
                    backgroundColor: Colors.green,
                  ),

                // Email Us Button
                if (business.emailAddress != null)
                  _buildFullWidthActionButton(
                    context,
                    icon: Icons.email,
                    label: 'Email',
                    onPressed: () =>
                        _launchEmail(context, business.emailAddress!),
                    backgroundColor: Colors.blue,
                  ),

                // Website Button
                if (business.website != null)
                  _buildFullWidthActionButton(
                    context,
                    icon: Icons.web,
                    label: 'Website',
                    onPressed: () => _launchWebsite(context, business.website!),
                    backgroundColor: Colors.purple,
                  ),

                // Rate Business Button
                _buildFullWidthActionButton(
                  context,
                  icon: Icons.star_border,
                  label: 'Rate Business',
                  onPressed: onRateBusiness,
                  backgroundColor: Colors.orange,
                ),
              ],
            ),

            // Social Media Links
            if (BusinessUtils.hasSocialMedia(business)) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
                  if (business.facebook != null)
                    _buildSocialButton(
                      icon: FontAwesomeIcons.facebookF,
                      backgroundColor: const Color(0xFF1877F2),
                      onPressed: () => _launchUrl(context, business.facebook!),
                    ),
                  if (business.facebook != null) const SizedBox(width: 12),
                  if (business.instagram != null)
                    _buildSocialButton(
                      icon: FontAwesomeIcons.instagram,
                      backgroundColor: const Color(0xFFC13584),
                      onPressed: () => _launchUrl(context, business.instagram!),
                    ),
                  if (business.instagram != null && business.whatsApp != null)
                    const SizedBox(width: 12),
                  if (business.whatsApp != null)
                    _buildSocialButton(
                      icon: FontAwesomeIcons.whatsapp,
                      backgroundColor: const Color(0xFF25D366),
                      onPressed: () => _launchUrl(context, business.whatsApp!),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFullWidthActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22, color: Colors.white),
        label: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
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

  Future<void> _launchPhone(BuildContext context, String phoneNumber) async {
    await ExternalLinkLauncher.callPhone(context, phoneNumber);
  }

  Future<void> _launchEmail(BuildContext context, String email) async {
    await ExternalLinkLauncher.sendEmail(context, email);
  }

  Future<void> _launchWebsite(BuildContext context, String website) async {
    await ExternalLinkLauncher.openWebsite(context, website);
  }

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    await ExternalLinkLauncher.openRaw(context, urlString);
  }
}
