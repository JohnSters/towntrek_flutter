import 'package:flutter/cupertino.dart';
import '../../core/core.dart';
import '../../core/utils/external_link_launcher.dart';
import '../../core/utils/url_utils.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import '../../core/errors/error_handler.dart';
import '../../core/constants/service_detail_constants.dart';
import 'service_detail_state.dart';

/// ViewModel for Service Detail page
/// Handles service detail loading and state management
class ServiceDetailViewModel extends ChangeNotifier {
  final ServiceRepository _serviceRepository;
  final ErrorHandler _errorHandler;
  final int serviceId;
  final String serviceName;

  ServiceDetailState _state;

  ServiceDetailViewModel({
    required ServiceRepository serviceRepository,
    required ErrorHandler errorHandler,
    required this.serviceId,
    required this.serviceName,
  })  : _serviceRepository = serviceRepository,
        _errorHandler = errorHandler,
        _state = ServiceDetailLoading() {
    loadServiceDetails();
  }

  /// Current state of the service detail page
  ServiceDetailState get state => _state;

  /// Load service details
  Future<void> loadServiceDetails() async {
    _state = ServiceDetailLoading();
    notifyListeners();

    try {
      final serviceDetails = await _serviceRepository.getServiceDetails(serviceId);
      _state = ServiceDetailSuccess(serviceDetails: serviceDetails);
      notifyListeners();
    } catch (e) {
      await _errorHandler.handleError(
        e,
        retryAction: loadServiceDetails,
      );

      _state = ServiceDetailError(
        title: ServiceDetailConstants.refreshErrorTitle,
        message: ServiceDetailConstants.refreshErrorMessage,
      );

      notifyListeners();
    }
  }

  /// Retry loading service details
  Future<void> retry() async {
    await loadServiceDetails();
  }

  Future<void> rateService(BuildContext context, ServiceDetailDto service) async {
    final servicePath = '${ServiceDetailConstants.publicServicePath}${service.id}'
        '${ServiceDetailConstants.reviewsSectionAnchor}';
    final serviceUrl = UrlUtils.resolveApiUrl(servicePath);

    await ExternalLinkLauncher.openWebsite(
      context,
      serviceUrl,
      failureMessage: ServiceDetailConstants.openReviewsFailedMessage,
    );
  }

  Future<void> openFullServiceDetails(BuildContext context, ServiceDetailDto service) async {
    final servicePath = '${ServiceDetailConstants.publicServicePath}${service.id}';
    final serviceUrl = UrlUtils.resolveApiUrl(servicePath);

    await ExternalLinkLauncher.openWebsite(
      context,
      serviceUrl,
      failureMessage: 'Unable to open full service details',
    );
  }
}