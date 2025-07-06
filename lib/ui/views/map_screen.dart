// ignore_for_file: deprecated_member_use

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

  @override
  void initState() {
    super.initState();
    ref.read(mapViewModelProvider).initialize();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(mapViewModelProvider);

    // Atualiza a linha sempre que o path mudar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_lineManager != null && vm.path.isNotEmpty) {
        _updateLine(vm.path);
      }
    });

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
                _lineManager = await _map!.annotations.createPolylineAnnotationManager();
                _map!.location.updateSettings(
                  LocationComponentSettings(
                    enabled: true,
                    pulsingEnabled: true,
                  ),
                );
                _updateLine(vm.path);
              },
              onStyleLoadedListener: (StyleLoadedEventData data) {
                _updateLine(vm.path);
              },
            ),
    );
  }

  void _updateLine(List<Location> path) async {
    if (_lineManager == null || path.length < 2) return;

    // Limpa linhas anteriores
    await _lineManager!.deleteAll();

    // Converte o path em uma lista de Position para o Mapbox
    final coordinates = path.map((location) => Position(
      location.longitude,
      location.latitude,
    )).toList();

    // Cria a linha
    final polylineAnnotationOptions = PolylineAnnotationOptions(
      geometry: LineString(coordinates: coordinates),
      lineColor: Colors.blue.value,
      lineWidth: 4.0,
    );

    await _lineManager!.create(polylineAnnotationOptions);
  }
}