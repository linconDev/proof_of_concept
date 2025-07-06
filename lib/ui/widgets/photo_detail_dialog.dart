import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/models/photo_marker.dart';

class PhotoDetailDialog extends StatefulWidget {
  final PhotoMarker photoMarker;
  final Function(String) onDescriptionChanged;

  const PhotoDetailDialog({
    super.key,
    required this.photoMarker,
    required this.onDescriptionChanged,
  });

  @override
  State<PhotoDetailDialog> createState() => _PhotoDetailDialogState();
}

class _PhotoDetailDialogState extends State<PhotoDetailDialog> {
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.photoMarker.description);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.photo_camera, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Foto do Trajeto',
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
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(widget.photoMarker.imagePath),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Timestamp
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(widget.photoMarker.timestamp),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.photoMarker.latitude.toStringAsFixed(6)}, ${widget.photoMarker.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description input
                    const Text(
                      'Descrição:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Adicione uma descrição para esta foto...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.onDescriptionChanged(_descriptionController.text);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
