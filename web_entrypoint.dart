// web_entrypoint.dart
import 'dart:ui' as ui;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  // Optional: Any variables you want to declare
  const String appTitle = "My Flutter App";

  // Register any web plugins here if needed
  setUrlStrategy(PathUrlStrategy());

  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Run the Flutter app
  runApp(MyApp(title: appTitle));
}

// Example MyApp, replace with your real app if needed
class MyApp extends StatelessWidget {
  final String title;

  const MyApp({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: Text('Flutter Web App Running!')),
      ),
    );
  }
}
