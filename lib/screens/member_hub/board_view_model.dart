import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';

enum BoardListFilter { all, parcels, routes }

/// Sub-filter for route rows when primary filter is All or Routes.
enum BoardRoutePerspectiveFilter { any, needLift, offeringLift }

class ParcelBoardViewModel extends ChangeNotifier {
  ParcelBoardViewModel({
    required this.town,
    required ParcelRepository repository,
  }) : _repository = repository {
    load();
  }

  final TownDto town;
  final ParcelRepository _repository;

  bool loading = true;
  String? error;
  List<ParcelSummaryDto> items = [];
  BoardListFilter listFilter = BoardListFilter.all;
  BoardRoutePerspectiveFilter routePerspectiveFilter =
      BoardRoutePerspectiveFilter.any;

  List<ParcelSummaryDto> get visibleItems {
    Iterable<ParcelSummaryDto> row = switch (listFilter) {
      BoardListFilter.all => items,
      BoardListFilter.parcels => items.where(
        (p) => p.requestType == ParcelRequestType.standardParcel,
      ),
      BoardListFilter.routes => items.where(
        (p) => p.requestType == ParcelRequestType.routeRequest,
      ),
    };
    if (listFilter == BoardListFilter.all ||
        listFilter == BoardListFilter.routes) {
      if (routePerspectiveFilter == BoardRoutePerspectiveFilter.needLift) {
        row = row.where(
          (p) =>
              p.requestType != ParcelRequestType.routeRequest ||
              p.routeListingPerspective == RouteListingPerspective.needLift,
        );
      } else if (routePerspectiveFilter ==
          BoardRoutePerspectiveFilter.offeringLift) {
        row = row.where(
          (p) =>
              p.requestType != ParcelRequestType.routeRequest ||
              p.routeListingPerspective == RouteListingPerspective.offeringLift,
        );
      }
    }
    return row.toList();
  }

  void setListFilter(BoardListFilter value) {
    if (listFilter == value) return;
    listFilter = value;
    notifyListeners();
  }

  void setRoutePerspectiveFilter(BoardRoutePerspectiveFilter value) {
    if (routePerspectiveFilter == value) return;
    routePerspectiveFilter = value;
    notifyListeners();
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final response = await _repository.getBoard(town.id);
      items = response.items;
    } catch (err) {
      error = resolveUserFacingApiError(err);
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
