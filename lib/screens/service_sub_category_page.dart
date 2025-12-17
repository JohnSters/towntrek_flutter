import 'package:flutter/material.dart';
import '../models/models.dart';
import '../core/widgets/navigation_footer.dart';
import '../core/widgets/page_header.dart';
import 'service_list_page.dart';

class ServiceSubCategoryPage extends StatefulWidget {
  final ServiceCategoryDto category;
  final TownDto town;
  final bool countsAvailable;

  const ServiceSubCategoryPage({
    super.key,
    required this.category,
    required this.town,
    this.countsAvailable = true,
  });

  @override
  State<ServiceSubCategoryPage> createState() => _ServiceSubCategoryPageState();
}

class _ServiceSubCategoryPageState extends State<ServiceSubCategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _buildContent(),
          ),
          const BackNavigationFooter(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return _buildSubCategoriesView();
  }

  Widget _buildSubCategoriesView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        PageHeader(
          title: widget.category.name,
          subtitle: 'Choose a specific service in ${widget.town.name}',
          height: 120,
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          Icons.build, // Default icon
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${widget.category.subCategories.length} sub-categories',
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
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: widget.category.subCategories.length,
                    itemBuilder: (context, index) {
                      final subCategory = widget.category.subCategories[index];
                      return _buildSubCategoryCard(subCategory);
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

  Widget _buildSubCategoryCard(ServiceSubCategoryDto subCategory) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDisabled = widget.countsAvailable && subCategory.serviceCount == 0;

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
          onTap: isDisabled
              ? null
              : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ServiceListPage(
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
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDisabled
                        ? colorScheme.surfaceContainerHighest
                        : colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.build,
                    size: 24,
                    color: isDisabled
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSecondaryContainer,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        subCategory.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDisabled
                              ? colorScheme.onSurface.withValues(alpha: 0.6)
                              : colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        isDisabled
                            ? 'No services available'
                            : widget.countsAvailable
                                ? '${subCategory.serviceCount} services'
                                : 'View services',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
