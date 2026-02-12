import 'package:flutter/material.dart';
import 'screens/map_screen.dart';

void main() {
  runApp(const BachesYTopesApp());
}

class BachesYTopesApp extends StatelessWidget {
  const BachesYTopesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BachesYTopes',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}
