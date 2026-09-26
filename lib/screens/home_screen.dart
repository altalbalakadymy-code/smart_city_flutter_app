import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'sectors_screen.dart';
import 'login_screen.dart';
import 'metaverse_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isChecking = true;
  bool _serverOnline = false;

  final Map<String, dynamic> _mockUser = const {
    'id': '1',
    'name': 'المدير العام',
    'phone': '777000000',
    'role': 'CLIENT',
    'is_vip': true,
  };

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  Future<void> _checkServer() async {
    final result = await ApiService.checkServerHealth();
    if (mounted) {
      setState(() {
        _serverOnline = result;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المنصة الذكية 3D'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isChecking = true);
              _checkServer();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      _isChecking
                          ? Icons.hourglass_top
                          : (_serverOnline ? Icons.check_circle : Icons.error),
                      color: _isChecking
                          ? Colors.orange
                          : (_serverOnline ? Colors.green : Colors.red),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'حالة الاتصال بالنظام:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _isChecking
                                ? 'جاري الفحص...'
                                : (_serverOnline ? 'متصل بالسيرفر' : 'غير متصل بالسيرفر'),
                            style: TextStyle(
                              color: _serverOnline ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.grid_view),
              label: const Text('دخول الأقسام والخدمات التسعة', style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SectorsScreen(currentUser: _mockUser),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.view_in_ar),
              label: const Text('عالم الميتافيرس 3D', style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MetaverseScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.dashboard_customize),
              label: const Text('لوحة التحكم والإحصائيات', style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DashboardScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('تسجيل الدخول / تبديل الحساب'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
