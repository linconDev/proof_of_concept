import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../providers.dart';
import '../../domain/models/location.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  MapboxMap? _map;
  PolylineAnnotationManager? _lineManager;
  PolylineAnnotation? _line;

  @override
  void initState() {
    super.initState();
    ref.read(mapViewModelProvider).initialize();
    ref.listen(mapViewModelProvider, (_, vm) {
      _updateLine(vm.path);
    });
  }

  Future<void> _updateLine(List<Location> path) async {
    if (_lineManager == null || path.length < 2) return;
    final coords = path
        .map((e) => Position(e.longitude, e.latitude))
        .toList();
    final options = PolylineAnnotationOptions(
      geometry: LineString(coordinates: coords),
      lineColor: "#0000ff",
      lineWidth: 4.0,
    );
    if (_line != null) {
      await _lineManager!.delete(_line!);
    }
    _line = await _lineManager!.create(options);
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(mapViewModelProvider);

    return Scaffold(
      body: vm.currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : MapWidget(
              cameraOptions: CameraOptions(
                center: Point(
                  coordinates: Position(
                    vm.currentLocation!.longitude,
                    vm.currentLocation!.latitude,
                  ),
                ),
                zoom: 14,
              ),
              onMapCreated: (MapboxMap mapboxMap) async {
                _map = mapboxMap;
                _lineManager = _map!.annotations.createPolylineAnnotationManager();
                _map!.location.updateSettings(
                  const LocationComponentSettings(
                    enabled: true,
                    pulsingEnabled: true,
                  ),
                );
                _updateLine(ref.read(mapViewModelProvider).path);
              },
            ),
    );
  }
}