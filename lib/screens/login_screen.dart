import 'package:flutter/material.dart';
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
  bool _isLoading = false;

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رقم الهاتف')),
      );
      return;
    }

    setState(() => _isLoading = true);

    if (_isSignUp) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى إدخال الاسم بالكامل')),
        );
        return;
      }

      final user = await ApiService.registerUser(
        name: name,
        phone: phone,
        role: _selectedRole,
      );

      setState(() => _isLoading = false);
      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(currentUser: user)),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل التسجيل، قد يكون الرقم مسجلاً بالفعل')),
        );
      }
    } else {
      final user = await ApiService.loginUser(phone);
      setState(() => _isLoading = false);

      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(currentUser: user)),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرقم غير موجود، يمكنك إنشاء حساب جديد')),
        );
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                  child: const Icon(Icons.location_city_rounded, color: Color(0xFF06B6D4), size: 48),
                ),
                const SizedBox(height: 18),
                Text(
                  _isSignUp ? 'إنشاء حساب جديد' : 'بوابة المدينة الذكية',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(
                  'منظومة الخدمات والأنشطة الموحدة',
                  style: TextStyle(fontSize: 13, color: Colors.white60),
                ),
                const SizedBox(height: 28),

                if (_isSignUp) ...[
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'الاسم الكامل',
                      labelStyle: const TextStyle(color: Colors.white60),
                      prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF06B6D4)),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
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
                          DropdownMenuItem(value: 'VENDOR', child: Text('تاجر / مزود خدمة')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedRole = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
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
                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06B6D4),
                      foregroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Color(0xFF0F172A))
                        : Text(
                            _isSignUp ? 'تسجيل حساب جديد' : 'تسجيل الدخول',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(
                    _isSignUp ? 'لديك حساب بالفعل؟ تسجيل الدخول' : 'ليس لديك حساب؟ إنشاء حساب جديد',
                    style: const TextStyle(color: Color(0xFF06B6D4)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
