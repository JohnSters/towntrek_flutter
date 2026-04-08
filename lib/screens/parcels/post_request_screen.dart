import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import 'access_code_entry_screen.dart';

class PostRequestViewModel extends ChangeNotifier {
  PostRequestViewModel({
    required this.town,
    required ParcelRepository repository,
  }) : _repository = repository;

  final TownDto town;
  final ParcelRepository _repository;

  final formKey = GlobalKey<FormState>();
  final pickupController = TextEditingController();
  final dropoffController = TextEditingController();
  final fullPickupController = TextEditingController();
  final fullDropoffController = TextEditingController();
  final noteController = TextEditingController();
  final thankYouController = TextEditingController();
  final routeSummaryController = TextEditingController();
  final routeTravelNoteController = TextEditingController();

  ParcelRequestType requestType = ParcelRequestType.standardParcel;
  ParcelSize parcelSize = ParcelSize.small;
  UrgencyLevel urgencyLevel = UrgencyLevel.flexible;
  DateTime expiresAt = DateTime.now().toUtc().add(const Duration(days: 2));
  DateTime? routeTravelDate;
  bool requiresPassengerSeat = false;
  bool submitting = false;

  void setRequestType(ParcelRequestType value) {
    requestType = value;
    notifyListeners();
  }

  void setParcelSize(ParcelSize value) {
    parcelSize = value;
    notifyListeners();
  }

  void setUrgency(UrgencyLevel value) {
    urgencyLevel = value;
    notifyListeners();
  }

  void setRequiresPassengerSeat(bool value) {
    requiresPassengerSeat = value;
    notifyListeners();
  }

  Future<bool> submit() async {
    if (!formKey.currentState!.validate()) return false;
    submitting = true;
    notifyListeners();
    try {
      await _repository.create(
        CreateParcelRequestDto(
          townId: town.id,
          requestType: requestType,
          pickupLocation: pickupController.text.trim(),
          dropoffLocation: dropoffController.text.trim(),
          fullPickupAddress: fullPickupController.text.trim(),
          fullDropoffAddress: fullDropoffController.text.trim(),
          parcelSize: parcelSize,
          urgencyLevel: urgencyLevel,
          note: noteController.text.trim().isEmpty
              ? null
              : noteController.text.trim(),
          thankYouOffer: thankYouController.text.trim().isEmpty
              ? null
              : thankYouController.text.trim(),
          expiresAt: expiresAt,
          routeSummary: routeSummaryController.text.trim().isEmpty
              ? null
              : routeSummaryController.text.trim(),
          routeTravelDate: routeTravelDate,
          routeTravelNote: routeTravelNoteController.text.trim().isEmpty
              ? null
              : routeTravelNoteController.text.trim(),
          requiresPassengerSeat: requiresPassengerSeat,
        ),
      );
      return true;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    pickupController.dispose();
    dropoffController.dispose();
    fullPickupController.dispose();
    fullDropoffController.dispose();
    noteController.dispose();
    thankYouController.dispose();
    routeSummaryController.dispose();
    routeTravelNoteController.dispose();
    super.dispose();
  }
}

class PostRequestScreen extends StatelessWidget {
  const PostRequestScreen({super.key, required this.town});

  final TownDto town;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PostRequestViewModel(
        town: town,
        repository: serviceLocator.parcelRepository,
      ),
      child: _PostRequestBody(town: town),
    );
  }
}

class _PostRequestBody extends StatelessWidget {
  const _PostRequestBody({required this.town});

  final TownDto town;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PostRequestViewModel>();
    return Scaffold(
      appBar: AppBar(title: Text('Post in ${town.name}')),
      body: Form(
        key: viewModel.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<ParcelRequestType>(
              initialValue: viewModel.requestType,
              items: const [
                DropdownMenuItem(
                  value: ParcelRequestType.standardParcel,
                  child: Text('Parcel request'),
                ),
                DropdownMenuItem(
                  value: ParcelRequestType.routeRequest,
                  child: Text('Route request'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  viewModel.setRequestType(value);
                }
              },
              decoration: const InputDecoration(labelText: 'Card type'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: viewModel.pickupController,
              decoration: InputDecoration(
                labelText: viewModel.requestType == ParcelRequestType.routeRequest
                    ? 'From'
                    : 'Pickup neighbourhood',
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Please fill this in' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: viewModel.dropoffController,
              decoration: InputDecoration(
                labelText: viewModel.requestType == ParcelRequestType.routeRequest
                    ? 'To'
                    : 'Drop-off neighbourhood',
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Please fill this in' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: viewModel.fullPickupController,
              decoration: const InputDecoration(labelText: 'Full pickup address'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Please fill this in' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: viewModel.fullDropoffController,
              decoration: const InputDecoration(labelText: 'Full drop-off address'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Please fill this in' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ParcelSize>(
              initialValue: viewModel.parcelSize,
              items: const [
                DropdownMenuItem(value: ParcelSize.small, child: Text('Small')),
                DropdownMenuItem(value: ParcelSize.medium, child: Text('Medium')),
                DropdownMenuItem(value: ParcelSize.large, child: Text('Large')),
              ],
              onChanged: (value) {
                if (value != null) {
                  viewModel.setParcelSize(value);
                }
              },
              decoration: const InputDecoration(labelText: 'Size'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<UrgencyLevel>(
              initialValue: viewModel.urgencyLevel,
              items: const [
                DropdownMenuItem(value: UrgencyLevel.flexible, child: Text('Flexible')),
                DropdownMenuItem(value: UrgencyLevel.today, child: Text('Today')),
                DropdownMenuItem(value: UrgencyLevel.urgent, child: Text('Urgent')),
              ],
              onChanged: (value) {
                if (value != null) {
                  viewModel.setUrgency(value);
                }
              },
              decoration: const InputDecoration(labelText: 'Urgency'),
            ),
            const SizedBox(height: 12),
            if (viewModel.requestType == ParcelRequestType.routeRequest) ...[
              TextFormField(
                controller: viewModel.routeSummaryController,
                decoration: const InputDecoration(
                  labelText: 'Route summary',
                  hintText: 'Swellendam to Cape Town, space for one',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: viewModel.routeTravelNoteController,
                decoration: const InputDecoration(
                  labelText: 'Travel note',
                  hintText: 'Leaving early next week',
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: viewModel.requiresPassengerSeat,
                onChanged: (value) {
                  viewModel.setRequiresPassengerSeat(value);
                },
                title: const Text('Needs passenger seat'),
              ),
            ],
            TextFormField(
              controller: viewModel.noteController,
              decoration: const InputDecoration(labelText: 'Note'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: viewModel.thankYouController,
              decoration: const InputDecoration(labelText: 'Thank-you offer'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: viewModel.submitting
                  ? null
                  : () async {
                      final ok =
                          await serviceLocator.mobileSessionManager.ensureAuthenticated();
                      if (!ok) {
                        if (context.mounted) {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AccessCodeEntryScreen(),
                            ),
                          );
                        }
                        return;
                      }

                      try {
                        final created = await viewModel.submit();
                        if (!context.mounted) return;
                        if (created) Navigator.of(context).pop(true);
                      } catch (error) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.toString())),
                        );
                      }
                    },
              child: Text(viewModel.submitting ? 'Posting...' : 'Post request'),
            ),
          ],
        ),
      ),
    );
  }
}
