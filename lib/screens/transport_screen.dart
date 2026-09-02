import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TransportScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const TransportScreen({super.key, this.currentUser});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> with SingleTickerProviderStateMixin {
  final String _baseUrl = "https://smartcitybackend-production-9d26.up.railway.app";
  late TabController _tabCtrl;

  List<dynamic> localLines = [];
  List<dynamic> intercityTrips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _fetchAllTransport();
  }

  Future<void> _fetchAllTransport() async {
    setState(() => isLoading = true);
    try {
      final localRes = await http.get(Uri.parse("$_baseUrl/api/v1/transport/lines"));
      final interRes = await http.get(Uri.parse("$_baseUrl/api/v1/transport/intercity-trips"));

      if (localRes.statusCode == 200 && interRes.statusCode == 200) {
        setState(() {
          localLines = jsonDecode(localRes.body);
          intercityTrips = jsonDecode(interRes.body);
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _bookLocalTicket(dynamic line) async {
    final userId = widget.currentUser?['id'] ?? 1;
    final pName = widget.currentUser?['full_name'] ?? 'مواطن ذكي';

    try {
      final res = await http.post(
        Uri.parse("$_baseUrl/api/v1/transport/tickets"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "passenger_name": pName,
          "route_line": line['line_name'],
          "price": line['price'],
        }),
      );

      if (res.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إصدار تذكرة المسار الداخلي (${line['line_name']}) بنجاح 🚌'),
            backgroundColor: const Color(0xFF06D6A0),
          ),
        );
      }
    } catch (_) {}
  }

  void _bookIntercityDialog(dynamic trip) {
    final phoneCtrl = TextEditingController(text: widget.currentUser?['phone'] ?? '');
    final userId = widget.currentUser?['id'] ?? 1;
    final pName = widget.currentUser?['full_name'] ?? 'مسافر يمني';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2541),
        title: Text('حجز رحلة: ${trip['from_city']} ⇄ ${trip['to_city']}', style: const TextStyle(color: Color(0xFF118AB2), fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الشركة: ${trip['company_name']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('المركبة: ${trip['vehicle_type']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text('وقت الانطلاق: ${trip['departure_time']}', style: const TextStyle(color: Color(0xFF06D6A0), fontSize: 12)),
            const SizedBox(height: 6),
            Text('سعر التذكرة: \$${trip['price']}', style: const TextStyle(color: Color(0xFFFFB703), fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'رقم هاتف المسافر للتأكيد',
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF118AB2)),
            onPressed: () async {
              if (phoneCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);

              try {
                final res = await http.post(
                  Uri.parse("$_baseUrl/api/v1/transport/intercity-book"),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "user_id": userId,
                    "passenger_name": pName,
                    "phone": phoneCtrl.text.trim(),
                    "trip_id": trip['id'],
                    "from_city": trip['from_city'],
                    "to_city": trip['to_city'],
                    "total_price": trip['price'],
                  }),
                );

                if (res.statusCode == 200) {
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: const Color(0xFF1C2541),
                      title: const Text('🎫 تم تأكيد حجز مقعد السفر!', style: TextStyle(color: Color(0xFF06D6A0))),
                      content: Text('الراكب: $pName\nالمسار: ${trip['from_city']} إلى ${trip['to_city']}\nالموعد: ${trip['departure_time']}\nالشركة: ${trip['company_name']}\n\nيرجى التواجد في الفرزة/المكتب قبل موعد الرحلة بنصف ساعة.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('تم', style: TextStyle(color: Colors.white))),
                      ],
                    ),
                  );
                }
              } catch (_) {}
            },
            child: const Text('تأكيد الحجز الفوري', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        title: const Text('منظومة النقل والمواصلات'),
        backgroundColor: const Color(0xFF1C2541),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _fetchAllTransport),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFF118AB2),
          labelColor: const Color(0xFF118AB2),
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'سفريات المحافظات (${intercityTrips.length})', icon: const Icon(Icons.alt_route_rounded)),
            Tab(text: 'نقل داخلي للمدينة (${localLines.length})', icon: const Icon(Icons.directions_bus_rounded)),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF118AB2)))
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildIntercityTab(),
                _buildLocalTab(),
              ],
            ),
    );
  }

  Widget _buildIntercityTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: intercityTrips.length,
      itemBuilder: (ctx, i) {
        final t = intercityTrips[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2541),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF118AB2).withOpacity(0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Color(0xFF118AB2), size: 18),
                      const SizedBox(width: 4),
                      Text('${t['from_city']} ⇄ ${t['to_city']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  Text('\$${t['price']}', style: const TextStyle(color: Color(0xFFFFB703), fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              Text('الشركة الناقلة: ${t['company_name']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text('نوع النقل: ${t['vehicle_type']} • الانطلاق: ${t['departure_time']}', style: const TextStyle(color: Color(0xFF06D6A0), fontSize: 11)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('المقاعد الشاغرة: ${t['available_seats']} مقعد', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF118AB2)),
                    onPressed: () => _bookIntercityDialog(t),
                    icon: const Icon(Icons.airplane_ticket_outlined, color: Colors.white, size: 16),
                    label: const Text('حجز مقعد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocalTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: localLines.length,
      itemBuilder: (ctx, i) {
        final l = localLines[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2541),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0x22118AB2),
                    child: Icon(Icons.directions_bus_rounded, color: Color(0xFF118AB2)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l['line_name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('الحافلة القادمة: ${l['next_bus']} • الحالة: ${l['status']}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الأجرة: \$${l['price']}', style: const TextStyle(color: Color(0xFFFFB703), fontWeight: FontWeight.bold, fontSize: 14)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF118AB2)),
                    onPressed: () => _bookLocalTicket(l),
                    child: const Text('تذكرة باص', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
