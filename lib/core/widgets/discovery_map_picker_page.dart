import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../core.dart';
import 'discovery_map_widget.dart';

typedef DiscoveryLocationSelection = ({double latitude, double longitude});

class DiscoveryMapPickerPage extends StatefulWidget {
  const DiscoveryMapPickerPage({
    super.key,
    required this.title,
    this.initialLatitude,
    this.initialLongitude,
    this.fallbackCenterLat,
    this.fallbackCenterLng,
    this.selectionEnabled = true,
    this.enableSearch = true,
    this.confirmLabel = 'Use this location',
  });

  final String title;
  final double? initialLatitude;
  final double? initialLongitude;
  final double? fallbackCenterLat;
  final double? fallbackCenterLng;
  final bool selectionEnabled;
  final bool enableSearch;
  final String confirmLabel;

  @override
  State<DiscoveryMapPickerPage> createState() => _DiscoveryMapPickerPageState();
}

class _DiscoveryMapPickerPageState extends State<DiscoveryMapPickerPage> {
  final TextEditingController _searchController = TextEditingController();

  List<_MapSearchResult> _results = const [];
  bool _searching = false;
  String? _searchError;
  late double? _selectedLat = widget.initialLatitude;
  late double? _selectedLng = widget.initialLongitude;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _runSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _results = const [];
        _searchError = 'Enter a place name or address to search.';
      });
      return;
    }

    setState(() {
      _searching = true;
      _searchError = null;
    });

    try {
      final token = await serviceLocator.configService.getMapboxAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Map search is unavailable right now.');
      }

      final encodedQuery = Uri.encodeComponent(query);
      final response = await serviceLocator.apiClient.dio
          .get<Map<String, dynamic>>(
            'https://api.mapbox.com/geocoding/v5/mapbox.places/$encodedQuery.json',
            queryParameters: {
              'access_token': token,
              'autocomplete': true,
              'limit': 6,
              'country': 'za',
              'language': 'en',
              'types': 'place,locality,neighborhood,address,poi',
              if (widget.fallbackCenterLng != null &&
                  widget.fallbackCenterLat != null)
                'proximity':
                    '${widget.fallbackCenterLng},${widget.fallbackCenterLat}',
            },
            options: Options(
              validateStatus: (status) => status != null && status < 500,
            ),
          );

      final statusCode = response.statusCode ?? 500;
      if (statusCode >= 400) {
        throw Exception('Map search is temporarily unavailable.');
      }

      final features = response.data?['features'] as List<dynamic>? ?? const [];
      final results = features
          .map(_MapSearchResult.fromFeature)
          .whereType<_MapSearchResult>()
          .toList(growable: false);

      if (!mounted) return;
      setState(() {
        _results = results;
        _searchError = results.isEmpty ? 'No matching places found.' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _results = const [];
        _searchError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _searching = false;
        });
      }
    }
  }

  void _applySearchResult(_MapSearchResult result) {
    setState(() {
      _selectedLat = result.latitude;
      _selectedLng = result.longitude;
      _results = const [];
      _searchError = null;
      _searchController.text = result.title;
    });
  }

  void _recenterToTown() {
    if (widget.fallbackCenterLat == null || widget.fallbackCenterLng == null) {
      return;
    }
    setState(() {
      _selectedLat = widget.fallbackCenterLat;
      _selectedLng = widget.fallbackCenterLng;
      _results = const [];
      _searchError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasSelectedPin = _selectedLat != null && _selectedLng != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (widget.selectionEnabled &&
              widget.fallbackCenterLat != null &&
              widget.fallbackCenterLng != null)
            IconButton(
              tooltip: 'Center on town',
              onPressed: _recenterToTown,
              icon: const Icon(Icons.center_focus_strong),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.enableSearch) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _runSearch(),
                        decoration: const InputDecoration(
                          labelText: 'Search places',
                          hintText: 'Try a landmark, address, or area',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _searching ? null : _runSearch,
                      child: _searching
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Search'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.selectionEnabled
                      ? 'Tap anywhere on the map to place or move the pin.'
                      : 'Pan and zoom the map to inspect the location.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
              ],
              if (_searchError != null) ...[
                Text(
                  _searchError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 12),
              ],
              if (_results.isNotEmpty) ...[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final result = _results[index];
                        return ListTile(
                          leading: const Icon(Icons.place_outlined),
                          title: Text(result.title),
                          subtitle: result.subtitle == null
                              ? null
                              : Text(result.subtitle!),
                          onTap: () => _applySearchResult(result),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => DiscoveryMapWidget(
                    height: constraints.maxHeight,
                    latitude: _selectedLat,
                    longitude: _selectedLng,
                    fallbackCenterLat: widget.fallbackCenterLat,
                    fallbackCenterLng: widget.fallbackCenterLng,
                    interactive: widget.selectionEnabled,
                    onLocationSelected: widget.selectionEnabled
                        ? (latitude, longitude) {
                            setState(() {
                              _selectedLat = latitude;
                              _selectedLng = longitude;
                              _results = const [];
                              _searchError = null;
                            });
                          }
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (hasSelectedPin)
                Text(
                  'Selected pin: ${_selectedLat!.toStringAsFixed(5)}, ${_selectedLng!.toStringAsFixed(5)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              if (widget.selectionEnabled) ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: hasSelectedPin
                      ? () => Navigator.of(context)
                            .pop<DiscoveryLocationSelection>((
                              latitude: _selectedLat!,
                              longitude: _selectedLng!,
                            ))
                      : null,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(widget.confirmLabel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MapSearchResult {
  const _MapSearchResult({
    required this.title,
    required this.latitude,
    required this.longitude,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final double latitude;
  final double longitude;

  static _MapSearchResult? fromFeature(dynamic rawFeature) {
    if (rawFeature is! Map<String, dynamic>) return null;

    final center = rawFeature['center'];
    if (center is! List || center.length < 2) return null;

    final longitude = (center[0] as num?)?.toDouble();
    final latitude = (center[1] as num?)?.toDouble();
    if (latitude == null || longitude == null) return null;

    final placeName = rawFeature['place_name'] as String?;
    final title = (rawFeature['text'] as String?) ?? placeName;
    if (title == null || title.trim().isEmpty) return null;

    final trimmedPlaceName = placeName?.trim();
    final subtitle =
        trimmedPlaceName == null || trimmedPlaceName == title.trim()
        ? null
        : trimmedPlaceName;

    return _MapSearchResult(
      title: title.trim(),
      subtitle: subtitle,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
