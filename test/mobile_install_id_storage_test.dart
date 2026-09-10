import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towntrek_flutter/core/utils/mobile_install_id_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    MobileInstallIdStorage.resetForTest();
  });

  test('reuses the persisted install id', () async {
    final first = await MobileInstallIdStorage.getInstallId();
    final second = await MobileInstallIdStorage.getInstallId();

    expect(first, isNotEmpty);
    expect(first.contains('-'), isTrue);
    expect(second, first);
  });

  test('creates a new install id when storage is empty', () async {
    final first = await MobileInstallIdStorage.getInstallId();
    MobileInstallIdStorage.resetForTest();
    FlutterSecureStorage.setMockInitialValues({});
    final second = await MobileInstallIdStorage.getInstallId();

    expect(second, isNotEmpty);
    expect(second, isNot(first));
  });
}
