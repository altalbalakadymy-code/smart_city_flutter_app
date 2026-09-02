import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'transport_screen.dart';
import 'tourism_screen.dart';
import 'water_tanker_screen.dart';
import 'qat_market_screen.dart';
import 'water_driver_dashboard.dart';
import 'qat_vendor_dashboard.dart';

class SectorsScreen extends StatelessWidget {
  final Map<String, dynamic> currentUser;

  const SectorsScreen({super.key, required this.currentUser});

  final List<Map<String, dynamic>> sectors = const [
    {
      'title': 'وايتات وخزانات الماء الذكية',
      'category': 'water',
      'icon': Icons.water_drop_rounded,
      'color': Color(0xFF00F5D4),
      'desc': 'طلب صهاريج الماء المنزلية (شرب / غسيل) وتعبئة الخزانات الفورية بالـ GPS.'
    },
    {
      'title': 'سوق القات الذكي المعتمد',
      'category': 'qat',
      'icon': Icons.eco_rounded,
      'color': Color(0xFF06D6A0),
      'desc': 'استعراض أصناف القات المعتمدة، مقارنة الأسعار، والطلب السريع للمقيل.'
    },
    {
      'title': 'النقل والمواصلات الذكية (قطاع 1)',
      'category': 'transportation',
      'icon': Icons.directions_bus_filled_outlined,
      'color': Color(0xFF118AB2),
      'desc': 'سفريات بين المحافظات (عدن، تعز، حضرموت) وحافلات النقل الداخلي.'
    },
    {
      'title': 'السياحة والضيافة والترفيه (قطاع 5)',
      'category': 'tourism',
      'icon': Icons.hotel_outlined,
      'color': Color(0xFFFB5607),
      'desc': 'حجز المعالم التاريخية (دار الحجر، صنعاء القديمة)، الفنادق، والمنتزهات.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = currentUser['role'] == 'admin';
    final bool isDriver = currentUser['role'] == 'water_driver';
    final bool isVendor = currentUser['role'] == 'qat_vendor';

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: Text(
          'أهلاً، ${currentUser['full_name'] ?? 'مواطن'}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1C2541),
        actions: [
          if (isDriver)
            IconButton(
              tooltip: 'لوحة مهام سائق الوايت',
              icon: const Icon(Icons.local_shipping_rounded, color: Color(0xFF00F5D4)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WaterDriverDashboard(driverUser: currentUser)),
                );
              },
            ),
          if (isVendor)
            IconButton(
              tooltip: 'لوحة بائع القات',
              icon: const Icon(Icons.eco_rounded, color: Color(0xFF06D6A0)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => QatVendorDashboard(vendorUser: currentUser)),
                );
              },
            ),
          if (isAdmin)
            IconButton(
              tooltip: 'لوحة القيادة',
              icon: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF00F5D4)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
              },
            ),
          IconButton(
            tooltip: 'تسجيل الخروج',
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFFF5964)),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.85,
        ),
        itemCount: sectors.length,
        itemBuilder: (context, index) {
          final s = sectors[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Widget screen;
                switch (s['category']) {
                  case 'water':
                    screen = WaterTankerScreen(currentUser: currentUser);
                    break;
                  case 'qat':
                    screen = QatMarketScreen(currentUser: currentUser);
                    break;
                  case 'transportation':
                    screen = TransportScreen(currentUser: currentUser);
                    break;
                  case 'tourism':
                  default:
                    screen = TourismScreen(currentUser: currentUser);
                }
                Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2541),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: (s['color'] as Color).withOpacity(0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: (s['color'] as Color).withOpacity(0.15),
                      child: Icon(s['icon'], color: s['color']),
                    ),
                    const Spacer(),
                    Text(
                      s['title'],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s['desc'],
                      style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 11, height: 1.2),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
