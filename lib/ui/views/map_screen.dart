// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../providers.dart';
import '../../domain/models/location.dart';
import '../../domain/models/photo_marker.dart';
import '../widgets/photo_detail_dialog.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  MapboxMap? _map;
  PolylineAnnotationManager? _lineManager;
  PointAnnotationManager? _photoAnnotationManager;

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
      if (_photoAnnotationManager != null && vm.photoMarkers.isNotEmpty) {
        _updatePhotoMarkers(vm.photoMarkers);
      }
    });

    return Scaffold(
      body: vm.currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                MapWidget(
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
                    _photoAnnotationManager = await _map!.annotations.createPointAnnotationManager();
                    
                    _map!.location.updateSettings(
                      LocationComponentSettings(
                        enabled: true,
                        pulsingEnabled: true,
                      ),
                    );
                    
                    _updateLine(vm.path);
                    _updatePhotoMarkers(vm.photoMarkers);
                  },
                  onStyleLoadedListener: (StyleLoadedEventData data) {
                    _updateLine(vm.path);
                    _updatePhotoMarkers(vm.photoMarkers);
                  },
                ),
                
                // Floating Action Buttons
                Positioned(
                  bottom: 20,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botão para ver galeria de fotos
                      if (vm.photoMarkers.isNotEmpty)
                        FloatingActionButton(
                          heroTag: "gallery",
                          onPressed: () => _showPhotoGallery(vm.photoMarkers),
                          backgroundColor: Colors.green,
                          child: const Icon(Icons.photo_library, color: Colors.white),
                        ),
                      
                      if (vm.photoMarkers.isNotEmpty)
                        const SizedBox(height: 8),
                      
                      // Botão para câmera
                      FloatingActionButton(
                        heroTag: "camera",
                        onPressed: () => ref.read(mapViewModelProvider).capturePhoto(),
                        backgroundColor: Colors.blue,
                        child: const Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
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

  void _updatePhotoMarkers(List<PhotoMarker> photoMarkers) async {
    if (_photoAnnotationManager == null) return;

    // Limpa marcadores anteriores
    await _photoAnnotationManager!.deleteAll();

    // Cria marcadores para cada foto
    for (final photoMarker in photoMarkers) {
      try {
        // Cria uma imagem circular para o marcador
        final image = await _createCircularPhotoMarker(photoMarker.imagePath);
        
        final pointAnnotationOptions = PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              photoMarker.longitude,
              photoMarker.latitude,
            ),
          ),
          image: image,
          iconSize: 1.0,
        );

        await _photoAnnotationManager!.create(pointAnnotationOptions);
      } catch (e) {
        debugPrint('Erro ao criar marcador de foto: $e');
      }
    }
  }

  Future<Uint8List> _createCircularPhotoMarker(String imagePath) async {
    // Por enquanto, vamos usar um ícone de câmera simples
    // Você pode melhorar isso depois para mostrar a foto real de forma circular
    
    try {
      // Cria um marcador simples usando um ícone de câmera
      final icon = Icons.camera_alt;
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final paint = ui.Paint()
        ..color = Colors.blue
        ..style = ui.PaintingStyle.fill;
      
      // Desenha um círculo azul
      canvas.drawCircle(const ui.Offset(25, 25), 25, paint);
      
      // Desenha o ícone da câmera
      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: 24,
            fontFamily: icon.fontFamily,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, const ui.Offset(13, 13));
      
      final picture = recorder.endRecording();
      final img = await picture.toImage(50, 50);
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      
      return data!.buffer.asUint8List();
    } catch (e) {
      debugPrint('Erro ao criar ícone do marcador: $e');
      // Fallback: retorna um array vazio
      return Uint8List(0);
    }
  }

  void _showPhotoGallery(List<PhotoMarker> photoMarkers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.photo_library, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Fotos do Trajeto (${photoMarkers.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Grid de fotos
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: photoMarkers.length,
                itemBuilder: (context, index) {
                  final photoMarker = photoMarkers[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      _showPhotoDetail(photoMarker);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(photoMarker.imagePath),
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.7),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: Text(
                                  _formatDateTime(photoMarker.timestamp),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showPhotoDetail(PhotoMarker photoMarker) {
    showDialog(
      context: context,
      builder: (context) => PhotoDetailDialog(
        photoMarker: photoMarker,
        onDescriptionChanged: (description) {
          ref.read(mapViewModelProvider).updatePhotoDescription(
            photoMarker.id,
            description,
          );
        },
      ),
    );
  }
}