import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'sectors_screen.dart';
import 'metaverse_screen.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const HomeScreen({super.key, this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, dynamic> user;

  @override
  void initState() {
    super.initState();
    user = widget.currentUser ?? {
      'id': '1',
      'name': 'المدير العام',
      'phone': '777000000',
      'role': 'ADMIN',
      'is_vip': true,
    };
  }

  void _showAddBusinessDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final feeCtrl = TextEditingController(text: '50');
    String selectedType = 'STORE';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'إضافة منشأة أو خدمة جديدة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'اسم المنشأة أو المحل',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(
                  labelText: 'القطاع الخدمي',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: const [
                  DropdownMenuItem(value: 'STORE', child: Text('المتاجر والاستهلاك')),
                  DropdownMenuItem(value: 'RESTAURANT', child: Text('المطاعم والوجبات')),
                  DropdownMenuItem(value: 'CLINIC', child: Text('العيادات والأطباء')),
                  DropdownMenuItem(value: 'BUS', child: Text('باصات السفر بين المحافظات')),
                  DropdownMenuItem(value: 'WATER', child: Text('وايتات مياه الشرب')),
                  DropdownMenuItem(value: 'QAT', child: Text('أسواق القات النموذجية')),
                  DropdownMenuItem(value: 'HOTEL', child: Text('الفنادق والأجنحة')),
                  DropdownMenuItem(value: 'CAR', child: Text('تأجير السيارات')),
                  DropdownMenuItem(value: 'REALTY', child: Text('العقارات والبيوت')),
                ],
                onChanged: (val) {
                  if (val != null) setModalState(() => selectedType = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'رقم هاتف المنشأة للتواصل',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  if (nameCtrl.text.isEmpty) return;
                  Navigator.pop(ctx);
                  final success = await ApiService.addBusiness(
                    name: nameCtrl.text.trim(),
                    type: selectedType,
                    phone: phoneCtrl.text.trim(),
                    monthlyFee: double.tryParse(feeCtrl.text) ?? 50.0,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'تم حفظ المنشأة بنجاح في قاعدة البيانات' : 'تعذر إضافة المنشأة'),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                    setState(() {});
                  }
                },
                child: const Text('حفظ المنشأة مباشرة', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        title: Row(
          children: [
            const Icon(Icons.location_city_rounded, color: Color(0xFF06B6D4), size: 24),
            const SizedBox(width: 8),
            Text(
              'المنصة الذكية (${user['name']})',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard, color: Colors.white70),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F172A),
        icon: const Icon(Icons.add_business, color: Color(0xFF06B6D4)),
        label: const Text('إضافة منشأة', style: TextStyle(color: Colors.white)),
        onPressed: _showAddBusinessDialog,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة VIP والمستخدم
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF06B6D4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            user['role'] == 'VENDOR' ? 'حساب تاجر' : 'عضوية VIP نشطة',
                            style: const TextStyle(color: Color(0xFF0F172A), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user['name'],
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'رقم الهاتف: ${user['phone']}',
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MetaverseScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF06B6D4).withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF06B6D4), width: 1.5),
                      ),
                      child: const Icon(Icons.view_in_ar, color: Color(0xFF06B6D4), size: 28),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            const Text(
              'القطاعات التسعة المعتمدة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            // قائمة القطاعات التسعة
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSectorCard('المتاجر', Icons.storefront, Colors.indigo),
                _buildSectorCard('المطاعم', Icons.restaurant, Colors.orange),
                _buildSectorCard('العيادات', Icons.medical_services, Colors.teal),
                _buildSectorCard('باصات السفر', Icons.directions_bus, Colors.blue),
                _buildSectorCard('وايتات مياه', Icons.water_drop, Colors.cyan),
                _buildSectorCard('سوق القات', Icons.eco, Colors.green),
                _buildSectorCard('الفنادق', Icons.hotel, Colors.deepPurple),
                _buildSectorCard('تأجير سيارات', Icons.directions_car, Colors.amber.shade800),
                _buildSectorCard('العقارات', Icons.home_work, Colors.blueGrey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectorCard(String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SectorsScreen(currentUser: user)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
