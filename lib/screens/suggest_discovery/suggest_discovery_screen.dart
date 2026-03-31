import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../core/constants/discovery_constants.dart';
import '../../core/utils/external_link_launcher.dart';
import '../../core/widgets/discovery_map_widget.dart';
import '../../models/models.dart';
import 'suggest_discovery_view_model.dart';

class SuggestDiscoveryScreen extends StatelessWidget {
  const SuggestDiscoveryScreen({super.key, required this.town});

  final TownDto town;

  static const EntityListingTheme _theme = EntityListingTheme.business;

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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SuggestDiscoveryViewModel>();

    return Scaffold(
      backgroundColor: EntityListingTheme.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            EntityListingHeroHeader(
              theme: SuggestDiscoveryScreen._theme,
              categoryIcon: Icons.add_location_alt_outlined,
              subCategoryName: 'Suggest a discovery',
              categoryName: vm.town.name,
              townName: 'Community',
            ),
            Expanded(
              child: vm.loadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : vm.loadError != null
                  ? Center(child: Text(vm.loadError!))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Form(
                        key: vm.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: vm.titleController,
                              decoration: const InputDecoration(
                                labelText: 'Title',
                                border: OutlineInputBorder(),
                              ),
                              maxLength: 150,
                              validator: (v) =>
                                  v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              value: vm.selectedCategoryId, // ignore: deprecated_member_use
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
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
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: vm.descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 4,
                              maxLength: 1000,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: vm.quickTipController,
                              decoration: const InputDecoration(
                                labelText: 'Quick tip (optional)',
                                border: OutlineInputBorder(),
                              ),
                              maxLength: 300,
                            ),
                            const SizedBox(height: 12),
                            if (vm.selectedCategoryId != null &&
                                (vm.selectedCategoryId == 1 || vm.selectedCategoryId == 9))
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Difficulty (optional)',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      children: ['Easy', 'Moderate', 'Hard']
                                          .map(
                                            (d) => ChoiceChip(
                                              label: Text(d),
                                              selected: vm.difficulty == d,
                                              onSelected: (sel) =>
                                                  vm.setDifficulty(sel ? d : null),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                            TextFormField(
                              controller: vm.durationController,
                              decoration: const InputDecoration(
                                labelText: 'Duration (optional)',
                                border: OutlineInputBorder(),
                                hintText: 'e.g. ~1 hour',
                              ),
                              maxLength: 100,
                            ),
                            const SizedBox(height: 12),
                            SwitchListTile(
                              title: const Text('Free access'),
                              value: vm.isFreeAccess,
                              onChanged: vm.setFreeAccess,
                            ),
                            if (!vm.isFreeAccess)
                              TextFormField(
                                controller: vm.entryInfoController,
                                decoration: const InputDecoration(
                                  labelText: 'Entry info',
                                  border: OutlineInputBorder(),
                                ),
                                maxLength: 200,
                              ),
                            const SizedBox(height: 12),
                            Text(
                              'Location on map',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            FutureBuilder<void>(
                              future: vm.mapboxPrimed,
                              builder: (context, snap) {
                                if (snap.connectionState != ConnectionState.done) {
                                  return const SizedBox(
                                    height: 200,
                                    child: Center(child: CircularProgressIndicator()),
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
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  'Pin: ${vm.pinLat!.toStringAsFixed(5)}, ${vm.pinLng!.toStringAsFixed(5)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            const SizedBox(height: 16),
                            Text(
                              'Photos (up to 5)',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (var i = 0; i < vm.images.length; i++)
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
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
                                          icon: const Icon(Icons.close, size: 20),
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
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .withValues(alpha: 0.4),
                                            style: BorderStyle.solid,
                                          ),
                                        ),
                                        child: const Icon(Icons.add_photo_alternate_outlined),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: vm.creditController,
                              decoration: const InputDecoration(
                                labelText: 'How should we credit you? (optional)',
                                border: OutlineInputBorder(),
                              ),
                              maxLength: 200,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              children: [
                                Text(
                                  'By submitting, you agree to our',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                TextButton(
                                  onPressed: () => ExternalLinkLauncher.openUri(
                                    context,
                                    Uri.parse(DiscoveryConstants.termsOfUseUrl),
                                  ),
                                  child: const Text('Terms of Use'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            FilledButton(
                              onPressed: vm.loading ? null : () => vm.submit(context),
                              child: vm.loading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Submit suggestion'),
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

  Future<void> _pickSource(BuildContext context, SuggestDiscoveryViewModel vm) async {
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
