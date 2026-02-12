import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import '../../services/navigation_service.dart';
import '../../core/utils/external_link_launcher.dart';
import '../../core/utils/url_utils.dart';
import 'business_details_state.dart';

/// ViewModel for Business Details page business logic
class BusinessDetailsViewModel extends ChangeNotifier {
  final BusinessRepository _businessRepository;
  final NavigationService _navigationService;
  final ErrorHandler _errorHandler;

  BusinessDetailsState _state = BusinessDetailsLoading();
  BusinessDetailsState get state => _state;

  final int businessId;
  final String businessName;

  BusinessDetailsViewModel({
    required this.businessId,
    required this.businessName,
    required BusinessRepository businessRepository,
    required NavigationService navigationService,
    required ErrorHandler errorHandler,
  })  : _businessRepository = businessRepository,
        _navigationService = navigationService,
        _errorHandler = errorHandler {
    loadBusinessDetails();
  }

  Future<void> loadBusinessDetails() async {
    _state = BusinessDetailsLoading();
    notifyListeners();

    try {
      final details = await _businessRepository.getBusinessDetails(businessId);
      _state = BusinessDetailsSuccess(details);
      notifyListeners();
    } catch (e) {
      final appError = await _errorHandler.handleError(
        e,
        retryAction: loadBusinessDetails,
      );
      _state = BusinessDetailsError(appError);
      notifyListeners();
    }
  }

  Future<void> navigateToBusiness(BuildContext context, BusinessDetailDto business) async {
    try {
      final result = await _navigationService.navigateToBusiness(business);
      if (result.isFailure) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? BusinessDetailsConstants.navigationFailedMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(BusinessDetailsConstants.navigationErrorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> rateBusiness(BuildContext context, BusinessDetailDto business) async {
    final businessPath = '${BusinessDetailsConstants.publicBusinessPath}${business.id}'
        '${BusinessDetailsConstants.reviewsSectionAnchor}';
    final businessUrl = UrlUtils.resolveApiUrl(businessPath);

    await ExternalLinkLauncher.openWebsite(
      context,
      businessUrl,
      failureMessage: 'Unable to open reviews page',
    );
  }
}