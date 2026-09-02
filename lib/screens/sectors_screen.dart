import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'merchant_dashboard_screen.dart';
import 'login_screen.dart';
import 'metaverse_screen.dart';
import 'healthcare_screen.dart';
import 'transport_screen.dart';
import 'retail_screen.dart';
import 'utilities_screen.dart';
import 'education_screen.dart';
import 'governance_screen.dart';
import 'safety_screen.dart';
import 'tourism_screen.dart';

class SectorsScreen extends StatelessWidget {
  final Map<String, dynamic> currentUser;

  const SectorsScreen({super.key, required this.currentUser});

  final List<Map<String, dynamic>> sectors = const [
    {
      'title': 'المتاجر والتسوق الذكي',
      'category': 'retail',
      'icon': Icons.shopping_bag_outlined,
      'color': Color(0xFFFF5964),
      'desc': 'كتالوج المنتجات، عربة التسوق الفورية، والدفع الرقمي الموحد.'
    },
    {
      'title': 'الرعاية الصحية والعيادات',
      'category': 'healthcare',
      'icon': Icons.local_hospital_outlined,
      'color': Color(0xFF06D6A0),
      'desc': 'حجز المواعيد الطبية، السجلات الصحية، ومؤشرات نبض المدينة.'
    },
    {
      'title': 'النقل والمواصلات الذكية',
      'category': 'transportation',
      'icon': Icons.directions_bus_filled_outlined,
      'color': Color(0xFF118AB2),
      'desc': 'تتبع الحافلات الذكية، محطات الشحن، ومسارات المرور الحية.'
    },
    {
      'title': 'الطاقة والمرافق العامة',
      'category': 'utilities',
      'icon': Icons.bolt_outlined,
      'color': Color(0xFFFFB703),
      'desc': 'مراقبة استهلاك الكهرباء، شبكة المياه، وإدارة النفايات الذكية.'
    },
    {
      'title': 'التعليم والتدريب التفاعلي',
      'category': 'education',
      'icon': Icons.school_outlined,
      'color': Color(0xFF8338EC),
      'desc': 'الفصول الافتراضية، الجامعات الذكية، والشهادات المعتمدة.'
    },
    {
      'title': 'الخدمات الحكومية والبلدية',
      'category': 'governance',
      'icon': Icons.account_balance_outlined,
      'color': Color(0xFF3A86FF),
      'desc': 'المعاملات الرقمية، التراخيص السريعة، وصوت المواطن.'
    },
    {
      'title': 'الأمن والسلامة والطوارئ',
      'category': 'safety',
      'icon': Icons.security_outlined,
      'color': Color(0xFFE63946),
      'desc': 'نظام الإنذار المبكر، الإسعاف السريع، وكاميرات المراقبة الذكية.'
    },
    {
      'title': 'السياحة والضيافة والترفيه',
      'category': 'tourism',
      'icon': Icons.hotel_outlined,
      'color': Color(0xFFFB5607),
      'desc': 'حجز الفنادق، الفعاليات الحية، والدليل السياحي التفاعلي.'
    },
    {
      'title': 'الميتافيرس والتوأم الرقمي (3D)',
      'category': 'metaverse',
      'icon': Icons.view_in_ar_outlined,
      'color': Color(0xFF00F5D4),
      'desc': 'عالم تفاعلي ثلاثي الأبعاد، استكشاف المتاجر الحية، وتدوير المشهد باللمس.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = currentUser['role'] == 'admin';
    final bool isMerchant = currentUser['role'] == 'merchant';

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: Text(
          'أهلاً، ${currentUser['full_name'] ?? 'مواطن'}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1C2541),
        actions: [
          if (isMerchant)
            IconButton(
              tooltip: 'لوحة إدارة المتجر والمنتجات',
              icon: const Icon(Icons.storefront_rounded, color: Color(0xFFFFB703)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MerchantDashboardScreen(merchantUser: currentUser),
                  ),
                );
              },
            ),
          if (isAdmin)
            IconButton(
              tooltip: 'مركز قيادة المدينة',
              icon: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF00F5D4)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              },
            ),
          IconButton(
            tooltip: 'تسجيل الخروج',
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFFF5964)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
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
                  case 'retail':
                    screen = RetailScreen(currentUser: currentUser);
                    break;
                  case 'healthcare':
                    screen = const HealthcareScreen();
                    break;
                  case 'transportation':
                    screen = const TransportScreen();
                    break;
                  case 'utilities':
                    screen = const UtilitiesScreen();
                    break;
                  case 'education':
                    screen = const EducationScreen();
                    break;
                  case 'governance':
                    screen = const GovernanceScreen();
                    break;
                  case 'safety':
                    screen = const SafetyScreen();
                    break;
                  case 'tourism':
                    screen = const TourismScreen();
                    break;
                  case 'metaverse':
                  default:
                    screen = const MetaverseScreen();
                }
                Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2541),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: (s['color'] as Color).withOpacity(0.3)),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s['desc'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 11,
                        height: 1.2,
                      ),
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
