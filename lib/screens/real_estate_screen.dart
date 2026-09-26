import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RealEstateScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const RealEstateScreen({super.key, this.currentUser});

  @override
  State<RealEstateScreen> createState() => _RealEstateScreenState();
}

class _RealEstateScreenState extends State<RealEstateScreen> {
  List<Map<String, dynamic>> _properties = [];
  bool _isLoading = true;

  String _selectedCategory = 'الكل';
  final List<String> _categories = [
    'الكل',
    'شقق سكنية عائلية',
    'فلل وقصور مستقلة',
    'محلات ومكاتب تجارية',
    'أراضي استثمارية وسكنية',
  ];

  bool get _isVip => widget.currentUser?['is_vip'] == true;
  bool get _isAuthorized =>
      widget.currentUser?['role'] == 'ADMIN' || widget.currentUser?['role'] == 'VENDOR';

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() => _isLoading = true);
    final data = await ApiService.fetchRealEstateProperties();
    if (mounted) {
      setState(() {
        _properties = data;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredProperties {
    if (_selectedCategory == 'الكل') return _properties;
    return _properties.where((p) => p['property_category'] == _selectedCategory).toList();
  }

  void _showAddPropertyDialog() {
    final brokerCtrl = TextEditingController(text: 'مكتب المستشار العقاري');
    final titleCtrl = TextEditingController();
    final locCtrl = TextEditingController(text: 'حي الأصبحي - صنعاء');
    final descCtrl = TextEditingController();
    final imgCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '150000');
    final bedsCtrl = TextEditingController(text: '3');
    final bathsCtrl = TextEditingController(text: '2');
    final areaCtrl = TextEditingController(text: '150');
    final phoneCtrl = TextEditingController(text: '770000000');
    String selectedType = 'إيجار شهري';
    String selectedCat = 'شقق سكنية عائلية';

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
                const Text('إدراج عقار جديد في المنصة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                TextField(controller: brokerCtrl, decoration: const InputDecoration(labelText: 'اسم المالك أو المكتب العقاري', prefixIcon: Icon(Icons.business), border: OutlineInputBorder())),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: const InputDecoration(labelText: 'نوع العرض', border: OutlineInputBorder()),
                        items: ['إيجار شهري', 'للبيع قطعي', 'إيجار سنوي'].map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (v) {
                          if (v != null) setDialogState(() => selectedType = v);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCat,
                        decoration: const InputDecoration(labelText: 'التصنيف', border: OutlineInputBorder()),
                        items: ['شقق سكنية عائلية', 'فلل وقصور مستقلة', 'محلات ومكاتب تجارية', 'أراضي استثمارية وسكنية'].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 11)))).toList(),
                        onChanged: (v) {
                          if (v != null) setDialogState(() => selectedCat = v);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'عنوان العقار بالكامل', prefixIcon: Icon(Icons.home_work), border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'الحي والشارع بالتفصيل', prefixIcon: Icon(Icons.location_on), border: OutlineInputBorder())),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: bedsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الغرف', border: OutlineInputBorder()))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: bathsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الحمامات', border: OutlineInputBorder()))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: areaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'المساحة (م²)', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'مواصفات وتشطيبات العقار', prefixIcon: Icon(Icons.description), border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: 'رابط صورة العقار (URL)', prefixIcon: Icon(Icons.image), border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر المطلوب بالريال اليمني', prefixIcon: Icon(Icons.money), border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم هاتف المالك/المكتب للتواصل', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder())),
                const SizedBox(height: 18),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    final ok = await ApiService.addRealEstateProperty(
                      brokerName: brokerCtrl.text.trim(),
                      propertyTitle: titleCtrl.text.trim(),
                      listingType: selectedType,
                      propertyCategory: selectedCat,
                      locationNeighborhood: locCtrl.text.trim(),
                      bedrooms: int.tryParse(bedsCtrl.text) ?? 3,
                      bathrooms: int.tryParse(bathsCtrl.text) ?? 2,
                      areaSqm: int.tryParse(areaCtrl.text) ?? 150,
                      description: descCtrl.text.trim().isEmpty ? 'عقار متميز وجاهز للمعاينة الفورية.' : descCtrl.text.trim(),
                      imageUrl: imgCtrl.text.trim(),
                      price: double.tryParse(priceCtrl.text) ?? 150000.0,
                      phone: phoneCtrl.text.trim(),
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(ok ? 'تم نشر العقار في السيرفر بنجاح' : 'تم الحفظ محلياً'), backgroundColor: Colors.blueGrey),
                      );
                      _loadProperties();
                    }
                  },
                  child: const Text('حفظ ونشر العقار'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _bookInspectionAppointment(Map<String, dynamic> prop) async {
    final ticketCode = 'PASS-REAL-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    String appointmentTime = 'اليوم بين 04:00 إلى 06:00 مساءً';

    await ApiService.addBusinessItem({
      'user_id': widget.currentUser?['id'] ?? '1',
      'business_name': '${prop['broker_name']} - ${prop['property_title']}',
      'category': 'REALTY',
      'total_price': 0.0,
      'qr_pass': ticketCode,
      'status': 'INSPECTION_CONFIRMED',
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
            const Text('تصريح معاينة عقارية مؤكد (Inspection QR Pass)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)), textAlign: TextAlign.center),
            Text(prop['property_title'], style: const TextStyle(color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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
                _buildInfo('الموعد المقترح', appointmentTime),
                _buildInfo('الحي والشارع', prop['location_neighborhood']),
                _buildInfo('المسؤول', prop['broker_name']),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.real_estate_agent_outlined, color: Colors.blueGrey, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('تم تأكيد طلب المعاينة الميدانية رسمياً؛ أبرز هذا التصريح لمالك العقار أو مندوب المكتب عند اللقاء للمعاينة الحية.', style: TextStyle(fontSize: 11, color: Colors.black87)),
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
              child: const Text('تم الحفظ في مواعيدي العقارية'),
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

  void _openBrokerChat(Map<String, dynamic> prop) {
    final msgCtrl = TextEditingController();
    final List<Map<String, String>> chat = [
      {'sender': 'broker', 'text': 'أهلاً بك في ${prop['broker_name']}. العقار المعروض (${prop['property_title']}) متاح وجاهز للمعاينة على أرض الواقع، هل ترغب بطلب تفاصيل أخرى أو تحديد موعد لزيارته؟'}
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
                        const CircleAvatar(backgroundColor: Color(0xFF0F172A), child: Icon(Icons.home_work, color: Colors.white, size: 20)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(prop['broker_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(prop['location_neighborhood'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
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
                            hintText: 'اكتب استفسارك للمالك أو المكتب...',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
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
        title: const Text('العقارات والمنازل وحجز المعاينة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        actions: [
          if (_isAuthorized)
            IconButton(
              icon: const Icon(Icons.add_home_outlined),
              tooltip: 'إضافة عقار',
              onPressed: _showAddPropertyDialog,
            ),
        ],
      ),
      floatingActionButton: _isAuthorized
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF0F172A),
              icon: const Icon(Icons.add_home, color: Color(0xFF06B6D4)),
              label: const Text('إضافة عقار للسيرفر', style: TextStyle(color: Colors.white)),
              onPressed: _showAddPropertyDialog,
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
                        child: Icon(Icons.real_estate_agent, color: Color(0xFF0F172A), size: 24),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'دليل خدمة المعاينة والتواصل العقاري المباشر:',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'تصفح الشقق والفلل والأراضي ⟵ اختر العقار واحجز موعد معاينة ميدانية (QR Pass) ⟵ تواصل مباشرة مع المالك أو المكتب دون وسطاء إضافيين.',
                              style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // فلتر الفئات العقارية
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

                // بطاقات العقارات المصورة
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredProperties.length,
                    itemBuilder: (context, idx) {
                      final prop = _filteredProperties[idx];
                      final double price = (prop['price'] as num).toDouble();
                      final String imgUrl = prop['image_url']?.toString() ?? '';
                      final String description = prop['description']?.toString() ?? '';

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
                            // صورة العقار مع شارة نوع العرض والمكتب
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
                                            child: const Icon(Icons.home_work_outlined, size: 60, color: Colors.blueGrey),
                                          ),
                                        )
                                      : Container(
                                          height: 150,
                                          color: const Color(0xFFF1F5F9),
                                          child: const Icon(Icons.home_work_outlined, size: 60, color: Colors.blueGrey),
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
                                      prop['broker_name'],
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
                                      color: prop['listing_type'] == 'للبيع قطعي' ? Colors.red.shade700 : Colors.teal.shade700,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      prop['listing_type'],
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // تفاصيل العقار
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    prop['property_title'],
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 14, color: Colors.red),
                                      const SizedBox(width: 4),
                                      Text(prop['location_neighborhood'], style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // مواصفات الغرف والمساحة
                                  Row(
                                    children: [
                                      if ((prop['bedrooms'] as int) > 0) ...[
                                        _buildFeatureChip(Icons.bed, '${prop['bedrooms']} غرف'),
                                        const SizedBox(width: 8),
                                      ],
                                      if ((prop['bathrooms'] as int) > 0) ...[
                                        _buildFeatureChip(Icons.bathtub, '${prop['bathrooms']} حمامات'),
                                        const SizedBox(width: 8),
                                      ],
                                      _buildFeatureChip(Icons.square_foot, '${prop['area_sqm']} م²'),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  if (description.isNotEmpty) ...[
                                    Text(
                                      description,
                                      style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 12, height: 1.4),
                                    ),
                                    const SizedBox(height: 10),
                                  ],

                                  const Divider(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('السعر المحدد:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                          Text(
                                            price >= 1000000
                                                ? '${(price / 1000000).toStringAsFixed(1)} مليون ر.ي'
                                                : '${price.toInt()} ر.ي',
                                            style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 17),
                                          ),
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
                                            label: const Text('شات المالك', style: TextStyle(fontSize: 12)),
                                            onPressed: () => _openBrokerChat(prop),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF0F172A),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            icon: const Icon(Icons.calendar_today, size: 16),
                                            label: const Text('طلب معاينة (QR)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                            onPressed: () => _bookInspectionAppointment(prop),
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

  Widget _buildFeatureChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.blueGrey),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
