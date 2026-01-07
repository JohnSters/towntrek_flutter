import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Centralized helper for launching external links without silent failures.
///
/// - Normalizes website URLs (adds https:// if missing)
/// - Launches using external applications when possible
/// - Shows user feedback via SnackBar when launch fails
class ExternalLinkLauncher {
  const ExternalLinkLauncher._();

  static Future<bool> openWebsite(
    BuildContext context,
    String website, {
    String? failureMessage,
  }) async {
    final normalized = _normalizeWebUrl(website);
    if (normalized == null) {
      _snack(context, failureMessage ?? 'Website link not available');
      return false;
    }
    return _launchExternal(context, Uri.parse(normalized), failureMessage: failureMessage);
  }

  static Future<bool> callPhone(
    BuildContext context,
    String phoneNumber, {
    String? failureMessage,
  }) async {
    final trimmed = phoneNumber.trim();
    if (trimmed.isEmpty) {
      _snack(context, failureMessage ?? 'Phone number not available');
      return false;
    }
    return _launchExternal(
      context,
      Uri.parse('tel:$trimmed'),
      failureMessage: failureMessage ?? 'Unable to start phone call',
    );
  }

  static Future<bool> sendEmail(
    BuildContext context,
    String email, {
    String? failureMessage,
  }) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      _snack(context, failureMessage ?? 'Email address not available');
      return false;
    }
    return _launchExternal(
      context,
      Uri.parse('mailto:$trimmed'),
      failureMessage: failureMessage ?? 'Unable to open email app',
    );
  }

  static Future<bool> openUri(
    BuildContext context,
    Uri uri, {
    String? failureMessage,
  }) async {
    return _launchExternal(context, uri, failureMessage: failureMessage);
  }

  static Future<bool> openRaw(
    BuildContext context,
    String urlString, {
    bool normalizeHttp = true,
    String? failureMessage,
  }) async {
    final raw = urlString.trim();
    if (raw.isEmpty) {
      _snack(context, failureMessage ?? 'Link not available');
      return false;
    }

    final normalized = normalizeHttp ? (_normalizeWebUrl(raw) ?? raw) : raw;
    final uri = Uri.tryParse(normalized);
    if (uri == null) {
      _snack(context, failureMessage ?? 'Invalid link');
      return false;
    }

    return _launchExternal(context, uri, failureMessage: failureMessage);
  }

  static String? _normalizeWebUrl(String urlString) {
    final trimmed = urlString.trim();
    if (trimmed.isEmpty) return null;

    final parsed = Uri.tryParse(trimmed);
    if (parsed != null && parsed.hasScheme) return trimmed;

    return 'https://$trimmed';
  }

  static Future<bool> _launchExternal(
    BuildContext context,
    Uri uri, {
    String? failureMessage,
  }) async {
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        _snack(context, failureMessage ?? 'Could not open link');
      }
      return launched;
    } catch (_) {
      _snack(context, failureMessage ?? 'Could not open link');
      return false;
    }
  }

  static void _snack(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}


