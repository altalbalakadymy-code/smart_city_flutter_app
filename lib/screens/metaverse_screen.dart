import 'dart:math';
import 'package:flutter/material.dart';
import 'transport_screen.dart';
import 'healthcare_screen.dart';
import 'water_tanker_screen.dart';
import 'restaurant_screen.dart';
import 'retail_screen.dart';
import 'qat_market_screen.dart';
import 'tourism_screen.dart';
import 'car_rental_screen.dart';
import 'real_estate_screen.dart';

class MetaverseScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const MetaverseScreen({super.key, this.currentUser});

  @override
  State<MetaverseScreen> createState() => _MetaverseScreenState();
}

class _MetaverseScreenState extends State<MetaverseScreen> {
  // موقع الأفاتار داخل عالم الميتافيرس (بالبكسل الافتراضي)
  double _avatarX = 180.0;
  double _avatarY = 280.0;

  // إحداثيات ومواقع مباني ومتاجر القطاعات داخل عالم الميتافيرس
  late final List<Map<String, dynamic>> _buildings;

  Map<String, dynamic>? _nearbyBuilding;

  @override
  void initState() {
    super.initState();
    final user = widget.currentUser ?? {'id': '1', 'name': 'مواطن', 'role': 'CLIENT'};

    _buildings = [
      {
        'id': 'STORE',
        'name': 'هايبر ماركت المدينة',
        'x': 60.0,
        'y': 90.0,
        'icon': Icons.storefront,
        'color': Colors.indigo,
        'screen': RetailScreen(currentUser: user),
      },
      {
        'id': 'RESTAURANT',
        'name': 'مطعم رويال فود',
        'x': 280.0,
        'y': 90.0,
        'icon': Icons.restaurant,
        'color': Colors.orange,
        'screen': RestaurantScreen(currentUser: user),
      },
      {
        'id': 'CLINIC',
        'name': 'مركز الشفاء الطبي',
        'x': 60.0,
        'y': 220.0,
        'icon': Icons.medical_services,
        'color': Colors.teal,
        'screen': HealthcareScreen(currentUser: user),
      },
      {
        'id': 'BUS',
        'name': 'محطة باصات النورس',
        'x': 280.0,
        'y': 220.0,
        'icon': Icons.directions_bus,
        'color': Colors.blue,
        'screen': TransportScreen(currentUser: user),
      },
      {
        'id': 'WATER',
        'name': 'محطة وايتات الكوثر',
        'x': 60.0,
        'y': 360.0,
        'icon': Icons.water_drop,
        'color': Colors.cyan,
        'screen': WaterTankerScreen(currentUser: user),
      },
      {
        'id': 'QAT',
        'name': 'سوق القات النموذجي',
        'x': 280.0,
        'y': 360.0,
        'icon': Icons.eco,
        'color': Colors.green,
        'screen': QatMarketScreen(currentUser: user),
      },
      {
        'id': 'HOTEL',
        'name': 'فندق الأفق الملكي',
        'x': 60.0,
        'y': 500.0,
        'icon': Icons.hotel,
        'color': Colors.deepPurple,
        'screen': TourismScreen(currentUser: user),
      },
      {
        'id': 'CAR',
        'name': 'شركة الصقر للسيارات',
        'x': 280.0,
        'y': 500.0,
        'icon': Icons.directions_car,
        'color': Colors.amber.shade900,
        'screen': CarRentalScreen(currentUser: user),
      },
      {
        'id': 'REALTY',
        'name': 'المستشار العقاري',
        'x': 170.0,
        'y': 620.0,
        'icon': Icons.home_work,
        'color': Colors.blueGrey,
        'screen': RealEstateScreen(currentUser: user),
      },
    ];
  }

  // فحص الاقتراب من المباني (Proximity Trigger)
  void _checkProximity() {
    Map<String, dynamic>? closest;
    double minDistance = 75.0; // مسافة التفاعل

    for (var b in _buildings) {
      double dx = _avatarX - (b['x'] as double);
      double dy = _avatarY - (b['y'] as double);
      double distance = sqrt(dx * dx + dy * dy);

      if (distance < minDistance) {
        closest = b;
        break;
      }
    }

    if (_nearbyBuilding != closest) {
      setState(() => _nearbyBuilding = closest);
    }
  }

