import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TourismScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const TourismScreen({super.key, this.currentUser});

  @override
  State<TourismScreen> createState() => _TourismScreenState();
}

class _TourismScreenState extends State<TourismScreen> {
  final String _baseUrl = "https://smartcitybackend-production-9d26.up.railway.app";
  List<dynamic> spots = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSpots();
  }

  Future<void> _fetchSpots() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse("$_baseUrl/api/v1/tourism/destinations"));
      if (res.statusCode == 200) {
        setState(() {
          spots = jsonDecode(res.body);
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _bookSpot(dynamic s) async {
    final userId = widget.currentUser?['id'] ?? 1;
    final gName = widget.currentUser?['full_name'] ?? 'مواطن ذكي';

    try {
      final res = await http.post(
        Uri.parse("$_baseUrl/api/v1/tourism/book"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "guest_name": gName,
          "destination_title": s['title'],
          "price": s['price'],
        }),
      );

      if (res.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تأكيد حجزك في ${s['title']} بنجاح 🌴'),
            backgroundColor: const Color(0xFF06D6A0),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر إتمام الحجز السياحي'), backgroundColor: Color(0xFFFF5964)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: const Text('السياحة والضيافة والترفيه'),
        backgroundColor: const Color(0xFF1C2541),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _fetchSpots),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFB5607)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: spots.length,
              itemBuilder: (ctx, i) {
                final s = spots[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C2541),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFB5607).withOpacity(0.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(s['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(s['rating'], style: const TextStyle(color: Color(0xFFFFB703), fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('النوع: ${s['type']} • السعر للشخص: \$${s['price']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFB5607)),
                          onPressed: () => _bookSpot(s),
                          child: const Text('حجز فوري', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
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
