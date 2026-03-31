import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as image_picker;

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import '../../services/discovery_api_service.dart' show DiscoveryApiService, DiscoverySubmitException;

class SuggestDiscoveryViewModel extends ChangeNotifier {
  SuggestDiscoveryViewModel({
    required this.town,
    required DiscoveryApiService discoveryApiService,
  }) : _api = discoveryApiService;

  final TownDto town;
  final DiscoveryApiService _api;

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final quickTipController = TextEditingController();
  final durationController = TextEditingController();
  final entryInfoController = TextEditingController();
  final seasonalNoteController = TextEditingController();
  final directionsHintController = TextEditingController();
  final creditController = TextEditingController(text: 'A local resident');

  final image_picker.ImagePicker _picker = image_picker.ImagePicker();
  final List<File> _images = [];
  List<File> get images => List.unmodifiable(_images);

  List<DiscoveryCategoryDto> categories = [];
  int? selectedCategoryId;
  String? difficulty;
  bool isFreeAccess = true;
  double? pinLat;
  double? pinLng;

  bool loading = false;
  bool loadingCategories = true;
  String? loadError;

  late final Future<void> mapboxPrimed = () async {
    final token = await serviceLocator.configService.getMapboxAccessToken();
    if (token != null && token.isNotEmpty) {
      MapboxOptions.setAccessToken(token);
    }
  }();

  Future<void> init() async {
    loadingCategories = true;
    notifyListeners();
    try {
      categories = await _api.getCategories();
      if (categories.isNotEmpty) {
        selectedCategoryId = categories.first.id;
      }
      loadError = null;
    } catch (e) {
      loadError = e.toString();
    } finally {
      loadingCategories = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    quickTipController.dispose();
    durationController.dispose();
    entryInfoController.dispose();
    seasonalNoteController.dispose();
    directionsHintController.dispose();
    creditController.dispose();
    super.dispose();
  }

  void setCategory(int? id) {
    selectedCategoryId = id;
    notifyListeners();
  }

  void setDifficulty(String? d) {
    difficulty = d;
    notifyListeners();
  }

  void setFreeAccess(bool v) {
    isFreeAccess = v;
    notifyListeners();
  }

  void setPin(double lat, double lng) {
    pinLat = lat;
    pinLng = lng;
    notifyListeners();
  }

  Future<void> pickImage(image_picker.ImageSource source) async {
    if (_images.length >= 5) return;
    final x = await _picker.pickImage(source: source, imageQuality: 85);
    if (x == null) return;
    _images.add(File(x.path));
    notifyListeners();
  }

  void removeImage(int index) {
    if (index < 0 || index >= _images.length) return;
    _images.removeAt(index);
    notifyListeners();
  }

  Future<void> submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a category')),
      );
      return;
    }

    loading = true;
    notifyListeners();
    try {
      await _api.submitSuggestion(
        townId: town.id,
        title: titleController.text.trim(),
        category: selectedCategoryId!,
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        quickTip: quickTipController.text.trim().isEmpty
            ? null
            : quickTipController.text.trim(),
        difficulty: difficulty,
        duration: durationController.text.trim().isEmpty
            ? null
            : durationController.text.trim(),
        isFreeAccess: isFreeAccess,
        entryInfo: !isFreeAccess && entryInfoController.text.trim().isNotEmpty
            ? entryInfoController.text.trim()
            : null,
        seasonalNote: seasonalNoteController.text.trim().isEmpty
            ? null
            : seasonalNoteController.text.trim(),
        directionsHint: directionsHintController.text.trim().isEmpty
            ? null
            : directionsHintController.text.trim(),
        latitude: pinLat,
        longitude: pinLng,
        submitterDisplayName: creditController.text.trim().isEmpty
            ? null
            : creditController.text.trim(),
        images: _images,
      );
      if (!context.mounted) return;
      loading = false;
      notifyListeners();
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (ctx) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Thank you!',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your suggestion is under review and will appear once approved.',
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      );
      if (context.mounted) Navigator.of(context).pop();
    } on DiscoverySubmitException catch (e) {
      loading = false;
      notifyListeners();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      loading = false;
      notifyListeners();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong: $e')),
      );
    }
  }
}
