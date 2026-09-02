import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'transport_screen.dart';
import 'tourism_screen.dart';
import 'qat_market_screen.dart';

class SectorsScreen extends StatelessWidget {
  final Map<String, dynamic> currentUser;

  const SectorsScreen({super.key, required this.currentUser});

  final List<Map<String, dynamic>> sectors = const [
    {
      'title': 'وايتات وخزانات الماء الذكية',
      'category': 'water',
      'icon': Icons.water_drop_rounded,
      'color': Color(0xFF00F5D4),
      'desc': 'طلب صهاريج الماء المنزلية (شرب / غسيل) وتعبئة الخزانات الفورية.'
    },
    {
      'title': 'سوق القات الذكي المعتمد',
      'category': 'qat',
      'icon': Icons.eco_rounded,
      'color': Color(0xFF06D6A0),
      'desc': 'استعراض أصناف القات المعتمدة، مقارنة الأسعار، والطلب السريع.'
    },
    {
      'title': 'النقل والمواصلات الذكية',
      'category': 'transportation',
      'icon': Icons.directions_bus_filled_outlined,
      'color': Color(0xFF118AB2),
      'desc': 'سفريات بين المحافظات (عدن، تعز، حضرموت) وحافلات النقل الداخلي.'
    },
    {
      'title': 'السياحة والضيافة والترفيه',
      'category': 'tourism',
      'icon': Icons.hotel_outlined,
      'color': Color(0xFFFB5607),
      'desc': 'حجز المعالم التاريخية، الفنادق، والمنتزهات السياحية.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = currentUser['role'] == 'admin';
    final bool isDriver = currentUser['role'] == 'water_driver';

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: Text(
          'أهلاً، ${currentUser['full_name'] ?? 'مواطن'}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1C2541),
        actions: [
          if (isDriver)
            IconButton(
              tooltip: 'لوحة مهام سائق الوايت',
              icon: const Icon(Icons.local_shipping_rounded, color: Color(0xFF00F5D4)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EmbeddedWaterDriverDashboard(driverUser: currentUser)),
                );
              },
            ),
          if (isAdmin)
            IconButton(
              tooltip: 'لوحة القيادة',
              icon: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF00F5D4)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
              },
            ),
          IconButton(
            tooltip: 'تسجيل الخروج',
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFFF5964)),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.85,
        ),
        itemCount: sectors.length,
        itemBuilder: (context, index) {
          final s = sectors[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Widget screen;
                switch (s['category']) {
                  case 'water':
                    screen = EmbeddedWaterTankerScreen(currentUser: currentUser);
                    break;
                  case 'qat':
                    screen = QatMarketScreen(currentUser: currentUser);
                    break;
                  case 'transportation':
                    screen = TransportScreen(currentUser: currentUser);
                    break;
                  case 'tourism':
                  default:
                    screen = TourismScreen(currentUser: currentUser);
                }
                Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2541),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: (s['color'] as Color).withOpacity(0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: (s['color'] as Color).withOpacity(0.15),
                      child: Icon(s['icon'], color: s['color']),
                    ),
                    const Spacer(),
                    Text(
                      s['title'],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s['desc'],
                      style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 11, height: 1.2),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ----------------- واجهة طلب وايت الماء للمواطن -----------------
class EmbeddedWaterTankerScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;
  const EmbeddedWaterTankerScreen({super.key, this.currentUser});

  @override
  State<EmbeddedWaterTankerScreen> createState() => _EmbeddedWaterTankerScreenState();
}

class _EmbeddedWaterTankerScreenState extends State<EmbeddedWaterTankerScreen> {
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
            content: Text('الحجم: $_tankerSize\nالنوع: $_waterQuality\nالسعر: \$$_price\n\nأقرب وايت متوجه الآن إلى موقعك وسيتم الاتصال بك.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسناً', style: TextStyle(color: Colors.white))),
            ],
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر الطلب، تحقق من الاتصال بالشبكة'), backgroundColor: Color(0xFFFF5964)),
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
                        Text('تعبئة الخزانات السريعة عبر السائقين المعتمدين', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('حجم الخزان المطلوب:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
            TextField(
              controller: _addressCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'عنوان المنزل (المنطقة، الشارع، جوار...)',
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
                const Text('إجمالي التكلفة:', style: TextStyle(color: Colors.white70)),
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

// ----------------- لوحة مهام سائق الوايت -----------------
class EmbeddedWaterDriverDashboard extends StatefulWidget {
  final Map<String, dynamic> driverUser;
  const EmbeddedWaterDriverDashboard({super.key, required this.driverUser});

  @override
  State<EmbeddedWaterDriverDashboard> createState() => _EmbeddedWaterDriverDashboardState();
}

class _EmbeddedWaterDriverDashboardState extends State<EmbeddedWaterDriverDashboard> {
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
