import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WaterTankerScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const WaterTankerScreen({super.key, this.currentUser});

  @override
  State<WaterTankerScreen> createState() => _WaterTankerScreenState();
}

class _WaterTankerScreenState extends State<WaterTankerScreen> {
  final String _baseUrl = "https://smartcitybackend-production-9d26.up.railway.app";
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String _tankerSize = 'وايت متوسط (30 برميل)';
  String _waterQuality = 'ماء كوثر نقي (شرب)';
  double _price = 15.0;
  bool _isOrdering = false;

  final Map<String, double> _sizePrices = {
    'صالون صغير (15 برميل)': 9.0,
    'وايت متوسط (30 برميل)': 15.0,
    'وايت كبير (60 برميل)': 26.0,
  };

  @override
  void initState() {
    super.initState();
    _phoneCtrl.text = widget.currentUser?['phone'] ?? '';
  }

  Future<void> _orderTanker() async {
    final address = _addressCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (address.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال عنوان المنزل ورقم الهاتف للتواصل')),
      );
      return;
    }

    setState(() => _isOrdering = true);
    final userId = widget.currentUser?['id'] ?? 1;
    final cName = widget.currentUser?['full_name'] ?? 'مواطن';

    try {
      final res = await http.post(
        Uri.parse("$_baseUrl/api/v1/water/order"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "citizen_name": cName,
          "phone": phone,
          "tanker_size": _tankerSize,
          "water_quality": _waterQuality,
          "location_address": address,
          "price": _price,
        }),
      );

      if (res.statusCode == 200) {
        if (!mounted) return;
        _addressCtrl.clear();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1C2541),
            title: const Text('🚰 تم تأكيد طلب الوايت بنجاح!', style: TextStyle(color: Color(0xFF00F5D4))),
            content: Text('الحجم: $_tankerSize\nالنوع: $_waterQuality\nالسعر: \$$_price\n\nأقرب شاحنة ماء متوجهة الآن إلى موقعك وسيتم الاتصال بك عند الوصول.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسناً', style: TextStyle(color: Colors.white))),
            ],
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر الطلب، تحقق من الاتصال'), backgroundColor: Color(0xFFFF5964)),
      );
    } finally {
      if (mounted) setState(() => _isOrdering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: const Text('خدمة وايتات وخزانات الماء'),
        backgroundColor: const Color(0xFF1C2541),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2541),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00F5D4).withOpacity(0.4)),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0x2200F5D4),
                    child: Icon(Icons.water_drop_rounded, color: Color(0xFF00F5D4)),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('طلب شاحنة ماء (وايت) للمنزل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(height: 3),
                        Text('تعبئة الخزانات الأرضية والعلوية بدقة وسرعة عبر السائقين المعتمدين', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('حجم الخزان / الشاحنة المطلوب:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _tankerSize,
              dropdownColor: const Color(0xFF1C2541),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1C2541),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _sizePrices.keys.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _tankerSize = val;
                    _price = _sizePrices[val]!;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            const Text('نوعية المياه:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _waterQuality,
              dropdownColor: const Color(0xFF1C2541),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1C2541),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: 'ماء كوثر نقي (شرب)', child: Text('ماء كوثر نقي (شرب)')),
                DropdownMenuItem(value: 'ماء آبار عادي (غسيل واستخدام)', child: Text('ماء آبار عادي (غسيل واستخدام)')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _waterQuality = val);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'عنوان المنزل بدقة (المنطقة، الشارع، جوار...)',
                labelStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF00F5D4)),
                filled: true,
                fillColor: const Color(0xFF1C2541),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'رقم هاتف الاتصال',
                labelStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF00F5D4)),
                filled: true,
                fillColor: const Color(0xFF1C2541),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('إجمالي التكلفة التقديرية:', style: TextStyle(color: Colors.white70)),
                Text('\$$_price', style: const TextStyle(color: Color(0xFFFFB703), fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00F5D4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isOrdering ? null : _orderTanker,
                icon: _isOrdering ? const SizedBox.shrink() : const Icon(Icons.local_shipping_rounded, color: Color(0xFF0B132B)),
                label: _isOrdering
                    ? const CircularProgressIndicator(color: Color(0xFF0B132B))
                    : const Text('طلب وايت الماء فوراً', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
