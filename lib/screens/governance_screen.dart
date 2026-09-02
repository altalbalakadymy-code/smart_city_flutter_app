import 'package:flutter/material.dart';

class GovernanceScreen extends StatefulWidget {
  const GovernanceScreen({super.key});

  @override
  State<GovernanceScreen> createState() => _GovernanceScreenState();
}

class _GovernanceScreenState extends State<GovernanceScreen> {
  final List<Map<String, dynamic>> services = [
    {
      'title': 'إصدار وتجديد الرخص التجارية',
      'dept': 'قطاع الشؤون الاقتصادية والبلدية',
      'duration': 'فوري (دقيقة واحدة)',
      'fee': '\$50',
      'icon': Icons.badge_rounded,
      'color': const Color(0xFF3A86FF),
    },
    {
      'title': 'توثيق العقود السكنية الذكية',
      'dept': 'إدارة السجل العقاري الرقمي',
      'duration': 'خلال 24 ساعة',
      'fee': '\$30',
      'icon': Icons.description_rounded,
      'color': const Color(0xFF00F5D4),
    },
    {
      'title': 'تسوية الفواتير والمخالفات البلدية',
      'dept': 'النافذة المالية الموحدة',
      'duration': 'دفع رقمي مباشر',
      'fee': 'حسب الفاتورة',
      'icon': Icons.payments_rounded,
      'color': const Color(0xFFFFB703),
    },
  ];

  void _applyServiceDialog(String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2541),
        title: const Text('بدء المعاملة الرقمية', style: TextStyle(color: Color(0xFF3A86FF))),
        content: Text(
          'هل ترغب في رفع طلبك والتحقق الآلي عبر الهوية الرقمية لخدمة:\n$title؟',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3A86FF)),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم توثيق طلبك وتوليد الرقم المرجعي للمعاملة بنجاح 🏛️'),
                  backgroundColor: Color(0xFF3A86FF),
                ),
              );
            },
            child: const Text('تأكيد وإرسال', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _citizenVoiceDialog() {
    final input = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2541),
        title: const Text('صوت المواطن (مقترح / شكوى)', style: TextStyle(color: Color(0xFF00F5D4))),
        content: TextField(
          controller: input,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'اكتب رسالتك المباشرة لرئيس البلدية أو القسم المعني...',
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
            filled: true,
            fillColor: const Color(0xFF0B132B),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F5D4)),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('وصل مقترحك لغرفة القرار والتحسين الحضري الذكي ✨'),
                  backgroundColor: Color(0xFF00F5D4),
                ),
              );
            },
            child: const Text('إرسال', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold)),
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
        title: const Text('الخدمات الحكومية والبلدية'),
        backgroundColor: const Color(0xFF1C2541),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1C2541), Color(0xFF0B132B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF3A86FF).withOpacity(0.4)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(Icons.verified_user_rounded, color: Color(0xFF00F5D4), size: 28),
                    SizedBox(height: 6),
                    Text('حالة الهوية الرقمية', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('نشطة وموثقة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.task_alt_rounded, color: Color(0xFF06D6A0), size: 28),
                    SizedBox(height: 6),
                    Text('معاملات منجزة', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('100% بدون ورق', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.timer_rounded, color: Color(0xFFFFB703), size: 28),
                    SizedBox(height: 6),
                    Text('متوسط زمن الإنجاز', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('3 دقائق', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'المعاملات والتراخيص الرقمية المتاحة',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...services.map((s) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2541),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: (s['color'] as Color).withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: (s['color'] as Color).withOpacity(0.15),
                      child: Icon(s['icon'], color: s['color'], size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(s['dept'], style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 6),
                          Text('${s['duration']} • الرسوم: ${s['fee']}', style: const TextStyle(color: Color(0xFF00F5D4), fontSize: 11)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A86FF),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () => _applyServiceDialog(s['title']),
                      child: const Text('تقديم', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00F5D4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _citizenVoiceDialog,
              icon: const Icon(Icons.campaign_rounded, color: Color(0xFF0B132B)),
              label: const Text(
                'منصة صوت المواطن (تقديم مقترح أو بلاغ)',
                style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
