import 'package:flutter/foundation.dart';
import '../../core/core.dart';
import '../../repositories/repositories.dart';
import 'creative_space_detail_state.dart';

/// ViewModel for Creative Space detail page
class CreativeSpaceDetailViewModel extends ChangeNotifier {
  final CreativeSpaceRepository _creativeSpaceRepository;
  final ErrorHandler _errorHandler;
  final int creativeSpaceId;
  final String creativeSpaceName;

  CreativeSpaceDetailState _state = CreativeSpaceDetailLoading();

  CreativeSpaceDetailViewModel({
    required CreativeSpaceRepository creativeSpaceRepository,
    required ErrorHandler errorHandler,
    required this.creativeSpaceId,
    required this.creativeSpaceName,
  })  : _creativeSpaceRepository = creativeSpaceRepository,
        _errorHandler = errorHandler {
    loadCreativeSpaceDetails();
  }

  CreativeSpaceDetailState get state => _state;

  String get title => creativeSpaceName;

  /// Loads creative space detail information
  Future<void> loadCreativeSpaceDetails() async {
    _state = CreativeSpaceDetailLoading();
    notifyListeners();

    try {
      final response = await _creativeSpaceRepository.getCreativeSpaceDetails(
        creativeSpaceId,
      );
      _state = CreativeSpaceDetailSuccess(creativeSpace: response);
      notifyListeners();
    } catch (error) {
      final appError = await _errorHandler.handleError(
        error,
        retryAction: loadCreativeSpaceDetails,
      );
      _state = CreativeSpaceDetailError(appError);
      notifyListeners();
    }
  }

  /// Retry loading details
  Future<void> retry() async {
    await loadCreativeSpaceDetails();
  }
}
