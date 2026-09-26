import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QrScannerScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const QrScannerScreen({super.key, required this.currentUser});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final TextEditingController _codeCtrl = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _scannedTicket;
  String? _errorMessage;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifyCode(String code) async {
    final cleanCode = code.trim();
    if (cleanCode.isEmpty) {
      setState(() {
        _errorMessage = 'يرجى إدخال أو مسح رمز التذكرة';
        _scannedTicket = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _scannedTicket = null;
    });

    final ticket = await ApiService.verifyTicket(cleanCode);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (ticket != null) {
          _scannedTicket = ticket;
          _errorMessage = null;
        } else {
          _errorMessage = 'التذكرة غير موجودة أو كود التحقق غير صالح';
        }
      });
    }
  }

  Future<void> _confirmRedeem() async {
    if (_scannedTicket == null) return;

    final qrPass = _scannedTicket!['qr_pass'].toString();
    setState(() => _isLoading = true);

    final ok = await ApiService.redeemTicket(qrPass);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (ok) {
          _scannedTicket!['status'] = 'REDEEMED';
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ تم تأكيد استلام الخدمة وإغلاق التذكرة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _getCategoryTitle(String cat) {
    switch (cat) {
      case 'BUS': return 'باص سفر';
      case 'CLINIC': return 'موعد طبي';
      case 'WATER': return 'وايت مياه';
      case 'RESTAURANT': return 'طلب مطعم';
      case 'STORE': return 'تثبيت سلعة';
      case 'QAT': return 'باقة قات';
      case 'HOTEL': return 'حجز فندقي';
      case 'CAR': return 'تأجير سيارة';
      case 'REALTY': return 'معاينة عقار';
      default: return 'خدمة موحدة';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _scannedTicket?['status']?.toString() ?? '';
    final isAlreadyRedeemed = status == 'REDEEMED';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text('التحقق ومسح التذاكر الرقمية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF06B6D4), width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 6)),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.5)),
                      ),
                      child: const Icon(Icons.qr_code_scanner, color: Color(0xFF06B6D4), size: 44),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'وجّه الكاميرا نحو كود تذكرة العميل',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'أو أدخل كود التذكرة يدوياً بالأسفل',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeCtrl,
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                    decoration: InputDecoration(
                      labelText: 'رمز التذكرة (QR Code)',
                      hintText: 'PASS-BUS-123456',
                      prefixIcon: const Icon(Icons.confirmation_number_outlined, color: Color(0xFF0F172A)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.black12)),
                    ),
                    onSubmitted: _verifyCode,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isLoading ? null : () => _verifyCode(_codeCtrl.text),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('فحص', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            if (_scannedTicket != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: isAlreadyRedeemed ? Colors.grey.shade300 : Colors.green.shade300, width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getCategoryTitle(_scannedTicket!['category'].toString()),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAlreadyRedeemed ? Colors.grey.shade100 : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isAlreadyRedeemed ? 'تم الاستلام مسبقاً' : 'تذكرة مؤكدة وسارية',
                            style: TextStyle(
                              color: isAlreadyRedeemed ? Colors.grey.shade700 : Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _scannedTicket!['business_name'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'كود التحقق: ${_scannedTicket!['qr_pass']}',
                      style: const TextStyle(color: Colors.blueGrey, fontSize: 12, letterSpacing: 1),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoColumn('المبلغ المطلوب', '${(_scannedTicket!['total_price'] as num).toInt()} ر.ي'),
                        _buildInfoColumn('رقم المواطن', _scannedTicket!['user_id'].toString()),
                        _buildInfoColumn('حالة الحجز', _scannedTicket!['status'].toString()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAlreadyRedeemed ? Colors.grey : Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: Icon(isAlreadyRedeemed ? Icons.check_circle : Icons.done_all),
                      label: Text(
                        isAlreadyRedeemed ? 'تم استلام الخدمة مسبقاً' : 'تأكيد تقديم الخدمة للعميل (Redeem)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      onPressed: isAlreadyRedeemed || _isLoading ? null : _confirmRedeem,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
      ],
    );
  }
}
