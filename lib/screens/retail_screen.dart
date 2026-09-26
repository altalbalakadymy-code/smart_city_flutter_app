import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RetailScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const RetailScreen({super.key, this.currentUser});

  @override
  State<RetailScreen> createState() => _RetailScreenState();
}

class _RetailScreenState extends State<RetailScreen> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String _selectedCategory = 'الكل';
  final List<String> _categories = [
    'الكل',
    'إلكترونيات وهواتف',
    'ملابس وموضة',
    'ألعاب وترفيه',
    'عطور ومستحضرات',
    'مستلزمات منزلية',
  ];

  bool get _isVip => widget.currentUser?['is_vip'] == true;
  bool get _isAuthorized =>
      widget.currentUser?['role'] == 'ADMIN' || widget.currentUser?['role'] == 'VENDOR';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final data = await ApiService.fetchRetailProducts();
    if (mounted) {
      setState(() {
        _products = data;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedCategory == 'الكل') return _products;
    return _products.where((p) => p['store_category'] == _selectedCategory).toList();
  }

  void _showAddProductDialog() {
    final storeCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final imgCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: '5');
    final hoursCtrl = TextEditingController(text: '48');
    final phoneCtrl = TextEditingController(text: '770000000');
    String selectedCat = 'إلكترونيات وهواتف';

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
                const Text('إضافة سلعة وبطاقة متجر جديدة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                TextField(controller: storeCtrl, decoration: InputDecoration(labelText: 'اسم المتجر أو المحل', prefixIcon: const Icon(Icons.store), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedCat,
                  decoration: InputDecoration(labelText: 'تصنيف المتجر', prefixIcon: const Icon(Icons.category), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  items: ['إلكترونيات وهواتف', 'ملابس وموضة', 'ألعاب وترفيه', 'عطور ومستحضرات', 'مستلزمات منزلية', 'أخرى']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedCat = v);
                  },
                ),
                const SizedBox(height: 10),
                TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'اسم السلعة / المنتج بالكامل', prefixIcon: const Icon(Icons.shopping_bag), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 10),
                TextField(controller: descCtrl, maxLines: 2, decoration: InputDecoration(labelText: 'وصف السلعة ومواصفاتها', prefixIcon: const Icon(Icons.description), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 10),
                TextField(controller: imgCtrl, decoration: InputDecoration(labelText: 'رابط صورة السلعة (URL)', prefixIcon: const Icon(Icons.image), hintText: 'https://...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 10),
                TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'السعر بالريال اليمني', prefixIcon: const Icon(Icons.money), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'الكمية المتوفرة', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(controller: hoursCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'مهلة الحفظ (ساعة)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: 'رقم هاتف المحل', prefixIcon: const Icon(Icons.phone), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 18),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty || storeCtrl.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    final ok = await ApiService.addRetailProduct(
                      storeName: storeCtrl.text.trim(),
                      storeCategory: selectedCat,
                      productTitle: titleCtrl.text.trim(),
                      description: descCtrl.text.trim().isEmpty ? 'سلعة أصلية مضمونة متوفرة في المتجر.' : descCtrl.text.trim(),
                      imageUrl: imgCtrl.text.trim(),
                      price: double.tryParse(priceCtrl.text) ?? 10000.0,
                      stock: int.tryParse(stockCtrl.text) ?? 5,
                      holdHours: int.tryParse(hoursCtrl.text) ?? 48,
                      phone: phoneCtrl.text.trim(),
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(ok ? 'تمت إضافة السلعة والبطاقة بنجاح' : 'تم الحفظ محلياً'), backgroundColor: Colors.indigo),
                      );
                      _loadProducts();
                    }
                  },
                  child: const Text('حفظ السلعة ونشرها في المتجر'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _reserveProduct(Map<String, dynamic> prod) async {
    final double basePrice = (prod['price'] as num).toDouble();
    final double finalPrice = _isVip ? basePrice * 0.8 : basePrice;
    final ticketCode = 'PASS-SHOP-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    await ApiService.addBusinessItem({
      'user_id': widget.currentUser?['id'] ?? '1',
      'business_name': '${prod['store_name']} - ${prod['product_title']}',
      'category': 'STORE',
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
            Center(
              child: Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 16),
            const Text('تذكرة تثبيت حجز سلعة (Hold Pass)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)), textAlign: TextAlign.center),
            Text('${prod['store_name']} | ${prod['product_title']}', style: const TextStyle(color: Colors.indigo, fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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
                _buildInfo('مهلة الحفظ', '${prod['hold_hours']} ساعة'),
                _buildInfo('المخزون المحجوز', 'قطعة واحدة'),
                _buildInfo('المبلغ عند الاستلام', '${finalPrice.toInt()} ر.ي'),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.lock_clock, color: Colors.indigo, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('تم تثبيت السلعة باسمك في المتجر ولن تُباع لأي شخص آخر، توجّه للمتجر وأبرز هذا الكود للدفع والاستلام المباشر.', style: TextStyle(fontSize: 11, color: Colors.indigo)),
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
              child: const Text('تم الحفظ في حجوزاتي'),
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

  void _openStoreChat(Map<String, dynamic> prod) {
    final msgCtrl = TextEditingController();
    final List<Map<String, String>> chat = [
      {'sender': 'vendor', 'text': 'مرحباً بك في ${prod['store_name']}. السلعة (${prod['product_title']}) متوفرة وجاهزة، هل تود الاستفسار عن تفاصيل أو ضمانات معينة؟'}
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
                        const CircleAvatar(backgroundColor: Colors.indigo, child: Icon(Icons.storefront, color: Colors.white, size: 20)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(prod['store_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(prod['store_category'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
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
                            hintText: 'اكتب استفسارك للبائع حول السلعة...',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
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
        title: const Text('المتاجر وحجز السلع قبل النفاد', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        actions: [
          if (_isAuthorized)
            IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              tooltip: 'إضافة سلعة',
              onPressed: _showAddProductDialog,
            ),
        ],
      ),
      floatingActionButton: _isAuthorized
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF0F172A),
              icon: const Icon(Icons.add_business, color: Color(0xFF06B6D4)),
              label: const Text('إضافة سلعة / متجر', style: TextStyle(color: Colors.white)),
              onPressed: _showAddProductDialog,
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
          : Column(
              children: [
                // فلتر فئات المتاجر
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

                // بطاقات السلع بنظام Grid Card
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, idx) {
                      final prod = _filteredProducts[idx];
                      final double basePrice = (prod['price'] as num).toDouble();
                      final double finalPrice = _isVip ? basePrice * 0.8 : basePrice;
                      final String imgUrl = prod['image_url']?.toString() ?? '';
                      final String description = prod['description']?.toString() ?? '';

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
                            // صورة السلعة مع شارات المتجر والمخزون
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  child: imgUrl.isNotEmpty
                                      ? Image.network(
                                          imgUrl,
                                          height: 180,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, stack) => Container(
                                            height: 140,
                                            color: const Color(0xFFF1F5F9),
                                            child: const Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.blueGrey),
                                          ),
                                        )
                                      : Container(
                                          height: 140,
                                          color: const Color(0xFFF1F5F9),
                                          child: const Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.blueGrey),
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
                                      prod['store_name'],
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
                                      color: Colors.blue.shade600,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'المتبقي: ${prod['stock_quantity']}',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // تفاصيل السلعة
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          prod['product_title'],
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(6)),
                                        child: Text(prod['store_category'], style: TextStyle(color: Colors.indigo.shade800, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  if (description.isNotEmpty) ...[
                                    Text(
                                      description,
                                      style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 12, height: 1.4),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  Row(
                                    children: [
                                      const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text('مهلة تثبيت الحجز: ${prod['hold_hours']} ساعة للاستلام المباشر', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                  const Divider(height: 22),
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
                                            icon: const Icon(Icons.chat_outlined, size: 16),
                                            label: const Text('شات البائع', style: TextStyle(fontSize: 12)),
                                            onPressed: () => _openStoreChat(prod),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF0F172A),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            icon: const Icon(Icons.lock_outline, size: 16),
                                            label: const Text('تثبيت الحجز', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                            onPressed: () => _reserveProduct(prod),
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
