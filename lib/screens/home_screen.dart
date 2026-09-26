import 'package:flutter/material.dart';
import 'sectors_screen.dart';
import 'metaverse_screen.dart';
import 'dashboard_screen.dart';
import 'water_tanker_screen.dart';
import 'transport_screen.dart';
import 'qat_market_screen.dart';
import 'healthcare_screen.dart';
import 'retail_screen.dart';
import 'tourism_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final Map<String, dynamic> _currentUser = const {
    'id': '1',
    'name': 'المدير العام',
    'phone': '777000000',
    'role': 'CLIENT',
    'is_vip': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.location_city_rounded, color: Color(0xFF00E5FF), size: 22),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المنصة الذكية 3D',
                  style: TextStyle(color: Color(0xFF0F172A), fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Text(
                  'منظومة الخدمات الموحدة',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_customize_outlined, color: Color(0xFF0F172A)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة VIP Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                                color: const Color(0xFF00E5FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'عضوية VIP',
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'خصومات فورية 20%',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'أهلاً بك، هيمو',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'نموذج الحجز المؤكد والتواصل المباشر',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MetaverseScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
                      ),
                      child: const Icon(Icons.view_in_ar, color: Color(0xFF00E5FF), size: 30),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // عنوان شبكة القطاعات
            const Text(
              'القطاعات والخدمات التسعة',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            // شبكة الخدمات الـ 9
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSectorItem(context, 'المتاجر', Icons.storefront, Colors.indigo, const RetailScreen()),
                _buildSectorItem(context, 'المطاعم', Icons.restaurant, Colors.orange, SectorsScreen(currentUser: _currentUser)),
                _buildSectorItem(context, 'العيادات', Icons.medical_services, Colors.teal, const HealthcareScreen()),
                _buildSectorItem(context, 'باصات السفر', Icons.directions_bus, Colors.blue, const TransportScreen()),
                _buildSectorItem(context, 'وايتات مياه', Icons.water_drop, Colors.cyan, WaterTankerScreen()),
                _buildSectorItem(context, 'سوق القات', Icons.eco, Colors.green, const QatMarketScreen()),
                _buildSectorItem(context, 'الفنادق', Icons.hotel, Colors.deepPurple, const TourismScreen()),
                _buildSectorItem(context, 'تأجير سيارات', Icons.directions_car, Colors.amber.shade800, SectorsScreen(currentUser: _currentUser)),
                _buildSectorItem(context, 'العقارات', Icons.home_work, Colors.blueGrey, SectorsScreen(currentUser: _currentUser)),
              ],
            ),

            const SizedBox(height: 20),

            // زر الميتافيرس المميز
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MetaverseScreen()));
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.gamepad, color: Colors.white, size: 28),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تسوق تفاعلي في الميتافيرس 3D',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            'تحكم بشخصيتك واكتشف المحلات عبر Unity',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectorItem(BuildContext context, String title, IconData icon, Color color, Widget targetScreen) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
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
