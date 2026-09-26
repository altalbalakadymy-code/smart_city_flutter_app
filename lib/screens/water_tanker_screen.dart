import 'dart:math';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WaterTankerScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const WaterTankerScreen({super.key, this.currentUser});

  @override
  State<WaterTankerScreen> createState() => _WaterTankerScreenState();
}

class _WaterTankerScreenState extends State<WaterTankerScreen> {
  List<Map<String, dynamic>> _tankers = [];
  bool _isLoading = true;

  // إحداثيات المستخدم الحالية الافتراضية (صنعاء - السبعين)
  final double _userLat = 15.3547;
  final double _userLng = 44.2066;

  int _selectedCapacityFilter = 0; // 0 تعني عرض الكل
  String _selectedWaterType = 'الكل';

  final _deliveryAddressCtrl = TextEditingController(text: 'حي الأصبحي - بالقرب من جامع الفردوس');

  bool get _isVip => widget.currentUser?['is_vip'] == true;
  bool get _isAuthorized =>
      widget.currentUser?['role'] == 'ADMIN' || widget.currentUser?['role'] == 'VENDOR';

  @override
  void initState() {
    super.initState();
    _loadTankers();
  }

  @override
  void dispose() {
    _deliveryAddressCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTankers() async {
    setState(() => _isLoading = true);
    final data = await ApiService.fetchWaterTankers();
    if (mounted) {
      setState(() {
        _tankers = data;
        _isLoading = false;
      });
    }
  }

  // خوارزمية Haversine لحساب المسافة الجغرافية بالكيلومتر
  double _calculateDistance(double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - _userLat) * p) / 2 +
        cos(_userLat * p) * cos(lat2 * p) * (1 - cos((lon2 - _userLng) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  List<Map<String, dynamic>> get _sortedTankers {
    var list = _tankers.map((t) {
      final dist = _calculateDistance(t['latitude'] as double, t['longitude'] as double);
      return {...t, 'distance_km': dist};
    }).toList();

    // فلترة حسب السعة
    if (_selectedCapacityFilter > 0) {
      list = list.where((t) => t['capacity_liters'] == _selectedCapacityFilter).toList();
    }

    // فلترة حسب نوع المياه
    if (_selectedWaterType != 'الكل') {
      list = list.where((t) => t['water_type'] == _selectedWaterType).toList();
    }

    // ترتيب من الأقرب جغرافياً للأبعد
    list.sort((a, b) => (a['distance_km'] as double).compareTo(b['distance_km'] as double));
    return list;
  }

  void _showAddTankerDialog() {
    final driverCtrl = TextEditingController();
    final stationCtrl = TextEditingController(text: 'مشروع آبار الصافية');
    final typeCtrl = TextEditingController(text: 'مياه شرب نقية مكررة');
    final capCtrl = TextEditingController(text: '6000');
    final priceCtrl = TextEditingController(text: '16000');
    final phoneCtrl = TextEditingController(text: '770000000');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('إضافة وايت / صهريج مياه جديد للسيرفر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextField(controller: driverCtrl, decoration: InputDecoration(labelText: 'اسم السائق المسؤول', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 10),
              TextField(controller: stationCtrl, decoration: InputDecoration(labelText: 'اسم المحطة أو البئر', prefixIcon: const Icon(Icons.water), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 10),
              TextField(controller: typeCtrl, decoration: InputDecoration(labelText: 'نوعية المياه (شرب، غسيل، عذبة)', prefixIcon: const Icon(Icons.category), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 10),
              TextField(controller: capCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'سعة الصهريج باللتر (مثال: 6000)', prefixIcon: const Icon(Icons.local_shipping), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 10),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'السعر بالريال اليمني', prefixIcon: const Icon(Icons.money), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 10),
              TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: 'رقم هاتف السائق', prefixIcon: const Icon(Icons.phone), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  if (driverCtrl.text.trim().isEmpty) return;
                  Navigator.pop(ctx);
                  final ok = await ApiService.addWaterTanker(
                    driverName: driverCtrl.text.trim(),
                    stationName: stationCtrl.text.trim(),
                    waterType: typeCtrl.text.trim(),
                    capacity: int.tryParse(capCtrl.text) ?? 6000,
                    price: double.tryParse(priceCtrl.text) ?? 15000.0,
                    phone: phoneCtrl.text.trim(),
                    lat: _userLat + 0.02,
                    lng: _userLng + 0.02,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(ok ? 'تم إضافة الصهريج وتثبيته في السيرفر' : 'تم الحفظ محلياً'), backgroundColor: Colors.cyan),
                    );
                    _loadTankers();
                  }
                },
                child: const Text('حفظ في قاعدة البيانات'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _bookTanker(Map<String, dynamic> t) async {
    final double basePrice = (t['price'] as num).toDouble();
    final double finalPrice = _isVip ? basePrice * 0.8 : basePrice;
    final ticketCode = 'PASS-H2O-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    // حفظ الطلب في السيرفر
    await ApiService.addBusinessItem({
      'user_id': widget.currentUser?['id'] ?? '1',
      'business_name': '${t['driver_name']} (${t['station_name']})',
      'category': 'WATER',
      'total_price': finalPrice,
      'qr_pass': ticketCode,
      'status': 'CONFIRMED',
    });

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 16),
            const Text('تأكيد طلب صهريج مياه (QR Pass)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)), textAlign: TextAlign.center),
            Text('${t['driver_name']} - ${t['station_name']}', style: const TextStyle(color: Colors.cyan, fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const Divider(height: 24),
            Center(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black12)),
                child: Column(
                  children: [
                    const Icon(Icons.qr_code_2, size: 130, color: Color(0xFF0F172A)),
                    Text(ticketCode, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfo('سعة الخزان', '${t['capacity_liters']} لتر'),
                _buildInfo('نوع المياه', t['water_type']),
                _buildInfo('المبلغ المطلوب', '${finalPrice.toInt()} ر.ي'),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.cyan.shade50, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.cyan, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text('العنوان المسجل: ${_deliveryAddressCtrl.text}', style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('تم الحفظ وتثبيت التوجيه'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(String title, String val) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
      ],
    );
  }

  void _openDriverChat(Map<String, dynamic> t) {
    final msgCtrl = TextEditingController();
    final List<Map<String, String>> chat = [
      {'sender': 'driver', 'text': 'مرحباً بك! أنا السائق ${t['driver_name']}، صهريج المياه جاهز والمسافة قريبة منك، يرجى تزويدي بأي علامة بارزة للشارع.'}
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setChat) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, top: 16, left: 16, right: 16),
          child: SizedBox(
            height: 450,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(backgroundColor: Colors.cyan, child: Icon(Icons.local_shipping, color: Colors.white, size: 20)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t['driver_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(t['station_name'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: chat.length,
                    itemBuilder: (context, idx) {
                      final m = chat[idx];
                      final isMe = m['sender'] == 'me';
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(m['text']!, style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 13)),
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
                          controller: msgCtrl,
                          decoration: InputDecoration(
                            hintText: 'اكتب وصف العنوان أو استفسارك...',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: Colors.cyan.shade700, foregroundColor: Colors.white),
                        icon: const Icon(Icons.send, size: 20),
                        onPressed: () {
                          if (msgCtrl.text.trim().isEmpty) return;
                          setChat(() => chat.add({'sender': 'me', 'text': msgCtrl.text.trim()}));
                          msgCtrl.clear();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text('وايتات مياه الشرب (الأقرب جغرافياً)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        actions: [
          if (_isAuthorized)
            IconButton(
              icon: const Icon(Icons.add_location_alt),
              tooltip: 'إضافة صهريج',
              onPressed: _showAddTankerDialog,
            ),
        ],
      ),
      floatingActionButton: _isAuthorized
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF0F172A),
              icon: const Icon(Icons.water_drop, color: Color(0xFF06B6D4)),
              label: const Text('إضافة صهريج للسيرفر', style: TextStyle(color: Colors.white)),
              onPressed: _showAddTankerDialog,
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
          : Column(
              children: [
                // بطاقة موقع العميل والـ GPS
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black.withOpacity(0.04)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFFE0F2FE),
                        child: Icon(Icons.my_location, color: Colors.blue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('موقعك لتحديد أقرب صهريج (GPS):', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text(_deliveryAddressCtrl.text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // فلتر السعة باللتر
                SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildCapChip(0, 'كل السعات'),
                      _buildCapChip(3000, '3,000 لتر (صغير)'),
                      _buildCapChip(6000, '6,000 لتر (متوسط)'),
                      _buildCapChip(10000, '10,000 لتر (كبير)'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // قائمة الوايتات المرتبة بالأقرب
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sortedTankers.length,
                    itemBuilder: (context, idx) {
                      final t = _sortedTankers[idx];
                      final double dist = (t['distance_km'] as double);
                      final double basePrice = (t['price'] as num).toDouble();
                      final double finalPrice = _isVip ? basePrice * 0.8 : basePrice;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black.withOpacity(0.04)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Color(0xFFECFEFF),
                                      child: Icon(Icons.water_drop, color: Colors.cyan, size: 22),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(t['driver_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                                        Text('${t['station_name']} | ${t['water_type']}', style: const TextStyle(color: Colors.blueGrey, fontSize: 11)),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.near_me, size: 12, color: Colors.green),
                                      const SizedBox(width: 4),
                                      Text('${dist.toStringAsFixed(1)} كم', style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 22),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('السعة: ${t['capacity_liters']} لتر', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    Text('${finalPrice.toInt()} ر.ي ${_isVip ? "(خصم VIP)" : ""}', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 15)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF0F172A),
                                        side: const BorderSide(color: Color(0xFF0F172A)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      icon: const Icon(Icons.chat_outlined, size: 16),
                                      label: const Text('محادثة السائق', style: TextStyle(fontSize: 12)),
                                      onPressed: () => _openDriverChat(t),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0F172A),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      icon: const Icon(Icons.check_circle_outline, size: 16),
                                      label: const Text('طلب الصهريج', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      onPressed: () => _bookTanker(t),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCapChip(int cap, String label) {
    final isSelected = _selectedCapacityFilter == cap;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF0F172A),
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 11),
        onSelected: (val) => setState(() => _selectedCapacityFilter = cap),
      ),
    );
  }
}
