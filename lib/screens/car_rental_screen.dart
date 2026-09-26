import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CarRentalScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const CarRentalScreen({super.key, this.currentUser});

  @override
  State<CarRentalScreen> createState() => _CarRentalScreenState();
}

class _CarRentalScreenState extends State<CarRentalScreen> {
  List<Map<String, dynamic>> _cars = [];
  bool _isLoading = true;

  // إدارة عدد أيام الإيجار لكل سيارة (Car ID -> Days)
  final Map<int, int> _selectedDays = {};
  String _selectedCategory = 'الكل';
  final List<String> _categories = [
    'الكل',
    'دفع رباعي عائلي (4x4)',
    'سيدان اقتصادي',
    'سيارات VIP فاخرة',
    'باصات عائلية وسياحية',
  ];

  bool get _isVip => widget.currentUser?['is_vip'] == true;
  bool get _isAuthorized =>
      widget.currentUser?['role'] == 'ADMIN' || widget.currentUser?['role'] == 'VENDOR';

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    setState(() => _isLoading = true);
    final data = await ApiService.fetchRentalCars();
    if (mounted) {
      setState(() {
        _cars = data;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredCars {
    if (_selectedCategory == 'الكل') return _cars;
    return _cars.where((c) => c['car_category'] == _selectedCategory).toList();
  }

  void _showAddCarDialog() {
    final agencyCtrl = TextEditingController(text: 'شركة الصقر لتأجير السيارات');
    final modelCtrl = TextEditingController();
    final yearCtrl = TextEditingController(text: '2024');
    final descCtrl = TextEditingController();
    final imgCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '35000');
    final unitsCtrl = TextEditingController(text: '3');
    final phoneCtrl = TextEditingController(text: '770000000');
    String selectedCat = 'دفع رباعي عائلي (4x4)';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
        child: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('إضافة سيارة جديدة لأسطول التأجير', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                TextField(controller: agencyCtrl, decoration: const InputDecoration(labelText: 'اسم معرض التأجير', prefixIcon: Icon(Icons.business), border: OutlineInputBorder())),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedCat,
                  decoration: const InputDecoration(labelText: 'فئة السيارة', prefixIcon: Icon(Icons.category), border: OutlineInputBorder()),
                  items: ['دفع رباعي عائلي (4x4)', 'سيدان اقتصادي', 'سيارات VIP فاخرة', 'باصات عائلية وسياحية']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedCat = v);
                  },
                ),
                const SizedBox(height: 10),
                TextField(controller: modelCtrl, decoration: const InputDecoration(labelText: 'موديل السيارة وطرازها', prefixIcon: Icon(Icons.directions_car), border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: yearCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سنة الصنع (الموديل)', prefixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'مواصفات السيارة والتأمين', prefixIcon: Icon(Icons.description), border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: 'رابط صورة السيارة (URL)', prefixIcon: Icon(Icons.image), border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سعر اليوم الواحد (ريال يمني)', prefixIcon: Icon(Icons.money), border: OutlineInputBorder())),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: unitsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'عدد السيارات المتاحة', border: OutlineInputBorder()))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'هاتف المعرض للتواصل', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () async {
                    if (modelCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    final ok = await ApiService.addRentalCar(
                      agencyName: agencyCtrl.text.trim(),
                      carModel: modelCtrl.text.trim(),
                      carCategory: selectedCat,
                      modelYear: int.tryParse(yearCtrl.text) ?? 2024,
                      description: descCtrl.text.trim().isEmpty ? 'سيارة نظيفة مؤمنة جاهزة للاستلام الفوري.' : descCtrl.text.trim(),
                      imageUrl: imgCtrl.text.trim(),
                      pricePerDay: double.tryParse(priceCtrl.text) ?? 30000.0,
                      availableUnits: int.tryParse(unitsCtrl.text) ?? 2,
                      phone: phoneCtrl.text.trim(),
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(ok ? 'تمت إضافة السيارة لأسطول السيرفر بنجاح' : 'تم الحفظ محلياً'), backgroundColor: Colors.amber.shade800),
                      );
                      _loadCars();
                    }
                  },
                  child: const Text('حفظ ونشر السيارة في السيرفر'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _bookCarRental(Map<String, dynamic> car) async {
    final carId = car['id'] as int;
    final int days = _selectedDays[carId] ?? 1;
    final double pricePerDay = (car['price_per_day'] as num).toDouble();
    final double subtotal = pricePerDay * days;
    final double finalPrice = _isVip ? subtotal * 0.8 : subtotal;
    final ticketCode = 'PASS-CAR-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    await ApiService.addBusinessItem({
      'user_id': widget.currentUser?['id'] ?? '1',
      'business_name': '${car['agency_name']} - ${car['car_model']}',
      'category': 'CAR',
      'total_price': finalPrice,
      'qr_pass': ticketCode,
      'status': 'RESERVED',
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
            const Text('تصريح استلام وتأجير سيارة (Car Pickup Pass)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)), textAlign: TextAlign.center),
            Text('${car['agency_name']} | ${car['car_model']}', style: TextStyle(color: Colors.amber.shade900, fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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
                _buildInfo('مدة الاستئجار', '$days يوم'),
                _buildInfo('سنة الصنع', '${car['model_year']}'),
                _buildInfo('المبلغ عند الاستلام', '${finalPrice.toInt()} ر.ي'),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.assignment_ind_outlined, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('المتطلبات عند الاستلام المباشر: أصل الهوية الشخصية ورخصة القيادة السارية لإتمام العقد وتسليم المفتاح.', style: TextStyle(fontSize: 11, color: Colors.black87)),
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
              child: const Text('تم الحفظ في تصاريحي وتذاكري'),
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

  void _openAgencyChat(Map<String, dynamic> car) {
    final msgCtrl = TextEditingController();
    final List<Map<String, String>> chat = [
      {'sender': 'agency', 'text': 'مرحباً بك في ${car['agency_name']}. سيارة ${car['car_model']} جاهزة ومفحوصة تماماً، هل تود الاستفسار عن شروط التأمين أو التنسيق لموعد محدد؟'}
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
                        CircleAvatar(backgroundColor: Colors.amber.shade800, child: const Icon(Icons.directions_car, color: Colors.white, size: 20)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(car['agency_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(car['car_model'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
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
                            hintText: 'اكتب استفسارك لمسؤول المعرض...',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: Colors.amber.shade800, foregroundColor: Colors.white),
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
        title: const Text('تأجير السيارات السياحية والعائلية', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        actions: [
          if (_isAuthorized)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'إضافة سيارة',
              onPressed: _showAddCarDialog,
            ),
        ],
      ),
      floatingActionButton: _isAuthorized
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF0F172A),
              icon: const Icon(Icons.directions_car, color: Color(0xFF06B6D4)),
              label: const Text('إضافة سيارة للأسطول', style: TextStyle(color: Colors.white)),
              onPressed: _showAddCarDialog,
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
          : Column(
              children: [
                // لافتة شارحة توضح ماذا تفعل الصفحة بالضبط
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xFF06B6D4),
                        radius: 20,
                        child: Icon(Icons.info_outline, color: Color(0xFF0F172A), size: 24),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'دليل خدمة تأجير السيارات المباشرة:',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'اختر المركبة وعدد الأيام المطلوبة ⟵ احصل على تصريح استلام رسمي (QR) ⟵ توجّه للمعرض مباشرة لإبراز الهوية والرخصة واستلام المفتاح.',
                              style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // فلتر فئات السيارات
                Container(
                  height: 48,
                  margin: const EdgeInsets.symmetric(vertical: 6),
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

                // بطاقات أسطول السيارات
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredCars.length,
                    itemBuilder: (context, idx) {
                      final car = _filteredCars[idx];
                      final carId = car['id'] as int;
                      final int days = _selectedDays[carId] ?? 1;
                      final double pricePerDay = (car['price_per_day'] as num).toDouble();
                      final double total = pricePerDay * days;
                      final double finalPrice = _isVip ? total * 0.8 : total;
                      final String imgUrl = car['image_url']?.toString() ?? '';
                      final String description = car['description']?.toString() ?? '';

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
                            // صورة السيارة مع شارات المعرض والموديل
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
                                            child: const Icon(Icons.directions_car, size: 60, color: Colors.blueGrey),
                                          ),
                                        )
                                      : Container(
                                          height: 150,
                                          color: const Color(0xFFF1F5F9),
                                          child: const Icon(Icons.directions_car, size: 60, color: Colors.blueGrey),
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
                                      car['agency_name'],
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
                                      color: Colors.amber.shade800,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'الموديل: ${car['model_year']}',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // تفاصيل السيارة والتأجير
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        car['car_model'],
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(6)),
                                        child: Text(car['car_category'], style: TextStyle(color: Colors.amber.shade900, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  if (description.isNotEmpty) ...[
                                    Text(
                                      description,
                                      style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 12, height: 1.4),
                                    ),
                                    const SizedBox(height: 10),
                                  ],

                                  // عداد أيام الإيجار
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('مدة الاستئجار المطلوبة:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove_circle_outline, color: Colors.blueGrey),
                                              onPressed: () {
                                                if (days > 1) {
                                                  setState(() => _selectedDays[carId] = days - 1);
                                                }
                                              },
                                            ),
                                            Text('$days أيام', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                            IconButton(
                                              icon: const Icon(Icons.add_circle, color: Color(0xFF0F172A)),
                                              onPressed: () {
                                                setState(() => _selectedDays[carId] = days + 1);
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
                                          Text('الإجمالي ($days أيام):', style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
                                            label: const Text('شات المعرض', style: TextStyle(fontSize: 12)),
                                            onPressed: () => _openAgencyChat(car),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF0F172A),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            icon: const Icon(Icons.car_rental, size: 16),
                                            label: const Text('حجز السيارة (QR)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                            onPressed: () => _bookCarRental(car),
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
