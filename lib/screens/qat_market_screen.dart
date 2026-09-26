import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QatMarketScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const QatMarketScreen({super.key, this.currentUser});

  @override
  State<QatMarketScreen> createState() => _QatMarketScreenState();
}

class _QatMarketScreenState extends State<QatMarketScreen> {
  List<Map<String, dynamic>> _lots = [];
  bool _isLoading = true;

  // قائمة الأسواق النموذجية المعتمدة
  final List<String> _markets = [
    'سوق مذبح المركزي النموذجي',
    'سوق شميلة الموحد',
    'سوق السنينة النموذجي',
    'سوق دار سلم الحديث',
    'سوق الحثيلي التخصصي',
  ];
  late String _selectedMarket;

  bool get _isVip => widget.currentUser?['is_vip'] == true;
  bool get _isAuthorized =>
      widget.currentUser?['role'] == 'ADMIN' || widget.currentUser?['role'] == 'VENDOR';

  @override
  void initState() {
    super.initState();
    _selectedMarket = _markets.first;
    _loadMarketLots();
  }

  Future<void> _loadMarketLots() async {
    setState(() => _isLoading = true);
    final data = await ApiService.fetchQatMarkets();
    if (mounted) {
      setState(() {
        _lots = data;
        _isLoading = false;
      });
    }
  }

  // فلترة المقاوته التابعين للسوق المحدد حالياً
  List<Map<String, dynamic>> get _currentMarketLots {
    return _lots.where((lot) => lot['market_name'] == _selectedMarket).toList();
  }

