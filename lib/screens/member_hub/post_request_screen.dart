import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import 'connect_device_sheet.dart';
import 'parcel_xp_feedback.dart';
import 'post_request_view_model.dart';

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
                            child: Text('Route listing'),
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
                              kEnableOfferingLiftRoutePost &&
                                      viewModel.routeListingPerspective ==
                                          RouteListingPerspective.offeringLift
                                  ? 'Describe your offered trip so it appears clearly on the board.'
                                  : 'Describe your route so it appears clearly on the board.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: listing.bodyText,
                                    height: 1.4,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Listing type',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: listing.textTitle,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ChoiceChip(
                                  label: const Text('I need a lift'),
                                  selected:
                                      viewModel.routeListingPerspective ==
                                      RouteListingPerspective.needLift,
                                  onSelected: (_) =>
                                      viewModel.setRouteListingPerspective(
                                        RouteListingPerspective.needLift,
                                      ),
                                ),
                                ChoiceChip(
                                  label: const Text('I\'m offering a lift'),
                                  selected:
                                      viewModel.routeListingPerspective ==
                                      RouteListingPerspective.offeringLift,
                                  onSelected: kEnableOfferingLiftRoutePost
                                      ? (_) => viewModel
                                            .setRouteListingPerspective(
                                              RouteListingPerspective
                                                  .offeringLift,
                                            )
                                      : null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: viewModel.routeSummaryController,
                              decoration: InputDecoration(
                                labelText: 'Route summary',
                                hintText:
                                    kEnableOfferingLiftRoutePost &&
                                        viewModel.routeListingPerspective ==
                                            RouteListingPerspective.offeringLift
                                    ? 'e.g. Barrydale to Swellendam Wed morning, 2 seats'
                                    : 'e.g. Swellendam to Barrydale — need one seat',
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
                              decoration: InputDecoration(
                                labelText: 'Timing note',
                                hintText:
                                    kEnableOfferingLiftRoutePost &&
                                        viewModel.routeListingPerspective ==
                                            RouteListingPerspective.offeringLift
                                    ? 'e.g. Leaving Wednesday around 8am'
                                    : 'e.g. Flexible this week / must arrive before Friday 5pm',
                              ),
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              value: viewModel.requiresPassengerSeat,
                              onChanged: viewModel.setRequiresPassengerSeat,
                              title: Text(
                                kEnableOfferingLiftRoutePost &&
                                        viewModel.routeListingPerspective ==
                                            RouteListingPerspective.offeringLift
                                    ? 'Passenger seat available'
                                    : 'I will be travelling (need a passenger seat)',
                              ),
                              subtitle: Text(
                                kEnableOfferingLiftRoutePost &&
                                        viewModel.routeListingPerspective ==
                                            RouteListingPerspective.offeringLift
                                    ? 'Turn off if you only have boot or cargo space.'
                                    : 'Turn off if you are only sending goods with someone\'s trip (no seat for you).',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: listing.bodyText),
                              ),
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
                              kEnableOfferingLiftRoutePost &&
                                      viewModel.routeListingPerspective ==
                                          RouteListingPerspective.offeringLift
                                  ? 'Short place names appear on the board. Full addresses are shared only '
                                        'with the member you arrange the trip with.'
                                  : 'Short place names appear on the board. Full addresses are shared only '
                                        'with the member who helps with your trip.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
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
                            validator: (value) =>
                                value == null || value.trim().isEmpty
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
                            validator: (value) =>
                                value == null || value.trim().isEmpty
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
                            validator: (value) =>
                                value == null || value.trim().isEmpty
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
                            validator: (value) =>
                                value == null || value.trim().isEmpty
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
                              decoration: const InputDecoration(
                                labelText: 'Urgency',
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: viewModel.noteController,
                              decoration: const InputDecoration(
                                labelText: 'Note',
                              ),
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
                                labelText: 'Luggage or gear size',
                                helperText:
                                    'Roughly how much space you need for bags or items',
                              ),
                            ),
                            if (!(isRoute &&
                                viewModel.routeTravelDate != null)) ...[
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
                                decoration: const InputDecoration(
                                  labelText: 'How soon do you need a match?',
                                  helperText:
                                      'How quickly you need someone to take the request',
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 10),
                              Text(
                                'You picked a travel date, so timing follows that date. '
                                'Urgency is set to Flexible for this post.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: listing.bodyText,
                                      height: 1.4,
                                    ),
                              ),
                            ],
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
                                hintText:
                                    'Accessibility, child seat, contact preferences, etc.',
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
                            final detail = await viewModel.submit();
                            if (!context.mounted) return;
                            if (detail != null) {
                              serviceLocator.mobileSessionManager
                                  .mergeFromParcelDetail(detail);
                              ParcelXpFeedback.showForDetail(detail);
                              Navigator.of(context).pop(true);
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
    final offering =
        kEnableOfferingLiftRoutePost &&
        viewModel.routeListingPerspective ==
            RouteListingPerspective.offeringLift;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: offering
            ? 'Departure date (optional)'
            : 'Preferred travel date (optional)',
        border: const OutlineInputBorder(),
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
