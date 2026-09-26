import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'sectors_screen.dart';
import 'metaverse_screen.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'transport_screen.dart';
import 'healthcare_screen.dart';
import 'water_tanker_screen.dart';
import 'restaurant_screen.dart';
import 'retail_screen.dart';
import 'qat_market_screen.dart';
import 'tourism_screen.dart';
import 'car_rental_screen.dart';
import 'real_estate_screen.dart';
import 'my_bookings_screen.dart';
import 'budget_matcher_screen.dart';
import 'qr_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const HomeScreen({super.key, this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, dynamic> user;

  @override
  void initState() {
    super.initState();
    user = widget.currentUser ?? {
      'id': '1',
      'name': 'المدير العام',
      'phone': '777000000',
      'role': 'ADMIN',
      'is_vip': true,
    };
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_user_session');

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = user['role'] ?? 'CLIENT';
    final isAuthorized = role == 'ADMIN' || role == 'VENDOR';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.location_city_rounded, color: Color(0xFF06B6D4), size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('المدينة الذكية 3D', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('المستخدم: ${user['name']}', style: const TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ],
        ),
        actions: [
          if (isAuthorized)
            IconButton(
              icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF10B981)),
              tooltip: 'التحقق من التذاكر',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QrScannerScreen(currentUser: user))),
            ),
          IconButton(
            icon: const Icon(Icons.confirmation_number_outlined, color: Color(0xFF06B6D4)),
            tooltip: 'تذاكري وحجوزاتي',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MyBookingsScreen(currentUser: user))),
          ),
          IconButton(
            icon: const Icon(Icons.dashboard_customize_outlined, color: Colors.white70),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            tooltip: 'تسجيل الخروج',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF06B6D4),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                role == 'ADMIN' ? 'صلاحية المدير العام' : (role == 'VENDOR' ? 'حساب تاجر معتمد' : 'عضوية VIP مفعّلة'),
                                style: const TextStyle(color: Color(0xFF0F172A), fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('خصم 20% آلي', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(user['name'], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('نموذج الحجز المؤكد والتواصل المباشر', style: TextStyle(color: Colors.white60, fontSize: 12)),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MetaverseScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF06B6D4).withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF06B6D4), width: 1.5),
                      ),
                      child: const Icon(Icons.view_in_ar, color: Color(0xFF06B6D4), size: 30),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BudgetMatcherScreen(currentUser: user))),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF10B981).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.calculate_outlined, color: Color(0xFF059669)),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('محرك مطابقة الميزانية الذكي (AI Matcher)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('حدد ميزانيتك المتوفرة وسيقوم النظام بفرز وترشيح أوفر الحزم لك', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MetaverseScreen())),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.gamepad, color: Colors.white, size: 28),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('تسوق تفاعلي في الميتافيرس 3D', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('تحكم بشخصيتك واكتشف المحلات عبر الجويستيك', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('القطاعات والخدمات التسعة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SectorsScreen(currentUser: user))),
                  child: const Text('عرض الكل', style: TextStyle(color: Color(0xFF06B6D4))),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSectorItem('المتاجر', Icons.storefront, Colors.indigo, RetailScreen(currentUser: user)),
                _buildSectorItem('المطاعم', Icons.restaurant, Colors.orange, RestaurantScreen(currentUser: user)),
                _buildSectorItem('العيادات', Icons.medical_services, Colors.teal, HealthcareScreen(currentUser: user)),
                _buildSectorItem('باصات السفر', Icons.directions_bus, Colors.blue, TransportScreen(currentUser: user)),
                _buildSectorItem('وايتات مياه', Icons.water_drop, Colors.cyan, WaterTankerScreen(currentUser: user)),
                _buildSectorItem('سوق القات', Icons.eco, Colors.green, QatMarketScreen(currentUser: user)),
                _buildSectorItem('الفنادق', Icons.hotel, Colors.deepPurple, TourismScreen(currentUser: user)),
                _buildSectorItem('تأجير سيارات', Icons.directions_car, Colors.amber.shade800, CarRentalScreen(currentUser: user)),
                _buildSectorItem('العقارات', Icons.home_work, Colors.blueGrey, RealEstateScreen(currentUser: user)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectorItem(String title, IconData icon, Color color, Widget targetScreen) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
