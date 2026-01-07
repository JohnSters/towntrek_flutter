import 'package:flutter/material.dart';
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
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
              // Section Title
              Row(
                children: [
                  Icon(
                    Icons.contact_phone,
                    size: 24,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Contact & Actions',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

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
                      onPressed: () => _launchPhone(context, business.phoneNumber!),
                      backgroundColor: Colors.green,
                    ),

                  // Email Us Button
                  if (business.emailAddress != null)
                    _buildFullWidthActionButton(
                      context,
                      icon: Icons.email,
                      label: 'Email',
                      onPressed: () => _launchEmail(context, business.emailAddress!),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (business.facebook != null)
                      _buildSocialButton(
                        context,
                        icon: Icons.facebook,
                        onPressed: () => _launchUrl(context, business.facebook!),
                      ),
                    if (business.instagram != null)
                      _buildSocialButton(
                        context,
                        icon: Icons.camera_alt, // Instagram-like icon
                        onPressed: () => _launchUrl(context, business.instagram!),
                      ),
                    if (business.whatsApp != null)
                      _buildSocialButton(
                        context,
                        icon: Icons.message,
                        onPressed: () => _launchUrl(context, business.whatsApp!),
                      ),
                  ],
                ),
              ],
            ],
          ),
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

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surfaceContainerHighest,
        padding: const EdgeInsets.all(12),
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

