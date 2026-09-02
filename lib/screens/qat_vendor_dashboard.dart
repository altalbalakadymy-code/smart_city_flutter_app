import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class QatVendorDashboard extends StatefulWidget {
  final Map<String, dynamic> vendorUser;

  const QatVendorDashboard({super.key, required this.vendorUser});

  @override
  State<QatVendorDashboard> createState() => _QatVendorDashboardState();
}

class _QatVendorDashboardState extends State<QatVendorDashboard> {
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

  Future<void> _updateStatus(int orderId, String nextStatus) async {
    await http.patch(
      Uri.parse("$_baseUrl/api/v1/vendor/qat-orders/$orderId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"status": nextStatus}),
    );
    _fetchOrders();
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
