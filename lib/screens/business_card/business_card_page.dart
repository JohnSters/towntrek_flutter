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
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          children: [
            // Main content area
            Expanded(
              child: _buildContent(context, viewModel),
            ),

            // Navigation footer
            const _BackToPropertiesFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BusinessCardViewModel viewModel) {
    final state = viewModel.state;

    if (state is BusinessCardLoading) {
      return _buildLoadingView(context, viewModel);
    }

    if (state is BusinessCardError) {
      return _buildErrorState(context, error: state.error, viewModel: viewModel);
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

  Widget _buildErrorState(
    BuildContext context, {
    required AppError error,
    required BusinessCardViewModel viewModel,
  }) {
    final header = BusinessCardHeroHeader(
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

  Widget _buildEmptyView(BuildContext context, BusinessCardViewModel viewModel) {
    return BusinessEmptyView(category: viewModel.category);
  }

  Widget _buildBusinessesView(BuildContext context, BusinessCardViewModel viewModel, BusinessCardSuccess state) {
    return Column(
      children: [
        BusinessCardHeroHeader(
          subCategoryName: viewModel.subCategory.name,
          categoryName: viewModel.category.name,
          categoryKey: viewModel.category.key,
          townName: viewModel.town.name,
        ),
        _ResultsLabel(
          count: viewModel.subCategory.businessCount,
          categoryName: viewModel.subCategory.name,
        ),
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
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.businesses.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == state.businesses.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: const CircularProgressIndicator(),
              ),
            );
          }
          final business = state.businesses[index];
          return BusinessCardWidget(
            business: business,
            categoryKey: viewModel.category.key,
            townName: viewModel.town.name,
            provinceName: viewModel.town.province,
            onTap: () => viewModel.onBusinessTap(context, business),
          );
        },
      ),
    );
  }
}

class _ResultsLabel extends StatelessWidget {
  final int count;
  final String categoryName;

  const _ResultsLabel({
    required this.count,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final resultText = count == 1 ? '1 result' : '$count results';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1A3A62),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            resultText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
          Flexible(
            child: Text(
              categoryName,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.85),
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackToPropertiesFooter extends StatelessWidget {
  const _BackToPropertiesFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F4F8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: SafeArea(
        top: false,
        child: Center(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.13),
                  width: 0.5,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back,
                    size: 13,
                    color: Color(0xFF3D5068),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Back to properties',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF3D5068),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}