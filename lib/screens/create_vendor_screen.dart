import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateVendorScreen extends StatefulWidget {
  const CreateVendorScreen({super.key});

  @override
  State<CreateVendorScreen> createState() => _CreateVendorScreenState();
}

class _CreateVendorScreenState extends State<CreateVendorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();
  String _selectedType = 'retail';
  bool _isSubmitting = false;

  final List<Map<String, String>> _types = [
    {'label': '🛒 متجر تجاري (Retail)', 'value': 'retail'},
    {'label': '🏥 عيادة / منشأة صحية (Healthcare)', 'value': 'healthcare'},
    {'label': '🚌 شركة نقل ومواصلات (Transportation)', 'value': 'transportation'},
    {'label': '⚡ مرفق طاقة وخدمات (Utilities)', 'value': 'utilities'},
    {'label': '🎓 مركز تعليمي (Education)', 'value': 'education'},
    {'label': '🏢 خدمة حكومية (Governance)', 'value': 'governance'},
    {'label': '🛡️ مركز أمان وسلامة (Safety)', 'value': 'safety'},
    {'label': '☕ سياحة وترفيه (Tourism)', 'value': 'tourism'},
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final success = await ApiService.createVendor(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      businessName: _businessNameController.text.trim(),
      businessType: _selectedType,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء وتسجيل التاجر سحابياً بنجاح! 🚀'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فشل إنشاء التاجر، تأكد من اتصال السيرفر.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: const Text('تسجيل تاجر / منشأة جديدة'),
        backgroundColor: const Color(0xFF1C2541),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _businessNameController,
                label: 'اسم المتجر أو المنشأة',
                icon: Icons.store,
                validator: (v) => v!.isEmpty ? 'الرجاء إدخال اسم المتجر' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _usernameController,
                label: 'اسم المستخدم (المالك)',
                icon: Icons.person,
                validator: (v) => v!.isEmpty ? 'الرجاء إدخال اسم المستخدم' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'البريد الإلكتروني',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => !v!.contains('@') ? 'الرجاء إدخال بريد صالح' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                label: 'كلمة المرور',
                icon: Icons.lock,
                obscureText: true,
                validator: (v) => v!.length < 6 ? 'كلمة المرور لا تقل عن 6 أحرف' : null,
              ),
              const SizedBox(height: 20),
              // Dropdown لقطاع النشاط
              DropdownButtonFormField<String>(
                value: _selectedType,
                dropdownColor: const Color(0xFF1C2541),
                decoration: InputDecoration(
                  labelText: 'قطاع النشاط الذكي',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.category, color: Color(0xFF48CAE4)),
                  filled: true,
                  fillColor: const Color(0xFF1C2541),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                style: const TextStyle(color: Colors.white),
                items: _types.map((t) {
                  return DropdownMenuItem(
                    value: t['value'],
                    child: Text(t['label']!),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedType = val!);
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06D6A0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : const Text(
                        'إرسال وحفظ في السيرفر السحابي',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B132B),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: const Color(0xFF48CAE4)),
        filled: true,
        fillColor: const Color(0xFF1C2541),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
      ),
    );
  }
}
