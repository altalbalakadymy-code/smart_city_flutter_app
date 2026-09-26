import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RestaurantScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const RestaurantScreen({super.key, this.currentUser});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  List<Map<String, dynamic>> _meals = [];
  bool _isLoading = true;
  String _selectedCategory = 'الكل';
  final List<String> _categories = ['الكل', 'شعبي يمني', 'مشويات ومندي', 'وجبات سريعة', 'بحريات'];

  // إدارة سلة الوجبات المحددة (Meal ID -> Quantity)
  final Map<int, int> _cart = {};
  String _pickupTime = 'بعد 20 دقيقة (استلام ساخن)';

  bool get _isVip => widget.currentUser?['is_vip'] == true;
  bool get _isAuthorized =>
      widget.currentUser?['role'] == 'ADMIN' || widget.currentUser?['role'] == 'VENDOR';

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    setState(() => _isLoading = true);
    final data = await ApiService.fetchRestaurantMeals();
    if (mounted) {
      setState(() {
        _meals = data;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredMeals {
    if (_selectedCategory == 'الكل') return _meals;
    return _meals.where((m) => m['category'] == _selectedCategory).toList();
  }

  double get _cartTotal {
    double total = 0.0;
    _cart.forEach((mealId, qty) {
      final meal = _meals.firstWhere((m) => m['id'] == mealId, orElse: () => {});
      if (meal.isNotEmpty) {
        total += (meal['price'] as num).toDouble() * qty;
      }
    });
    return _isVip ? total * 0.8 : total; // تطبيق خصم الـ VIP بنسبة 20%
  }

  int get _cartItemCount => _cart.values.fold(0, (sum, q) => sum + q);

  void _showAddMealDialog() {
    final restCtrl = TextEditingController(text: 'مطعم الشيباني الملكي');
    final titleCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'شعبي يمني');
    final priceCtrl = TextEditingController(text: '4500');
    final timeCtrl = TextEditingController(text: '15');
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
              const Text('إضافة وجبة جديدة للسيرفر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextField(controller: restCtrl, decoration: InputDecoration(labelText: 'اسم المطعم', prefixIcon: const Icon(Icons.store), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 10),
              TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'اسم الوجبة بالكامل', prefixIcon: const Icon(Icons.restaurant_menu), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 10),
              TextField(controller: catCtrl, decoration: InputDecoration(labelText: 'التصنيف (شعبي، مشويات، سريع)', prefixIcon: const Icon(Icons.category), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 10),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'السعر بالريال اليمني', prefixIcon: const Icon(Icons.money), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 10),
              TextField(controller: timeCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'وقت التجهيز بالدقائق', prefixIcon: const Icon(Icons.timer), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 10),
              TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: 'هاتف الكاشير للتواصل', prefixIcon: const Icon(Icons.phone), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  if (titleCtrl.text.trim().isEmpty) return;
                  Navigator.pop(ctx);
                  final ok = await ApiService.addRestaurantMeal(
                    restaurantName: restCtrl.text.trim(),
                    mealTitle: titleCtrl.text.trim(),
                    category: catCtrl.text.trim(),
                    price: double.tryParse(priceCtrl.text) ?? 4500.0,
                    prepTime: int.tryParse(timeCtrl.text) ?? 15,
                    phone: phoneCtrl.text.trim(),
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(ok ? 'تمت إضافة الوجبة للسيرفر بنجاح' : 'تم الحفظ محلياً'), backgroundColor: Colors.orange.shade800),
                    );
                    _loadMeals();
                  }
                },
                child: const Text('حفظ الوجبة في قاعدة البيانات'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmPreOrder() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إضافة وجبة واحدة على الأقل للسلة')));
      return;
    }

    final ticketCode = 'PASS-FOOD-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    await ApiService.addBusinessItem({
      'user_id': widget.currentUser?['id'] ?? '1',
      'business_name': 'طلبية وجبات مسبقة (Pre-order)',
      'category': 'RESTAURANT',
      'total_price': _cartTotal,
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
            const Text('تذكرة تجهيز واستلام مباشر (Takeaway)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('وقت الوصول المحدد: $_pickupTime', style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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
                _buildInfo('عدد الوجبات', '$_cartItemCount أصناف'),
                _buildInfo('طريقة الاستلام', 'استلام مباشر ذاتي'),
                _buildInfo('المبلغ المطلوب', '${_cartTotal.toInt()} ر.ي'),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.takeout_dining, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('يتم تجهيز الوجبة لتكون ساخنة فور وصولك، أبرز هذا الكود لقسم الاستلام المباشر بالمطعم.', style: TextStyle(fontSize: 11, color: Colors.brown)),
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
              onPressed: () {
                setState(() => _cart.clear());
                Navigator.pop(ctx);
              },
              child: const Text('تم الحفظ في طلباتي النشطة'),
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

  void _openKitchenChat(Map<String, dynamic> meal) {
    final msgCtrl = TextEditingController();
    final List<Map<String, String>> chat = [
      {'sender': 'kitchen', 'text': 'أهلاً بك في ${meal['restaurant_name']}. يتم تحضير الوجبات طازجة، يرجى كتابة أي ملاحظات خاصة (بدون فلفل، زيادة مرق، إلخ).'}
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
                        const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.soup_kitchen, color: Colors.white, size: 20)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(meal['restaurant_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('كاشير ومطبخ الوجبات', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
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
                            hintText: 'اكتب ملاحظات الوجبة للمطبخ...',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
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
        title: const Text('المطاعم وتجهيز الوجبات المسبق', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        actions: [
          if (_isAuthorized)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'إضافة وجبة',
              onPressed: _showAddMealDialog,
            ),
        ],
      ),
      floatingActionButton: _isAuthorized
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF0F172A),
              icon: const Icon(Icons.restaurant, color: Color(0xFF06B6D4)),
              label: const Text('إضافة وجبة للسيرفر', style: TextStyle(color: Colors.white)),
              onPressed: _showAddMealDialog,
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
          : Column(
              children: [
                // فلتر أصناف الوجبات
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

                // محدد وقت الوصول والاستلام المباشر
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black.withOpacity(0.04)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_filled, color: Colors.orange, size: 20),
                      const SizedBox(width: 10),
                      const Text('موعد وصولك للاستلام:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _pickupTime,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
                            items: const [
                              DropdownMenuItem(value: 'بعد 20 دقيقة (استلام ساخن)', child: Text('بعد 20 دقيقة')),
                              DropdownMenuItem(value: 'بعد 35 دقيقة', child: Text('بعد 35 دقيقة')),
                              DropdownMenuItem(value: 'بعد ساعة كاملة', child: Text('بعد ساعة كاملة')),
                            ],
                            onChanged: (v) {
                              if (v != null) setState(() => _pickupTime = v);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // قائمة الوجبات
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredMeals.length,
                    itemBuilder: (context, idx) {
                      final meal = _filteredMeals[idx];
                      final mealId = meal['id'] as int;
                      final int qty = _cart[mealId] ?? 0;
                      final double price = (meal['price'] as num).toDouble();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.black.withOpacity(0.04)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(meal['meal_title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                                      const SizedBox(height: 2),
                                      Text('${meal['restaurant_name']} | وقت التجهيز: ${meal['prep_time_mins']} دقيقة', style: const TextStyle(color: Colors.blueGrey, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.orange),
                                  tooltip: 'ملاحظات للمطبخ',
                                  onPressed: () => _openKitchenChat(meal),
                                ),
                              ],
                            ),
                            const Divider(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${price.toInt()} ر.ي', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 16)),
                                Row(
                                  children: [
                                    if (qty > 0) ...[
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                        onPressed: () => setState(() {
                                          if (qty == 1) {
                                            _cart.remove(mealId);
                                          } else {
                                            _cart[mealId] = qty - 1;
                                          }
                                        }),
                                      ),
                                      Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    ],
                                    IconButton(
                                      icon: const Icon(Icons.add_circle, color: Color(0xFF0F172A)),
                                      onPressed: () => setState(() => _cart[mealId] = qty + 1),
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

                // شريط السلة والسعر النهائي بالأسفل
                if (_cartItemCount > 0)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F172A),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('الوجبات المحددة: $_cartItemCount', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            Row(
                              children: [
                                Text('${_cartTotal.toInt()} ر.ي', style: const TextStyle(color: Color(0xFF06B6D4), fontSize: 20, fontWeight: FontWeight.bold)),
                                if (_isVip) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                                    child: const Text('خصم VIP 20%', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF06B6D4),
                            foregroundColor: const Color(0xFF0F172A),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.takeout_dining),
                          label: const Text('تأكيد الطلب (QR Pass)', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: _confirmPreOrder,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
