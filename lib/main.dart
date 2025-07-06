import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'ui/views/map_screen.dart';
import 'ui/views/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    MapboxOptions.setAccessToken("pk.eyJ1IjoibGluY29uc2FudG9zIiwiYSI6ImNtYThwb2p5NTBhZW0ybXExODVxYXhocHcifQ.QsKurkddiwbfSUGQD7LzoA");
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/current_location': (context) => const MapScreen(),
      },
    );
  }
}