  void _showAddVendorLotDialog() {
    final venCtrl = TextEditingController();
    final stallCtrl = TextEditingController(text: 'بسطة 12');
    final typeCtrl = TextEditingController(text: 'همداني غيلي رطب');
    final descCtrl = TextEditingController();
    final imgCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final bndCtrl = TextEditingController(text: '6');
    final phoneCtrl = TextEditingController(text: '770000000');
    String selectedMkt = _selectedMarket;

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
                const Text('إضافة مقوتي وباقة قات جديدة للسوق', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedMkt,
                  decoration: const InputDecoration(labelText: 'السوق التابع له', prefixIcon: Icon(Icons.store), border: OutlineInputBorder()),
                  items: _markets.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedMkt = v);
                  },
                ),
                const SizedBox(height: 10),
                TextField(controller: venCtrl, decoration: const InputDecoration(labelText: 'اسم المقوتي (البائع)', prefixIcon: Icon(Icons.person), border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: stallCtrl, decoration: const InputDecoration(labelText: 'موقع البسطة أو الركن بالسوق', prefixIcon: Icon(Icons.location_on), border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'نوع القات (همداني، أرحبي، صبري، شامي)', prefixIcon: Icon(Icons.eco), border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'وصف القطفة والجودة', prefixIcon: const Icon(Icons.description), border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: 'رابط صورة الباقة الطازجة (URL)', prefixIcon: Icon(Icons.image), border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سعر الباقة بالريال اليمني', prefixIcon: Icon(Icons.money), border: OutlineInputBorder())),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(controller: bndCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'عدد الحبات المتوفرة', border: OutlineInputBorder())),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم هاتف المقوتي', border: OutlineInputBorder())),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () async {
                    if (venCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    final ok = await ApiService.addQatVendorLot(
                      marketName: selectedMkt,
                      vendorName: venCtrl.text.trim(),
                      stallNumber: stallCtrl.text.trim(),
                      qatType: typeCtrl.text.trim(),
                      description: descCtrl.text.trim().isEmpty ? 'قطفة اليوم طازجة رطبة من أفضل المزارع.' : descCtrl.text.trim(),
                      imageUrl: imgCtrl.text.trim(),
                      price: double.tryParse(priceCtrl.text) ?? 8000.0,
                      bundles: int.tryParse(bndCtrl.text) ?? 5,
                      phone: phoneCtrl.text.trim(),
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(ok ? 'تمت إضافة المقوتي وباقته للسوق بنجاح' : 'تم الحفظ محلياً'), backgroundColor: Colors.green.shade800),
                      );
                      _loadMarketLots();
                    }
                  },
                  child: const Text('حفظ ونشر الباقة في السوق'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _reserveLot(Map<String, dynamic> lot) async {
    final double basePrice = (lot['price'] as num).toDouble();
    final double finalPrice = _isVip ? basePrice * 0.8 : basePrice;
    final ticketCode = 'PASS-QAT-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    await ApiService.addBusinessItem({
      'user_id': widget.currentUser?['id'] ?? '1',
      'business_name': '${lot['market_name']} - المقوتي ${lot['vendor_name']}',
      'category': 'QAT',
      'total_price': finalPrice,
      'qr_pass': ticketCode,
      'status': 'HOLD_CONFIRMED',
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
            const Text('تذكرة تثبيت باقة قات (استلام يدوي مباشر)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)), textAlign: TextAlign.center),
            Text('${lot['market_name']} | المقوتي: ${lot['vendor_name']}', style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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
                _buildInfo('موقع المقوتي', lot['stall_number']),
                _buildInfo('نوع القات', lot['qat_type']),
                _buildInfo('المبلغ عند الاستلام', '${finalPrice.toInt()} ر.ي'),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.verified, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('تم تثبيت الحبة باسمك في بسطة المقوتي حتى لا تُباع لأحد، توجّه للسوق وأبرز الكود لاستلامها يدوياً.', style: TextStyle(fontSize: 11, color: Colors.black87)),
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
              child: const Text('تم الحفظ في تذاكري'),
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

  void _openVendorChat(Map<String, dynamic> lot) {
    final msgCtrl = TextEditingController();
    final List<Map<String, String>> chat = [
      {'sender': 'vendor', 'text': 'حياك الله يا غالي، أنا المقوتي ${lot['vendor_name']} في ${lot['stall_number']}. القات (${lot['qat_type']}) طازج قطفة اليوم ونظيف جداً، تشتي أثبت لك الحبة؟'}
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
                        const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.eco, color: Colors.white, size: 20)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('المقوتي: ${lot['vendor_name']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(lot['stall_number'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
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
                            hintText: 'اكتب استفسارك أو تفاوضك مع المقوتي...',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
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
    final lotsToDisplay = _currentMarketLots;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text('أسواق القات النموذجية والمقاوته', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        actions: [
          if (_isAuthorized)
            IconButton(
              icon: const Icon(Icons.add_business),
              tooltip: 'إضافة مقوتي وباقة',
              onPressed: _showAddVendorLotDialog,
            ),
        ],
      ),
      floatingActionButton: _isAuthorized
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF0F172A),
              icon: const Icon(Icons.eco, color: Color(0xFF06B6D4)),
              label: const Text('إضافة مقوتي / باقة', style: TextStyle(color: Colors.white)),
              onPressed: _showAddVendorLotDialog,
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
          : Column(
              children: [
                // محدد السوق النموذجي
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('اختر السوق النموذجي لعرض مقاوته السوق:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedMarket,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.storefront, color: Colors.green),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        isExpanded: true,
                        items: _markets.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)))).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedMarket = v);
                        },
                      ),
                    ],
                  ),
                ),

                // بطاقة توجيه الاستلام المباشر
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_user_outlined, color: Colors.green, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'تثبيت الباقة يضمن عزل الحبة لك في بسطة المقوتي بالسوق وتستلمها يدوياً فور وصولك.',
                          style: TextStyle(fontSize: 11, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),

                // عرض مقاوته وباقات السوق المختار
                Expanded(
                  child: lotsToDisplay.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.eco_outlined, size: 60, color: Colors.grey.shade400),
                              const SizedBox(height: 10),
                              Text('لا توجد باقات مسجلة حالياً في $_selectedMarket', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: lotsToDisplay.length,
                          itemBuilder: (context, idx) {
                            final lot = lotsToDisplay[idx];
                            final double basePrice = (lot['price'] as num).toDouble();
                            final double finalPrice = _isVip ? basePrice * 0.8 : basePrice;
                            final String imgUrl = lot['image_url']?.toString() ?? '';
                            final String description = lot['description']?.toString() ?? '';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 18),
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
                                  // صورة الباقة الطازجة
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                        child: imgUrl.isNotEmpty
                                            ? Image.network(
                                                imgUrl,
                                                height: 170,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (ctx, err, stack) => Container(
                                                  height: 140,
                                                  color: const Color(0xFFF1F5F9),
                                                  child: const Icon(Icons.eco, size: 60, color: Colors.green),
                                                ),
                                              )
                                            : Container(
                                                height: 140,
                                                color: const Color(0xFFF1F5F9),
                                                child: const Icon(Icons.eco, size: 60, color: Colors.green),
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
                                            'المقوتي: ${lot['vendor_name']}',
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
                                            color: Colors.green.shade700,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'المتبقي: ${lot['available_bundles']} حبات',
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // تفاصيل باقة المقوتي
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              lot['qat_type'],
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                                              child: Text(lot['stall_number'], style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.w600)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        if (description.isNotEmpty) ...[
                                          Text(
                                            description,
                                            style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 12, height: 1.4),
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                        const Divider(height: 20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
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
                                                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                                                  label: const Text('تفاوض المقوتي', style: TextStyle(fontSize: 12)),
                                                  onPressed: () => _openVendorChat(lot),
                                                ),
                                                const SizedBox(width: 8),
                                                ElevatedButton.icon(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF0F172A),
                                                    foregroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  ),
                                                  icon: const Icon(Icons.lock_outline, size: 16),
                                                  label: const Text('تثبيت الحبة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                                  onPressed: () => _reserveLot(lot),
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
