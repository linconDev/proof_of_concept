import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapboxService {
  late final MapboxMap controller;

  void onMapCreated(MapboxMap mapboxMap) {
    controller = mapboxMap;
  }
}