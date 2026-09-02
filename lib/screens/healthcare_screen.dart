import 'package:flutter/material.dart';

class HealthcareScreen extends StatefulWidget {
  const HealthcareScreen({super.key});

  @override
  State<HealthcareScreen> createState() => _HealthcareScreenState();
}

class _HealthcareScreenState extends State<HealthcareScreen> {
  final List<Map<String, dynamic>> clinics = [
    {
      'name': 'مركز المدينة للقلب والأوعية',
      'doctor': 'د. أحمد سالم',
      'specialty': 'استشاري أمراض القلب',
      'rating': 4.9,
      'available': 'متاح اليوم',
      'icon': Icons.favorite_rounded,
      'color': const Color(0xFFFF5964),
    },
    {
      'name': 'عيادة النور لطب الأطفال',
      'doctor': 'د. سارة المنصوري',
      'specialty': 'أخصائية طب الأطفال وحديثي الولادة',
      'rating': 4.8,
      'available': 'متاح غداً',
      'icon': Icons.child_care_rounded,
      'color': const Color(0xFF06D6A0),
    },
    {
      'name': 'مجمع العيون التخصصي',
      'doctor': 'د. ياسر الشامي',
      'specialty': 'جراحة العيون والليزر',
      'rating': 4.7,
      'available': 'متاح اليوم',
      'icon': Icons.visibility_rounded,
      'color': const Color(0xFF118AB2),
    },
    {
      'name': 'مركز الأسنان الرقمي الذكي',
      'doctor': 'د. مريم العولقي',
      'specialty': 'طب وجراحة الفم والأسنان',
      'rating': 4.9,
      'available': 'متاح اليوم',
      'icon': Icons.health_and_safety_rounded,
      'color': const Color(0xFFFFB703),
    },
  ];

  void _bookAppointment(String clinicName, String doctor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2541),
        title: const Text('تأكيد الحجز الذكي', style: TextStyle(color: Color(0xFF00F5D4))),
        content: Text(
          'هل ترغب في تأكيد حجز موعد فوري لدى $doctor في $clinicName؟',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06D6A0)),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حجز موعدك بنجاح مع $doctor'),
                  backgroundColor: const Color(0xFF06D6A0),
                ),
              );
            },
            child: const Text('تأكيد الحجز', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold)),
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
        title: const Text('الرعاية الصحية والعيادات'),
        backgroundColor: const Color(0xFF1C2541),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // لوحة مؤشرات صحة المدينة
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1C2541), Color(0xFF0B132B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF06D6A0).withOpacity(0.4)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(Icons.monitor_heart_rounded, color: Color(0xFF06D6A0), size: 28),
                    SizedBox(height: 6),
                    Text('مؤشر صحة المدينة', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('98.4%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.local_hospital_rounded, color: Color(0xFF00F5D4), size: 28),
                    SizedBox(height: 6),
                    Text('العيادات المتاحة', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('14 عيادة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.speed_rounded, color: Color(0xFFFFB703), size: 28),
                    SizedBox(height: 6),
                    Text('متوسط الانتظار', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('12 دقيقة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'العيادات والمراكز التخصصية المتاحة',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...clinics.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2541),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: (c['color'] as Color).withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: (c['color'] as Color).withOpacity(0.15),
                      child: Icon(c['icon'], color: c['color'], size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c['name'],
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            c['doctor'] + ' - ' + c['specialty'],
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Color(0xFFFFB703), size: 14),
                              const SizedBox(width: 4),
                              Text('${c['rating']}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF06D6A0).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  c['available'],
                                  style: const TextStyle(color: Color(0xFF06D6A0), fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00F5D4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () => _bookAppointment(c['name'], c['doctor']),
                      child: const Text('حجز', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
