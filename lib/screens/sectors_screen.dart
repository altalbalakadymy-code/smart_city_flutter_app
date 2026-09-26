import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SectorsScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const SectorsScreen({super.key, required this.currentUser});

  @override
  State<SectorsScreen> createState() => _SectorsScreenState();
}

class _SectorsScreenState extends State<SectorsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _sectors = const [
    {'type': 'STORE', 'name': 'المتاجر', 'icon': Icons.storefront},
    {'type': 'RESTAURANT', 'name': 'المطاعم', 'icon': Icons.restaurant},
    {'type': 'CLINIC', 'name': 'العيادات', 'icon': Icons.medical_services},
    {'type': 'BUS', 'name': 'باصات السفر', 'icon': Icons.directions_bus},
    {'type': 'WATER', 'name': 'وايتات مياه', 'icon': Icons.water_drop},
    {'type': 'QAT', 'name': 'سوق القات', 'icon': Icons.eco},
    {'type': 'HOTEL', 'name': 'الفنادق', 'icon': Icons.hotel},
    {'type': 'CAR', 'name': 'تأجير سيارات', 'icon': Icons.directions_car},
    {'type': 'REALTY', 'name': 'العقارات', 'icon': Icons.home_work},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _sectors.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showBookingDialog(Map<String, dynamic> item) {
    final isVip = widget.currentUser['is_vip'] == true;
    final originalPrice = (item['price'] as num).toDouble();
    final finalPrice = isVip ? originalPrice * 0.8 : originalPrice; // خصم 20% للـ VIP

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 18),
            Text(
              'تأكيد الحجز الفوري (استلام مباشر)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(item['name'], style: const TextStyle(fontSize: 15, color: Colors.teal, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('السعر الأصلي:', style: TextStyle(color: Colors.grey)),
                      Text('${originalPrice.toInt()} ر.ي', style: TextStyle(decoration: isVip ? TextDecoration.lineThrough : null, color: Colors.black87)),
                    ],
                  ),
                  if (isVip) ...[
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('خصم بطاقة VIP (20%):', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        Text('مفعل آلياً', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('المبلغ النهائي المطلوب:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${finalPrice.toInt()} ر.ي', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _showTicketDialog(item, finalPrice);
              },
              child: const Text('تأكيد وإصدار تذكرة الحجز (QR)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showTicketDialog(Map<String, dynamic> item, double price) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.teal, size: 60),
            const SizedBox(height: 12),
            const Text('تم تأكيد الحجز بنجاح', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('أبرز هذا الكود عند الاستلام أو الصعود', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_2, size: 140, color: Color(0xFF0F172A)),
                  const SizedBox(height: 8),
                  Text('PASS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('المنشأة: ${item['name']}', style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('المبلغ: ${price.toInt()} ر.ي', style: const TextStyle(color: Colors.teal)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق التذكرة', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showChatDialog(Map<String, dynamic> item) {
    final chatCtrl = TextEditingController();
    final List<Map<String, String>> messages = [
      {'sender': 'vendor', 'text': 'مرحباً بك في ${item['name']}، كيف يمكننا خدمتك؟'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setChatState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, top: 16, left: 16, right: 16),
          child: SizedBox(
            height: 450,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('محادثة فورية: ${item['name']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, idx) {
                      final m = messages[idx];
                      final isMe = m['sender'] == 'me';
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFF0F172A) : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(m['text']!, style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: chatCtrl,
                          decoration: InputDecoration(
                            hintText: 'اكتب استفسارك هنا...',
                            filled: true,
                            fillColor: const Color(0xFFF1F5F9),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (chatCtrl.text.trim().isEmpty) return;
                          setChatState(() {
                            messages.add({'sender': 'me', 'text': chatCtrl.text.trim()});
                          });
                          chatCtrl.clear();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddDialog(String sectorType) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '5000');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('إضافة نشاط / خدمة جديدة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'اسم المنشأة / السلعة', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: 'رقم الهاتف للتواصل', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'السعر بالريال اليمني', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                Navigator.pop(ctx);
                await ApiService.addBusinessItem({
                  'id': DateTime.now().millisecondsSinceEpoch,
                  'name': nameCtrl.text.trim(),
                  'type': sectorType,
                  'phone': phoneCtrl.text.trim(),
                  'details': 'خدمة فورية مضافة حديثاً',
                  'price': double.tryParse(priceCtrl.text) ?? 5000.0,
                  'rating': 5.0,
                });
                setState(() {});
              },
              child: const Text('حفظ ونشر فوراً'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.currentUser['role'] ?? 'CLIENT';
    final isAuthorized = role == 'ADMIN' || role == 'VENDOR';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('منظومة الخدمات الموحدة (9 قطاعات)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              'المستخدم: ${widget.currentUser['name']} (${role == 'ADMIN' ? 'مدير عام' : (role == 'VENDOR' ? 'تاجر' : 'عميل VIP')})',
              style: const TextStyle(fontSize: 12, color: Color(0xFF06B6D4)),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFF06B6D4),
          indicatorWeight: 3,
          labelColor: const Color(0xFF06B6D4),
          unselectedLabelColor: Colors.white70,
          tabs: _sectors.map((s) => Tab(text: s['name'], icon: Icon(s['icon'], size: 20))).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _sectors.map((sector) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: ApiService.getBusinessesByCategory(sector['type']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)));
              }
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(sector['icon'], size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text('لا توجد عروض في قطاع ${sector['name']} حالياً', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, idx) {
                  final itm = items[idx];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black.withOpacity(0.04)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(itm['name'], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text('${itm['rating']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(itm['details'], style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13)),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('السعر المحدد:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                Text('${(itm['price'] as num).toInt()} ر.ي', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                              ],
                            ),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF0F172A),
                                    side: const BorderSide(color: Color(0xFF0F172A)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                                  label: const Text('شات فوري'),
                                  onPressed: () => _showChatDialog(itm),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F172A),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.confirmation_number_outlined, size: 16),
                                  label: const Text('حجز مؤكد'),
                                  onPressed: () => _showBookingDialog(itm),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        }).toList(),
      ),
      floatingActionButton: isAuthorized
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF0F172A),
              icon: const Icon(Icons.add, color: Color(0xFF06B6D4)),
              label: Text('إضافة إلى ${_sectors[_tabController.index]['name']}', style: const TextStyle(color: Colors.white)),
              onPressed: () => _showAddDialog(_sectors[_tabController.index]['type']),
            )
          : null,
    );
  }
}
