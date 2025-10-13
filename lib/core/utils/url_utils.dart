import '../config/api_config.dart';

/// Utility functions for handling URLs
class UrlUtils {
  /// Converts a potentially relative URL to a full URL
  /// If the URL starts with '/', it's treated as relative to the API base URL
  /// Otherwise, returns the URL as-is
  static String resolveImageUrl(String url) {
    if (url.startsWith('/')) {
      // Remove leading slash and combine with base URL
      final relativePath = url.substring(1);
      return '${ApiConfig.baseUrl}/$relativePath';
    }
    return url;
  }

  /// Checks if a URL is a full URL (starts with http/https)
  static bool isFullUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }
}
