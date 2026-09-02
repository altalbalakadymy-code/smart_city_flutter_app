import 'package:flutter/material.dart';

class RetailScreen extends StatefulWidget {
  const RetailScreen({super.key});

  @override
  State<RetailScreen> createState() => _RetailScreenState();
}

class _RetailScreenState extends State<RetailScreen> {
  final List<Map<String, dynamic>> products = [
    {
      'id': '1',
      'name': 'ساعة ذكية للمدينة الذكية (IoT)',
      'price': 120.0,
      'category': 'إلكترونيات',
      'icon': Icons.watch_rounded,
      'rating': 4.9,
    },
    {
      'id': '2',
      'name': 'نظارة الواقع الافتراضي VR Pro',
      'price': 250.0,
      'category': 'الميتافيرس',
      'icon': Icons.view_in_ar_rounded,
      'rating': 4.8,
    },
    {
      'id': '3',
      'name': 'حساس منزلي ذكي للطاقة والمناخ',
      'price': 45.0,
      'category': 'إنترنت الأشياء',
      'icon': Icons.sensors_rounded,
      'rating': 4.7,
    },
    {
      'id': '4',
      'name': 'بطاقة التنقل والمحفظة الرقمية الذكية',
      'price': 15.0,
      'category': 'خدمات',
      'icon': Icons.credit_card_rounded,
      'rating': 4.9,
    },
  ];

  final Map<String, int> cart = {};

  void _addToCart(String productId) {
    setState(() {
      cart[productId] = (cart[productId] ?? 0) + 1;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تمت إضافة المنتج إلى السلة الذكية 🛒'),
        duration: Duration(milliseconds: 900),
        backgroundColor: Color(0xFF00F5D4),
      ),
    );
  }

  double _calculateTotal() {
    double total = 0;
    cart.forEach((id, qty) {
      final item = products.firstWhere((p) => p['id'] == id);
      total += (item['price'] as double) * qty;
    });
    return total;
  }

  void _checkoutDialog() {
    final total = _calculateTotal();
    if (total == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('السلة فارغة حالياً! أضف بعض المنتجات أولاً.'),
          backgroundColor: Color(0xFFFF5964),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2541),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'سلة الشراء والدفع الرقمي الموحد',
              style: TextStyle(color: Color(0xFF00F5D4), fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            ...cart.entries.map((entry) {
              final product = products.firstWhere((p) => p['id'] == entry.key);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${product['name']} (x${entry.value})',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      '\$${(product['price'] * entry.value).toStringAsFixed(1)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
            const Divider(color: Colors.white24, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الإجمالي المستحق:', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(color: Color(0xFF06D6A0), fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06D6A0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() => cart.clear());
                  showDialog(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      backgroundColor: const Color(0xFF1C2541),
                      title: const Text('تمت العملية بنجاح! 💳', style: TextStyle(color: Color(0xFF00F5D4))),
                      content: const Text(
                        'تم خصم المبلغ وتأكيد الفاتورة الرقمية المشفرة في محفظة المدينة الذكية.',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F5D4)),
                          onPressed: () => Navigator.pop(dCtx),
                          child: const Text('حسناً', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text(
                  'تأكيد الدفع الرقمي الفوري',
                  style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalItems = cart.values.fold(0, (sum, count) => sum + count);

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: const Text('المتاجر والتسوق الذكي'),
        backgroundColor: const Color(0xFF1C2541),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                onPressed: _checkoutDialog,
              ),
              if (totalItems > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF5964),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$totalItems',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // لوحة الترويج الذكي
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1C2541), Color(0xFF283655)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFF5964).withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.local_offer_rounded, color: Color(0xFFFF5964), size: 36),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('سوق المدينة الافتراضي الموحد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 4),
                      Text('شراء فوري بالدفع الرقمي مع تسليم عبر الدرونز الذكية في دقائق.', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'أحدث المنتجات والخدمات الذكية',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...products.map((p) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2541),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFFF5964).withOpacity(0.15),
                      child: Icon(p['icon'], color: const Color(0xFFFF5964), size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text('${p['category']} • ★ ${p['rating']}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          const SizedBox(height: 6),
                          Text('\$${p['price']}', style: const TextStyle(color: Color(0xFF00F5D4), fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5964),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      onPressed: () => _addToCart(p['id']),
                      icon: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
                      label: const Text('إضافة', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
              )),
        ],
      ),
      bottomNavigationBar: totalItems > 0
          ? Container(
              padding: const EdgeInsets.all(14),
              color: const Color(0xFF1C2541),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00F5D4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _checkoutDialog,
                child: Text(
                  'عرض السلة ($totalItems عناصر) - \$${_calculateTotal().toStringAsFixed(2)}',
                  style: const TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            )
          : null,
    );
  }
}
