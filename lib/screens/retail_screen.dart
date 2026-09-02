import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RetailScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const RetailScreen({super.key, this.currentUser});

  @override
  State<RetailScreen> createState() => _RetailScreenState();
}

class _RetailScreenState extends State<RetailScreen> {
  final String _baseUrl = "https://smartcitybackend-production-9d26.up.railway.app";
  List<dynamic> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMarketItems();
  }

  Future<void> _fetchMarketItems() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse("$_baseUrl/api/v1/market/items"));
      if (res.statusCode == 200) {
        setState(() {
          items = jsonDecode(res.body);
          isLoading = false;
        });
      } else {
        throw Exception();
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _buyItem(dynamic item) async {
    final userId = widget.currentUser?['id'] ?? 1;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2541),
        title: const Text('تأكيد الشراء والطلب', style: TextStyle(color: Color(0xFF00F5D4))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المنتج: ${item['title']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('المتجر: ${item['store_name']}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            Text('الإجمالي: \$${item['price']}', style: const TextStyle(color: Color(0xFFFFB703), fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F5D4)),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final res = await http.post(
                  Uri.parse("$_baseUrl/api/v1/market/orders"),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "user_id": userId,
                    "item_id": item['id'],
                    "quantity": 1,
                    "total_price": item['price'],
                  }),
                );
                if (res.statusCode == 200) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تأكيد طلبك بنجاح وجارٍ التجهيز في المتجر 🛍️'),
                      backgroundColor: Color(0xFF06D6A0),
                    ),
                  );
                }
              } catch (_) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تعذر إتمام الطلب، تحقق من الاتصال'),
                    backgroundColor: Color(0xFFFF5964),
                  ),
                );
              }
            },
            child: const Text('تأكيد الطلب', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: const Text('المتاجر والتسوق الذكي'),
        backgroundColor: const Color(0xFF1C2541),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchMarketItems,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00F5D4)))
          : items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.storefront_outlined, size: 70, color: Colors.white.withOpacity(0.3)),
                      const SizedBox(height: 12),
                      const Text('لا توجد منتجات أو خدمات معروضة حالياً', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      const Text('بإمكان التجار المعتمدين إضافة عناصر جديدة من لوحاتهم', style: TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final itm = items[i];
                    final hasImg = itm['image_url'] != null && itm['image_url'].toString().startsWith('http');
                    final isService = itm['item_type'] == 'service';

                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2541),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: hasImg
                                ? Image.network(
                                    itm['image_url'],
                                    height: 110,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 110,
                                      color: const Color(0xFF0B132B),
                                      child: Icon(isService ? Icons.design_services : Icons.shopping_bag, color: Colors.white38),
                                    ),
                                  )
                                : Container(
                                    height: 110,
                                    width: double.infinity,
                                    color: const Color(0xFF0B132B),
                                    child: Icon(isService ? Icons.design_services : Icons.shopping_bag, color: Colors.white38),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  itm['title'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  itm['store_name'] ?? 'متجر معتمد',
                                  style: const TextStyle(color: Color(0xFF00F5D4), fontSize: 11),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '\$${itm['price']}',
                                      style: const TextStyle(color: Color(0xFFFFB703), fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    SizedBox(
                                      height: 32,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF00F5D4),
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                        ),
                                        onPressed: () => _buyItem(itm),
                                        child: const Text('طلب', style: TextStyle(color: Color(0xFF0B132B), fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
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
    );
  }
}
