import 'package:flutter/material.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  final List<Map<String, dynamic>> busRoutes = [
    {
      'route': 'مسار A1 - مترو الساحة المركزية',
      'nextBus': '4 دقائق',
      'status': 'منتظم',
      'stations': '12 محطة',
      'icon': Icons.directions_bus_rounded,
      'color': const Color(0xFF118AB2),
    },
    {
      'route': 'مسار B3 - مجمع التقنية والميتافيرس',
      'nextBus': '8 دقائق',
      'status': 'مزدحم نسبياً',
      'stations': '8 محطات',
      'icon': Icons.directions_bus_filled_rounded,
      'color': const Color(0xFF00F5D4),
    },
    {
      'route': 'مسار C5 - المنطقة الطبية والمستشفيات',
      'nextBus': '2 دقيقة',
      'status': 'سريع',
      'stations': '6 محطات',
      'icon': Icons.electric_bolt_rounded,
      'color': const Color(0xFF06D6A0),
    },
  ];

  final List<Map<String, dynamic>> evStations = [
    {
      'name': 'محطة واحة الطاقة 1',
      'available': '4 من 6 شواحن متاحة',
      'power': '150 kW فائق السرعة',
    },
    {
      'name': 'شاحن برج الأعمال الذكي',
      'available': '2 من 2 شواحن متاحة',
      'power': '60 kW سريع',
    },
  ];

  void _bookTicket(String routeName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2541),
        title: const Text('حجز تذكرة ذكية', style: TextStyle(color: Color(0xFF00F5D4))),
        content: Text(
          'هل ترغب في إصدار تذكرة تنقل رقمية مشفرة لـ:\n$routeName؟',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF118AB2)),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إصدار تذكرة النقل وتفعيل رمز QR الذكي بنجاح'),
                  backgroundColor: Color(0xFF118AB2),
                ),
              );
            },
            child: const Text('تأكيد وإصدار', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        title: const Text('النقل والمواصلات الذكية'),
        backgroundColor: const Color(0xFF1C2541),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // لوحة نبض شبكة النقل
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1C2541), Color(0xFF0B132B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF118AB2).withOpacity(0.4)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(Icons.traffic_rounded, color: Color(0xFF06D6A0), size: 28),
                    SizedBox(height: 6),
                    Text('سيولة المرور', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('سلسة 94%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.directions_bus_rounded, color: Color(0xFF00F5D4), size: 28),
                    SizedBox(height: 6),
                    Text('حافلات في الخدمة', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('28 حافلة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.ev_station_rounded, color: Color(0xFFFFB703), size: 28),
                    SizedBox(height: 6),
                    Text('محطات EV', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('18 محطة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'مسارات الحافلات الذكية الحية',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...busRoutes.map((b) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2541),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: (b['color'] as Color).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: (b['color'] as Color).withOpacity(0.15),
                      child: Icon(b['icon'], color: b['color'], size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b['route'],
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text('الوصول: ${b['nextBus']}', style: const TextStyle(color: Color(0xFF00F5D4), fontSize: 12)),
                              const SizedBox(width: 10),
                              Text('• ${b['stations']}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF118AB2),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () => _bookTicket(b['route']),
                      child: const Text('تذكرة', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          const Text(
            'محطات شحن السيارات الكهربائية (EV)',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...evStations.map((ev) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2541).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFB703).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.ev_station, color: Color(0xFFFFB703), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ev['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text('${ev['available']} • ${ev['power']}', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                        ],
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
