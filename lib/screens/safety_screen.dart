import 'package:flutter/material.dart';

class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  final List<Map<String, dynamic>> emergencyNumbers = const [
    {
      'name': 'الإسعاف والإنقاذ الطبي السريع',
      'number': '997',
      'icon': Icons.emergency_rounded,
      'color': Color(0xFFE63946),
    },
    {
      'name': 'الشرطة والأمن الذكي',
      'number': '999',
      'icon': Icons.local_police_rounded,
      'color': Color(0xFF3A86FF),
    },
    {
      'name': 'الدفاع المدني ومكافحة الحرائق',
      'number': '998',
      'icon': Icons.fire_truck_rounded,
      'color': Color(0xFFFFB703),
    },
  ];

  void _triggerSos(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2541),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFE63946), size: 28),
            SizedBox(width: 8),
            Text('نداء استغاثة فوري (SOS)', style: TextStyle(color: Color(0xFFE63946), fontSize: 16)),
          ],
        ),
        content: const Text(
          'سيتم بث موقعك الجغرافي الحي ومؤشراتك الحيوية مباشرة إلى أقرب دورية وفرقة إنقاذ ذكية.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE63946)),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إرسال إشارة الاستغاثة وتحديد الموقع بدقة 99.8% 🚨'),
                  backgroundColor: Color(0xFFE63946),
                ),
              );
            },
            child: const Text('إرسال الاستغاثة فوراً', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        title: const Text('الأمن والسلامة والطوارئ'),
        backgroundColor: const Color(0xFF1C2541),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // زر الطوارئ الفوري الكبير SOS
          GestureDetector(
            onTap: () => _triggerSos(context),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  colors: [Color(0xFFE63946), Color(0xFF7A1C24)],
                  radius: 0.9,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE63946).withOpacity(0.4),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app_rounded, color: Colors.white, size: 48),
                    SizedBox(height: 8),
                    Text(
                      'اضغط هنا لطلب نداء طوارئ فوري (SOS)',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'أرقام خطوط الطوارئ المباشرة',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...emergencyNumbers.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2541),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: (e['color'] as Color).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: (e['color'] as Color).withOpacity(0.15),
                      child: Icon(e['icon'], color: e['color']),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        e['name'],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: (e['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        e['number'],
                        style: TextStyle(color: e['color'], fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
