import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import 'business_card_state.dart';
import 'business_card_view_model.dart';
import 'widgets/widgets.dart';

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
          headerType: HeaderType.business,
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
          headerType: HeaderType.business,
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