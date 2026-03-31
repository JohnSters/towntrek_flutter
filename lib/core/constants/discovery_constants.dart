/// Discoveries / UGC copy and compliance helpers.
class DiscoveryConstants {
  DiscoveryConstants._();

  static const String termsOfUseUrl = 'https://towntrek.co.za/terms';
  static const String reportEmail = 'support@towntrek.co.za';

  static String reportDiscoveryMailto(int discoveryId) =>
      'mailto:$reportEmail?subject=${Uri.encodeComponent('Report Discovery #$discoveryId')}';
}
