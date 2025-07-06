import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prova de Conceito')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pushNamed('/current_location'),
          child: const Text('Localiza\u00e7\u00e3o atual com Mapbox'),
        ),
      ),
    );
  }
}
