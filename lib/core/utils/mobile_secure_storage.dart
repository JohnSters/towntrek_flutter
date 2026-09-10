import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Shared [FlutterSecureStorage] options for mobile auth secrets.
class MobileSecureStorage {
  MobileSecureStorage._();

  static const FlutterSecureStorage instance = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
}
