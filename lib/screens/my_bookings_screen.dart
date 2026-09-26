import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MyBookingsScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const MyBookingsScreen({super.key, required this.currentUser});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  String _selectedFilter = 'الكل';
  final List<String> _filters = ['الكل', 'BUS', 'CLINIC', 'WATER', 'RESTAURANT', 'STORE', 'QAT', 'HOTEL', 'CAR', 'REALTY'];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    final userId = widget.currentUser['id']?.toString() ?? '1';
    final data = await ApiService.fetchUserBookings(userId);
    if (mounted) {
      setState(() {
        _bookings = data;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredBookings {
    if (_selectedFilter == 'الكل') return _bookings;
    return _bookings.where((b) => b['category'] == _selectedFilter).toList();
  }

  String _getCategoryTitle(String cat) {
    switch (cat) {
      case 'BUS': return 'باص سفر';
      case 'CLINIC': return 'موعد طبي';
      case 'WATER': return 'وايت مياه';
      case 'RESTAURANT': return 'طلب مطعم';
      case 'STORE': return 'تثبيت سلعة';
      case 'QAT': return 'باقة قات';
      case 'HOTEL': return 'حجز فندقي';
      case 'CAR': return 'تأجير سيارة';
      case 'REALTY': return 'معاينة عقار';
      default: return 'خدمة مؤكدة';
    }
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'BUS': return Icons.directions_bus;
      case 'CLINIC': return Icons.medical_services;
      case 'WATER': return Icons.water_drop;
      case 'RESTAURANT': return Icons.restaurant;
      case 'STORE': return Icons.shopping_bag;
      case 'QAT': return Icons.eco;
      case 'HOTEL': return Icons.hotel;
      case 'CAR': return Icons.directions_car;
      case 'REALTY': return Icons.home_work;
      default: return Icons.confirmation_number;
    }
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'BUS': return Colors.blue;
      case 'CLINIC': return Colors.teal;
      case 'WATER': return Colors.cyan;
      case 'RESTAURANT': return Colors.orange;
      case 'STORE': return Colors.indigo;
      case 'QAT': return Colors.green;
      case 'HOTEL': return Colors.deepPurple;
      case 'CAR': return Colors.amber.shade900;
      case 'REALTY': return Colors.blueGrey;
      default: return const Color(0xFF0F172A);
    }
  }

  void _showTicketDetailDialog(Map<String, dynamic> b) {
    final cat = b['category'].toString();
    final color = _getCategoryColor(cat);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(22),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Text(
                _getCategoryTitle(cat),
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              b['business_name'].toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_2, size: 140, color: Color(0xFF0F172A)),
                  const SizedBox(height: 6),
                  Text(
                    b['qr_pass'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('المبلغ المسجل', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    Text('${(b['total_price'] as num).toInt()} ر.ي', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal)),
                  ],
                ),
                Column(
                  children: [
                    const Text('حالة التذكرة', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    Text(b['status'].toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: b['status'] == 'CONFIRMED' ? Colors.green : Colors.red)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'أبرز هذا الكود للمزود أو المحطة لتأكيد الخدمة والاستلام المباشر.',
              style: TextStyle(fontSize: 11, color: Colors.blueGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(Map<String, dynamic> b) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إلغاء التذكرة / الحجز'),
        content: Text('هل أنت متأكد من إلغاء حجزك في "${b['business_name']}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('تراجع')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await ApiService.cancelBooking(b['id'] as int);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إلغاء الحجز بنجاح')));
              _loadBookings();
            },
            child: const Text('تأكيد الإلغاء'),
          ),
        ],
      ),
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
        title: const Text('تذاكري وحجوزاتي المحفوظة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
          : Column(
              children: [
                // فلتر القطاعات
                Container(
                  height: 48,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filters.length,
                    itemBuilder: (context, idx) {
                      final f = _filters[idx];
                      final isSelected = _selectedFilter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(f == 'الكل' ? 'الكل' : _getCategoryTitle(f)),
                          selected: isSelected,
                          selectedColor: const Color(0xFF0F172A),
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 11),
                          onSelected: (val) => setState(() => _selectedFilter = f),
                        ),
                      );
                    },
                  ),
                ),

                // قائمة التذاكر
                Expanded(
                  child: _filteredBookings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.confirmation_number_outlined, size: 70, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              const Text('لا توجد حجوزات أو تذاكر صادرة حالياً', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredBookings.length,
                          itemBuilder: (context, idx) {
                            final b = _filteredBookings[idx];
                            final cat = b['category'].toString();
                            final color = _getCategoryColor(cat);
                            final icon = _getCategoryIcon(cat);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.black.withOpacity(0.04)),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3)),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: color.withOpacity(0.12),
                                        child: Icon(icon, color: color, size: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(b['business_name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                                            const SizedBox(height: 2),
                                            Text('كود التذكرة: ${b['qr_pass']}', style: const TextStyle(color: Colors.blueGrey, fontSize: 11, letterSpacing: 1)),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.qr_code, color: Color(0xFF0F172A), size: 28),
                                        tooltip: 'عرض كود الـ QR',
                                        onPressed: () => _showTicketDetailDialog(b),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('المبلغ المطلوب:', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                          Text('${(b['total_price'] as num).toInt()} ر.ي', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 15)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          TextButton.icon(
                                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                                            icon: const Icon(Icons.cancel_outlined, size: 16),
                                            label: const Text('إلغاء الحجز', style: TextStyle(fontSize: 11)),
                                            onPressed: () => _confirmCancel(b),
                                          ),
                                          const SizedBox(width: 6),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF0F172A),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                                            label: const Text('إبراز التذكرة', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                            onPressed: () => _showTicketDetailDialog(b),
                                          ),
                                        ],
                                      ),
                                    ],
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
}
