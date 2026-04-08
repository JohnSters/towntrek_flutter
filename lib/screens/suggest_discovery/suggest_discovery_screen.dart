import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../core/constants/discovery_constants.dart';
import '../../core/utils/external_link_launcher.dart';
import '../../core/widgets/discovery_map_picker_page.dart';
import '../../core/widgets/discovery_map_widget.dart';
import '../../models/models.dart';
import 'suggest_discovery_view_model.dart';

class SuggestDiscoveryScreen extends StatelessWidget {
  const SuggestDiscoveryScreen({super.key, required this.town});

  final TownDto town;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = SuggestDiscoveryViewModel(
          town: town,
          discoveryApiService: serviceLocator.discoveryApiService,
        );
        vm.init();
        return vm;
      },
      child: const _SuggestDiscoveryContent(),
    );
  }
}

class _SuggestDiscoveryContent extends StatelessWidget {
  const _SuggestDiscoveryContent();

  static const double _sectionGap = 12;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SuggestDiscoveryViewModel>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: context.entityListing.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            EntityListingHeroHeader(
              theme: context.entityListingTheme,
              categoryIcon: Icons.add_location_alt_outlined,
              subCategoryName: 'Suggest a discovery',
              categoryName: vm.town.name,
              townName: 'Community',
            ),
            Expanded(
              child: vm.loadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : vm.loadError != null
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          vm.loadError!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                      child: Form(
                        key: vm.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Share a place or activity for the community map.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DetailSectionShell(
                              icon: Icons.edit_note_outlined,
                              title: 'Title & description',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: vm.titleController,
                                    decoration: const InputDecoration(
                                      labelText: 'Title',
                                    ),
                                    maxLength: 150,
                                    validator: (v) =>
                                        v == null || v.trim().isEmpty
                                        ? 'Required'
                                        : null,
                                  ),
                                  const SizedBox(height: _sectionGap),
                                  DropdownButtonFormField<int>(
                                    initialValue: vm.selectedCategoryId,
                                    decoration: const InputDecoration(
                                      labelText: 'Category',
                                    ),
                                    items: vm.categories
                                        .map(
                                          (c) => DropdownMenuItem(
                                            value: c.id,
                                            child: Text(c.name),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: vm.setCategory,
                                  ),
                                  const SizedBox(height: _sectionGap),
                                  TextFormField(
                                    controller: vm.descriptionController,
                                    decoration: const InputDecoration(
                                      labelText: 'Description',
                                      alignLabelWithHint: true,
                                    ),
                                    maxLines: 4,
                                    maxLength: 1000,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: _sectionGap),
                            DetailSectionShell(
                              icon: Icons.tips_and_updates_outlined,
                              title: 'Tips & access',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: vm.quickTipController,
                                    decoration: const InputDecoration(
                                      labelText: 'Quick tip (optional)',
                                    ),
                                    maxLength: 300,
                                  ),
                                  if (vm.selectedCategoryId != null &&
                                      (vm.selectedCategoryId == 1 ||
                                          vm.selectedCategoryId == 9)) ...[
                                    const SizedBox(height: _sectionGap),
                                    Text(
                                      'Difficulty (optional)',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: ['Easy', 'Moderate', 'Hard']
                                          .map(
                                            (d) => ChoiceChip(
                                              label: Text(d),
                                              selected: vm.difficulty == d,
                                              onSelected: (sel) =>
                                                  vm.setDifficulty(
                                                    sel ? d : null,
                                                  ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                  const SizedBox(height: _sectionGap),
                                  TextFormField(
                                    controller: vm.durationController,
                                    decoration: const InputDecoration(
                                      labelText: 'Duration (optional)',
                                      hintText: 'e.g. ~1 hour',
                                    ),
                                    maxLength: 100,
                                  ),
                                  const SizedBox(height: _sectionGap),
                                  TextFormField(
                                    controller: vm.seasonalNoteController,
                                    decoration: const InputDecoration(
                                      labelText: 'Seasonal note (optional)',
                                      hintText:
                                          'e.g. Best after rain, closed in winter',
                                      alignLabelWithHint: true,
                                    ),
                                    maxLines: 2,
                                    maxLength:
                                        DiscoveryConstants.seasonalNoteMaxLength,
                                  ),
                                  const SizedBox(height: 4),
                                  SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text('Free access'),
                                    value: vm.isFreeAccess,
                                    onChanged: vm.setFreeAccess,
                                  ),
                                  if (!vm.isFreeAccess) ...[
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      controller: vm.entryInfoController,
                                      decoration: const InputDecoration(
                                        labelText: 'Entry info',
                                      ),
                                      maxLength: 200,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: _sectionGap),
                            DetailSectionShell(
                              icon: Icons.map_outlined,
                              title: 'Location on map',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: vm.directionsHintController,
                                    decoration: const InputDecoration(
                                      labelText: 'Directions hint (optional)',
                                      hintText:
                                          'How to find it — parking, gate, landmark',
                                      alignLabelWithHint: true,
                                    ),
                                    maxLines: 2,
                                    maxLength: DiscoveryConstants
                                        .directionsHintMaxLength,
                                  ),
                                  const SizedBox(height: _sectionGap),
                                  FutureBuilder<void>(
                                    future: vm.mapboxPrimed,
                                    builder: (context, snap) {
                                      if (snap.connectionState !=
                                          ConnectionState.done) {
                                        return const SizedBox(
                                          height: 200,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      }
                                      return DiscoveryMapWidget(
                                        height: 220,
                                        latitude: vm.pinLat,
                                        longitude: vm.pinLng,
                                        fallbackCenterLat: vm.town.latitude,
                                        fallbackCenterLng: vm.town.longitude,
                                        interactive: true,
                                        onLocationSelected: vm.setPin,
                                      );
                                    },
                                  ),
                                  if (vm.pinLat != null && vm.pinLng != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        'Pin: ${vm.pinLat!.toStringAsFixed(5)}, ${vm.pinLng!.toStringAsFixed(5)}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 10),
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      final selection = await Navigator.of(
                                        context,
                                      ).push<DiscoveryLocationSelection>(
                                        MaterialPageRoute(
                                          builder: (_) => DiscoveryMapPickerPage(
                                            title: 'Choose discovery location',
                                            initialLatitude: vm.pinLat,
                                            initialLongitude: vm.pinLng,
                                            fallbackCenterLat: vm.town.latitude,
                                            fallbackCenterLng:
                                                vm.town.longitude,
                                            selectionEnabled: true,
                                            enableSearch: true,
                                            confirmLabel: 'Use this pin',
                                          ),
                                        ),
                                      );
                                      if (selection == null) return;
                                      vm.setPin(
                                        selection.latitude,
                                        selection.longitude,
                                      );
                                    },
                                    icon: const Icon(Icons.fullscreen),
                                    label: Text(
                                      vm.pinLat == null || vm.pinLng == null
                                          ? 'Open full-screen map & search'
                                          : 'Adjust pin on full-screen map',
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Tip: full-screen mode is easier to pan on Android emulators.',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: _sectionGap),
                            DetailSectionShell(
                              icon: Icons.photo_library_outlined,
                              title: 'Photos (up to 5)',
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (var i = 0; i < vm.images.length; i++)
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.file(
                                            vm.images[i],
                                            width: 88,
                                            height: 88,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.close,
                                              size: 20,
                                            ),
                                            onPressed: () => vm.removeImage(i),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (vm.images.length < 5)
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => _pickSource(context, vm),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          width: 88,
                                          height: 88,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: colorScheme
                                                .surfaceContainerHighest
                                                .withValues(alpha: 0.5),
                                            border: Border.all(
                                              color: colorScheme.outline
                                                  .withValues(alpha: 0.35),
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.add_photo_alternate_outlined,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: _sectionGap),
                            DetailSectionShell(
                              icon: Icons.person_outline,
                              title: 'Credit & submit',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: vm.creditController,
                                    decoration: const InputDecoration(
                                      labelText:
                                          'How should we credit you? (optional)',
                                    ),
                                    maxLength: 200,
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 4,
                                    children: [
                                      Text(
                                        'By submitting, you agree to our',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            ExternalLinkLauncher.openUri(
                                          context,
                                          Uri.parse(
                                            DiscoveryConstants.termsOfUseUrl,
                                          ),
                                        ),
                                        child: const Text('Terms of Use'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  FilledButton(
                                    onPressed: vm.loading
                                        ? null
                                        : () => vm.submit(context),
                                    child: vm.loading
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text('Submit suggestion'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            const ListingBackFooter(label: 'Back'),
          ],
        ),
      ),
    );
  }

  Future<void> _pickSource(
    BuildContext context,
    SuggestDiscoveryViewModel vm,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                vm.pickImage(image_picker.ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(ctx);
                vm.pickImage(image_picker.ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}
