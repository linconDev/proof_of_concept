class PhotoMarker {
  final String id;
  final double latitude;
  final double longitude;
  final String imagePath;
  final String description;
  final DateTime timestamp;

  const PhotoMarker({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.imagePath,
    required this.description,
    required this.timestamp,
  });
}
