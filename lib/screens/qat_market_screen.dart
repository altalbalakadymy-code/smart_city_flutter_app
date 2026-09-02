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
    final bool isVendor = widget.currentUser?['role'] == 'qat_vendor';

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: const Text('سوق القات الذكي المعتمد'),
        backgroundColor: const Color(0xFF1C2541),
        actions: [
          if (isVendor)
            IconButton(
              tooltip: 'لوحة إدارة طلباتي وبضاعتي',
              icon: const Icon(Icons.storefront_rounded, color: Color(0xFF06D6A0)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EmbeddedQatVendorDashboard(vendorUser: widget.currentUser!)),
                );
              },
            ),
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

// ----------------- لوحة تحكم بائع القات المدمجة -----------------
class EmbeddedQatVendorDashboard extends StatefulWidget {
  final Map<String, dynamic> vendorUser;
  const EmbeddedQatVendorDashboard({super.key, required this.vendorUser});

  @override
  State<EmbeddedQatVendorDashboard> createState() => _EmbeddedQatVendorDashboardState();
}

class _EmbeddedQatVendorDashboardState extends State<EmbeddedQatVendorDashboard> {
  final String _baseUrl = "https://smartcitybackend-production-9d26.up.railway.app";
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse("$_baseUrl/api/v1/vendor/qat-orders"));
      if (res.statusCode == 200) {
        setState(() {
          orders = jsonDecode(res.body);
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateStatus(int orderId, String nextStatus) async {
    await http.patch(
      Uri.parse("$_baseUrl/api/v1/vendor/qat-orders/$orderId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"status": nextStatus}),
    );
    _fetchOrders();
  }

  void _showAddItemDialog() {
    final typeCtrl = TextEditingController();
    final gradeCtrl = TextEditingController(text: "سوبر ممتاز");
    final locCtrl = TextEditingController(text: "سوق شميلة الموحد");
    final priceCtrl = TextEditingController(text: "15");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2541),
        title: const Text('إضافة صنف قات للسوق', style: TextStyle(color: Color(0xFF06D6A0), fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: typeCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'النوع (مثال: همداني قطاف اليوم)')),
            TextField(controller: gradeCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'الرتبة والجودة')),
            TextField(controller: locCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'موقع السوق')),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'السعر (\$ / ربطة)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06D6A0)),
            onPressed: () async {
              if (typeCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await http.post(
                Uri.parse("$_baseUrl/api/v1/vendor/qat-items"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "vendor_id": widget.vendorUser['id'],
                  "qat_type": typeCtrl.text.trim(),
                  "quality_grade": gradeCtrl.text.trim(),
                  "market_location": locCtrl.text.trim(),
                  "price": double.tryParse(priceCtrl.text.trim()) ?? 15.0,
                }),
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نشر الصنف في السوق الرقمي 🌿')));
            },
            child: const Text('نشر في السوق', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold)),
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
        title: Text('لوحة البائع: ${widget.vendorUser['full_name'] ?? 'بائع القات'}'),
        backgroundColor: const Color(0xFF1C2541),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _fetchOrders),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF06D6A0),
        onPressed: _showAddItemDialog,
        icon: const Icon(Icons.add, color: Color(0xFF0B132B)),
        label: const Text('إضافة صنف جديد', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF06D6A0)))
          : orders.isEmpty
              ? const Center(child: Text('لا توجد طلبات مقايل حالياً', style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (ctx, i) {
                    final o = orders[i];
                    final isDelivered = o['status'] == 'تم التوصيل للمقيل';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2541),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDelivered ? Colors.white24 : const Color(0xFF06D6A0).withOpacity(0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(o['citizen_name'] ?? 'مشتري', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('\$${o['total_price']}', style: const TextStyle(color: Color(0xFFFFB703), fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('الصنف: ${o['qat_type']}', style: const TextStyle(color: Color(0xFF06D6A0), fontSize: 13, fontWeight: FontWeight.bold)),
                          Text('عنوان المقيل: ${o['delivery_address']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('الحالة: ${o['status']}', style: TextStyle(color: isDelivered ? const Color(0xFF06D6A0) : const Color(0xFFFFB703), fontWeight: FontWeight.bold, fontSize: 12)),
                              if (!isDelivered)
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06D6A0)),
                                  onPressed: () => _updateStatus(o['id'], 'تم التوصيل للمقيل'),
                                  child: const Text('تأكيد التوصيل', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
