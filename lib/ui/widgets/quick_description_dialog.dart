import 'package:flutter/material.dart';

class QuickDescriptionDialog extends StatefulWidget {
  final Function(String) onDescriptionEntered;

  const QuickDescriptionDialog({
    super.key,
    required this.onDescriptionEntered,
  });

  @override
  State<QuickDescriptionDialog> createState() => _QuickDescriptionDialogState();
}

class _QuickDescriptionDialogState extends State<QuickDescriptionDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.camera_alt, color: Colors.blue),
          const SizedBox(width: 8),
          const Text('Foto Capturada!'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Adicione uma descrição para esta foto:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 3,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Ex: Veículo me cortou na faixa da direita...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Pular descrição
            widget.onDescriptionEntered('');
            Navigator.of(context).pop();
          },
          child: const Text('Pular'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onDescriptionEntered(_controller.text.trim());
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
