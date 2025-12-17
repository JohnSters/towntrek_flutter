import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/core.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../core/widgets/error_view.dart';
import '../core/widgets/navigation_footer.dart';
import '../core/widgets/page_header.dart';
import '../core/errors/app_error.dart';
import '../core/errors/error_handler.dart';
import 'town_selection_screen.dart';
import 'town_feature_selection_screen.dart';
import 'service_sub_category_page.dart';

class ServiceCategoryPage extends StatefulWidget {
  final TownDto town;

  const ServiceCategoryPage({
    super.key,
    required this.town,
  });

  @override
  State<ServiceCategoryPage> createState() => _ServiceCategoryPageState();
}

class _ServiceCategoryPageState extends State<ServiceCategoryPage> {
  List<ServiceCategoryDto> _categories = [];
  bool _isLoading = true;
  AppError? _error;
  bool _countsAvailable = true;

  final ServiceRepository _serviceRepository = serviceLocator.serviceRepository;
  final ErrorHandler _errorHandler = serviceLocator.errorHandler;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _countsAvailable = true;
    });

    try {
      // Prefer counts endpoint (enables disabling empty categories).
      // If the endpoint is not deployed/available yet, fall back to plain categories
      // so the app remains usable (no hard failure / no permanent disabling).
      List<ServiceCategoryDto> categories;
      try {
        categories = await _serviceRepository.getCategoriesWithCounts(widget.town.id);
        _countsAvailable = true;
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          categories = await _serviceRepository.getCategories();
          _countsAvailable = false;
        } else {
          rethrow;
        }
      }
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      final appError = await _errorHandler.handleError(e, retryAction: _loadCategories);
      if (mounted) {
        setState(() {
          _error = appError;
          _isLoading = false;
        });
      }
    }
  }

  void _changeTown() {
    Navigator.of(context).push<TownDto>(
      MaterialPageRoute(
        builder: (context) => const TownSelectionScreen(),
      ),
    ).then((selectedTown) {
      if (selectedTown != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TownFeatureSelectionScreen(town: selectedTown),
          ),
        );
      }
    });
  }

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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ErrorView(error: _error!);
    }

    return _buildCategoriesView();
  }

  Widget _buildCategoriesView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        PageHeader(
          title: widget.town.name,
          subtitle: '${widget.town.province} • Services',
          height: 120,
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActionButtons(),
                const SizedBox(height: 24),
                if (_categories.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.handyman,
                          size: 64,
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No service categories found',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return _buildCategoryCard(category);
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _CategoryActionButton(
            icon: Icons.location_on,
            label: 'Change Town',
            onTap: _changeTown,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: SizedBox(), // Placeholder for Events or other action
        ),
      ],
    );
  }

  Widget _buildCategoryCard(ServiceCategoryDto category) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDisabled = _countsAvailable && category.serviceCount == 0;

    return Card(
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
                      builder: (context) => ServiceSubCategoryPage(
                        category: category,
                        town: widget.town,
                        countsAvailable: _countsAvailable,
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
                    children: [
                      Text(
                        category.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDisabled
                              ? colorScheme.onSurface.withValues(alpha: 0.6)
                              : colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        isDisabled
                            ? 'No services available'
                            : _countsAvailable
                                ? '${category.serviceCount} services'
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
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _CategoryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
