import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartCitySuperApp());
}

class SmartCitySuperApp extends StatelessWidget {
  const SmartCitySuperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart City Metaverse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1C2541),
        scaffoldBackgroundColor: const Color(0xFF0B132B),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
