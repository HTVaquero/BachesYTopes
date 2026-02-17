import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/map_screen.dart';

void main() {
  runApp(const BachesYTopesApp());
}

class BachesYTopesApp extends StatelessWidget {
  const BachesYTopesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BachesYTopes',
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', 'MX'),
      supportedLocales: const [
        Locale('es', 'MX'),
        Locale('es'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}
