import 'package:flutter/material.dart';
import '../models/models.dart';
import '../core/config/business_category_config.dart';
import '../core/widgets/navigation_footer.dart';
import '../core/widgets/page_header.dart';
import 'business_card_page.dart';

/// Page for displaying business sub-categories for a selected category
class BusinessSubCategoryPage extends StatefulWidget {
  final CategoryWithCountDto category;
  final TownDto town;

  const BusinessSubCategoryPage({
    super.key,
    required this.category,
    required this.town,
  });

  @override
  State<BusinessSubCategoryPage> createState() => _BusinessSubCategoryPageState();
}

class _BusinessSubCategoryPageState extends State<BusinessSubCategoryPage> {
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // No additional loading needed as sub-categories are already available
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Main content area
          Expanded(
            child: _buildContent(),
          ),

          // Navigation footer
          BackNavigationFooter(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingView();
    }

    return _buildSubCategoriesView();
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildSubCategoriesView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Page Header
        PageHeader(
          title: widget.category.name,
          subtitle: 'Choose a specific type in ${widget.town.name}',
          height: 120,
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtitle with category info
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          BusinessCategoryConfig.getCategoryIcon(widget.category.key),
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${widget.category.businessCount} total businesses • ${widget.category.subCategories.length} sub-categories',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Sub-categories grid
                if (widget.category.subCategories.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.category,
                          size: 64,
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No sub-categories found',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Builder(
                    builder: (context) {
                      // Sort subcategories: active ones (with businesses) first, then inactive ones
                      final sortedSubCategories = [...widget.category.subCategories]
                        ..sort((a, b) {
                          // Primary sort: businesses with count > 0 come first
                          if (a.businessCount > 0 && b.businessCount == 0) return -1;
                          if (a.businessCount == 0 && b.businessCount > 0) return 1;
                          // Secondary sort: alphabetical by name for same business count
                          return a.name.compareTo(b.name);
                        });

                      return SizedBox(
                        width: double.infinity,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: sortedSubCategories.length,
                          itemBuilder: (context, index) {
                            final subCategory = sortedSubCategories[index];
                            return _buildSubCategoryCard(subCategory);
                          },
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubCategoryCard(SubCategoryWithCountDto subCategory) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDisabled = subCategory.businessCount == 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1.0,
        child: InkWell(
          onTap: isDisabled ? null : () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BusinessCardPage(
                  category: widget.category,
                  subCategory: subCategory,
                  town: widget.town,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Icon Container - use category icon since sub-category doesn't have its own
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: BusinessCategoryConfig.getCategoryColor(widget.category.key, colorScheme),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    BusinessCategoryConfig.getCategoryIcon(widget.category.key),
                    size: 24,
                    color: BusinessCategoryConfig.getCategoryIconColor(widget.category.key, colorScheme),
                  ),
                ),

                const SizedBox(width: 16),

                // Title and Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        subCategory.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDisabled
                              ? colorScheme.onSurface.withValues(alpha: 0.5)
                              : colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 2),

                      // Description
                      Text(
                        subCategory.businessCount == 0
                            ? 'No businesses yet'
                            : '${subCategory.businessCount} businesses',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDisabled
                              ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                              : colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Arrow Icon
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: isDisabled
                      ? colorScheme.onSurfaceVariant.withValues(alpha: 0.3)
                      : colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
