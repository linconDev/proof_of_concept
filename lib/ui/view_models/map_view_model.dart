import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:proof_of_concept/data/repositories/location_repository.dart';
import 'package:proof_of_concept/domain/models/location.dart';

class MapViewModel extends ChangeNotifier {
  final LocationRepository _repo;
  Location? currentLocation;
  StreamSubscription<Location>? _sub;

  MapViewModel(this._repo);

  void initialize() {
    _sub = _repo.locationStream.listen((loc) {
      currentLocation = loc;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}