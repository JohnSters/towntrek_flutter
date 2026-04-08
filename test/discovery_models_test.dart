import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:towntrek_flutter/core/utils/discovery_install_id_storage.dart';
import 'package:towntrek_flutter/models/discovery_dto.dart';

void main() {
  test('TownDiscoveryDto parses vote fields from API payload', () {
    final dto = TownDiscoveryDto.fromJson({
      'id': 42,
      'title': 'Barrydale walk',
      'category': 1,
      'categoryName': 'Trails & hikes',
      'isFreeAccess': true,
      'isFeatured': false,
      'voteScore': 5,
      'upvoteCount': 7,
      'downvoteCount': 2,
      'currentDeviceVote': 1,
    });

    expect(dto.voteScore, 5);
    expect(dto.upvoteCount, 7);
    expect(dto.downvoteCount, 2);
    expect(dto.currentDeviceVote, 1);
  });

  test('DiscoveryInstallIdStorage reuses stored install id', () async {
    SharedPreferences.setMockInitialValues({});

    final first = await DiscoveryInstallIdStorage.getInstallId();
    final second = await DiscoveryInstallIdStorage.getInstallId();

    expect(first, isNotEmpty);
    expect(second, first);
  });
}
