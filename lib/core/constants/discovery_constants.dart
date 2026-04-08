/// Discoveries / UGC copy and compliance helpers.
class DiscoveryConstants {
  DiscoveryConstants._();

  /// Matches API `SubmitDiscoveryRequestDto` / server validation.
  static const int directionsHintMaxLength = 500;
  static const int seasonalNoteMaxLength = 300;

  static const String termsOfUseUrl = 'https://towntrek.co.za/Home/Privacy';
  static const String reportEmail = 'support@towntrek.co.za';

  static String reportDiscoveryMailto(int discoveryId) =>
      'mailto:$reportEmail?subject=${Uri.encodeComponent('Report Discovery #$discoveryId')}';
}