  // تحريك الأفاتار بواسطة الجويستيك
  void _moveAvatar(double dx, double dy) {
    setState(() {
      _avatarX = (_avatarX + dx).clamp(30.0, 330.0);
      _avatarY = (_avatarY + dy).clamp(50.0, 680.0);
    });
    _checkProximity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text('ميتافيرس المدينة الذكية 3D', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'كيفية التجول',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1E293B),
                  title: const Text('دليل التجول الافتراضي', style: TextStyle(color: Colors.white)),
                  content: const Text(
                    'استخدم عصا التحكم (Joystick) بالأسفل لتحريك الأفاتار في شوارع المدينة.\nعند الاقتراب من أي متجر أو مرفق صحي، سيضيء المبنى وتظهر لك بطاقة الدخول المباشر للقطاع.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسناً', style: TextStyle(color: Color(0xFF06B6D4)))),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. أرضية وعالم الميتافيرس الشبكي (Cyber Grid Ground)
          Positioned.fill(
            child: CustomPaint(
              painter: _CyberGridPainter(),
            ),
          ),

          // 2. مباني القطاعات المنتشرة في العالم
          ..._buildings.map((b) {
            final isNear = _nearbyBuilding?['id'] == b['id'];
            final Color col = b['color'] as Color;

            return Positioned(
              left: (b['x'] as double) - 35,
              top: (b['y'] as double) - 35,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => b['screen'] as Widget));
                },
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isNear ? Colors.cyanAccent : col.withOpacity(0.6),
                          width: isNear ? 3 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isNear ? Colors.cyanAccent.withOpacity(0.5) : col.withOpacity(0.2),
                            blurRadius: isNear ? 16 : 8,
                            spreadRadius: isNear ? 4 : 1,
                          ),
                        ],
                      ),
                      child: Icon(b['icon'] as IconData, color: isNear ? Colors.cyanAccent : Colors.white, size: 26),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        b['name'].toString(),
                        style: TextStyle(
                          color: isNear ? Colors.cyanAccent : Colors.white70,
                          fontSize: 10,
                          fontWeight: isNear ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          // 3. مجسم الأفاتار (شخصية المستخدم)
          Positioned(
            left: _avatarX - 16,
            top: _avatarY - 16,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF06B6D4).withOpacity(0.8),
                        blurRadius: 14,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person, color: Color(0xFF0F172A), size: 20),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
                  child: const Text('أنت هنا', style: TextStyle(color: Color(0xFF06B6D4), fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // 4. بطاقة التفاعل المنبثقة عند الاقتراب من متجر (Proximity Card)
          if (_nearbyBuilding != null)
            Positioned(
              top: 14,
              left: 16,
              right: 16,
              child: AnimatedOpacity(
                opacity: _nearbyBuilding != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.cyanAccent, width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.cyanAccent.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _nearbyBuilding!['color'] as Color,
                        child: Icon(_nearbyBuilding!['icon'] as IconData, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nearbyBuilding!['name'].toString(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const Text('أنت تقف عند بوابة المرفق مباشرة!', style: TextStyle(color: Colors.cyanAccent, fontSize: 11)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF06B6D4),
                          foregroundColor: const Color(0xFF0F172A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => _nearbyBuilding!['screen'] as Widget));
                        },
                        child: const Text('دخول المرفق', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 5. عصا التحكم الافتراضية (Virtual Joystick) في أسفل الشاشة
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.7),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // زر للأعلى
                    Positioned(
                      top: 4,
                      child: IconButton(
                        icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white70, size: 30),
                        onPressed: () => _moveAvatar(0, -20),
                      ),
                    ),
                    // زر للأسفل
                    Positioned(
                      bottom: 4,
                      child: IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 30),
                        onPressed: () => _moveAvatar(0, 20),
                      ),
                    ),
                    // زر لليسار
                    Positioned(
                      left: 4,
                      child: IconButton(
                        icon: const Icon(Icons.keyboard_arrow_left, color: Colors.white70, size: 30),
                        onPressed: () => _moveAvatar(-20, 0),
                      ),
                    ),
                    // زر لليمين
                    Positioned(
                      right: 4,
                      child: IconButton(
                        icon: const Icon(Icons.keyboard_arrow_right, color: Colors.white70, size: 30),
                        onPressed: () => _moveAvatar(20, 0),
                      ),
                    ),
                    // المركز
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFF06B6D4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.gamepad, color: Color(0xFF0F172A), size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// رسم شبكة إلكترونية لأرضية الميتافيرس
class _CyberGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.3)
      ..strokeWidth = 1.0;

    const step = 35.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
