import 'package:flutter/material.dart';

class MetaverseScreen extends StatefulWidget {
  const MetaverseScreen({super.key});

  @override
  State<MetaverseScreen> createState() => _MetaverseScreenState();
}

class _MetaverseScreenState extends State<MetaverseScreen> {
  // موقع الأفاتار على الخريطة التفاعلية
  double _avatarX = 140;
  double _avatarY = 220;
  String _activeZone = 'الساحة المركزية للمدينة الذكية';

  void _triggerZoneAction(String title, String sectorType) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.view_in_ar, color: Colors.teal, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('حدث اقتراب تصادمي (Trigger)', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'أنت الآن أمام الواجهة التفاعلية ثلاثية الأبعاد؛ اختر الإجراء المطلوب مباشرة وفق المعمارية الهندسية:',
              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.confirmation_num_outlined),
              label: const Text('تثبيت الحجز المباشر (استلام فوري)', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم إصدار تذكرة الحجز المؤكد لـ $title')),
                );
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.chat_outlined),
              label: const Text('بدء محادثة فورية مع المسؤول'),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم فتح قناة الدردشة المباشرة مع كاشير/طبيب $title')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.gamepad, color: Color(0xFF06B6D4), size: 22),
            SizedBox(width: 8),
            Text('عالم التسوق الافتراضي (Unity 3D)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Stack(
        children: [
          // بيئة الخريطة ثلاثية الأبعاد المحاكاة
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.9,
                  colors: [const Color(0xFF1E293B), const Color(0xFF090D16)],
                ),
              ),
              child: Stack(
                children: [
                  // نقاط المنشآت على الخريطة
                  _buildMapBuilding(50, 60, 'هايبر المتاجر', 'STORE'),
                  _buildMapBuilding(220, 60, 'مركز العيادات', 'CLINIC'),
                  _buildMapBuilding(60, 360, 'محطة السفريات', 'BUS'),
                  _buildMapBuilding(220, 360, 'فندق القصر', 'HOTEL'),

                  // شخصية المستخدم (Avatar)
                  Positioned(
                    left: _avatarX,
                    top: _avatarY,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFF06B6D4), borderRadius: BorderRadius.circular(6)),
                          child: const Text('أنت (Avatar)', style: TextStyle(fontSize: 10, color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 2),
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person_pin, color: Color(0xFF0F172A), size: 28),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // شريط المنطقة الحالية بالأعلى
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.85),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.radar, color: Color(0xFF06B6D4), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'الموقع الحالي: $_activeZone',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // عصا التحكم اللمسية (Virtual Joystick) بأسفل الشاشة
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // زر للأعلى
                    Positioned(
                      top: 4,
                      child: IconButton(
                        icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
                        onPressed: () => setState(() {
                          if (_avatarY > 60) _avatarY -= 25;
                          _activeZone = 'حي المراكز الخدمية';
                        }),
                      ),
                    ),
                    // زر للأسفل
                    Positioned(
                      bottom: 4,
                      child: IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                        onPressed: () => setState(() {
                          if (_avatarY < 420) _avatarY += 25;
                          _activeZone = 'بوابة المحطات والفنادق';
                        }),
                      ),
                    ),
                    // زر لليمين
                    Positioned(
                      right: 4,
                      child: IconButton(
                        icon: const Icon(Icons.keyboard_arrow_right, color: Colors.white),
                        onPressed: () => setState(() {
                          if (_avatarX < 260) _avatarX += 25;
                          _activeZone = 'شارع العيادات والفنادق';
                        }),
                      ),
                    ),
                    // زر لليسار
                    Positioned(
                      left: 4,
                      child: IconButton(
                        icon: const Icon(Icons.keyboard_arrow_left, color: Colors.white),
                        onPressed: () => setState(() {
                          if (_avatarX > 30) _avatarX -= 25;
                          _activeZone = 'شارع المتاجر والمحطات';
                        }),
                      ),
                    ),
                    // مركز الجويستيك
                    const CircleAvatar(radius: 18, backgroundColor: Color(0xFF06B6D4)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapBuilding(double left, double top, String title, String sector) {
    return Positioned(
      left: left,
      top: top,
      child: InkWell(
        onTap: () => _triggerZoneAction(title, sector),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.5)),
            boxShadow: [
              BoxShadow(color: const Color(0xFF06B6D4).withOpacity(0.1), blurRadius: 10),
            ],
          ),
          child: Column(
            children: [
              const Icon(Icons.storefront, color: Color(0xFF06B6D4), size: 28),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.teal.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                child: const Text('اقترب للتفاعل', style: TextStyle(color: Colors.tealAccent, fontSize: 9)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
