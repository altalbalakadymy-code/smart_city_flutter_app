import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSignUp = false;
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedRole = 'CLIENT';
  String _selectedSector = 'STORE'; // افتراضياً متجر
  bool _isLoading = false;

  final Map<String, String> _sectorLabels = {
    'STORE': 'المتاجر والسلع',
    'RESTAURANT': 'المطاعم والوجبات',
    'CLINIC': 'العيادات والمراكز الطبية',
    'BUS': 'باصات النقل والسفريات',
    'WATER': 'محطات وصهاريج المياه',
    'QAT': 'أسواق وبسطات القات',
    'HOTEL': 'الفنادق والشقق المفروشة',
    'CAR': 'مكاتب تأجير السيارات',
    'REALTY': 'المكاتب والمنازل العقارية',
  };

  Future<void> _persistSessionAndNavigate(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_user_session', jsonEncode(user));

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(currentUser: user)),
    );
  }

  void _loginAsRole(String role, String name, String phone, bool isVip, {String? sector}) {
    final user = {
      'id': role == 'ADMIN' ? '1' : (role == 'VENDOR' ? '3' : '2'),
      'name': name,
      'phone': phone,
      'role': role,
      'is_vip': isVip,
      'vendor_sector': sector ?? (role == 'VENDOR' ? 'STORE' : null),
    };
    _persistSessionAndNavigate(user);
  }

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رقم الهاتف')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        final name = _nameController.text.trim();
        final finalName = name.isEmpty ? 'مستخدم جديد' : name;

        final user = await ApiService.registerUser(
          name: finalName,
          phone: phone,
          role: _selectedRole,
        );

        if (!mounted) return;
        setState(() => _isLoading = false);

        final userData = user ?? {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'name': finalName,
          'phone': phone,
          'role': _selectedRole,
          'is_vip': _selectedRole == 'CLIENT',
        };

        if (_selectedRole == 'VENDOR') {
          userData['vendor_sector'] = _selectedSector;
        }

        await _persistSessionAndNavigate(userData);
      } else {
        final user = await ApiService.loginUser(phone);
        if (!mounted) return;
        setState(() => _isLoading = false);

        final userData = user ?? {
          'id': '101',
          'name': 'مستخدم المنصة',
          'phone': phone,
          'role': 'CLIENT',
          'is_vip': true,
        };

        if (userData['role'] == 'VENDOR' && !userData.containsKey('vendor_sector')) {
          userData['vendor_sector'] = 'STORE';
        }

        await _persistSessionAndNavigate(userData);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        _loginAsRole('CLIENT', 'مواطن', phone, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF06B6D4), width: 2),
                  ),
                  child: const Icon(Icons.location_city_rounded, color: Color(0xFF06B6D4), size: 44),
                ),
                const SizedBox(height: 16),
                Text(
                  _isSignUp ? 'إنشاء حساب جديد مخصص' : 'بوابة المدينة الذكية',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(
                  'منظومة الخدمات والأنشطة الموحدة',
                  style: TextStyle(fontSize: 13, color: Colors.white60),
                ),
                const SizedBox(height: 24),

                if (_isSignUp) ...[
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: _selectedRole == 'VENDOR' ? 'اسم المنشأة / صاحب الخدمة' : 'الاسم الكامل',
                      labelStyle: const TextStyle(color: Colors.white60),
                      prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF06B6D4)),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedRole,
                        dropdownColor: const Color(0xFF1E293B),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'CLIENT', child: Text('مواطن / عميل طالب خدمة')),
                          DropdownMenuItem(value: 'VENDOR', child: Text('صاحب منشأة / مزود قطاع')),
                          DropdownMenuItem(value: 'ADMIN', child: Text('مدير نظام (Super Admin)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedRole = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // في حال كان الحساب تاجر تظهر قائمة القطاع التخصصي
                  if (_selectedRole == 'VENDOR') ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.5)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSector,
                          dropdownColor: const Color(0xFF1E293B),
                          style: const TextStyle(color: Color(0xFF06B6D4), fontSize: 14, fontWeight: FontWeight.bold),
                          isExpanded: true,
                          items: _sectorLabels.entries.map((e) {
                            return DropdownMenuItem(value: e.key, child: Text('قطاع: ${e.value}'));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedSector = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],

                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    labelStyle: const TextStyle(color: Colors.white60),
                    prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF06B6D4)),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06B6D4),
                      foregroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Color(0xFF0F172A), strokeWidth: 2))
                        : Text(
                            _isSignUp ? 'تأكيد وحفظ الحساب' : 'تسجيل الدخول',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 14),

                TextButton(
                  onPressed: () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(
                    _isSignUp ? 'لديك حساب بالفعل؟ تسجيل الدخول' : 'ليس لديك حساب؟ إنشاء حساب جديد',
                    style: const TextStyle(color: Color(0xFF06B6D4), fontSize: 13),
                  ),
                ),

                const Divider(color: Colors.white24, height: 32),

                const Text(
                  'أو الدخول التجريبي المباشر بحساب قطاع محدد:',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildQuickRoleBtn('أدمن النظام', 'ADMIN', null, Colors.red),
                    _buildQuickRoleBtn('طبيب عيادة', 'VENDOR', 'CLINIC', Colors.teal),
                    _buildQuickRoleBtn('سائق صهريج', 'VENDOR', 'WATER', Colors.cyan),
                    _buildQuickRoleBtn('كاشير مطعم', 'VENDOR', 'RESTAURANT', Colors.orange),
                    _buildQuickRoleBtn('مقوتي معتمد', 'VENDOR', 'QAT', Colors.green),
                    _buildQuickRoleBtn('معرض سيارات', 'VENDOR', 'CAR', Colors.amber.shade800),
                    _buildQuickRoleBtn('مواطن VIP', 'CLIENT', null, Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickRoleBtn(String label, String role, String? sector, Color col) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: col),
        foregroundColor: col,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => _loginAsRole(role, label, '770000000', role == 'CLIENT', sector: sector),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
