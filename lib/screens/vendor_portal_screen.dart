import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'qr_scanner_screen.dart';
import 'transport_screen.dart';
import 'healthcare_screen.dart';
import 'water_tanker_screen.dart';
import 'restaurant_screen.dart';
import 'retail_screen.dart';
import 'qat_market_screen.dart';
import 'tourism_screen.dart';
import 'car_rental_screen.dart';
import 'real_estate_screen.dart';

class VendorPortalScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const VendorPortalScreen({super.key, required this.currentUser});

  @override
  State<VendorPortalScreen> createState() => _VendorPortalScreenState();
}

class _VendorPortalScreenState extends State<VendorPortalScreen> {
  List<Map<String, dynamic>> _mySectorOrders = [];
  bool _isLoading = true;

  String get _vendorSector => widget.currentUser['vendor_sector'] ?? 'STORE';

  final Map<String, Map<String, dynamic>> _sectorMeta = {
    'STORE': {'title': 'قطاع المتاجر والسلع', 'icon': Icons.storefront, 'color': Colors.indigo},
    'RESTAURANT': {'title': 'قطاع المطاعم والوجبات', 'icon': Icons.restaurant, 'color': Colors.orange},
    'CLINIC': {'title': 'قطاع العيادات والأطباء', 'icon': Icons.medical_services, 'color': Colors.teal},
    'BUS': {'title': 'قطاع باصات السفر والنقل', 'icon': Icons.directions_bus, 'color': Colors.blue},
    'WATER': {'title': 'قطاع وايتات وصهاريج المياه', 'icon': Icons.water_drop, 'color': Colors.cyan},
    'QAT': {'title': 'قطاع أسواق القات والمقاوته', 'icon': Icons.eco, 'color': Colors.green},
    'HOTEL': {'title': 'قطاع الفنادق والشقق المفروشة', 'icon': Icons.hotel, 'color': Colors.deepPurple},
    'CAR': {'title': 'قطاع تأجير السيارات السياحية', 'icon': Icons.directions_car, 'color': Colors.amber},
    'REALTY': {'title': 'قطاع العقارات والمنازل', 'icon': Icons.home_work, 'color': Colors.blueGrey},
  };

  @override
  void initState() {
    super.initState();
    _loadVendorOrders();
  }

  Future<void> _loadVendorOrders() async {
    setState(() => _isLoading = true);
    // جلب حجوزات هذا القطاع تحديداً
    final allOrders = await ApiService.fetchUserBookings(widget.currentUser['id']?.toString() ?? '1');
    if (mounted) {
      setState(() {
        _mySectorOrders = allOrders.where((o) => o['category'] == _vendorSector || _vendorSector == 'ALL').toList();
        _isLoading = false;
      });
    }
  }

  double get _totalEarnings {
    double total = 0;
    for (var o in _mySectorOrders) {
      total += (o['total_price'] as num?)?.toDouble() ?? 0.0;
    }
    return total;
  }

  void _openSectorAddScreen() {
    Widget target;
    switch (_vendorSector) {
      case 'BUS': target = TransportScreen(currentUser: widget.currentUser); break;
      case 'CLINIC': target = HealthcareScreen(currentUser: widget.currentUser); break;
      case 'WATER': target = WaterTankerScreen(currentUser: widget.currentUser); break;
      case 'RESTAURANT': target = RestaurantScreen(currentUser: widget.currentUser); break;
      case 'STORE': target = RetailScreen(currentUser: widget.currentUser); break;
      case 'QAT': target = QatMarketScreen(currentUser: widget.currentUser); break;
      case 'HOTEL': target = TourismScreen(currentUser: widget.currentUser); break;
      case 'CAR': target = CarRentalScreen(currentUser: widget.currentUser); break;
      case 'REALTY': target = RealEstateScreen(currentUser: widget.currentUser); break;
      default: target = RetailScreen(currentUser: widget.currentUser); break;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => target));
  }

  @override
  Widget build(BuildContext context) {
    final meta = _sectorMeta[_vendorSector] ?? _sectorMeta['STORE']!;
    final Color sectorColor = meta['color'] as Color;
    final IconData sectorIcon = meta['icon'] as IconData;
    final String sectorTitle = meta['title'] as String;

    final vendorName = widget.currentUser['name'] ?? 'مزود معتمد';
    final vendorPhone = widget.currentUser['phone'] ?? '770000000';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text('لوحة حساب: $sectorTitle', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVendorOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // بطاقة المنشأة وهوية القطاع
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF0F172A), sectorColor.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.white,
                              child: Icon(sectorIcon, color: sectorColor, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(vendorName, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified, color: Color(0xFF06B6D4), size: 16),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(sectorTitle, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text('هاتف التواصل: $vendorPhone', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white24, height: 26),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatItem('العمليات والتذاكر', '${_mySectorOrders.length} طلب'),
                            _buildStatItem('إجمالي مبيعات القطاع', '${_totalEarnings.toInt()} ر.ي'),
                            _buildStatItem('الصلاحية', 'مزود معتمد'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // الإجراءات الخاصة بقطاع التاجر
                  const Text('العمليات السريعة للقطاع', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QrScannerScreen(currentUser: widget.currentUser))),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black.withOpacity(0.04)),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3)),
                              ],
                            ),
                            child: const Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Color(0xFFECFDF5),
                                  child: Icon(Icons.qr_code_scanner, color: Colors.green),
                                ),
                                SizedBox(height: 8),
                                Text('فحص تذكرة زبون', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                Text('مسح كود الاستلام', style: TextStyle(color: Colors.grey, fontSize: 10)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: _openSectorAddScreen,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black.withOpacity(0.04)),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3)),
                              ],
                            ),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: sectorColor.withOpacity(0.12),
                                  child: Icon(Icons.add_circle_outline, color: sectorColor),
                                ),
                                const SizedBox(height: 8),
                                const Text('إضافة عنصر جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                Text('نشر في $sectorTitle', style: const TextStyle(color: Colors.grey, fontSize: 10), overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // سجل الحجوزات الخاصة بهذا القطاع فقط
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('طلبات $sectorTitle الموجهة لك', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      Text('${_mySectorOrders.length} تذاكر', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_mySectorOrders.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          Icon(sectorIcon, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text('لا توجد حجوزات جديدة مسجلة لـ $sectorTitle حتى الآن', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _mySectorOrders.length,
                      itemBuilder: (context, idx) {
                        final order = _mySectorOrders[idx];
                        final isDone = order['status'] == 'REDEEMED';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black.withOpacity(0.04)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(order['business_name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                                  const SizedBox(height: 2),
                                  Text('الكود: ${order['qr_pass']}', style: const TextStyle(color: Colors.blueGrey, fontSize: 11)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${(order['total_price'] as num?)?.toInt() ?? 0} ر.ي', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDone ? Colors.green.shade50 : Colors.amber.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isDone ? 'تم الاستلام' : 'بانتظار العميل',
                                      style: TextStyle(color: isDone ? Colors.green.shade800 : Colors.amber.shade900, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String title, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
