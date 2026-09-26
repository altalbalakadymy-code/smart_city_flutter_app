import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TourismScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const TourismScreen({super.key, this.currentUser});

  @override
  State<TourismScreen> createState() => _TourismScreenState();
}

class _TourismScreenState extends State<TourismScreen> {
  List<Map<String, dynamic>> _rooms = [];
  bool _isLoading = true;

  // إدارة عدد الليالي لكل غرفة محددة (Room ID -> Nights)
  final Map<int, int> _selectedNights = {};
  String _selectedCategory = 'الكل';
  final List<String> _categories = ['الكل', 'جناح ملكي', 'شقق مفروشة', 'غرفة ديلوكس', 'غرفة مفردة'];

  bool get _isVip => widget.currentUser?['is_vip'] == true;
  bool get _isAuthorized =>
      widget.currentUser?['role'] == 'ADMIN' || widget.currentUser?['role'] == 'VENDOR';

  @override
  void initState() {
    super.initState();
    _loadHotelRooms();
  }

  Future<void> _loadHotelRooms() async {
    setState(() => _isLoading = true);
    final data = await ApiService.fetchHotelsAndRooms();
    if (mounted) {
      setState(() {
        _rooms = data;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredRooms {
    if (_selectedCategory == 'الكل') return _rooms;
    return _rooms.where((r) => r['room_type'].toString().contains(_selectedCategory)).toList();
  }

  void _showAddHotelRoomDialog() {
    final hotelCtrl = TextEditingController();
    final typeCtrl = TextEditingController(text: 'جناح ملكي فاخر');
    final locCtrl = TextEditingController(text: 'حي حِدة - شارع بيروت');
    final descCtrl = TextEditingController();
    final imgCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '30000');
    final roomsCtrl = TextEditingController(text: '5');
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
              const Text('إضافة فندق / جناح جديد للسيرفر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextField(controller: hotelCtrl, decoration: const InputDecoration(labelText: 'اسم الفندق أو المجمع السكني', prefixIcon: Icon(Icons.hotel), border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'نوع الغرفة أو الجناح', prefixIcon: Icon(Icons.meeting_room), border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'موقع الفندق والشارع', prefixIcon: Icon(Icons.location_on), border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'المميزات (إفطار، واي فاي، مسبح)', prefixIcon: Icon(Icons.description), border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: 'رابط صورة الغرفة (URL)', prefixIcon: Icon(Icons.image), border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سعر الليلة الواحدة (ريال يمني)', prefixIcon: Icon(Icons.money), border: OutlineInputBorder())),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: roomsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'عدد الغرف الشاغرة', border: OutlineInputBorder()))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'هاتف الاستقبال (ريسبشن)', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  if (hotelCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty) return;
                  Navigator.pop(ctx);
                  final ok = await ApiService.addHotelRoom(
                    hotelName: hotelCtrl.text.trim(),
                    roomType: typeCtrl.text.trim(),
                    location: locCtrl.text.trim(),
                    description: descCtrl.text.trim().isEmpty ? 'خدمة فندقية راقية شاملة الخدمات.' : descCtrl.text.trim(),
                    imageUrl: imgCtrl.text.trim(),
                    pricePerNight: double.tryParse(priceCtrl.text) ?? 25000.0,
                    availableRooms: int.tryParse(roomsCtrl.text) ?? 3,
                    phone: phoneCtrl.text.trim(),
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(ok ? 'تمت إضافة الفندق والجناح بنجاح' : 'تم الحفظ محلياً'), backgroundColor: Colors.deepPurple),
                    );
                    _loadHotelRooms();
                  }
                },
                child: const Text('حفظ ونشر الجناح في السيرفر'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _bookHotelRoom(Map<String, dynamic> room) async {
    final roomId = room['id'] as int;
    final int nights = _selectedNights[roomId] ?? 1;
    final double pricePerNight = (room['price_per_night'] as num).toDouble();
    final double subtotal = pricePerNight * nights;
    final double finalPrice = _isVip ? subtotal * 0.8 : subtotal;
    final ticketCode = 'PASS-HTL-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    await ApiService.addBusinessItem({
      'user_id': widget.currentUser?['id'] ?? '1',
      'business_name': '${room['hotel_name']} - ${room['room_type']}',
      'category': 'HOTEL',
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
            Center(child: Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 16),
            const Text('تذكرة حجز فندقي مؤكد (Lobby QR Pass)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)), textAlign: TextAlign.center),
            Text(room['hotel_name'], style: const TextStyle(color: Colors.deepPurple, fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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
                _buildInfo('مدة الإقامة', '$nights ليلة'),
                _buildInfo('الموقع', room['location']),
                _buildInfo('المبلغ عند الاستقبال', '${finalPrice.toInt()} ر.ي'),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.vpn_key_outlined, color: Colors.deepPurple, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('أبرز هذا الكود في لوبي الفندق لموظف الاستقبال لتسجيل الوصول واستلام مفتاح الجناح مباشرة.', style: TextStyle(fontSize: 11, color: Colors.black87)),
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
              child: const Text('تم الحفظ في حجوزاتي الفندقية'),
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

  void _openReceptionChat(Map<String, dynamic> room) {
    final msgCtrl = TextEditingController();
    final List<Map<String, String>> chat = [
      {'sender': 'reception', 'text': 'مرحباً بك في خدمة استقبال ${room['hotel_name']}. الجناح جاهز ومجهز بالكامل، هل تود ترتيب موعد وصول معين أو لديك طلبات إضافية؟'}
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
                        const CircleAvatar(backgroundColor: Colors.deepPurple, child: Icon(Icons.room_service, color: Colors.white, size: 20)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(room['hotel_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const Text('استقبال وخدمات الغرف (ريسبشن)', style: TextStyle(color: Colors.grey, fontSize: 11)),
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
                            hintText: 'اكتب استفسارك للاستقبال...',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
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
        title: const Text('الفنادق والشقق المفروشة (حجز مباشر)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        actions: [
          if (_isAuthorized)
            IconButton(
              icon: const Icon(Icons.add_home_work_outlined),
              tooltip: 'إضافة فندق',
              onPressed: _showAddHotelRoomDialog,
            ),
        ],
      ),
      floatingActionButton: _isAuthorized
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF0F172A),
              icon: const Icon(Icons.hotel, color: Color(0xFF06B6D4)),
              label: const Text('إضافة فندق / جناح', style: TextStyle(color: Colors.white)),
              onPressed: _showAddHotelRoomDialog,
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
          : Column(
              children: [
                // فلتر الفئات
                Container(
                  height: 48,
                  margin: const EdgeInsets.only(top: 12),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, idx) {
                      final cat = _categories[idx];
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: const Color(0xFF0F172A),
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12),
                          onSelected: (val) => setState(() => _selectedCategory = cat),
                        ),
                      );
                    },
                  ),
                ),

                // بطاقات الفنادق والأجنحة
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredRooms.length,
                    itemBuilder: (context, idx) {
                      final room = _filteredRooms[idx];
                      final roomId = room['id'] as int;
                      final int nights = _selectedNights[roomId] ?? 1;
                      final double pricePerNight = (room['price_per_night'] as num).toDouble();
                      final double total = pricePerNight * nights;
                      final double finalPrice = _isVip ? total * 0.8 : total;
                      final String imgUrl = room['image_url']?.toString() ?? '';
                      final String description = room['description']?.toString() ?? '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.black.withOpacity(0.04)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // صورة الجناح الفندقي
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                                  child: imgUrl.isNotEmpty
                                      ? Image.network(
                                          imgUrl,
                                          height: 180,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, stack) => Container(
                                            height: 150,
                                            color: const Color(0xFFF1F5F9),
                                            child: const Icon(Icons.hotel, size: 60, color: Colors.deepPurple),
                                          ),
                                        )
                                      : Container(
                                          height: 150,
                                          color: const Color(0xFFF1F5F9),
                                          child: const Icon(Icons.hotel, size: 60, color: Colors.deepPurple),
                                        ),
                                ),
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A).withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      room['hotel_name'],
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.shade700,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'المتبقي: ${room['available_rooms']} غرف',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // تفاصيل الغرفة والفندق
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    room['room_type'],
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 14, color: Colors.red),
                                      const SizedBox(width: 4),
                                      Text(room['location'], style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (description.isNotEmpty) ...[
                                    Text(
                                      description,
                                      style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 12, height: 1.4),
                                    ),
                                    const SizedBox(height: 10),
                                  ],

                                  // عداد ليالي الإقامة
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('عدد ليالي الإقامة المطلوبة:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove_circle_outline, color: Colors.blueGrey),
                                              onPressed: () {
                                                if (nights > 1) {
                                                  setState(() => _selectedNights[roomId] = nights - 1);
                                                }
                                              },
                                            ),
                                            Text('$nights ليلة', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                            IconButton(
                                              icon: const Icon(Icons.add_circle, color: Color(0xFF0F172A)),
                                              onPressed: () {
                                                setState(() => _selectedNights[roomId] = nights + 1);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  const Divider(height: 22),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('الإجمالي ($nights ليالي):', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                          Text('${finalPrice.toInt()} ر.ي', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 18)),
                                          if (_isVip)
                                            const Text('خصم VIP (20%) مفعّل', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
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
                                            label: const Text('شات الاستقبال', style: TextStyle(fontSize: 12)),
                                            onPressed: () => _openReceptionChat(room),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF0F172A),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            icon: const Icon(Icons.vpn_key, size: 16),
                                            label: const Text('حجز الغرفة (QR)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                            onPressed: () => _bookHotelRoom(room),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
}
