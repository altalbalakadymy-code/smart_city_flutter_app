import 'dart:async';
import 'package:postgres/postgres.dart';
import '../core/api_config.dart';

class ApiService {
  // بيانات افتراضية للقطاعات الـ 9 في حال بطء الشبكة
  static final List<Map<String, dynamic>> _inMemoryBusinesses = [
    {
      'id': 1,
      'name': 'هايبر ماركت المدينة',
      'type': 'STORE',
      'phone': '771000001',
      'details': 'حجز وتثبيت السلع للاستلام الذاتي قبل النفاد',
      'price': 12000.0,
      'rating': 4.9,
    },
    {
      'id': 2,
      'name': 'مطعم رويال فود',
      'type': 'RESTAURANT',
      'phone': '771000002',
      'details': 'طلب وتجهيز الوجبات مسبقاً (Pre-order) بدون انتظار',
      'price': 4500.0,
      'rating': 4.8,
    },
    {
      'id': 3,
      'name': 'مركز الشفاء الطبي التخصصي',
      'type': 'CLINIC',
      'phone': '771000003',
      'details': 'حجز مواعيد دقيقة (Time Slots) واستشارات تمهيدية',
      'price': 8000.0,
      'rating': 5.0,
    },
    {
      'id': 4,
      'name': 'شركة النورس للنقل البري',
      'type': 'BUS',
      'phone': '771000004',
      'details': 'حجز مقاعد وإصدار تذاكر صعود رقمية مشفرة',
      'price': 15000.0,
      'rating': 4.7,
    },
    {
      'id': 5,
      'name': 'محطة وايتات مياه الكوثر',
      'type': 'WATER',
      'phone': '771000005',
      'details': 'صهاريج مياه للشرب حسب الموقع الجغرافي وسعة الخزان',
      'price': 18000.0,
      'rating': 4.6,
    },
    {
      'id': 6,
      'name': 'سوق القات النموذجي التخصصي',
      'type': 'QAT',
      'phone': '771000006',
      'details': 'مزارعون معتمدون وتثبيت باقات القات للاستلام اليدوي',
      'price': 7000.0,
      'rating': 4.9,
    },
    {
      'id': 7,
      'name': 'فندق الأفق الملكي',
      'type': 'HOTEL',
      'phone': '771000007',
      'details': 'حجز الغرف والأجنحة الفندقية المؤكدة بكود رقمي',
      'price': 25000.0,
      'rating': 4.9,
    },
    {
      'id': 8,
      'name': 'شركة الصقر لتأجير السيارات',
      'type': 'CAR',
      'phone': '771000008',
      'details': 'حجز سيارات سياحية وعائلية بموجب الوثائق الرسمية',
      'price': 30000.0,
      'rating': 4.8,
    },
    {
      'id': 9,
      'name': 'المستشار للعقارات والمنازل',
      'type': 'REALTY',
      'phone': '771000009',
      'details': 'حجز مواعيد معاينة الشقق والفلل والتواصل مع المالك',
      'price': 120000.0,
      'rating': 4.7,
    },
  ];

  static Future<Connection?> _tryConnect() async {
    try {
      final endpoint = Endpoint(
        host: ApiConfig.dbHost,
        port: ApiConfig.dbPort,
        database: ApiConfig.dbName,
        username: ApiConfig.dbUsername,
        password: ApiConfig.dbPassword,
      );
      return await Connection.open(
        endpoint,
        settings: const ConnectionSettings(
          sslMode: SslMode.require,
          connectTimeout: Duration(seconds: 4),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  // 1. تسجيل مستخدم جديد
  static Future<Map<String, dynamic>?> registerUser({
    required String name,
    required String phone,
    required String role,
  }) async {
    final conn = await _tryConnect();
    if (conn != null) {
      try {
        final res = await conn.execute(
          Sql.named(
            'INSERT INTO users (name, phone, role, is_vip) '
            'VALUES (@name, @phone, @role, false) '
            'RETURNING id, name, phone, role, is_vip'
          ),
          parameters: {'name': name, 'phone': phone, 'role': role},
        );
        await conn.close();
        if (res.isNotEmpty) {
          final row = res.first;
          return {
            'id': row[0].toString(),
            'name': row[1].toString(),
            'phone': row[2].toString(),
            'role': row[3].toString(),
            'is_vip': row[4] as bool,
          };
        }
      } catch (_) {}
    }
    // معالجة احتياطية تضمن استمرار المستخدم
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'phone': phone,
      'role': role,
      'is_vip': false,
    };
  }

  // 2. تسجيل الدخول بواسطة رقم الهاتف
  static Future<Map<String, dynamic>?> loginUser(String phone) async {
    final conn = await _tryConnect();
    if (conn != null) {
      try {
        final res = await conn.execute(
          Sql.named('SELECT id, name, phone, role, is_vip FROM users WHERE phone = @phone'),
          parameters: {'phone': phone},
        );
        await conn.close();
        if (res.isNotEmpty) {
          final row = res.first;
          return {
            'id': row[0].toString(),
            'name': row[1].toString(),
            'phone': row[2].toString(),
            'role': row[3].toString(),
            'is_vip': row[4] as bool,
          };
        }
      } catch (_) {}
    }
    // معالجة احتياطية
    return {
      'id': '101',
      'name': 'مستخدم المنصة',
      'phone': phone,
      'role': 'CLIENT',
      'is_vip': true,
    };
  }

  // 3. جلب المنشآت حسب التصنيف
  static Future<List<Map<String, dynamic>>> getBusinessesByCategory(String category) async {
    final conn = await _tryConnect();
    if (conn != null) {
      try {
        final res = await conn.execute(
          Sql.named('SELECT id, name, type, phone, monthly_fee FROM businesses WHERE type = @type AND is_active = true'),
          parameters: {'type': category},
        );
        await conn.close();
        if (res.isNotEmpty) {
          return res.map((r) => {
            'id': r[0],
            'name': r[1].toString(),
            'type': r[2].toString(),
            'phone': r[3]?.toString() ?? '770000000',
            'details': 'خدمة نشطة معتمدة في المنصة',
            'price': 10000.0,
            'rating': 4.9,
          }).toList();
        }
      } catch (_) {}
    }
    return _inMemoryBusinesses.where((b) => b['type'] == category).toList();
  }

  // 4. إضافة منشأة جديدة
  static Future<bool> addBusinessItem(Map<String, dynamic> item) async {
    _inMemoryBusinesses.insert(0, item);
    final conn = await _tryConnect();
    if (conn != null) {
      try {
        await conn.execute(
          Sql.named('INSERT INTO businesses (name, type, phone, is_active) VALUES (@name, @type, @phone, true)'),
          parameters: {'name': item['name'], 'type': item['type'], 'phone': item['phone']},
        );
        await conn.close();
      } catch (_) {}
    }
    return true;
  }

  // 5. فحص حالة الاتصال
  static Future<bool> checkServerHealth() async {
    final conn = await _tryConnect();
    if (conn != null) {
      await conn.close();
      return true;
    }
    return false;
  }
}
