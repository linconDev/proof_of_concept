import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../providers.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(mapViewModelProvider).initialize();
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
              onMapCreated: (MapboxMap mapboxMap) {
              },
            ),
    );
  }
}