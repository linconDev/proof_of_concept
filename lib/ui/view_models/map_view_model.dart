import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:proof_of_concept/data/repositories/location_repository.dart';
import 'package:proof_of_concept/domain/models/location.dart';
import 'package:proof_of_concept/domain/models/photo_marker.dart';

class MapViewModel extends ChangeNotifier {
  final LocationRepository _repo;
  final ImagePicker _imagePicker = ImagePicker();
  
  Location? currentLocation;
  final List<Location> _path = [];
  final List<PhotoMarker> _photoMarkers = [];
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
  List<PhotoMarker> get photoMarkers => List.unmodifiable(_photoMarkers);

  Future<void> capturePhoto() async {
    if (currentLocation == null) return;

    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        // Salva a foto no diretório de documentos do app
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String photoDir = '${appDocDir.path}/photos';
        await Directory(photoDir).create(recursive: true);
        
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String fileName = 'photo_$timestamp.jpg';
        final String savedPath = '$photoDir/$fileName';
        
        await File(photo.path).copy(savedPath);

        // Cria o marcador de foto
        final photoMarker = PhotoMarker(
          id: timestamp,
          latitude: currentLocation!.latitude,
          longitude: currentLocation!.longitude,
          imagePath: savedPath,
          description: '', // Será preenchido depois
          timestamp: DateTime.now(),
        );

        _photoMarkers.add(photoMarker);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao capturar foto: $e');
    }
  }

  void updatePhotoDescription(String photoId, String description) {
    final index = _photoMarkers.indexWhere((marker) => marker.id == photoId);
    if (index != -1) {
      final updatedMarker = PhotoMarker(
        id: _photoMarkers[index].id,
        latitude: _photoMarkers[index].latitude,
        longitude: _photoMarkers[index].longitude,
        imagePath: _photoMarkers[index].imagePath,
        description: description,
        timestamp: _photoMarkers[index].timestamp,
      );
      _photoMarkers[index] = updatedMarker;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}