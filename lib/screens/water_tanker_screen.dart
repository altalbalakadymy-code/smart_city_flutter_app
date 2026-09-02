import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WaterDriverDashboard extends StatefulWidget {
  final Map<String, dynamic> driverUser;

  const WaterDriverDashboard({super.key, required this.driverUser});

  @override
  State<WaterDriverDashboard> createState() => _WaterDriverDashboardState();
}

class _WaterDriverDashboardState extends State<WaterDriverDashboard> {
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
      final res = await http.get(Uri.parse("$_baseUrl/api/v1/driver/water-orders"));
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
      Uri.parse("$_baseUrl/api/v1/driver/water-orders/$orderId"),
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
        title: Text('مهام الوايت: ${widget.driverUser['full_name'] ?? 'السائق'}'),
        backgroundColor: const Color(0xFF1C2541),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _fetchOrders),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00F5D4)))
          : orders.isEmpty
              ? const Center(child: Text('لا توجد طلبات تعبئة مياه حالياً', style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (ctx, i) {
                    final o = orders[i];
                    final isDelivered = o['status'] == 'تم التوصيل والتعبئة';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2541),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDelivered ? Colors.white24 : const Color(0xFF00F5D4).withOpacity(0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(o['citizen_name'] ?? 'مواطن', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('\$${o['price']}', style: const TextStyle(color: Color(0xFFFFB703), fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('الحجم: ${o['tanker_size']} • ${o['water_quality']}', style: const TextStyle(color: Color(0xFF00F5D4), fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('العنوان: ${o['location_address']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          Text('الهاتف: ${o['phone']}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('الحالة: ${o['status']}', style: TextStyle(color: isDelivered ? const Color(0xFF06D6A0) : const Color(0xFFFFB703), fontWeight: FontWeight.bold, fontSize: 12)),
                              if (!isDelivered)
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F5D4)),
                                  onPressed: () => _updateStatus(o['id'], 'تم التوصيل والتعبئة'),
                                  child: const Text('تأكيد التعبئة', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold, fontSize: 12)),
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
