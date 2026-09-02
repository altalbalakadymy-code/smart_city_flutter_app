import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'businesses_screen.dart';
import 'create_vendor_screen.dart';
import 'sectors_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isConnected = false;
  bool isLoading = true;
  String serverStatusMessage = "جاري فحص حالة السيرفر السحابي...";

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  Future<void> _checkServer() async {
    setState(() => isLoading = true);
    final result = await ApiService.checkServerHealth();
    setState(() {
      isConnected = result['isOnline'] == true;
      serverStatusMessage = result['message'] ?? '';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: const Text(
          'المدينة الذكية | Super App',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1C2541),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'إعادة فحص السيرفر',
            onPressed: _checkServer,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بطاقة حالة السيرفر السحابي (Cloud Status Card)
            _buildServerStatusCard(),
            const SizedBox(height: 25),

            // عنوان البوابات الرئيسية
            const Text(
              "الخدمات والبوابات المركزية",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 15),

            // أزرار التنقل الرئيسية
            _buildActionCard(
              title: "استعراض القطاعات الذكية التسعة",
              subtitle: "التسوق، الصحة، النقل، الطاقة، والتوأم الرقمي 3D",
              icon: Icons.dashboard_customize_outlined,
              color: const Color(0xFF48CAE4),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SectorsScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              title: "المتاجر والأنشطة المسجلة",
              subtitle: "جلب الأنشطة التجارية الحية من قاعدة بيانات PostgreSQL",
              icon: Icons.storefront_outlined,
              color: const Color(0xFF06D6A0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BusinessesScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              title: "تسجيل نشاط / تاجر جديد",
              subtitle: "إرسال طلب POST سحابي لإضافة متجر أو منشأة إلى السيرفر",
              icon: Icons.person_add_alt_1_outlined,
              color: const Color(0xFFFFB703),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateVendorScreen()),
                );
              },
            ),
            const SizedBox(height: 25),

            // مواصفات الربط والمنصة
            _buildInfoFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildServerStatusCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2541),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConnected ? const Color(0xFF06D6A0).withOpacity(0.5) : Colors.redAccent.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isConnected ? const Color(0xFF06D6A0).withOpacity(0.1) : Colors.redAccent.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: isConnected ? const Color(0xFF06D6A0).withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : Icon(
                    isConnected ? Icons.cloud_done : Icons.cloud_off,
                    color: isConnected ? const Color(0xFF06D6A0) : Colors.redAccent,
                    size: 30,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected ? "السيرفر السحابي متصل بنجاح 🟢" : "السيرفر السحابي غير متصل 🔴",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  serverStatusMessage,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF1C2541),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoFooter() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.link, size: 16, color: Color(0xFF48CAE4)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Railway Base URL: up.railway.app",
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Backend: FastAPI • DB: PostgreSQL • Frontend: Flutter",
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10),
          ),
        ],
      ),
    );
  }
}
