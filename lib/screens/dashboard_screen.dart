import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text(
          'لوحة الإحصائيات وإدارة المنظومة',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة الملخص المالي والتراخيص
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('إجمالي الاشتراكات الشهرية النشطة', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Icon(Icons.monetization_on, color: Color(0xFF06B6D4), size: 24),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '565,000 ر.ي',
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMiniBadge('9 قطاعات مفعلة', Colors.teal),
                      const SizedBox(width: 8),
                      _buildMiniBadge('خادم FastAPI متصل', Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // مؤشرات سريعة
            const Text(
              'حالة العمليات المباشرة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard('الحجوزات المؤكدة', '142', Icons.confirmation_num, Colors.blue),
                const SizedBox(width: 12),
                _buildStatCard('غرف المحادثة', '38', Icons.chat, Colors.amber.shade800),
                const SizedBox(width: 12),
                _buildStatCard('أعضاء VIP', '89', Icons.verified, Colors.purple),
              ],
            ),
            const SizedBox(height: 24),

            // جدول المنشآت والحجوزات الأخيرة
            const Text(
              'أحدث الحجوزات الواردة للمنشآت',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 10),
            _buildBookingTile('شركة النورس للسفريات', 'تذكرة باص (صنعاء - عدن)', 'PASS-89211', '13,500 ر.ي', 'مؤكد'),
            _buildBookingTile('مركز الشفاء الطبي', 'كشف ومعاينة عيادة العظام', 'PASS-44120', '6,400 ر.ي', 'مؤكد'),
            _buildBookingTile('وايت مياه النبع', 'صهريج 4000 لتر - حي الروضة', 'PASS-77312', '18,000 ر.ي', 'قيد الاستلام'),
            _buildBookingTile('سوق القات النموذجي', 'حجز وتثبيت باقة صبري سوبر', 'PASS-11209', '7,000 ر.ي', 'مؤكد'),
          ],
        ),
      ),
    );
  }

  static Widget _buildMiniBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 10),
            Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 2),
            Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingTile(String business, String service, String pass, String price, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF0F172A).withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.qr_code, color: Color(0xFF0F172A), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(business, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                Text(service, style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                Text('كود التذكرة: $pass', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.teal)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                child: Text(status, style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
