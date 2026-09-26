import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'transport_screen.dart';
import 'healthcare_screen.dart';
import 'restaurant_screen.dart';
import 'retail_screen.dart';
import 'qat_market_screen.dart';
import 'tourism_screen.dart';
import 'car_rental_screen.dart';
import 'real_estate_screen.dart';
import 'water_tanker_screen.dart';

class BudgetMatcherScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const BudgetMatcherScreen({super.key, required this.currentUser});

  @override
  State<BudgetMatcherScreen> createState() => _BudgetMatcherScreenState();
}

class _BudgetMatcherScreenState extends State<BudgetMatcherScreen> {
  final TextEditingController _budgetCtrl = TextEditingController(text: '20000');
  bool _isLoading = false;
  List<Map<String, dynamic>> _matchedOptions = [];
  String _selectedPriority = 'ALL'; // ALL, ESSENTIALS, LEISURE

  bool get _isVip => widget.currentUser['is_vip'] == true;

  @override
  void initState() {
    super.initState();
    _executeBudgetMatching();
  }

  @override
  void dispose() {
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _executeBudgetMatching() async {
    final double? budget = double.tryParse(_budgetCtrl.text.trim());
    if (budget == null || budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال مبلغ ميزانية صالح')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // جلب عناصر من مختلف القطاعات للمطابقة
      final meals = await ApiService.fetchRestaurantMeals();
      final products = await ApiService.fetchRetailProducts();
      final routes = await ApiService.fetchBusRoutes();
      final qatLots = await ApiService.fetchQatMarkets();
      final doctors = await ApiService.fetchDoctors();
      final rooms = await ApiService.fetchHotelsAndRooms();
      final tankers = await ApiService.fetchWaterTankers();

      List<Map<String, dynamic>> aggregated = [];

      // 1. المطاعم
      for (var m in meals) {
        final p = (m['price'] as num).toDouble();
        final finalP = _isVip ? p * 0.8 : p;
        if (finalP <= budget) {
          aggregated.add({
            'title': m['meal_title'],
            'source': m['restaurant_name'],
            'category': 'مطاعم وتجهيز وجبات',
            'raw_price': p,
            'final_price': finalP,
            'icon': Icons.restaurant,
            'color': Colors.orange,
            'target': RestaurantScreen(currentUser: widget.currentUser),
            'priority': 'ESSENTIALS',
          });
        }
      }

      // 2. صهاريج المياه
      for (var t in tankers) {
        final p = (t['price'] as num).toDouble();
        final finalP = _isVip ? p * 0.8 : p;
        if (finalP <= budget) {
          aggregated.add({
            'title': '${t['driver_name']} (${t['water_type']})',
            'source': t['station_name'],
            'category': 'وايتات مياه شرب',
            'raw_price': p,
            'final_price': finalP,
            'icon': Icons.water_drop,
            'color': Colors.cyan,
            'target': WaterTankerScreen(currentUser: widget.currentUser),
            'priority': 'ESSENTIALS',
          });
        }
      }

      // 3. باصات السفر
      for (var r in routes) {
        final p = (r['price'] as num).toDouble();
        final finalP = _isVip ? p * 0.8 : p;
        if (finalP <= budget) {
          aggregated.add({
            'title': 'سفر: ${r['route_name']}',
            'source': r['company_name'],
            'category': 'نقل وتذاكر باصات',
            'raw_price': p,
            'final_price': finalP,
            'icon': Icons.directions_bus,
            'color': Colors.blue,
            'target': TransportScreen(currentUser: widget.currentUser),
            'priority': 'ESSENTIALS',
          });
        }
      }

      // 4. مواعيد العيادات
      for (var d in doctors) {
        final p = (d['consultation_fee'] as num).toDouble();
        final finalP = _isVip ? p * 0.8 : p;
        if (finalP <= budget) {
          aggregated.add({
            'title': 'كشف: ${d['name']}',
            'source': '${d['specialty']} - ${d['clinic_name']}',
            'category': 'عيادات واستشارات طبية',
            'raw_price': p,
            'final_price': finalP,
            'icon': Icons.medical_services,
            'color': Colors.teal,
            'target': HealthcareScreen(currentUser: widget.currentUser),
            'priority': 'ESSENTIALS',
          });
        }
      }

      // 5. المتاجر والسلع
      for (var item in products) {
        final p = (item['price'] as num).toDouble();
        final finalP = _isVip ? p * 0.8 : p;
        if (finalP <= budget) {
          aggregated.add({
            'title': item['product_title'],
            'source': item['store_name'],
            'category': 'متاجر وتسوق',
            'raw_price': p,
            'final_price': finalP,
            'icon': Icons.shopping_bag,
            'color': Colors.indigo,
            'target': RetailScreen(currentUser: widget.currentUser),
            'priority': 'LEISURE',
          });
        }
      }

      // 6. أسواق القات
      for (var q in qatLots) {
        final p = (q['price'] as num).toDouble();
        final finalP = _isVip ? p * 0.8 : p;
        if (finalP <= budget) {
          aggregated.add({
            'title': '${q['qat_type']} (المقوتي ${q['vendor_name']})',
            'source': q['market_name'],
            'category': 'سوق القات',
            'raw_price': p,
            'final_price': finalP,
            'icon': Icons.eco,
            'color': Colors.green,
            'target': QatMarketScreen(currentUser: widget.currentUser),
            'priority': 'LEISURE',
          });
        }
      }

      // 7. الفنادق
      for (var rm in rooms) {
        final p = (rm['price_per_night'] as num).toDouble();
        final finalP = _isVip ? p * 0.8 : p;
        if (finalP <= budget) {
          aggregated.add({
            'title': rm['room_type'],
            'source': rm['hotel_name'],
            'category': 'فنادق وأجنحة',
            'raw_price': p,
            'final_price': finalP,
            'icon': Icons.hotel,
            'color': Colors.deepPurple,
            'target': TourismScreen(currentUser: widget.currentUser),
            'priority': 'LEISURE',
          });
        }
      }

      // ترتيب الخيارات من الأوفر للأعلى سعراً
      aggregated.sort((a, b) => (a['final_price'] as double).compareTo(b['final_price'] as double));

      if (mounted) {
        setState(() {
          _matchedOptions = aggregated;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _displayList {
    if (_selectedPriority == 'ALL') return _matchedOptions;
    return _matchedOptions.where((opt) => opt['priority'] == _selectedPriority).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text('محرك مطابقة الميزانية الذكي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // شريط إدخال الميزانية
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'أدخل ميزانيتك المتوفرة (بالريال اليمني):',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _budgetCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.account_balance_wallet, color: Color(0xFF06B6D4)),
                          suffixText: 'ر.ي',
                          suffixStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                          filled: true,
                          fillColor: const Color(0xFF1E293B),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF06B6D4),
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _executeBudgetMatching,
                      child: const Text('فرز ومطابقة', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                if (_isVip) ...[
                  const SizedBox(height: 8),
                  const Text('✓ يتم احتساب خصم بطاقة VIP (20%) تلقائياً على كل ترشيح', style: TextStyle(color: Colors.greenAccent, fontSize: 11)),
                ],
              ],
            ),
          ),

          // فلاتر التخصيص
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                _buildPriorityChip('ALL', 'كافة الخيارات المتاحة'),
                const SizedBox(width: 8),
                _buildPriorityChip('ESSENTIALS', 'الخدمات الأساسية'),
                const SizedBox(width: 8),
                _buildPriorityChip('LEISURE', 'التسوق والترفيه'),
              ],
            ),
          ),

          // قائمة النتائج المطابقة
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
                : _displayList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.money_off, size: 60, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text('لا توجد خيارات تلائم هذه الميزانية، جرّب رفع المبلغ قليلاً', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        itemCount: _displayList.length,
                        itemBuilder: (context, idx) {
                          final item = _displayList[idx];
                          final double finalPrice = item['final_price'] as double;
                          final double rawPrice = item['raw_price'] as double;
                          final Color color = item['color'] as Color;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.black.withOpacity(0.04)),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3)),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: color.withOpacity(0.12),
                                  child: Icon(item['icon'] as IconData, color: color, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'].toString(),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item['category']} | ${item['source']}',
                                        style: const TextStyle(color: Colors.blueGrey, fontSize: 11),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            '${finalPrice.toInt()} ر.ي',
                                            style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                          if (_isVip) ...[
                                            const SizedBox(width: 6),
                                            Text(
                                              '${rawPrice.toInt()} ر.ي',
                                              style: const TextStyle(color: Colors.grey, fontSize: 11, decoration: TextDecoration.lineThrough),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F172A),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  ),
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => item['target'] as Widget));
                                  },
                                  child: const Text('طلب وحجز', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(String key, String label) {
    final isSelected = _selectedPriority == key;
    return InkWell(
      onTap: () => setState(() => _selectedPriority = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFF0F172A) : Colors.black12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
