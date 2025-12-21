import 'dart:io';

/// HttpOverrides to allow self-signed certificates for local development
class LocalDevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // ALLOW self-signed certificates for specific local hosts
        // BE CAREFUL: Do not use this in production for public URLs
        return host == 'localhost' || 
               host == '10.0.2.2' || 
               host.startsWith('192.168.'); 
      };
  }
}

