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
  
  String _selectedClinic = 'مركز طب الأسرة والعيادات العامة';
  String _selectedDoctor = 'د. سارة الأحمدي (استشارية باطنية)';
  bool _isBooking = false;

  final Map<String, List<String>> _clinicsData = {
    'مركز طب الأسرة والعيادات العامة': [
      'د. سارة الأحمدي (استشارية باطنية)',
      'د. خالد اليافعي (طب أسرة عام)',
    ],
    'مركز القلب والأوعية الدموية': [
      'د. منصور العولقي (استشاري قسطرة وقلب)',
      'د. ريم المهدي (أخصائية تخطيط قلب)',
    ],
    'مركز طب وجراحة الأسنان الذكي': [
      'د. عمر الشامي (جراحة وزراعة أسنان)',
      'د. هدى الصبري (تقويم وتجميل أسنان)',
    ],
    'عيادات العيون والليزك': [
      'د. وليد القاسمي (استشاري بصريات وجراحة عيون)',
    ],
  };

  Future<void> _bookAppointment() async {
    setState(() => _isBooking = true);
    final patientName = widget.currentUser?['full_name'] ?? 'مواطن ذكي';

    try {
      final res = await http.post(
        Uri.parse("$_baseUrl/api/v1/health/book"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "clinic_name": _selectedClinic,
          "doctor_name": _selectedDoctor,
          "patient_name": patientName,
        }),
      );

      if (res.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حجز الموعد بنجاح للمريض: $patientName 🏥'),
            backgroundColor: const Color(0xFF06D6A0),
          ),
        );
      } else {
        throw Exception();
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تأكيد الحجز، تحقق من الاتصال بالشبكة'),
          backgroundColor: Color(0xFFFF5964),
        ),
      );
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorsList = _clinicsData[_selectedClinic] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: const Text('الرعاية الصحية والعيادات'),
        backgroundColor: const Color(0xFF1C2541),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2541),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF06D6A0).withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0x2206D6A0),
                    child: Icon(Icons.monitor_heart_rounded, color: Color(0xFF06D6A0)),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('منظومة الصحة الذكية الرقمية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(height: 2),
                        Text('حجز فوري للعيادات المعتمدة وربط الملف الطبي بالهوية', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('اختر العيادة أو المركز الطبي:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedClinic,
              dropdownColor: const Color(0xFF1C2541),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1C2541),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _clinicsData.keys.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedClinic = val;
                    _selectedDoctor = _clinicsData[val]!.first;
                  });
                }
              },
            ),
            const SizedBox(height: 18),
            const Text('اختر الطبيب المعالج:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedDoctor,
              dropdownColor: const Color(0xFF1C2541),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1C2541),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: doctorsList.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedDoctor = val);
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
                onPressed: _isBooking ? null : _bookAppointment,
                icon: _isBooking
                    ? const SizedBox.shrink()
                    : const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF0B132B)),
                label: _isBooking
                    ? const CircularProgressIndicator(color: Color(0xFF0B132B))
                    : const Text('تأكيد وحجز الموعد الفوري', style: TextStyle(color: Color(0xFF0B132B), fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
