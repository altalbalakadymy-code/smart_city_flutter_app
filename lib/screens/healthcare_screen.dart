import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HealthcareScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const HealthcareScreen({super.key, this.currentUser});

  @override
  State<HealthcareScreen> createState() => _HealthcareScreenState();
}

class _HealthcareScreenState extends State<HealthcareScreen> {
  final String _baseUrl = "https://smartcitybackend-production-9d26.up.railway.app";
  List<dynamic> catalog = [];
  bool isLoading = true;

  int? selectedClinicId;
  String? selectedClinicName;
  String? selectedDoctorName;
  bool isBooking = false;

  @override
  void initState() {
    super.initState();
    _fetchCatalog();
  }

  Future<void> _fetchCatalog() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse("$_baseUrl/api/v1/health/clinics-catalog"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List<dynamic>;
        setState(() {
          catalog = data;
          if (catalog.isNotEmpty) {
            selectedClinicId = catalog.first['clinic_id'];
            selectedClinicName = catalog.first['clinic_name'];
            final docs = catalog.first['doctors'] as List<dynamic>;
            if (docs.isNotEmpty) {
              selectedDoctorName = docs.first['doctor_name'];
            }
          }
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _bookNow() async {
    if (selectedClinicName == null || selectedDoctorName == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار العيادة والطبيب أولاً')));
      return;
    }

    setState(() => isBooking = true);
    final patientName = widget.currentUser?['full_name'] ?? 'مواطن ذكي';

    try {
      final res = await http.post(
        Uri.parse("$_baseUrl/api/v1/health/book"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "business_id": selectedClinicId,
          "clinic_name": selectedClinicName,
          "doctor_name": selectedDoctorName,
          "patient_name": patientName,
          "appointment_date": "اليوم",
        }),
      );

      if (res.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تأكيد حجزك لدى $selectedDoctorName في $selectedClinicName بنجاح 🏥'),
            backgroundColor: const Color(0xFF06D6A0),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر إتمام الحجز، تحقق من الاتصال'), backgroundColor: Color(0xFFFF5964)),
      );
    } finally {
      if (mounted) setState(() => isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> currentDoctors = [];
    if (selectedClinicId != null) {
      final match = catalog.firstWhere((c) => c['clinic_id'] == selectedClinicId, orElse: () => null);
      if (match != null) {
        currentDoctors = match['doctors'] ?? [];
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: const Text('الرعاية الصحية والعيادات المعتمدة'),
        backgroundColor: const Color(0xFF1C2541),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _fetchCatalog),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF06D6A0)))
          : catalog.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_hospital_outlined, size: 70, color: Colors.white.withOpacity(0.3)),
                      const SizedBox(height: 12),
                      const Text('لا توجد عيادات أو مراكز صحية مسجلة بعد', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      const Text('يمكن لإدارة المدينة اعتماد المراكز الطبية وإصدار حساباتها', style: TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C2541),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF06D6A0).withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Color(0x2206D6A0),
                              child: Icon(Icons.health_and_safety_rounded, color: Color(0xFF06D6A0)),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'احجز استشارتك الطبية فورياً لدى المراكز المعتمدة بالمدينة الرقمية',
                                style: TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('اختر المركز الطبي أو العيادة:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<int>(
                        value: selectedClinicId,
                        dropdownColor: const Color(0xFF1C2541),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF1C2541),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: catalog.map<DropdownMenuItem<int>>((c) {
                          return DropdownMenuItem<int>(
                            value: c['clinic_id'] as int,
                            child: Text(c['clinic_name'] ?? '', style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedClinicId = val;
                              final c = catalog.firstWhere((e) => e['clinic_id'] == val);
                              selectedClinicName = c['clinic_name'];
                              final docs = c['doctors'] as List<dynamic>;
                              selectedDoctorName = docs.isNotEmpty ? docs.first['doctor_name'] : null;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 18),
                      const Text('اختر الطبيب المعالج:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 10),
                      currentDoctors.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFF1C2541), borderRadius: BorderRadius.circular(10)),
                              child: const Text('لم تقم هذه العيادة بإضافة أطبائها بعد', style: TextStyle(color: Colors.white54, fontSize: 12)),
                            )
                          : DropdownButtonFormField<String>(
                              value: selectedDoctorName,
                              dropdownColor: const Color(0xFF1C2541),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF1C2541),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              items: currentDoctors.map<DropdownMenuItem<String>>((d) {
                                return DropdownMenuItem<String>(
                                  value: d['doctor_name'] as String,
                                  child: Text('${d['doctor_name']} (${d['specialty']})', style: const TextStyle(fontSize: 13)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => selectedDoctorName = val);
                              },
                            ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF06D6A0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: (isBooking || currentDoctors.isEmpty) ? null : _bookNow,
                          icon: isBooking
                              ? const SizedBox.shrink()
                              : const Icon(Icons.calendar_today_rounded, color: Color(0xFF0B132B)),
                          label: isBooking
                              ? const CircularProgressIndicator(color: Color(0xFF0B132B))
                              : const Text('تأكيد الحجز الفوري', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
