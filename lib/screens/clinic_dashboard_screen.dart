import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ClinicDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> clinicUser;

  const ClinicDashboardScreen({super.key, required this.clinicUser});

  @override
  State<ClinicDashboardScreen> createState() => _ClinicDashboardScreenState();
}

class _ClinicDashboardScreenState extends State<ClinicDashboardScreen> with SingleTickerProviderStateMixin {
  final String _baseUrl = "https://smartcitybackend-production-9d26.up.railway.app";
  late TabController _tabCtrl;

  List<dynamic> doctors = [];
  List<dynamic> appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _fetchClinicData();
  }

  Future<void> _fetchClinicData() async {
    final bId = widget.clinicUser['business_id'];
    if (bId == null) {
      setState(() => isLoading = false);
      return;
    }
    setState(() => isLoading = true);
    try {
      final docRes = await http.get(Uri.parse("$_baseUrl/api/v1/clinic/doctors/$bId"));
      final appRes = await http.get(Uri.parse("$_baseUrl/api/v1/clinic/appointments/$bId"));

      if (docRes.statusCode == 200 && appRes.statusCode == 200) {
        setState(() {
          doctors = jsonDecode(docRes.body);
          appointments = jsonDecode(appRes.body);
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  void _showAddDoctorDialog() {
    final nameCtrl = TextEditingController();
    final specCtrl = TextEditingController();
    final feeCtrl = TextEditingController(text: "20");
    final timeCtrl = TextEditingController(text: "8:00 AM - 1:00 PM");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2541),
        title: const Text('إضافة طبيب للكادر الطبي', style: TextStyle(color: Color(0xFF06D6A0), fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'اسم الطبيب الرباعي',
                  labelStyle: const TextStyle(color: Colors.white60),
                  filled: true,
                  fillColor: const Color(0xFF0B132B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: specCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'التخصص الطبي الدقيق',
                  labelStyle: const TextStyle(color: Colors.white60),
                  filled: true,
                  fillColor: const Color(0xFF0B132B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: feeCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'رسوم الكشف (\$)',
                  labelStyle: const TextStyle(color: Colors.white60),
                  filled: true,
                  fillColor: const Color(0xFF0B132B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: timeCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'أوقات الدوام والاستشارات',
                  labelStyle: const TextStyle(color: Colors.white60),
                  filled: true,
                  fillColor: const Color(0xFF0B132B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06D6A0)),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final spec = specCtrl.text.trim();
              if (name.isEmpty || spec.isEmpty) return;
              Navigator.pop(ctx);

              await http.post(
                Uri.parse("$_baseUrl/api/v1/clinic/doctors"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "business_id": widget.clinicUser['business_id'],
                  "doctor_name": name,
                  "specialty": spec,
                  "consultation_fee": double.tryParse(feeCtrl.text.trim()) ?? 0.0,
                  "available_time": timeCtrl.text.trim(),
                }),
              );
              _fetchClinicData();
            },
            child: const Text('إضافة وتثبيت', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _completeAppointment(int id) async {
    await http.patch(
      Uri.parse("$_baseUrl/api/v1/clinic/appointments/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"status": "اكتمل الكشف"}),
    );
    _fetchClinicData();
  }

  @override
  Widget build(BuildContext context) {
    final clinicName = widget.clinicUser['business_name'] ?? 'المركز الطبي';

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: Text('إدارة: $clinicName', style: const TextStyle(fontSize: 16)),
        backgroundColor: const Color(0xFF1C2541),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _fetchClinicData),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFF06D6A0),
          labelColor: const Color(0xFF06D6A0),
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'مواعيد المرضى (${appointments.length})', icon: const Icon(Icons.people_alt_outlined)),
            Tab(text: 'الأطباء المعتمدون (${doctors.length})', icon: const Icon(Icons.medical_services_outlined)),
          ],
        ),
      ),
      floatingActionButton: _tabCtrl.index == 1
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF06D6A0),
              onPressed: _showAddDoctorDialog,
              icon: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF0B132B)),
              label: const Text('إضافة طبيب', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold)),
            )
          : null,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF06D6A0)))
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildAppointmentsTab(),
                _buildDoctorsTab(),
              ],
            ),
    );
  }

  Widget _buildAppointmentsTab() {
    if (appointments.isEmpty) {
      return const Center(child: Text('لا توجد حجوزات مرضى حالياً', style: TextStyle(color: Colors.white54)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (ctx, i) {
        final a = appointments[i];
        final isDone = a['status'] == 'اكتمل الكشف';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2541),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDone ? Colors.white24 : const Color(0xFF06D6A0).withOpacity(0.4)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: (isDone ? Colors.white24 : const Color(0xFF06D6A0)).withOpacity(0.2),
                child: Icon(Icons.person_pin_rounded, color: isDone ? Colors.white54 : const Color(0xFF06D6A0)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('المريض: ${a['patient_name']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('الطبيب: ${a['doctor_name']} • الحالة: ${a['status']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              if (!isDone)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06D6A0)),
                  onPressed: () => _completeAppointment(a['id']),
                  child: const Text('إنهاء الكشف', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold, fontSize: 11)),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDoctorsTab() {
    if (doctors.isEmpty) {
      return const Center(child: Text('لم تقم بإضافة أطباء بعد، اضغط على زر الإضافة بالأسفل', style: TextStyle(color: Colors.white54)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: doctors.length,
      itemBuilder: (ctx, i) {
        final d = doctors[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2541),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF06D6A0).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0x2206D6A0),
                child: Icon(Icons.medical_services_rounded, color: Color(0xFF06D6A0)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d['doctor_name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('التخصص: ${d['specialty']} • الدوام: ${d['available_time']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text('رسوم الكشف: \$${d['consultation_fee']}', style: const TextStyle(color: Color(0xFFFFB703), fontWeight: FontWeight.bold, fontSize: 12)),
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
