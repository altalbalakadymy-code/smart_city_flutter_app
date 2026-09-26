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
  String get _vendorName => widget.currentUser['name'] ?? 'مزود الخدمة المعتمد';
  String get _vendorPhone => widget.currentUser['phone'] ?? '770000000';

  @override
  void initState() {
    super.initState();
    _loadVendorData();
  }

  Future<void> _loadVendorData() async {
    setState(() => _isLoading = true);
    final allOrders = await ApiService.fetchUserBookings(widget.currentUser['id']?.toString() ?? '1');
    if (mounted) {
      setState(() {
        _mySectorOrders = allOrders.where((o) => o['category'] == _vendorSector || _vendorSector == 'ALL').toList();
        _isLoading = false;
      });
    }
  }

  // تفاصيل وصف وهوية كل قطاع بناءً على اختصاصه المهني
  Map<String, dynamic> _getSectorProfile() {
    switch (_vendorSector) {
      case 'CLINIC':
        return {
          'title': 'لوحة الطبيب والعيادة التخصصية',
          'roleTitle': 'طبيب / استشاري معتمد',
          'description': 'إدارة وتنظيم جدول كشوفات واستشارات المرضى، فتح الفترات الزمنية المتاحة، والتحقق من تذكرة كشف المريض رقمياً عند وصوله لغرفة الفحص.',
          'icon': Icons.medical_services,
          'color': Colors.teal,
          'statLabel1': 'كشوفات المرضى',
          'statLabel2': 'عائد المعاينات',
          'actionTitle': 'إضافة وتعديل مواعيد الفحص',
          'actionDesc': 'تحديد أوقات الدوام ورسوم الكشف',
          'targetScreen': HealthcareScreen(currentUser: widget.currentUser),
        };
      case 'WATER':
        return {
          'title': 'لوحة محطة وسائقي صهاريج المياه',
          'roleTitle': 'مزود صهاريج مياه معتمد',
          'description': 'استقبال طلبات تعبئة المياه العذبة ومياه الشرب الموجهة لخزانك، متابعة السعة المطلوبة باللتر وموقع العميل، وتأكيد تفريغ الصهريج بالـ QR.',
          'icon': Icons.water_drop,
          'color': Colors.cyan.shade800,
          'statLabel1': 'وايتات مطلوبة',
          'statLabel2': 'عائد التعبئة والتوصيل',
          'actionTitle': 'تحديث بيانات الوايت والمحطة',
          'actionDesc': 'تعديل سعة الصهريج والسعر والموقع',
          'targetScreen': WaterTankerScreen(currentUser: widget.currentUser),
        };
      case 'RESTAURANT':
        return {
          'title': 'شاشة المطبخ والكاشير للطلبات المسبقة',
          'roleTitle': 'إدارة المطعم والمطبخ',
          'description': 'استلام طلبات الوجبات المحجوزة مسبقاً (Pre-Orders)، تجهيز الأطعمة بوقت محدد بدقة، وتسليمها الساخنة فور حضور العميل بدون انتظار.',
          'icon': Icons.restaurant,
          'color': Colors.orange.shade800,
          'statLabel1': 'وجبات مطلوبة للتحضير',
          'statLabel2': 'إجمالي مبيعات المطبخ',
          'actionTitle': 'إدراج وجبة أو قائمة طعام',
          'actionDesc': 'إضافة أطباق جديدة وتحديد مدة الطبخ',
          'targetScreen': RestaurantScreen(currentUser: widget.currentUser),
        };
      case 'QAT':
        return {
          'title': 'لوحة سوق القات والمقاوته المعتمدين',
          'roleTitle': 'مقوتي / تاجر سوق معتمد',
          'description': 'عرض باقات القات الطازجة لزبائنك بالبسطة، تثبيت الحزم المحجوزة لمنع بيعها، واستقبال الزبون في السوق لتسليمه القات عبر كود التذكرة.',
          'icon': Icons.eco,
          'color': Colors.green.shade800,
          'statLabel1': 'حبات وباقات محجوزة',
          'statLabel2': 'عائد المبيعات المباشرة',
          'actionTitle': 'إدراج باقة قات جديدة للبسطة',
          'actionDesc': 'تحديد الصنف وجودة القطفة والسعر',
          'targetScreen': QatMarketScreen(currentUser: widget.currentUser),
        };
      case 'CAR':
        return {
          'title': 'لوحة معرض ومكتب تأجير السيارات',
          'roleTitle': 'مسؤول أسطول تأجير المركبات',
          'description': 'إدارة حركة أسطول السيارات المتاحة والمحجوزة، التحقق من رخصة قيادة وهوية العميل المستأجر، واعتماد عقد التسليم بالكود المشفر.',
          'icon': Icons.directions_car,
          'color': Colors.amber.shade900,
          'statLabel1': 'مركبات محجوزة للإيجار',
          'statLabel2': 'مداخيل عقود الإيجار',
          'actionTitle': 'إضافة سيارة لأسطول المعرض',
          'actionDesc': 'إدراج موديل السيارة وسعر اليوم الواحد',
          'targetScreen': CarRentalScreen(currentUser: widget.currentUser),
        };
      case 'REALTY':
        return {
          'title': 'لوحة المكتب العقاري وملاك المنازل',
          'roleTitle': 'وسيط عقاري / مالك معتمد',
          'description': 'إدارة طلبات المعاينة الميدانية للشقق والفلل والأراضي، استقبال اتصالات واستفسارات المهتمين، وتأكيد موعد الحضور للمعاينة على الطبيعة.',
          'icon': Icons.home_work,
          'color': Colors.blueGrey.shade800,
          'statLabel1': 'مواعيد معاينة مجدولة',
          'statLabel2': 'قيمة العقارات المدارة',
          'actionTitle': 'إدراج عقار جديد للبيع أو الإيجار',
          'actionDesc': 'تحديد المساحة، عدد الغرف، والسعر',
          'targetScreen': RealEstateScreen(currentUser: widget.currentUser),
        };
      case 'HOTEL':
        return {
          'title': 'لوحة إدارة الفندق والاستقبال الملكي',
          'roleTitle': 'مسؤول الحجوزات والاستقبال',
          'description': 'متابعة حركات الغرف والأجنحة الفندقية المشغولة والمتاحة، فحص كود تأكيد النزيل رقمياً، وتجهيز الغرفة قبل وصول الضيف للاستلام الفوري.',
          'icon': Icons.hotel,
          'color': Colors.deepPurple.shade700,
          'statLabel1': 'غرف وأجنحة محجوزة',
          'statLabel2': 'إجمالي عوائد الإقامة',
          'actionTitle': 'إضافة جناح أو غرفة فندقية',
          'actionDesc': 'تحديد نوع الإقامة وسعر الليلة والمزايا',
          'targetScreen': TourismScreen(currentUser: widget.currentUser),
        };
      case 'BUS':
        return {
          'title': 'لوحة إدارة خطوط وباصات السفر البري',
          'roleTitle': 'مشرف سفريات ونقل دولي/محلي',
          'description': 'مراقبة سعة الحافلات وحجوزات المقاعد المؤكدة، فحص تذاكر الصعود الإلكترونية للركاب عند المحطة، وجدولة الرحلات المنطلقة.',
          'icon': Icons.directions_bus,
          'color': Colors.blue.shade800,
          'statLabel1': 'تذاكر ركاب مؤكدة',
          'statLabel2': 'عوائد التذاكر للرحلات',
          'actionTitle': 'جدولة رحلة أو مسار باص جديد',
          'actionDesc': 'تحديد خط السير، موعد الانطلاق، والسعر',
          'targetScreen': TransportScreen(currentUser: widget.currentUser),
        };
      case 'STORE':
      default:
        return {
          'title': 'لوحة التاجر وإدارة السلع والمخزون',
          'roleTitle': 'تاجر تجزئة وإلكترونيات معتمد',
          'description': 'متابعة السلع والمنتجات المحجوزة للاستلام اليدوي، التأكد من جاهزية البضاعة في المتجر قبل وصول الزبون، وتسليمها بعد مسح كود التثبيت.',
          'icon': Icons.storefront,
          'color': Colors.indigo.shade800,
          'statLabel1': 'سلع مثبتة للاستلام',
          'statLabel2': 'مبيعات المنتجات المحققة',
          'actionTitle': 'إضافة سلعة جديدة للمتجر',
          'actionDesc': 'تحديد المخزون، ساعات التثبيت، والسعر',
          'targetScreen': RetailScreen(currentUser: widget.currentUser),
        };
    }
  }

  double get _totalEarnings {
    double total = 0;
    for (var o in _mySectorOrders) {
      total += (o['total_price'] as num?)?.toDouble() ?? 0.0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final profile = _getSectorProfile();
    final Color sectorColor = profile['color'] as Color;
    final IconData sectorIcon = profile['icon'] as IconData;
    final String sectorTitle = profile['title'] as String;
    final String roleTitle = profile['roleTitle'] as String;
    final String sectorDesc = profile['description'] as String;
    final String statLabel1 = profile['statLabel1'] as String;
    final String statLabel2 = profile['statLabel2'] as String;
    final String actionTitle = profile['actionTitle'] as String;
    final String actionDesc = profile['actionDesc'] as String;
    final Widget targetScreen = profile['targetScreen'] as Widget;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(sectorTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
                  // 1. بطاقة تعريفية تصف بالضبط طبيعة الشاشة وماذا تقدم لصاحب هذا القطاع
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: sectorColor.withOpacity(0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(color: sectorColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: sectorColor.withOpacity(0.12),
                          child: Icon(Icons.info_outline, color: sectorColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مهمة هذه الواجهة لنشاطك:',
                                style: TextStyle(color: sectorColor, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                sectorDesc,
                                style: const TextStyle(color: Color(0xFF334155), fontSize: 11.5, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. الهوية المؤسسية للمزود وإحصائيات النشاط المخصصة
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF0F172A), sectorColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
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
                                      Text(_vendorName, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified, color: Color(0xFF06B6D4), size: 16),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(roleTitle, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text('رقم الاتصال: $_vendorPhone', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white24, height: 26),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatItem(statLabel1, '${_mySectorOrders.length} طلب'),
                            _buildStatItem(statLabel2, '${_totalEarnings.toInt()} ر.ي'),
                            _buildStatItem('حالة النشاط', 'مفعل بالسيرفر'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 3. أدوات الخدمة الميدانية المصممة لقطاعه
                  const Text('أدوات الإدارة الميدانية لقطاعك', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // زر التحقق الرقمي وفحص التذاكر
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
                                Text('فحص تذكرة العميل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                Text('تأكيد الاستلام وإغلاق الكود', style: TextStyle(color: Colors.grey, fontSize: 10)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // زر الإضافة والتعديل الخاص بقطاعه حصراً
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen)),
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
                                  child: Icon(Icons.add_business_outlined, color: sectorColor),
                                ),
                                const SizedBox(height: 8),
                                Text(actionTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(actionDesc, style: const TextStyle(color: Colors.grey, fontSize: 10), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 4. سجل الطلبات الواردة لقطاعه
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('سجل التذاكر والطلبات المباشرة', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      Text('${_mySectorOrders.length} تذكرة', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_mySectorOrders.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(28),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                      child: Column(
                        children: [
                          Icon(sectorIcon, size: 50, color: Colors.grey.shade300),
                          const SizedBox(height: 10),
                          Text('لا توجد حجوزات جديدة واردة لـ $sectorTitle حالياً', style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
                                  Text('كود التذكرة: ${order['qr_pass']}', style: const TextStyle(color: Colors.blueGrey, fontSize: 11, letterSpacing: 0.5)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${(order['total_price'] as num?)?.toInt() ?? 0} ر.ي', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 3),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isDone ? Colors.green.shade50 : Colors.amber.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isDone ? 'تم تقديم الخدمة' : 'بانتظار حضور العميل',
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
