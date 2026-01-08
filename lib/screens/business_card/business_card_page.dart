import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import '../business_details/business_details.dart';
import 'widgets/widgets.dart';

/// State classes for Business Card page
sealed class BusinessCardState {}

class BusinessCardLoading extends BusinessCardState {}

class BusinessCardSuccess extends BusinessCardState {
  final List<BusinessDto> businesses;
  final bool hasMorePages;
  final bool isLoadingMore;

  BusinessCardSuccess({
    required this.businesses,
    required this.hasMorePages,
    this.isLoadingMore = false,
  });

  BusinessCardSuccess copyWith({
    List<BusinessDto>? businesses,
    bool? hasMorePages,
    bool? isLoadingMore,
  }) {
    return BusinessCardSuccess(
      businesses: businesses ?? this.businesses,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class BusinessCardError extends BusinessCardState {
  final AppError error;
  BusinessCardError(this.error);
}

class BusinessCardEmpty extends BusinessCardState {}

/// ViewModel for Business Card page business logic
class BusinessCardViewModel extends ChangeNotifier {
  final BusinessRepository _businessRepository;
  final ErrorHandler _errorHandler;

  BusinessCardState _state = BusinessCardLoading();
  BusinessCardState get state => _state;

  final CategoryWithCountDto category;
  final SubCategoryWithCountDto subCategory;
  final TownDto town;

  int _currentPage = 1;

  BusinessCardViewModel({
    required this.category,
    required this.subCategory,
    required this.town,
    required BusinessRepository businessRepository,
    required ErrorHandler errorHandler,
  })  : _businessRepository = businessRepository,
        _errorHandler = errorHandler {
    loadBusinesses();
  }

  Future<void> loadBusinesses({bool loadMore = false}) async {
    if (loadMore && _state is BusinessCardSuccess) {
      final currentState = _state as BusinessCardSuccess;
      if (!currentState.hasMorePages || currentState.isLoadingMore) return;

      _state = currentState.copyWith(isLoadingMore: true);
      notifyListeners();
    } else {
      _state = BusinessCardLoading();
      notifyListeners();
      _currentPage = 1;
    }

    try {
      final response = await _businessRepository.getBusinesses(
        townId: town.id,
        category: category.key,
        subCategory: subCategory.key,
        page: loadMore ? _currentPage + 1 : 1,
        pageSize: BusinessCardConstants.pageSize,
      );

      if (loadMore && _state is BusinessCardSuccess) {
        final currentState = _state as BusinessCardSuccess;
        final newBusinesses = [...currentState.businesses, ...response.businesses];
        _state = BusinessCardSuccess(
          businesses: newBusinesses,
          hasMorePages: response.businesses.length == BusinessCardConstants.pageSize,
          isLoadingMore: false,
        );
        _currentPage++;
      } else {
        if (response.businesses.isEmpty) {
          _state = BusinessCardEmpty();
        } else {
          _state = BusinessCardSuccess(
            businesses: response.businesses,
            hasMorePages: response.businesses.length == BusinessCardConstants.pageSize,
          );
        }
      }
      notifyListeners();
    } catch (e) {
      final appError = await _errorHandler.handleError(
        e,
        retryAction: () => loadBusinesses(loadMore: loadMore),
      );
      _state = BusinessCardError(appError);
      notifyListeners();
    }
  }

  void onBusinessTap(BuildContext context, BusinessDto business) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BusinessDetailsPage(
          businessId: business.id,
          businessName: business.name,
        ),
      ),
    );
  }
}

/// Page for displaying businesses in a beautiful card layout for a selected sub-category
class BusinessCardPage extends StatelessWidget {
  final CategoryWithCountDto category;
  final SubCategoryWithCountDto subCategory;
  final TownDto town;

  const BusinessCardPage({
    super.key,
    required this.category,
    required this.subCategory,
    required this.town,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BusinessCardViewModel(
        category: category,
        subCategory: subCategory,
        town: town,
        businessRepository: serviceLocator.businessRepository,
        errorHandler: serviceLocator.errorHandler,
      ),
      child: const _BusinessCardPageContent(),
    );
  }
}

class _BusinessCardPageContent extends StatelessWidget {
  const _BusinessCardPageContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BusinessCardViewModel>();

    return Scaffold(
      body: Column(
        children: [
          // Main content area
          Expanded(
            child: _buildContent(context, viewModel),
          ),

          // Navigation footer
          const BackNavigationFooter(),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, BusinessCardViewModel viewModel) {
    final state = viewModel.state;

    if (state is BusinessCardLoading) {
      return _buildLoadingView(context, viewModel);
    }

    if (state is BusinessCardError) {
      return _buildErrorView(context, viewModel, state);
    }

    if (state is BusinessCardEmpty) {
      return _buildEmptyView(context, viewModel);
    }

    if (state is BusinessCardSuccess) {
      return _buildBusinessesView(context, viewModel, state);
    }

    return const SizedBox();
  }

  Widget _buildLoadingView(BuildContext context, BusinessCardViewModel viewModel) {
    return BusinessLoadingView(
      category: viewModel.category,
      subCategory: viewModel.subCategory,
      town: viewModel.town,
    );
  }

  Widget _buildErrorView(BuildContext context, BusinessCardViewModel viewModel, BusinessCardError state) {
    return Column(
      children: [
        PageHeader(
          title: viewModel.subCategory.name,
          subtitle: '${viewModel.category.name} in ${viewModel.town.name}',
          height: BusinessCardConstants.loadingHeaderHeight,
        ),
        Expanded(
          child: ErrorView(error: state.error),
        ),
      ],
    );
  }

  Widget _buildEmptyView(BuildContext context, BusinessCardViewModel viewModel) {
    return BusinessEmptyView(category: viewModel.category);
  }

  Widget _buildBusinessesView(BuildContext context, BusinessCardViewModel viewModel, BusinessCardSuccess state) {
    return Column(
      children: [
        // Page Header
        PageHeader(
          title: viewModel.subCategory.name,
          subtitle: '${viewModel.category.name} in ${viewModel.town.name}',
          height: BusinessCardConstants.successHeaderHeight,
        ),

        // Business count info
        BusinessCountInfo(
          category: viewModel.category,
          subCategory: viewModel.subCategory,
        ),

        // Businesses Grid/List
        Expanded(
          child: _buildBusinessesList(context, viewModel, state),
        ),
      ],
    );
  }

  Widget _buildBusinessesList(BuildContext context, BusinessCardViewModel viewModel, BusinessCardSuccess state) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            !state.isLoadingMore &&
            state.hasMorePages) {
          viewModel.loadBusinesses(loadMore: true);
        }
        return false;
      },
      child: ListView.builder(
        padding: EdgeInsets.all(BusinessCardConstants.listPadding),
        itemCount: state.businesses.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.businesses.length) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(BusinessCardConstants.loadingIndicatorPadding),
                child: const CircularProgressIndicator(),
              ),
            );
          }
          final business = state.businesses[index];
          return BusinessCardWidget(
            business: business,
            onTap: () => viewModel.onBusinessTap(context, business),
          );
        },
      ),
    );
  }
}