import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import 'connect_device_sheet.dart';
import 'parcel_xp_feedback.dart';

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
    if (value == ParcelRequestType.standardParcel) {
      requiresPassengerSeat = false;
    }
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

  void setRouteTravelDate(DateTime? value) {
    routeTravelDate = value;
    notifyListeners();
  }

  Future<ParcelDetailDto?> submit() async {
    if (!formKey.currentState!.validate()) return null;
    submitting = true;
    notifyListeners();
    try {
      final detail = await _repository.create(
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
      return detail;
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
    final listing = context.entityListing;
    final isRoute = viewModel.requestType == ParcelRequestType.routeRequest;

    return Scaffold(
      backgroundColor: listing.pageBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EntityListingHeroHeader(
              theme: context.entityListingTheme,
              categoryIcon: Icons.add_box_outlined,
              subCategoryName: 'Post a request',
              categoryName: TownFeatureConstants.parcelsTitle,
              townName: town.name,
            ),
            Expanded(
              child: Form(
                key: viewModel.formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  children: [
            DetailSectionShell(
              title: 'Request type',
              icon: Icons.category_outlined,
              child: DropdownButtonFormField<ParcelRequestType>(
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
                decoration: const InputDecoration(
                  labelText: 'What are you posting?',
                ),
              ),
            ),
            if (isRoute) ...[
              const SizedBox(height: 12),
              DetailSectionShell(
                title: 'Route & ride',
                icon: Icons.alt_route_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Describe the lift you need so drivers can see it on the board. '
                      'Pickup and exact addresses come in the next section.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: listing.bodyText,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: viewModel.routeSummaryController,
                      decoration: const InputDecoration(
                        labelText: 'Route summary',
                        hintText: 'e.g. Swellendam to Barrydale, one seat',
                      ),
                      maxLength: 200,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please add a short route summary';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _RouteTravelDateRow(viewModel: viewModel),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: viewModel.routeTravelNoteController,
                      decoration: const InputDecoration(
                        labelText: 'Travel / timing note',
                        hintText: 'e.g. Leaving Tuesday morning',
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: viewModel.requiresPassengerSeat,
                      onChanged: viewModel.setRequiresPassengerSeat,
                      title: const Text('Needs a passenger seat'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            DetailSectionShell(
              title: isRoute ? 'Pickup & drop-off' : 'Places',
              icon: Icons.place_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isRoute)
                    Text(
                      'Public labels appear on the board; full addresses are shared only '
                      'with the member who takes your request.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: listing.bodyText,
                        height: 1.4,
                      ),
                    ),
                  if (isRoute) const SizedBox(height: 12),
                  TextFormField(
                    controller: viewModel.pickupController,
                    decoration: InputDecoration(
                      labelText: isRoute
                          ? 'From (area or landmark)'
                          : 'Pickup neighbourhood',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please fill this in'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: viewModel.dropoffController,
                    decoration: InputDecoration(
                      labelText: isRoute
                          ? 'To (area or landmark)'
                          : 'Drop-off neighbourhood',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please fill this in'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: viewModel.fullPickupController,
                    decoration: InputDecoration(
                      labelText: isRoute
                          ? 'Full address at pickup / start'
                          : 'Full pickup address',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please fill this in'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: viewModel.fullDropoffController,
                    decoration: InputDecoration(
                      labelText: isRoute
                          ? 'Full address at drop-off / end'
                          : 'Full drop-off address',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please fill this in'
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (!isRoute)
              DetailSectionShell(
                title: 'Parcel details',
                icon: Icons.inventory_2_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<ParcelSize>(
                      initialValue: viewModel.parcelSize,
                      items: const [
                        DropdownMenuItem(
                          value: ParcelSize.small,
                          child: Text('Small'),
                        ),
                        DropdownMenuItem(
                          value: ParcelSize.medium,
                          child: Text('Medium'),
                        ),
                        DropdownMenuItem(
                          value: ParcelSize.large,
                          child: Text('Large'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          viewModel.setParcelSize(value);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Parcel size',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<UrgencyLevel>(
                      initialValue: viewModel.urgencyLevel,
                      items: const [
                        DropdownMenuItem(
                          value: UrgencyLevel.flexible,
                          child: Text('Flexible'),
                        ),
                        DropdownMenuItem(
                          value: UrgencyLevel.today,
                          child: Text('Today'),
                        ),
                        DropdownMenuItem(
                          value: UrgencyLevel.urgent,
                          child: Text('Urgent'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          viewModel.setUrgency(value);
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Urgency'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: viewModel.noteController,
                      decoration: const InputDecoration(labelText: 'Note'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: viewModel.thankYouController,
                      decoration: const InputDecoration(
                        labelText: 'Thank-you offer',
                      ),
                    ),
                  ],
                ),
              )
            else
              DetailSectionShell(
                title: 'Trip logistics',
                icon: Icons.tune_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<ParcelSize>(
                      initialValue: viewModel.parcelSize,
                      items: const [
                        DropdownMenuItem(
                          value: ParcelSize.small,
                          child: Text('Small'),
                        ),
                        DropdownMenuItem(
                          value: ParcelSize.medium,
                          child: Text('Medium'),
                        ),
                        DropdownMenuItem(
                          value: ParcelSize.large,
                          child: Text('Large'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          viewModel.setParcelSize(value);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Space / load size',
                        helperText: 'Approximate luggage or cargo volume',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<UrgencyLevel>(
                      initialValue: viewModel.urgencyLevel,
                      items: const [
                        DropdownMenuItem(
                          value: UrgencyLevel.flexible,
                          child: Text('Flexible'),
                        ),
                        DropdownMenuItem(
                          value: UrgencyLevel.today,
                          child: Text('Today'),
                        ),
                        DropdownMenuItem(
                          value: UrgencyLevel.urgent,
                          child: Text('Urgent'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          viewModel.setUrgency(value);
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Urgency'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: viewModel.thankYouController,
                      decoration: const InputDecoration(
                        labelText: 'Thank-you offer',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: viewModel.noteController,
                      decoration: const InputDecoration(
                        labelText: 'Other notes (optional)',
                        hintText: 'Anything else helpers should know',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
          ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: viewModel.submitting
                      ? null
                      : () async {
                          await runWithParcelSession(context, () async {
                            try {
                              final detail = await viewModel.submit();
                              if (!context.mounted) return;
                              if (detail != null) {
                                serviceLocator.mobileSessionManager
                                    .mergeFromParcelDetail(detail);
                                ParcelXpFeedback.showForDetail(detail);
                                Navigator.of(context).pop(true);
                              }
                            } catch (error) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error.toString())),
                              );
                            }
                          });
                        },
                  child: Text(
                    viewModel.submitting ? 'Posting...' : 'Post request',
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
}

class _RouteTravelDateRow extends StatelessWidget {
  const _RouteTravelDateRow({required this.viewModel});

  final PostRequestViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = viewModel.routeTravelDate == null
        ? 'No date selected'
        : DateFormat.yMMMd().format(viewModel.routeTravelDate!.toLocal());

    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Travel date (optional)',
        border: OutlineInputBorder(),
      ),
      child: Row(
        children: [
          Expanded(child: Text(summary, style: theme.textTheme.bodyLarge)),
          IconButton(
            tooltip: 'Choose date',
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () async {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final picked = await showDatePicker(
                context: context,
                initialDate: viewModel.routeTravelDate ?? today,
                firstDate: today,
                lastDate: today.add(const Duration(days: 365 * 2)),
              );
              if (picked != null) {
                viewModel.setRouteTravelDate(
                  DateTime(picked.year, picked.month, picked.day),
                );
              }
            },
          ),
          if (viewModel.routeTravelDate != null)
            IconButton(
              tooltip: 'Clear date',
              icon: const Icon(Icons.clear),
              onPressed: () => viewModel.setRouteTravelDate(null),
            ),
        ],
      ),
    );
  }
}
