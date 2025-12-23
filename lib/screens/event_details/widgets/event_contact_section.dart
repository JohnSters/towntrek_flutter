import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/models.dart';

class EventContactSection extends StatelessWidget {
  final EventDetailDto event;

  const EventContactSection({
    super.key,
    required this.event,
  });

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makeCall(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _sendEmail(String email) async {
    final url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
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
                  () => _makeCall(event.phoneNumber!),
                ),
                
              if (event.emailAddress != null)
                _buildContactRow(
                  context, 
                  Icons.email, 
                  event.emailAddress!, 
                  () => _sendEmail(event.emailAddress!),
                ),
                
              if (event.website != null)
                _buildContactRow(
                  context, 
                  Icons.language, 
                  'Visit Website', 
                  () => _launchUrl(event.website!),
                ),

              if (event.requiresTickets) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      if (event.website != null) {
                        _launchUrl(event.website!);
                      } else {
                         // Fallback or show dialog info
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Check website or call for tickets')),
                         );
                      }
                    },
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

