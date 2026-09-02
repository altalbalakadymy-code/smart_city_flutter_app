import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/business_model.dart';

class ApiService {
  // فحص حالة السيرفر السحابي
  static Future<Map<String, dynamic>> checkServerHealth() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.healthCheck)).timeout(
        const Duration(seconds: 10),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'isOnline': data['status'] == 'online',
          'message': data['system'] ?? 'السيرفر متصل بنجاح',
          'statusCode': response.statusCode,
        };
      }
      return {'isOnline': false, 'message': 'كود الاستجابة: ${response.statusCode}'};
    } catch (e) {
      return {'isOnline': false, 'message': 'تعذر الاتصال بالسيرفر: $e'};
    }
  }

  // جلب قائمة الأنشطة والمتاجر المسجلة
  static Future<List<BusinessModel>> fetchBusinesses() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.businessesList)).timeout(
        const Duration(seconds: 10),
      );
      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded.map((item) => BusinessModel.fromJson(item)).toList();
        } else if (decoded is Map && decoded.containsKey('businesses')) {
          final List list = decoded['businesses'];
          return list.map((item) => BusinessModel.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // إنشاء تاجر أو نشاط تجاري جديد
  static Future<bool> createVendor({
    required String username,
    required String email,
    required String password,
    required String businessName,
    required String businessType,
  }) async {
    try {
      final body = jsonEncode({
        "username": username,
        "email": email,
        "password": password,
        "business_name": businessName,
        "business_type": businessType,
      });

      final response = await http.post(
        Uri.parse(ApiConfig.createVendor),
        headers: {"Content-Type": "application/json"},
        body: body,
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
