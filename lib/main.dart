import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // قراءة بيانات الجلسة المخزنة محلياً
  final prefs = await SharedPreferences.getInstance();
  final userString = prefs.getString('saved_user_session');
  
  Map<String, dynamic>? initialUser;
  if (userString != null && userString.isNotEmpty) {
    try {
      initialUser = jsonDecode(userString) as Map<String, dynamic>;
    } catch (_) {
      initialUser = null;
    }
  }

  runApp(SmartCityApp(initialUser: initialUser));
}

class SmartCityApp extends StatelessWidget {
  final Map<String, dynamic>? initialUser;

  const SmartCityApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'المدينة الذكية الموحدة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Tajawal',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A),
          primary: const Color(0xFF0F172A),
          secondary: const Color(0xFF06B6D4),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: initialUser != null
          ? HomeScreen(currentUser: initialUser)
          : const LoginScreen(),
    );
  }
}
