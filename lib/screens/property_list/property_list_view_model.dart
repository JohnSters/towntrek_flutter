import 'package:flutter/foundation.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import 'property_list_state.dart';

class PropertyListViewModel extends ChangeNotifier {
  final PropertyRepository _propertyRepository;
  final ErrorHandler _errorHandler;
  final int _townId;
  String _searchTerm = '';

  PropertyListState _state = PropertyListLoading();

  PropertyListViewModel({
    required PropertyRepository propertyRepository,
    required ErrorHandler errorHandler,
    required int townId,
  }) : _propertyRepository = propertyRepository,
       _errorHandler = errorHandler,
       _townId = townId {
    load();
  }

  PropertyListState get state => _state;
  String get searchTerm => _searchTerm;

  List<PropertyListingCardDto> filteredItems(
    List<PropertyListingCardDto> items,
  ) {
    final t = _searchTerm.trim().toLowerCase();
    if (t.isEmpty) return items;
    return items.where((p) {
      return p.ownerName.toLowerCase().contains(t) ||
          p.address.toLowerCase().contains(t) ||
          (p.summary?.toLowerCase().contains(t) ?? false) ||
          p.townName.toLowerCase().contains(t) ||
          p.province.toLowerCase().contains(t);
    }).toList();
  }

  void setSearchTerm(String value) {
    if (_searchTerm == value) return;
    _searchTerm = value;
    notifyListeners();
  }

  Future<void> load() async {
    _state = PropertyListLoading();
    notifyListeners();

    try {
      final response = await _propertyRepository.getList(
        townId: _townId,
        page: 1,
        pageSize: 12,
      );
      _state = PropertyListSuccess(
        items: response.items,
        totalCount: response.totalCount,
        currentPage: response.page,
        hasNextPage: response.hasNextPage,
      );
      notifyListeners();
    } catch (e) {
      final appError = await _errorHandler.handleError(e, retryAction: load);
      _state = PropertyListError(appError);
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    final current = _state;
    if (current is! PropertyListSuccess) return;
    if (!current.hasNextPage || current.isLoadingMore) return;

    _state = PropertyListSuccess(
      items: current.items,
      totalCount: current.totalCount,
      currentPage: current.currentPage,
      hasNextPage: current.hasNextPage,
      isLoadingMore: true,
    );
    notifyListeners();

    try {
      final nextPage = current.currentPage + 1;
      final response = await _propertyRepository.getList(
        townId: _townId,
        page: nextPage,
        pageSize: 12,
      );
      _state = PropertyListSuccess(
        items: [...current.items, ...response.items],
        totalCount: response.totalCount,
        currentPage: response.page,
        hasNextPage: response.hasNextPage,
      );
      notifyListeners();
    } catch (e) {
      await _errorHandler.handleError(e, retryAction: loadMore);
      _state = PropertyListSuccess(
        items: current.items,
        totalCount: current.totalCount,
        currentPage: current.currentPage,
        hasNextPage: current.hasNextPage,
      );
      notifyListeners();
    }
  }
}
