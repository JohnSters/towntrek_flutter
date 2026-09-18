import 'dart:io';

import '../models/town_flyer_dto.dart';
import '../services/town_flyer_api_service.dart';

abstract class TownFlyerRepository {
  Future<List<TownFlyerDto>> getLive(int townId);

  Future<TownFlyerQuotaDto> getQuota({int? townId});

  Future<TownFlyerCreateResultDto> create({
    required int townId,
    required File image,
    required double latitude,
    required double longitude,
    String? physicalAddress,
    String? contactPhone,
  });

  Future<void> remove(int flyerId);
}

class TownFlyerRepositoryImpl implements TownFlyerRepository {
  TownFlyerRepositoryImpl(this._apiService);

  final TownFlyerApiService _apiService;

  @override
  Future<List<TownFlyerDto>> getLive(int townId) => _apiService.getLive(townId);

  @override
  Future<TownFlyerQuotaDto> getQuota({int? townId}) =>
      _apiService.getQuota(townId: townId);

  @override
  Future<TownFlyerCreateResultDto> create({
    required int townId,
    required File image,
    required double latitude,
    required double longitude,
    String? physicalAddress,
    String? contactPhone,
  }) {
    return _apiService.create(
      townId: townId,
      image: image,
      latitude: latitude,
      longitude: longitude,
      physicalAddress: physicalAddress,
      contactPhone: contactPhone,
    );
  }

  @override
  Future<void> remove(int flyerId) => _apiService.remove(flyerId);
}
