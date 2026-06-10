import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../repositories/repositories.dart';
import 'landing_page_state.dart';
import '../../core/constants/landing_page_constants.dart';
import '../../core/utils/logger.dart';

// ViewModel for business logic separation
class LandingViewModel extends ChangeNotifier {
  LandingScreenState _state = LandingScreenLoading();
  LandingScreenState get state => _state;

  final StatsRepository _statsRepository;

  LandingViewModel({required StatsRepository statsRepository})
    : _statsRepository = statsRepository {
    loadStats();
  }

  Future<void> loadStats() async {
    _state = LandingScreenLoading();
    notifyListeners();

    try {
      final stats = await _statsRepository.getLandingStats();
      _state = LandingScreenSuccess(
        businessCount: stats.businessCount,
        serviceCount: stats.serviceCount,
        eventCount: stats.eventCount,
        creativeSpaceCount: stats.creativeSpaceCount,
        propertyListingCount: stats.propertyListingCount,
        equipmentRentalBusinessCount: stats.equipmentRentalBusinessCount,
        infoBannerMessage: stats.infoBannerMessage,
        issueBannerMessage: stats.issueBannerMessage,
      );
      notifyListeners();
    } catch (e) {
      Logger.w('Stats loading error: $e');
      _state = LandingScreenError(e.toString());
      notifyListeners();
    }
  }

  Future<void> launchOwnerUrl(BuildContext context) async {
    final Uri url = Uri.parse(LandingScreenConstants.ownerWebsiteUrl);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(LandingScreenConstants.launchUrlErrorMessage),
            ),
          );
        }
      }
    } catch (e) {
      Logger.w('Error launching URL: $e');
    }
  }

  Future<void> launchFeedbackEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: LandingScreenConstants.feedbackEmail,
    );
    try {
      if (!await launchUrl(emailUri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(LandingScreenConstants.launchEmailErrorMessage),
            ),
          );
        }
      }
    } catch (e) {
      Logger.w('Error launching email: $e');
    }
  }
}
