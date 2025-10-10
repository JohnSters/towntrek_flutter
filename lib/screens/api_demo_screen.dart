import 'package:flutter/material.dart';
import '../core/core.dart';
import '../models/models.dart';

/// Demonstration screen showing how to use the API consumption layer
class ApiDemoScreen extends StatefulWidget {
  const ApiDemoScreen({super.key});

  @override
  State<ApiDemoScreen> createState() => _ApiDemoScreenState();
}

class _ApiDemoScreenState extends State<ApiDemoScreen> {
  // Example data holders
  List<TownDto>? _towns;
  List<CategoryDto>? _categories;
  BusinessListResponse? _businesses;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  /// Load initial data to demonstrate API usage
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Ensure service locator is initialized
      if (!serviceLocator.isInitialized) {
        serviceLocator.initialize();
      }

      // Load towns and categories in parallel
      final results = await Future.wait([
        serviceLocator.townRepository.getTowns(),
        serviceLocator.businessRepository.getCategories(),
      ]);

      if (mounted) {
        setState(() {
          _towns = results[0] as List<TownDto>;
          _categories = results[1] as List<CategoryDto>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// Load businesses for a specific town (demo)
  Future<void> _loadBusinessesForTown(int townId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Ensure service locator is initialized
      if (!serviceLocator.isInitialized) {
        serviceLocator.initialize();
      }

      final businesses = await serviceLocator.businessRepository.getBusinesses(
        townId: townId,
        pageSize: 10,
      );

      if (mounted) {
        setState(() {
          _businesses = businesses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// Load business details (demo)
  Future<void> _loadBusinessDetails(int businessId) async {
    try {
      // Ensure service locator is initialized
      if (!serviceLocator.isInitialized) {
        serviceLocator.initialize();
      }

      final details = await serviceLocator.businessRepository.getBusinessDetails(businessId);
      // In a real app, you'd navigate to a details screen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loaded details for: ${details.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading business details: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Demo'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0, // No shadow as per style guide
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _buildContentView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading data',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadInitialData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Towns Section
          if (_towns != null) ...[
            Text(
              'Available Towns (${_towns!.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ..._towns!.map((town) => Card(
              child: ListTile(
                title: Text(town.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (town.description != null) Text(town.description!),
                    Text('${town.businessCount} businesses • ${town.province}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                trailing: const Icon(Icons.location_city, color: Colors.blue),
                onTap: () => _loadBusinessesForTown(town.id),
              ),
            )),
            const SizedBox(height: 24),
          ],

          // Categories Section
          if (_categories != null) ...[
            Text(
              'Business Categories (${_categories!.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ..._categories!.map((category) => Card(
              child: ExpansionTile(
                title: Text(category.name),
                subtitle: Text('${category.subCategories.length} subcategories'),
                children: category.subCategories.map((sub) => ListTile(
                  title: Text(sub.name),
                  contentPadding: const EdgeInsets.only(left: 32, right: 16),
                )).toList(),
              ),
            )),
            const SizedBox(height: 24),
          ],

          // Businesses Section (shown when loaded)
          if (_businesses != null) ...[
            Text(
              'Businesses (${_businesses!.totalCount})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ..._businesses!.businesses.map((business) => Card(
              child: ListTile(
                title: Text(business.name),
                subtitle: Text(business.category),
                trailing: business.isVerified
                    ? const Icon(Icons.verified, color: Colors.blue)
                    : null,
                onTap: () => _loadBusinessDetails(business.id),
              ),
            )),
            const SizedBox(height: 12),
            // Pagination info
            Center(
              child: Text(
                'Page ${_businesses!.page} of ${_businesses!.totalPages} (${_businesses!.businesses.length} shown)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],

          // API Usage Examples
          const SizedBox(height: 32),
          Text(
            'API Usage Examples',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _buildApiExample(
            'Load Towns',
            'serviceLocator.townRepository.getTowns()',
            _loadInitialData,
          ),
          _buildApiExample(
            'Search Businesses',
            'serviceLocator.businessRepository.searchBusinesses(query: "restaurant")',
            () => _searchBusinesses("restaurant"),
          ),
          _buildApiExample(
            'Get Categories with Counts',
            'serviceLocator.businessRepository.getCategoriesWithCounts(townId)',
            _towns != null && _towns!.isNotEmpty ? () => _loadCategoriesWithCounts(_towns!.first.id) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildApiExample(String title, String code, VoidCallback? onPressed) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              code,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onPressed,
                child: const Text('Execute'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchBusinesses(String query) async {
    try {
      // Ensure service locator is initialized
      if (!serviceLocator.isInitialized) {
        serviceLocator.initialize();
      }

      final result = await serviceLocator.businessRepository.searchBusinesses(
        query: query,
        pageSize: 5,
      );
      if (mounted) {
        setState(() {
          _businesses = result;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  Future<void> _loadCategoriesWithCounts(int townId) async {
    try {
      // Ensure service locator is initialized
      if (!serviceLocator.isInitialized) {
        serviceLocator.initialize();
      }

      final categories = await serviceLocator.businessRepository.getCategoriesWithCounts(townId);
      // Show in a dialog or update UI
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Categories with Counts'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    title: Text(category.name),
                    trailing: Text('${category.businessCount} businesses'),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: $e')),
        );
      }
    }
  }
}
