import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../repositories/repositories.dart';
import 'landing_page_state.dart';
import '../../core/constants/landing_page_constants.dart';

// ViewModel for business logic separation
class LandingViewModel extends ChangeNotifier {
  LandingPageState _state = LandingPageLoading();
  LandingPageState get state => _state;

  final StatsRepository _statsRepository;

  LandingViewModel({required StatsRepository statsRepository})
      : _statsRepository = statsRepository {
    loadStats();
  }

  Future<void> loadStats() async {
    _state = LandingPageLoading();
    notifyListeners();

    try {
      final stats = await _statsRepository.getLandingStats();
      _state = LandingPageSuccess(
        businessCount: stats.businessCount,
        serviceCount: stats.serviceCount,
        eventCount: stats.eventCount,
      );
      notifyListeners();
    } catch (e) {
      _state = LandingPageError(e.toString());
      notifyListeners();
    }
  }

  Future<void> launchOwnerUrl(BuildContext context) async {
    final Uri url = Uri.parse(LandingPageConstants.ownerWebsiteUrl);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(LandingPageConstants.launchUrlErrorMessage)),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}