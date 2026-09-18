import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as image_picker;

import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import '../discovery/map_picker_screen.dart';

class TownFlyerComposerViewModel extends ChangeNotifier {
  TownFlyerComposerViewModel({
    required this.town,
    required TownFlyerRepository repository,
    String? initialPhone,
  }) : _repository = repository {
    if (initialPhone != null && initialPhone.trim().isNotEmpty) {
      phoneController.text = initialPhone.trim();
    }
    pinLat = town.latitude;
    pinLng = town.longitude;
  }

  final TownDto town;
  final TownFlyerRepository _repository;
  final phoneController = TextEditingController();
  final image_picker.ImagePicker _picker = image_picker.ImagePicker();

  File? image;
  double? pinLat;
  double? pinLng;
  TownFlyerQuotaDto? quota;
  bool loading = true;
  bool submitting = false;
  bool upgrading = false;
  String? error;

  bool get canSubmit =>
      image != null &&
      pinLat != null &&
      pinLng != null &&
      !submitting &&
      quota != null &&
      quota!.canPostNow &&
      !quota!.townCapFull;

  Future<void> loadQuota() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      quota = await _repository.getQuota(townId: town.id);
    } catch (e) {
      error = resolveUserFacingApiError(e);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> pickImage(image_picker.ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    final file = File(picked.path);
    final bytes = await file.length();
    if (bytes > TownFlyerConstants.maxImageBytes) {
      error = 'Please choose a poster under 5 MB.';
      notifyListeners();
      return;
    }
    image = file;
    error = null;
    notifyListeners();
  }

  Future<void> pickPin(BuildContext context) async {
    final selection = await Navigator.of(context).push<DiscoveryLocationSelection>(
      MaterialPageRoute(
        builder: (_) => DiscoveryMapPickerScreen(
          title: TownFlyerConstants.pinLabel,
          initialLatitude: pinLat,
          initialLongitude: pinLng,
          fallbackCenterLat: town.latitude,
          fallbackCenterLng: town.longitude,
          confirmLabel: 'Use this pin',
        ),
      ),
    );
    if (selection == null) return;
    pinLat = selection.latitude;
    pinLng = selection.longitude;
    notifyListeners();
  }

  Future<bool> upgrade() async {
    upgrading = true;
    error = null;
    notifyListeners();
    try {
      await serviceLocator.mobileSessionManager.upgradeFreeBasic();
      await loadQuota();
      return true;
    } catch (e) {
      error = resolveUserFacingApiError(e);
      return false;
    } finally {
      upgrading = false;
      notifyListeners();
    }
  }

  Future<String?> submit() async {
    if (!canSubmit) return null;
    submitting = true;
    error = null;
    notifyListeners();
    try {
      final result = await _repository.create(
        townId: town.id,
        image: image!,
        latitude: pinLat!,
        longitude: pinLng!,
        contactPhone: phoneController.text.trim().isEmpty
            ? null
            : phoneController.text.trim(),
      );
      return result.message;
    } catch (e) {
      error = resolveUserFacingApiError(e);
      return null;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }
}
