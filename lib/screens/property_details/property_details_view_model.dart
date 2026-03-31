import 'package:flutter/material.dart';

import '../../core/constants/property_details_constants.dart';
import '../../core/core.dart';
import '../../core/utils/external_link_launcher.dart';
import '../../core/utils/url_utils.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import '../../services/navigation_service.dart';
import 'property_details_state.dart';

class PropertyDetailsViewModel extends ChangeNotifier {
  final PropertyRepository _propertyRepository;
  final NavigationService _navigationService;
  final ErrorHandler _errorHandler;

  PropertyDetailsState _state = PropertyDetailsLoading();
  PropertyDetailsState get state => _state;

  final int listingId;
  final String titleFallback;

  PropertyDetailsViewModel({
    required this.listingId,
    required this.titleFallback,
    required PropertyRepository propertyRepository,
    required NavigationService navigationService,
    required ErrorHandler errorHandler,
  })  : _propertyRepository = propertyRepository,
        _navigationService = navigationService,
        _errorHandler = errorHandler {
    load();
  }

  Future<void> load() async {
    _state = PropertyDetailsLoading();
    notifyListeners();

    try {
      final listing = await _propertyRepository.getDetail(listingId);
      _state = PropertyDetailsSuccess(listing);
      notifyListeners();
    } catch (e) {
      final appError = await _errorHandler.handleError(e, retryAction: load);
      _state = PropertyDetailsError(appError);
      notifyListeners();
    }
  }

  Future<void> openDirections(BuildContext context, PropertyListingDetailDto listing) async {
    if (listing.latitude == null || listing.longitude == null) return;
    final label = listing.address.trim().isNotEmpty ? listing.address : listing.townName;
    try {
      final result = await _navigationService.openExternalNavigation(
        listing.latitude!,
        listing.longitude!,
        label,
      );
      if (result.isFailure && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? PropertyDetailsConstants.navigationFailedMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(PropertyDetailsConstants.navigationErrorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> openFullListingOnWeb(BuildContext context) async {
    final path = '${PropertyDetailsConstants.publicPropertyPath}$listingId';
    final url = UrlUtils.resolveApiUrl(path);
    await ExternalLinkLauncher.openWebsite(
      context,
      url,
      failureMessage: 'Unable to open listing in browser',
    );
  }
}
