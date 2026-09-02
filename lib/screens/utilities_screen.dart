import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UtilitiesScreen extends StatefulWidget {
  const UtilitiesScreen({super.key});

  @override
  State<UtilitiesScreen> createState() => _UtilitiesScreenState();
}

class _UtilitiesScreenState extends State<UtilitiesScreen> {
  final String _baseUrl = "https://smartcitybackend-production-9d26.up.railway.app";
  final _descCtrl = TextEditingController();
  String _selectedService = 'طوارئ الكهرباء والإنارة';
  bool _isSending = false;

  final List<String> _services = const [
    'طوارئ الكهرباء والإنارة',
    'شبكة المياه والصرف',
    'إدارة النفايات وإعادة التدوير',
    'أعطال شبكة الاتصالات الذكية',
  ];

  Future<void> _submitReport() async {
    final desc = _descCtrl.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى كتابة تفاصيل البلاغ أو المشكلة')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final res = await http.post(
        Uri.parse("$_baseUrl/api/v1/utilities/report"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "service_type": _selectedService,
          "description": desc,
        }),
      );

      if (res.statusCode == 200) {
        _descCtrl.clear();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال البلاغ لغرفة عمليات المدينة الذكية بنجاح 🚨'),
            backgroundColor: Color(0xFF06D6A0),
          ),
        );
      } else {
        throw Exception();
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر إرسال البلاغ، تحقق من الاتصال'),
          backgroundColor: Color(0xFFFF5964),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: const Text('الطاقة والمرافق العامة'),
        backgroundColor: const Color(0xFF1C2541),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2541),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFB703).withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bolt_rounded, color: Color(0xFFFFB703), size: 30),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('شبكة الاستشعار اللحظي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(height: 2),
                        Text('كفاءة الشبكة العامة: 98.4% • لا توجد انقطاعات حرجة', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('رفع بلاغ طارئ لغرفة العمليات:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedService,
              dropdownColor: const Color(0xFF1C2541),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1C2541),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _services.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedService = val);
              },
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'اكتب وصف المشكلة، الشارع أو رقم العمود/العداد...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF1C2541),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB703),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSending ? null : _submitReport,
                icon: _isSending
                    ? const SizedBox.shrink()
                    : const Icon(Icons.send_rounded, color: Color(0xFF0B132B)),
                label: _isSending
                    ? const CircularProgressIndicator(color: Color(0xFF0B132B))
                    : const Text('إرسال البلاغ فوراً', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
