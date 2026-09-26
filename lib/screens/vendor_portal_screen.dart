import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'qr_scanner_screen.dart';

class VendorPortalScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const VendorPortalScreen({super.key, required this.currentUser});

  @override
  State<VendorPortalScreen> createState() => _VendorPortalScreenState();
}

class _VendorPortalScreenState extends State<VendorPortalScreen> {
  List<Map<String, dynamic>> _myIncomingOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVendorData();
  }

  Future<void> _loadVendorData() async {
    setState(() => _isLoading = true);
    // جلب حجوزات المنشأة الحالية
    final orders = await ApiService.fetchUserBookings(widget.currentUser['id']?.toString() ?? '1');
    if (mounted) {
      setState(() {
        _myIncomingOrders = orders;
        _isLoading = false;
      });
    }
  }

  double get _totalEarnings {
    double total = 0;
    for (var o in _myIncomingOrders) {
      if (o['status'] == 'REDEEMED' || o['status'] == 'CONFIRMED') {
        total += (o['total_price'] as num?)?.toDouble() ?? 0.0;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final vendorName = widget.currentUser['name'] ?? 'تاجر معتمد';
    final vendorPhone = widget.currentUser['phone'] ?? '770000000';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text('لوحة تحكم ومحفظة التاجر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVendorData,
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
                  // بطاقة هوية التاجر
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
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
                              backgroundColor: const Color(0xFF06B6D4).withOpacity(0.15),
                              child: const Icon(Icons.storefront, color: Color(0xFF06B6D4), size: 28),
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
                                  Text('هاتف التواصل: $vendorPhone', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.amber.shade900, borderRadius: BorderRadius.circular(8)),
                              child: const Text('حساب مزود', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white24, height: 26),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatItem('الطلبات الواردة', '${_myIncomingOrders.length} طلب'),
                            _buildStatItem('المبيعات المحققة', '${_totalEarnings.toInt()} ر.ي'),
                            _buildStatItem('حالة النشاط', 'نشط بالسيرفر'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // الإجراءات السريعة
                  const Text('إجراءات مزود الخدمة السريعة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
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
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('يمكنك نشر وإضافة خدمات جديدة مباشرة من خلال شاشة قطاعك التخصصي')),
                            );
                          },
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
                                  backgroundColor: Color(0xFFEFF6FF),
                                  child: Icon(Icons.add_business, color: Colors.blue),
                                ),
                                SizedBox(height: 8),
                                Text('إضافة بضاعة / خدمة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                Text('تثبيت عرض جديد', style: TextStyle(color: Colors.grey, fontSize: 10)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // قائمة الطلبات الموجهة للمنشأة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('سجل الطلبات والتذاكر الخاصة بنشاطك', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      Text('${_myIncomingOrders.length} عمليات', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_myIncomingOrders.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: const Column(
                        children: [
                          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('لا توجد طلبات جديدة موجهة لمنشأتك حالياً', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _myIncomingOrders.length,
                      itemBuilder: (context, idx) {
                        final order = _myIncomingOrders[idx];
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
                                      isDone ? 'تم التسليم' : 'بانتظار الاستلام',
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
