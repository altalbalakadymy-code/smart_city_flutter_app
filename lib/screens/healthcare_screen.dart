import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HealthcareScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const HealthcareScreen({super.key, this.currentUser});

  @override
  State<HealthcareScreen> createState() => _HealthcareScreenState();
}

class _HealthcareScreenState extends State<HealthcareScreen> {
  List<Map<String, dynamic>> _doctors = [];
  bool _isLoading = true;
  String _selectedSpecialty = 'الكل';
  final List<String> _specialties = ['الكل', 'باطنية وقلب', 'طب وجراحة العيون', 'جراحة العظام والمفاصل', 'أطفال وحديثي ولادة', 'طب وجراحة الأسنان'];

  String? _selectedDate = '2026-10-01';
  Map<int, String> _selectedSlots = {}; // تخزين الفترة المحددة لكل طبيب

  bool get _isVip => widget.currentUser?['is_vip'] == true;
  bool get _isAuthorized =>
      widget.currentUser?['role'] == 'ADMIN' || widget.currentUser?['role'] == 'VENDOR';

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);
    final data = await ApiService.fetchDoctors();
    if (mounted) {
      setState(() {
        _doctors = data;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredDoctors {
    if (_selectedSpecialty == 'الكل') return _doctors;
    return _doctors.where((d) => d['specialty'] == _selectedSpecialty).toList();
  }

  void _showAddDoctorDialog() {
    final nameCtrl = TextEditingController();
    final specCtrl = TextEditingController(text: 'باطنية وقلب');
    final clinicCtrl = TextEditingController(text: 'المركز الطبي الاستشاري');
    final feeCtrl = TextEditingController(text: '8000');
    final slotsCtrl = TextEditingController(text: '04:00 م, 04:30 م, 05:00 م, 05:30 م');
    final phoneCtrl = TextEditingController(text: '770000000');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                'إضافة طبيب / عيادة جديدة للسيرفر',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: 'اسم الطبيب واللقب', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: specCtrl,
                decoration: InputDecoration(labelText: 'التخصص الدقيق', prefixIcon: const Icon(Icons.medical_services), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: clinicCtrl,
                decoration: InputDecoration(labelText: 'اسم المركز أو المستشفى', prefixIcon: const Icon(Icons.local_hospital), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: feeCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'رسوم المعاينة (ريال يمني)', prefixIcon: const Icon(Icons.money), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: slotsCtrl,
                decoration: InputDecoration(labelText: 'الفترات المتاحة (مفصولة بفواصل)', prefixIcon: const Icon(Icons.access_time), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'هاتف العيادة', prefixIcon: const Icon(Icons.phone), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
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
                  if (nameCtrl.text.trim().isEmpty) return;
                  Navigator.pop(ctx);
                  final ok = await ApiService.addDoctor(
                    name: nameCtrl.text.trim(),
                    specialty: specCtrl.text.trim(),
                    clinicName: clinicCtrl.text.trim(),
                    fee: double.tryParse(feeCtrl.text) ?? 8000.0,
                    slots: slotsCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(ok ? 'تم إضافة الطبيب بنجاح' : 'تم الحفظ محلياً'), backgroundColor: Colors.teal),
                    );
                    _loadDoctors();
                  }
                },
                child: const Text('حفظ في قاعدة البيانات'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _bookDoctorSlot(Map<String, dynamic> doc) async {
    final docId = doc['id'] as int;
    final slot = _selectedSlots[docId];

    if (slot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار الفترة الزمنية المناسبة للكشف أولاً')),
      );
      return;
    }

    final double fee = (doc['consultation_fee'] as num).toDouble();
    final double finalFee = _isVip ? fee * 0.8 : fee;
    final ticketCode = 'PASS-MED-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

    // حفظ الحجز في السيرفر
    await ApiService.addBusinessItem({
      'user_id': widget.currentUser?['id'] ?? '1',
      'business_name': '${doc['clinic_name']} - ${doc['name']}',
      'category': 'CLINIC',
      'total_price': finalFee,
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
            const Text('تذكرة موعد طبي مؤكد (QR)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(doc['clinic_name'], style: const TextStyle(color: Colors.teal, fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfo('الطبيب', doc['name']),
                _buildInfo('موعد الكشف', slot),
                _buildInfo('المبلغ المطلوب', '${finalFee.toInt()} ر.ي'),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.teal, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('أبرز هذه التذكرة لموظف استقبال العيادة للدخول المباشر بدون انتظار.', style: TextStyle(fontSize: 11, color: Colors.teal)),
                  ),
                ],
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
              onPressed: () => Navigator.pop(ctx),
              child: const Text('تم الحفظ في مواعيدي'),
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
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
      ],
    );
  }

  void _openMedicalChat(Map<String, dynamic> doc) {
    final msgCtrl = TextEditingController();
    final List<Map<String, String>> chat = [
      {'sender': 'doctor', 'text': 'مرحباً بك، أنا مساعد ${doc['name']}. يمكنك كتابة وصف موجز لحالتك أو السؤال عن الفحوصات المطلوبة قبل الحضور.'}
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setChat) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, top: 16, left: 16, right: 16),
          child: SizedBox(
            height: 450,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.medical_services, color: Colors.white, size: 20)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doc['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(doc['specialty'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: chat.length,
                    itemBuilder: (context, idx) {
                      final m = chat[idx];
                      final isMe = m['sender'] == 'me';
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(m['text']!, style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 13)),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: msgCtrl,
                          decoration: InputDecoration(
                            hintText: 'اكتب استشارتك التمهيدية...',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                        icon: const Icon(Icons.send, size: 20),
                        onPressed: () {
                          if (msgCtrl.text.trim().isEmpty) return;
                          setChat(() => chat.add({'sender': 'me', 'text': msgCtrl.text.trim()}));
                          msgCtrl.clear();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
        title: const Text('العيادات وحجز المواعيد الدقيقة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          if (_isAuthorized)
            IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: 'إضافة طبيب',
              onPressed: _showAddDoctorDialog,
            ),
        ],
      ),
      floatingActionButton: _isAuthorized
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF0F172A),
              icon: const Icon(Icons.medical_services, color: Color(0xFF06B6D4)),
              label: const Text('إضافة طبيب للسيرفر', style: TextStyle(color: Colors.white)),
              onPressed: _showAddDoctorDialog,
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
          : Column(
              children: [
                // فلتر التخصصات الطبية
                Container(
                  height: 48,
                  margin: const EdgeInsets.only(top: 12),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _specialties.length,
                    itemBuilder: (context, idx) {
                      final spec = _specialties[idx];
                      final isSelected = _selectedSpecialty == spec;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(spec),
                          selected: isSelected,
                          selectedColor: const Color(0xFF0F172A),
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12),
                          onSelected: (val) => setState(() => _selectedSpecialty = spec),
                        ),
                      );
                    },
                  ),
                ),

                // قائمة الأطباء والعيادات
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredDoctors.length,
                    itemBuilder: (context, idx) {
                      final doc = _filteredDoctors[idx];
                      final docId = doc['id'] as int;
                      final List<String> slots = List<String>.from(doc['available_slots'] ?? []);
                      final double fee = (doc['consultation_fee'] as num).toDouble();
                      final double finalFee = _isVip ? fee * 0.8 : fee;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black.withOpacity(0.04)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(doc['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                                    const SizedBox(height: 2),
                                    Text('${doc['specialty']} | ${doc['clinic_name']}', style: const TextStyle(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.teal),
                                  tooltip: 'استشارة تمهيدية',
                                  onPressed: () => _openMedicalChat(doc),
                                ),
                              ],
                            ),
                            const Divider(height: 20),

                            // عنوان الفترات الزمنية المتاحة (Time Slots)
                            const Text('اختر وقت الكشف الدقيق (Time Slot):', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 8),

                            // رقائق الفترات الزمنية
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: slots.map((s) {
                                final isSelected = _selectedSlots[docId] == s;
                                return InkWell(
                                  onTap: () => setState(() => _selectedSlots[docId] = s),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: isSelected ? const Color(0xFF0F172A) : Colors.transparent),
                                    ),
                                    child: Text(
                                      s,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black87,
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),

                            // شريط السعر وزر الحجز
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('رسوم الكشف ${_isVip ? "(خصم VIP 20%)" : ""}:', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    Text('${finalFee.toInt()} ر.ي', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F172A),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.calendar_month, size: 18),
                                  label: const Text('تأكيد الموعد (QR)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  onPressed: () => _bookDoctorSlot(doc),
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
