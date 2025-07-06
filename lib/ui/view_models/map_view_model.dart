import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:proof_of_concept/data/repositories/location_repository.dart';
import 'package:proof_of_concept/domain/models/location.dart';

class MapViewModel extends ChangeNotifier {
  final LocationRepository _repo;
  Location? currentLocation;
  final List<Location> _path = [];
  StreamSubscription<Location>? _sub;

  MapViewModel(this._repo);

  void initialize() {
    _sub = _repo.locationStream.listen((loc) {
      currentLocation = loc;
      _path.add(loc);
      notifyListeners();
    });
  }

  List<Location> get path => List.unmodifiable(_path);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}