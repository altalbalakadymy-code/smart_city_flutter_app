import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class QatMarketScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const QatMarketScreen({super.key, this.currentUser});

  @override
  State<QatMarketScreen> createState() => _QatMarketScreenState();
}

class _QatMarketScreenState extends State<QatMarketScreen> {
  final String _baseUrl = "https://smartcitybackend-production-9d26.up.railway.app";
  List<dynamic> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMarket();
  }

  Future<void> _fetchMarket() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse("$_baseUrl/api/v1/qat/market"));
      if (res.statusCode == 200) {
        setState(() {
          items = jsonDecode(res.body);
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  void _orderDialog(dynamic item) {
    final addrCtrl = TextEditingController();
    final userId = widget.currentUser?['id'] ?? 1;
    final cName = widget.currentUser?['full_name'] ?? 'مواطن';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2541),
        title: Text('طلب ${item['qat_type']}', style: const TextStyle(color: Color(0xFF06D6A0), fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الجودة: ${item['quality_grade']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text('السوق: ${item['market_location']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 6),
            Text('السعر: \$${item['price']}', style: const TextStyle(color: Color(0xFFFFB703), fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            TextField(
              controller: addrCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'عنوان التوصيل (المقيل أو المنزل)',
                labelStyle: const TextStyle(color: Colors.white60),
                filled: true,
                fillColor: const Color(0xFF0B132B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06D6A0)),
            onPressed: () async {
              if (addrCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);

              try {
                final res = await http.post(
                  Uri.parse("$_baseUrl/api/v1/qat/order"),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "user_id": userId,
                    "citizen_name": cName,
                    "item_id": item['id'],
                    "qat_type": item['qat_type'],
                    "quantity": 1,
                    "total_price": item['price'],
                    "delivery_address": addrCtrl.text.trim(),
                  }),
                );
                if (res.statusCode == 200) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تأكيد الطلب وجارٍ التجهيز والتوصيل للمقيل 🌿🚗'),
                      backgroundColor: Color(0xFF06D6A0),
                    ),
                  );
                }
              } catch (_) {}
            },
            child: const Text('تأكيد الشراء', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold)),
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
        title: const Text('سوق القات الذكي المعتمد'),
        backgroundColor: const Color(0xFF1C2541),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _fetchMarket),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF06D6A0)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final itm = items[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C2541),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF06D6A0).withOpacity(0.35)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: Color(0x2206D6A0),
                        child: Icon(Icons.eco_rounded, color: Color(0xFF06D6A0), size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(itm['qat_type'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 3),
                            Text('الرتبة: ${itm['quality_grade']} • ${itm['market_location']}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text('\$${itm['price']}', style: const TextStyle(color: Color(0xFFFFB703), fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06D6A0)),
                        onPressed: () => _orderDialog(itm),
                        child: const Text('طلب الآن', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
