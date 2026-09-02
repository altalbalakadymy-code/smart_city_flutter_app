import 'package:flutter/material.dart';

class TourismScreen extends StatelessWidget {
  const TourismScreen({super.key});

  final List<Map<String, dynamic>> attractions = const [
    {
      'title': 'برج واحة الابتكار والميتافيرس',
      'category': 'معالم ذكية',
      'rating': 4.9,
      'time': 'مفتوح 24/7',
      'icon': Icons.location_city_rounded,
      'color': Color(0xFFFB5607),
    },
    {
      'title': 'ممشى الحديقة البيئية المعلقة',
      'category': 'طبيعة وترفيه',
      'rating': 4.8,
      'time': '06:00 ص - 11:00 م',
      'icon': Icons.park_rounded,
      'color': Color(0xFF06D6A0),
    },
    {
      'title': 'مسرح الفنون الرقمية والهولوجرام',
      'category': 'عروض حية',
      'rating': 4.9,
      'time': 'تبدأ العروض 08:00 م',
      'icon': Icons.theater_comedy_rounded,
      'color': Color(0xFF8338EC),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: const Text('السياحة والضيافة والترفيه'),
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
              border: Border.all(color: const Color(0xFFFB5607).withOpacity(0.4)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(Icons.hotel_rounded, color: Color(0xFFFB5607), size: 28),
                    SizedBox(height: 6),
                    Text('الفنادق الذكية', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('18 فندق', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.attractions_rounded, color: Color(0xFF00F5D4), size: 28),
                    SizedBox(height: 6),
                    Text('الفعاليات الحية', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('12 فعالية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.restaurant_rounded, color: Color(0xFFFFB703), size: 28),
                    SizedBox(height: 6),
                    Text('المطاعم والكافيهات', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('64 وجهة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'أبرز الوجهات والفعاليات في المدينة',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...attractions.map((a) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2541),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: (a['color'] as Color).withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: (a['color'] as Color).withOpacity(0.15),
                      child: Icon(a['icon'], color: a['color']),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            '${a['category']} • ${a['time']}',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Color(0xFFFFB703), size: 14),
                              const SizedBox(width: 4),
                              Text('${a['rating']}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFB5607),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تم فتح الدليل السياحي وحجز مسار الزيارة لـ ${a['title']}'),
                            backgroundColor: const Color(0xFFFB5607),
                          ),
                        );
                      },
                      child: const Text('استكشاف', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
