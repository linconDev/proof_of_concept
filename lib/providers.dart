import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proof_of_concept/data/services/device_location_service.dart';
import 'package:proof_of_concept/ui/view_models/map_view_model.dart';
import 'data/repositories/location_repository.dart';

final deviceLocationServiceProvider = Provider((ref) => DeviceLocationService());
final locationRepositoryProvider = Provider(
  (ref) => LocationRepository(device: ref.read(deviceLocationServiceProvider)),
);

final mapViewModelProvider = ChangeNotifierProvider(
  (ref) => MapViewModel(ref.read(locationRepositoryProvider)),
);