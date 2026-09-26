import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TransportScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const TransportScreen({super.key, this.currentUser});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  List<Map<String, dynamic>> _routes = [];
  bool _isLoading = true;
  int _selectedRouteIndex = 0;

  // المقاعد
  final Set<int> _bookedSeats = {3, 4, 7, 12, 15, 16, 23, 24};
  final Set<int> _familySeats = {1, 2, 5, 6};
  final Set<int> _selectedSeats = {};

  final _passengerNameCtrl = TextEditingController(text: 'محمد ياسر');
  final _passengerPhoneCtrl = TextEditingController(text: '770000000');

  bool get _isVip => widget.currentUser?['is_vip'] == true;
  bool get _isAuthorized =>
      widget.currentUser?['role'] == 'ADMIN' || widget.currentUser?['role'] == 'VENDOR';

  Map<String, dynamic>? get _currentRoute =>
      _routes.isNotEmpty ? _routes[_selectedRouteIndex] : null;

  double get _seatPrice => _currentRoute?['price'] ?? 15000.0;
  double get _totalPrice {
    final subtotal = _selectedSeats.length * _seatPrice;
    return _isVip ? subtotal * 0.8 : subtotal;
  }

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    setState(() => _isLoading = true);
    final data = await ApiService.fetchBusRoutes();
    if (mounted) {
      setState(() {
        _routes = data;
        _isLoading = false;
        if (_selectedRouteIndex >= _routes.length) _selectedRouteIndex = 0;
      });
    }
  }

  void _showAddRouteDialog() {
    final routeCtrl = TextEditingController();
    final companyCtrl = TextEditingController(text: 'سفريات النور VIP');
    final timeCtrl = TextEditingController(text: '08:30 صباحاً');
    final priceCtrl = TextEditingController(text: '16000');
    final typeCtrl = TextEditingController(text: 'حافلة VIP ملكية مكيفة');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'إضافة مسار رحلة جديد (مباشر إلى السيرفر)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: routeCtrl,
                decoration: InputDecoration(
                  labelText: 'مسار الرحلة (مثال: صنعاء - تعز)',
                  prefixIcon: const Icon(Icons.alt_route),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: companyCtrl,
                decoration: InputDecoration(
                  labelText: 'اسم شركة النقل',
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: timeCtrl,
                decoration: InputDecoration(
                  labelText: 'وقت التحرك',
                  prefixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'سعر المقعد بالريال اليمني',
                  prefixIcon: const Icon(Icons.money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: typeCtrl,
                decoration: InputDecoration(
                  labelText: 'مواصفات الباص',
                  prefixIcon: const Icon(Icons.directions_bus),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (routeCtrl.text.trim().isEmpty) return;
                  Navigator.pop(ctx);
                  final success = await ApiService.addBusRoute(
                    routeName: routeCtrl.text.trim(),
                    companyName: companyCtrl.text.trim(),
                    departureTime: timeCtrl.text.trim(),
                    price: double.tryParse(priceCtrl.text) ?? 15000.0,
                    busType: typeCtrl.text.trim(),
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'تم حفظ المسار في السيرفر بنجاح' : 'تم إضافة المسار محلياً'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadRoutes();
                  }
                },
                child: const Text('حفظ المسار في قاعدة البيانات', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmBooking() async {
    if (_selectedSeats.isEmpty || _currentRoute == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار مقعد واحد على الأقل على المخطط التفاعلي')),
      );
      return;
    }

    final ticketCode = 'PASS-BUS-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    await ApiService.addBusinessItem({
      'user_id': widget.currentUser?['id'] ?? '1',
      'business_name': _currentRoute!['company_name'],
      'category': 'BUS',
      'total_price': _totalPrice,
      'qr_pass': ticketCode,
      'status': 'CONFIRMED',
    });

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 16),
            Text(_currentRoute!['company_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
            Text('خط السير: ${_currentRoute!['route_name']}', style: const TextStyle(color: Colors.blueGrey, fontSize: 13), textAlign: TextAlign.center),
            const Divider(height: 24),
            Center(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black12)),
                child: Column(
                  children: [
                    const Icon(Icons.qr_code_2, size: 130, color: Color(0xFF0F172A)),
                    Text(ticketCode, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfo('المقاعد', _selectedSeats.join(', ')),
                _buildInfo('وقت الإقلاع', _currentRoute!['departure_time']),
                _buildInfo('المبلغ', '${_totalPrice.toInt()} ر.ي'),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إغلاق وتأكيد التذكرة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(String title, String val) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text('باصات النقل وحجز المقاعد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          if (_isAuthorized)
            IconButton(
              icon: const Icon(Icons.add_road),
              tooltip: 'إضافة مسار رحلة',
              onPressed: _showAddRouteDialog,
            ),
        ],
      ),
      floatingActionButton: _isAuthorized
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF0F172A),
              icon: const Icon(Icons.add_road, color: Color(0xFF06B6D4)),
              label: const Text('إضافة مسار للسيرفر', style: TextStyle(color: Colors.white)),
              onPressed: _showAddRouteDialog,
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اختيار المسار المحمل من السيرفر
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black.withOpacity(0.04)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('المسارات المتوفرة على السيرفر:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<int>(
                          value: _selectedRouteIndex,
                          decoration: const InputDecoration(prefixIcon: Icon(Icons.alt_route, color: Color(0xFF06B6D4))),
                          isExpanded: true,
                          items: List.generate(_routes.length, (idx) {
                            final r = _routes[idx];
                            return DropdownMenuItem(
                              value: idx,
                              child: Text('${r['route_name']} (${r['company_name']})', style: const TextStyle(fontSize: 13)),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedRouteIndex = val;
                                _selectedSeats.clear();
                              });
                            }
                          },
                        ),
                        if (_currentRoute != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('الموعد: ${_currentRoute!['departure_time']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              Text('${(_currentRoute!['price'] as num).toInt()} ر.ي / للمقعد', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          Text(_currentRoute!['bus_type'], style: const TextStyle(color: Colors.blueGrey, fontSize: 11)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // دليل الألوان
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegend(Colors.white, 'متاح', true),
                      _buildLegend(const Color(0xFF0F172A), 'محدد', false),
                      _buildLegend(Colors.pink.shade50, 'عائلات', true, borderColor: Colors.pink.shade200),
                      _buildLegend(Colors.grey.shade300, 'محجوز', false),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // مخطط الباص التفاعلي 32 مقعداً
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                              child: const Text('باب الصعود ⟵', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            Icon(Icons.airline_seat_recline_extra, color: Colors.blueGrey.shade400, size: 28),
                          ],
                        ),
                        const Divider(height: 24),
                        for (int row = 0; row < 8; row++) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSeat(row * 4 + 1),
                              _buildSeat(row * 4 + 2),
                              Container(
                                width: 28,
                                alignment: Alignment.center,
                                child: Text('${row + 1}', style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                              ),
                              _buildSeat(row * 4 + 3),
                              _buildSeat(row * 4 + 4),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // شريط السعر وتأكيد الحجز
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('المقاعد: ${_selectedSeats.isEmpty ? "لم تحدد" : _selectedSeats.join(", ")}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text('${_totalPrice.toInt()} ر.ي', style: const TextStyle(color: Color(0xFF06B6D4), fontSize: 20, fontWeight: FontWeight.bold)),
                                  if (_isVip && _selectedSeats.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                                      child: const Text('خصم VIP 20%', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF06B6D4),
                            foregroundColor: const Color(0xFF0F172A),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.qr_code_scanner, size: 20),
                          label: const Text('إصدار التذكرة (QR)', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: _confirmBooking,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSeat(int seatNum) {
    final isBooked = _bookedSeats.contains(seatNum);
    final isSelected = _selectedSeats.contains(seatNum);
    final isFamily = _familySeats.contains(seatNum);

    Color bg = Colors.white;
    Color border = Colors.black12;
    Color text = Colors.black87;

    if (isBooked) {
      bg = Colors.grey.shade300;
      border = Colors.grey.shade300;
      text = Colors.grey.shade600;
    } else if (isSelected) {
      bg = const Color(0xFF0F172A);
      border = const Color(0xFF0F172A);
      text = Colors.white;
    } else if (isFamily) {
      bg = Colors.pink.shade50;
      border = Colors.pink.shade200;
      text = Colors.pink.shade700;
    }

    return InkWell(
      onTap: () {
        if (isBooked) return;
        setState(() {
          if (_selectedSeats.contains(seatNum)) {
            _selectedSeats.remove(seatNum);
          } else {
            _selectedSeats.add(seatNum);
          }
        });
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Center(
          child: Text('$seatNum', style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label, bool border, {Color? borderColor}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: border ? Border.all(color: borderColor ?? Colors.black26) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
      ],
    );
  }
}
