import 'package:flutter/material.dart';

class UtilitiesScreen extends StatefulWidget {
  const UtilitiesScreen({super.key});

  @override
  State<UtilitiesScreen> createState() => _UtilitiesScreenState();
}

class _UtilitiesScreenState extends State<UtilitiesScreen> {
  bool _ecoMode = true;

  void _reportIssueDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2541),
        title: const Text('بلاغ عطل طارئ', style: TextStyle(color: Color(0xFFFFB703))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أدخل وصف المشكلة (كهرباء / مياه / إنارة):',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: textController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'مثال: تسريب مياه في الشارع الرئيسي...',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF0B132B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFB703)),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إرسال البلاغ لغرفة عمليات المرافق الذكية فوراً ⚡'),
                  backgroundColor: Color(0xFFFFB703),
                ),
              );
            },
            child: const Text('إرسال البلاغ', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: const Text('الطاقة والمرافق الذكية'),
        backgroundColor: const Color(0xFF1C2541),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // لوحة الاستهلاك الحي
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1C2541), Color(0xFF0B132B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFB703).withOpacity(0.4)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(Icons.bolt_rounded, color: Color(0xFFFFB703), size: 30),
                    SizedBox(height: 6),
                    Text('استهلاك الكهرباء', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('14.2 kWh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.water_drop_rounded, color: Color(0xFF00F5D4), size: 30),
                    SizedBox(height: 6),
                    Text('استهلاك المياه', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('120 L', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.solar_power_rounded, color: Color(0xFF06D6A0), size: 30),
                    SizedBox(height: 6),
                    Text('توليد الطاقة النظيفة', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('68%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // وضع توفير الطاقة الذكي (IoT)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2541),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.eco_rounded, color: Color(0xFF06D6A0)),
                    SizedBox(width: 10),
                    Text('الوضع البيئي الذكي (Eco-Mode)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                Switch(
                  value: _ecoMode,
                  activeColor: const Color(0xFF06D6A0),
                  onChanged: (val) {
                    setState(() => _ecoMode = val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'حالة شبكات ومحطات الحي',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // بطاقة شبكة الكهرباء
          _buildUtilityCard(
            title: 'شبكة الطاقة والكهرباء',
            status: 'مستقرة - جهد 220V',
            statusColor: const Color(0xFF06D6A0),
            icon: Icons.electric_meter_rounded,
            iconColor: const Color(0xFFFFB703),
          ),
          // بطاقة شبكة المياه
          _buildUtilityCard(
            title: 'شبكة التغذية المائية',
            status: 'ضغط ممتاز - جودة نقاء 99.1%',
            statusColor: const Color(0xFF06D6A0),
            icon: Icons.water_rounded,
            iconColor: const Color(0xFF00F5D4),
          ),
          // بطاقة معالجة النفايات
          _buildUtilityCard(
            title: 'إدارة النفايات الذكية',
            status: 'الحاويات الذكية: 40% سعة متبقية',
            statusColor: const Color(0xFFFFB703),
            icon: Icons.delete_outline_rounded,
            iconColor: const Color(0xFFFF5964),
          ),

          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB703),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _reportIssueDialog,
              icon: const Icon(Icons.report_problem_rounded, color: Color(0xFF0B132B)),
              label: const Text(
                'الإبلاغ عن عطل أو طوارئ في المرافق',
                style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityCard({
    required String title,
    required String status,
    required Color statusColor,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2541),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: iconColor.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.15),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(status, style: TextStyle(color: statusColor, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
