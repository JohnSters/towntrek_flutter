import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Embedded Mapbox map with optional pin (circle) and tap-to-place when [interactive].
///
/// Call [MapboxOptions.setAccessToken] with a non-empty token before this widget
/// is first built (e.g. load via [ConfigService] in the parent).
class DiscoveryMapWidget extends StatefulWidget {
  const DiscoveryMapWidget({
    super.key,
    required this.height,
    this.latitude,
    this.longitude,
    this.fallbackCenterLat,
    this.fallbackCenterLng,
    this.interactive = false,
    this.onLocationSelected,
  });

  final double height;

  /// Pin / focus (optional until user taps in interactive mode).
  final double? latitude;
  final double? longitude;

  /// When no pin, center here (e.g. town). Defaults to South Africa overview.
  final double? fallbackCenterLat;
  final double? fallbackCenterLng;

  final bool interactive;
  final void Function(double latitude, double longitude)? onLocationSelected;

  static const double _defaultLat = -28.5;
  static const double _defaultLng = 24.5;

  @override
  State<DiscoveryMapWidget> createState() => _DiscoveryMapWidgetState();
}

class _DiscoveryMapWidgetState extends State<DiscoveryMapWidget> {
  MapboxMap? _map;
  CircleAnnotationManager? _circleMgr;
  CircleAnnotation? _circle;

  double get _centerLat =>
      widget.latitude ??
      widget.fallbackCenterLat ??
      DiscoveryMapWidget._defaultLat;

  double get _centerLng =>
      widget.longitude ??
      widget.fallbackCenterLng ??
      DiscoveryMapWidget._defaultLng;

  Future<void> _putPin(double lng, double lat) async {
    final mgr = _circleMgr;
    if (mgr == null) return;
    final existing = _circle;
    if (existing != null) {
      await mgr.delete(existing);
      _circle = null;
    }
    _circle = await mgr.create(
      CircleAnnotationOptions(
        geometry: Point(coordinates: Position(lng, lat)),
        circleRadius: 10,
        circleColor: 0xFFE65100,
        circleStrokeColor: 0xFFFFFFFF,
        circleStrokeWidth: 2,
      ),
    );
    await _map?.setCamera(
      CameraOptions(center: Point(coordinates: Position(lng, lat)), zoom: 14),
    );
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    _map = map;
    await map.gestures.updateSettings(
      GesturesSettings(rotateEnabled: false, pitchEnabled: false),
    );
    _circleMgr = await map.annotations.createCircleAnnotationManager();
    if (widget.latitude != null && widget.longitude != null) {
      await _putPin(widget.longitude!, widget.latitude!);
    }
  }

  @override
  void didUpdateWidget(covariant DiscoveryMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      if (widget.latitude != null && widget.longitude != null) {
        _putPin(widget.longitude!, widget.latitude!);
      }
    }
  }

  @override
  void dispose() {
    _map = null;
    _circleMgr = null;
    _circle = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MapWidget(
          styleUri: MapboxStyles.STANDARD,
          textureView: true,
          androidHostingMode: AndroidPlatformViewHostingMode.VD,
          gestureRecognizers: widget.interactive
              ? {
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                }
              : null,
          cameraOptions: CameraOptions(
            center: Point(coordinates: Position(_centerLng, _centerLat)),
            zoom: (widget.latitude != null && widget.longitude != null)
                ? 14
                : 5,
          ),
          onMapCreated: _onMapCreated,
          onTapListener: widget.interactive
              ? (ctx) {
                  if (ctx.gestureState != GestureState.ended) return;
                  final c = ctx.point.coordinates;
                  final lat = c.lat.toDouble();
                  final lng = c.lng.toDouble();
                  _putPin(lng, lat);
                  widget.onLocationSelected?.call(lat, lng);
                }
              : null,
        ),
      ),
    );
  }
}
