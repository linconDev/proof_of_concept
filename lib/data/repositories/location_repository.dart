import 'package:proof_of_concept/data/services/device_location_service.dart';
import 'package:proof_of_concept/domain/models/location.dart';

class LocationRepository {
  final DeviceLocationService device;

  LocationRepository({required this.device});

  Stream<Location> get locationStream => device.locationStream;
}