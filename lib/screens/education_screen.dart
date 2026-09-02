import 'package:flutter/material.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final List<Map<String, dynamic>> courses = [
    {
      'title': 'هندسة المدن الذكية وإنترنت الأشياء (IoT)',
      'instructor': 'د. خلدون الأحمد',
      'level': 'متقدم',
      'duration': '6 أسابيع',
      'enrolled': '1,240 طالب',
      'rating': 4.9,
      'icon': Icons.precision_manufacturing_rounded,
      'color': const Color(0xFF8338EC),
    },
    {
      'title': 'تطوير العوالم الافتراضية ثلاثية الأبعاد (Metaverse)',
      'instructor': 'م. رنا النمري',
      'level': 'متوسط',
      'duration': '4 أسابيع',
      'enrolled': '890 طالب',
      'rating': 4.8,
      'icon': Icons.vrpano_rounded,
      'color': const Color(0xFF00F5D4),
    },
    {
      'title': 'الذكاء الاصطناعي وتحليل بيانات الحشود',
      'instructor': 'د. عادل البركاني',
      'level': 'متقدم',
      'duration': '8 أسابيع',
      'enrolled': '2,100 طالب',
      'rating': 4.9,
      'icon': Icons.psychology_rounded,
      'color': const Color(0xFFFFB703),
    },
  ];

  void _enrollCourse(String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2541),
        title: const Text('التسجيل في المسار الذكي', style: TextStyle(color: Color(0xFF8338EC))),
        content: Text(
          'هل ترغب في الانضمام الفوري للمسار التعليمي:\n$title؟',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8338EC)),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم التسجيل بنجاح وإضافة المحاضرات إلى جدولك الأكاديمي 🎓'),
                  backgroundColor: Color(0xFF8338EC),
                ),
              );
            },
            child: const Text('تأكيد التسجيل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        title: const Text('التعليم والتدريب التفاعلي'),
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
              border: Border.all(color: const Color(0xFF8338EC).withOpacity(0.4)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(Icons.school_rounded, color: Color(0xFF8338EC), size: 28),
                    SizedBox(height: 6),
                    Text('الأكاديميات النشطة', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('8 جامعات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.video_camera_front_rounded, color: Color(0xFF00F5D4), size: 28),
                    SizedBox(height: 6),
                    Text('فصول تفاعلية حية', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('42 فصل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.verified_rounded, color: Color(0xFF06D6A0), size: 28),
                    SizedBox(height: 6),
                    Text('شهادات رقمية', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('موثقة بالكامل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'أبرز المسارات الأكاديمية والمهنية',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...courses.map((c) => Container(
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
                      child: Icon(c['icon'], color: c['color'], size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c['title'],
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${c['instructor']} • ${c['duration']}',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Color(0xFFFFB703), size: 14),
                              const SizedBox(width: 4),
                              Text('${c['rating']}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                              const SizedBox(width: 10),
                              Text(c['enrolled'], style: const TextStyle(color: Colors.white54, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8338EC),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () => _enrollCourse(c['title']),
                      child: const Text('انضمام', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
