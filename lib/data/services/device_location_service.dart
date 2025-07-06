import 'package:proof_of_concept/domain/models/location.dart';
import 'package:geolocator/geolocator.dart';

class DeviceLocationService {
  Stream<Location> get locationStream async* {
    bool ok = await Geolocator.isLocationServiceEnabled();
    if(!ok) throw Exception("Serviço de localização desativado");

    LocationPermission perm = await Geolocator.checkPermission();
    if(perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if(perm == LocationPermission.denied) {
        throw Exception("Permissão de localização negada");
      }
    }

    await Geolocator.requestPermission();
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).map((pos) => Location(
      latitude: pos.latitude,
      longitude: pos.longitude,
      timestamp: pos.timestamp,
    ));
  }
}