import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _baseUrl = "https://smartcitybackend-production-9d26.up.railway.app";

  List<dynamic> users = [];
  List<dynamic> businesses = [];
  List<dynamic> reports = [];
  List<dynamic> appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() => isLoading = true);
    try {
      final uRes = await http.get(Uri.parse("$_baseUrl/api/v1/admin/users"));
      final bRes = await http.get(Uri.parse("$_baseUrl/api/v1/admin/businesses"));
      final rRes = await http.get(Uri.parse("$_baseUrl/api/v1/admin/reports"));
      final aRes = await http.get(Uri.parse("$_baseUrl/api/v1/admin/appointments"));

      if (uRes.statusCode == 200 && bRes.statusCode == 200 && rRes.statusCode == 200 && aRes.statusCode == 200) {
        setState(() {
          users = jsonDecode(uRes.body);
          businesses = jsonDecode(bRes.body);
          reports = jsonDecode(rRes.body);
          appointments = jsonDecode(aRes.body);
          isLoading = false;
        });
      } else {
        throw Exception();
      }
    } catch (_) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر تحميل بيانات اللوحة من السحابة'),
            backgroundColor: Color(0xFFFF5964),
          ),
        );
      }
    }
  }

  void _showAddBusinessDialog() {
    final nameCtrl = TextEditingController();
    String selectedCategory = 'retail';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDState) => AlertDialog(
          backgroundColor: const Color(0xFF1C2541),
          title: const Text('تسجيل متجر في السيرفر والميتافيرس', style: TextStyle(color: Color(0xFF00F5D4), fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'اسم المتجر أو المنشأة...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF0B132B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                dropdownColor: const Color(0xFF1C2541),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF0B132B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: const [
                  DropdownMenuItem(value: 'retail', child: Text('متاجر وتسوق')),
                  DropdownMenuItem(value: 'tech', child: Text('تقنية وميتافيرس')),
                  DropdownMenuItem(value: 'cafe', child: Text('مطاعم ومقاهي')),
                ],
                onChanged: (val) {
                  if (val != null) setDState(() => selectedCategory = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F5D4)),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(ctx);
                await http.post(
                  Uri.parse("$_baseUrl/api/v1/admin/businesses"),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({"name": name, "category": selectedCategory}),
                );
                _fetchAllData();
              },
              child: const Text('إضافة وتأكيد', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteBusiness(int id) async {
    await http.delete(Uri.parse("$_baseUrl/api/v1/admin/businesses/$id"));
    _fetchAllData();
  }

  Future<void> _toggleUserStatus(int id, String currentStatus) async {
    final nextStatus = currentStatus == 'موثق' ? 'موقوف' : 'موثق';
    await http.patch(
      Uri.parse("$_baseUrl/api/v1/admin/users/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"status": nextStatus}),
    );
    _fetchAllData();
  }

  Future<void> _resolveReport(int id) async {
    await http.patch(
      Uri.parse("$_baseUrl/api/v1/admin/reports/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"status": "تمت المعالجة"}),
    );
    _fetchAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: const Text('مركز قيادة المدينة الذكية'),
        backgroundColor: const Color(0xFF1C2541),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchAllData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFF00F5D4),
          labelColor: const Color(0xFF00F5D4),
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'المتاجر (${businesses.length})', icon: const Icon(Icons.store_rounded)),
            Tab(text: 'المواطنون (${users.length})', icon: const Icon(Icons.people_alt_rounded)),
            Tab(text: 'طوارئ المرافق (${reports.length})', icon: const Icon(Icons.report_gmailerrorred_rounded)),
            Tab(text: 'الحجوزات الطبية (${appointments.length})', icon: const Icon(Icons.medical_services_rounded)),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF00F5D4),
              onPressed: _showAddBusinessDialog,
              icon: const Icon(Icons.add_business_rounded, color: Color(0xFF0B132B)),
              label: const Text('إضافة متجر', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold)),
            )
          : null,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00F5D4)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBusinessesTab(),
                _buildUsersTab(),
                _buildReportsTab(),
                _buildAppointmentsTab(),
              ],
            ),
    );
  }

  Widget _buildBusinessesTab() {
    if (businesses.isEmpty) {
      return const Center(child: Text('لا توجد متاجر مسجلة', style: TextStyle(color: Colors.white54)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: businesses.length,
      itemBuilder: (ctx, i) {
        final b = businesses[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2541),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF00F5D4).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0x2200F5D4),
                child: Icon(Icons.store_mall_directory_rounded, color: Color(0xFF00F5D4)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('القسم: ${b['category']} • الحالة: ${b['status'] ?? 'معتمد'}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF5964)),
                onPressed: () => _deleteBusiness(b['id']),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsersTab() {
    if (users.isEmpty) {
      return const Center(child: Text('لا يوجد مواطنون مسجلون', style: TextStyle(color: Colors.white54)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (ctx, i) {
        final u = users[i];
        final isActive = u['status'] == 'موثق';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2541),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isActive ? const Color(0xFF06D6A0) : const Color(0xFFFF5964), width: 0.8),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: (isActive ? const Color(0xFF06D6A0) : const Color(0xFFFF5964)).withOpacity(0.2),
                child: Icon(Icons.person, color: isActive ? const Color(0xFF06D6A0) : const Color(0xFFFF5964)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u['full_name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('الهوية: ${u['national_id']} • الهاتف: ${u['phone'] ?? 'غير مسجل'}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _toggleUserStatus(u['id'], u['status'] ?? 'موثق'),
                child: Text(
                  isActive ? 'تجميد' : 'تفعيل',
                  style: TextStyle(color: isActive ? const Color(0xFFFF5964) : const Color(0xFF06D6A0), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportsTab() {
    if (reports.isEmpty) {
      return const Center(child: Text('لا توجد بلاغات طوارئ', style: TextStyle(color: Colors.white54)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (ctx, i) {
        final r = reports[i];
        final isResolved = r['status'] == 'تمت المعالجة';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2541),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isResolved ? const Color(0xFF06D6A0) : const Color(0xFFFFB703), width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(r['service_type'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(r['status'] ?? '', style: TextStyle(color: isResolved ? const Color(0xFF06D6A0) : const Color(0xFFFFB703), fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Text(r['description'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              if (!isResolved) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06D6A0)),
                    onPressed: () => _resolveReport(r['id']),
                    child: const Text('اعتماد المعالجة', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppointmentsTab() {
    if (appointments.isEmpty) {
      return const Center(child: Text('لا توجد حجوزات مسجلة', style: TextStyle(color: Colors.white54)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (ctx, i) {
        final a = appointments[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2541),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF00F5D4).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0x2200F5D4),
                child: Icon(Icons.local_hospital_rounded, color: Color(0xFF00F5D4)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('المريض: ${a['patient_name'] ?? 'مواطن'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('${a['clinic_name']} - ${a['doctor_name']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
