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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Main content area
            Expanded(
              child: _buildContent(context, viewModel),
            ),

            // Navigation footer
            const BackNavigationFooter(),
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
        PageHeader(
          title: viewModel.subCategory.name,
          subtitle: '${viewModel.category.name} in ${viewModel.town.name}',
          height: BusinessCardConstants.successHeaderHeight,
          headerType: HeaderType.business,
        ),
        _ListInfoBar(
          icon: Icons.business_center_rounded,
          text:
              '${viewModel.subCategory.businessCount} businesses \u2022 ${viewModel.subCategory.name}',
          backgroundColor: const Color(0xFFE9F7EF),
          textColor: const Color(0xFF1D7A38),
          borderColor: const Color(0xFFBFE5CB),
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
            onTap: () => viewModel.onBusinessTap(context, business),
          );
        },
      ),
    );
  }
}

class _ListInfoBar extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const _ListInfoBar({
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}