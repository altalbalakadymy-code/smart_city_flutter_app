import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'retail_screen.dart';

class MetaverseScreen extends StatefulWidget {
  const MetaverseScreen({super.key});

  @override
  State<MetaverseScreen> createState() => _MetaverseScreenState();
}

class _MetaverseScreenState extends State<MetaverseScreen> {
  final String _baseUrl = "https://smartcitybackend-production-9d26.up.railway.app";
  List<dynamic> businesses = [];
  bool isLoading = true;

  double _rotX = 0.6;
  double _rotY = -0.6;

  @override
  void initState() {
    super.initState();
    _fetchBusinesses();
  }

  Future<void> _fetchBusinesses() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse("$_baseUrl/api/v1/admin/businesses"));
      if (res.statusCode == 200) {
        setState(() {
          businesses = jsonDecode(res.body);
          isLoading = false;
        });
      } else {
        throw Exception();
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  void _openStore(dynamic store) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2541),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.apartment_rounded, color: Color(0xFF00F5D4), size: 28),
                const SizedBox(width: 10),
                Text(
                  store['name'] ?? 'متجر رقمي',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('القطاع: ${store['category']}', style: const TextStyle(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F5D4)),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RetailScreen()));
                },
                child: const Text('دخول المتجر وتصفح البضائع', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: const Text('التوأم الرقمي الحي للمدينة'),
        backgroundColor: const Color(0xFF1C2541),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchBusinesses,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00F5D4)))
          : GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _rotY += details.delta.dx * 0.01;
                  _rotX -= details.delta.dy * 0.01;
                });
              },
              child: Stack(
                children: [
                  Center(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(_rotX)
                        ..rotateY(_rotY),
                      child: Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF00F5D4).withOpacity(0.4), width: 1.5),
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFF1C2541).withOpacity(0.3),
                        ),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: businesses.isEmpty ? 1 : businesses.length,
                          itemBuilder: (ctx, i) {
                            if (businesses.isEmpty) {
                              return const Center(
                                child: Text('لا توجد منشآت', style: TextStyle(color: Colors.white38, fontSize: 11)),
                              );
                            }
                            final b = businesses[i];
                            return InkWell(
                              onTap: () => _openStore(b),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00F5D4).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF00F5D4)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.storefront_rounded, color: Color(0xFF00F5D4), size: 28),
                                    const SizedBox(height: 4),
                                    Text(
                                      b['name'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2541).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.touch_app_rounded, color: Color(0xFF00F5D4), size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'اسحب بإصبعك لتدوير المشهد ثلاثي الأبعاد، واضغط على أي مبنى للتفاعل معه.',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
