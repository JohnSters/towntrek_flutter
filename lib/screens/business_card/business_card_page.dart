import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../core/utils/business_category_copy.dart';
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
    final listingTheme = BusinessCategoryCopy.listingTheme(viewModel.category.key);
    final backLabel = BusinessCategoryCopy.listingBackFooterLabel(viewModel.category.key);

    return Scaffold(
      backgroundColor: EntityListingTheme.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildContent(context, viewModel, listingTheme),
            ),
            ListingBackFooter(label: backLabel),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    BusinessCardViewModel viewModel,
    EntityListingTheme listingTheme,
  ) {
    final state = viewModel.state;

    if (state is BusinessCardLoading) {
      return _buildLoadingView(context, viewModel, listingTheme);
    }

    if (state is BusinessCardError) {
      return _buildErrorState(
        context,
        error: state.error,
        viewModel: viewModel,
        listingTheme: listingTheme,
      );
    }

    if (state is BusinessCardEmpty) {
      return _buildEmptyView(context, viewModel, listingTheme);
    }

    if (state is BusinessCardSuccess) {
      return _buildBusinessesView(context, viewModel, state, listingTheme);
    }

    return const SizedBox();
  }

  Widget _buildLoadingView(
    BuildContext context,
    BusinessCardViewModel viewModel,
    EntityListingTheme listingTheme,
  ) {
    return BusinessLoadingView(
      category: viewModel.category,
      subCategory: viewModel.subCategory,
      town: viewModel.town,
      listingTheme: listingTheme,
    );
  }

  Widget _buildErrorState(
    BuildContext context, {
    required AppError error,
    required BusinessCardViewModel viewModel,
    required EntityListingTheme listingTheme,
  }) {
    final header = BusinessCardHeroHeader(
      theme: listingTheme,
      subCategoryName: viewModel.subCategory.name,
      categoryName: viewModel.category.name,
      categoryKey: viewModel.category.key,
      townName: viewModel.town.name,
    );

    if (error.actionText != null && error.action != null) {
      return Column(
        children: [
          header,
          Expanded(child: ErrorView(error: error)),
        ],
      );
    }

    return Column(
      children: [
        header,
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              ErrorView(error: error),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: viewModel.loadBusinesses,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyView(
    BuildContext context,
    BusinessCardViewModel viewModel,
    EntityListingTheme listingTheme,
  ) {
    return Column(
      children: [
        BusinessCardHeroHeader(
          theme: listingTheme,
          subCategoryName: viewModel.subCategory.name,
          categoryName: viewModel.category.name,
          categoryKey: viewModel.category.key,
          townName: viewModel.town.name,
        ),
        ListingResultsBand(
          count: viewModel.subCategory.businessCount,
          categoryName: viewModel.subCategory.name,
          bandColor: listingTheme.resultsBand,
        ),
        Expanded(child: BusinessEmptyView(category: viewModel.category)),
      ],
    );
  }

  Widget _buildBusinessesView(
    BuildContext context,
    BusinessCardViewModel viewModel,
    BusinessCardSuccess state,
    EntityListingTheme listingTheme,
  ) {
    return Column(
      children: [
        BusinessCardHeroHeader(
          theme: listingTheme,
          subCategoryName: viewModel.subCategory.name,
          categoryName: viewModel.category.name,
          categoryKey: viewModel.category.key,
          townName: viewModel.town.name,
        ),
        ListingResultsBand(
          count: viewModel.subCategory.businessCount,
          categoryName: viewModel.subCategory.name,
          bandColor: listingTheme.resultsBand,
        ),
        Expanded(
          child: _buildBusinessesList(context, viewModel, state, listingTheme),
        ),
      ],
    );
  }

  Widget _buildBusinessesList(
    BuildContext context,
    BusinessCardViewModel viewModel,
    BusinessCardSuccess state,
    EntityListingTheme listingTheme,
  ) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            !state.isLoadingMore &&
            state.hasMorePages) {
          viewModel.loadBusinesses(loadMore: true);
        }
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.businesses.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == state.businesses.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          final business = state.businesses[index];
          return BusinessCardWidget(
            business: business,
            categoryKey: viewModel.category.key,
            listingTheme: listingTheme,
            townName: viewModel.town.name,
            provinceName: viewModel.town.province,
            onTap: () => viewModel.onBusinessTap(context, business),
          );
        },
      ),
    );
  }
}
