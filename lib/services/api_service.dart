import 'package:postgres/postgres.dart';
import '../core/api_config.dart';

class ApiService {
  static Future<Connection> _getConnection() async {
    final endpoint = Endpoint(
      host: ApiConfig.dbHost,
      port: ApiConfig.dbPort,
      database: ApiConfig.dbName,
      username: ApiConfig.dbUsername,
      password: ApiConfig.dbPassword,
    );

    return await Connection.open(
      endpoint,
      settings: const ConnectionSettings(sslMode: SslMode.require),
    );
  }

  // تسجيل مستخدم جديد
  static Future<Map<String, dynamic>?> registerUser({
    required String name,
    required String phone,
    required String role,
  }) async {
    Connection? conn;
    try {
      conn = await _getConnection();
      final result = await conn.execute(
        Sql.named(
          'INSERT INTO users (name, phone, role, is_vip) '
          'VALUES (@name, @phone, @role, false) '
          'RETURNING id, name, phone, role, is_vip'
        ),
        parameters: {'name': name, 'phone': phone, 'role': role},
      );
      if (result.isNotEmpty) {
        final row = result.first;
        return {
          'id': row[0].toString(),
          'name': row[1].toString(),
          'phone': row[2].toString(),
          'role': row[3].toString(),
          'is_vip': row[4] as bool,
        };
      }
      return null;
    } catch (e) {
      return null;
    } finally {
      await conn?.close();
    }
  }

  // تسجيل الدخول بواسطة الهاتف
  static Future<Map<String, dynamic>?> loginUser(String phone) async {
    Connection? conn;
    try {
      conn = await _getConnection();
      final result = await conn.execute(
        Sql.named('SELECT id, name, phone, role, is_vip FROM users WHERE phone = @phone'),
        parameters: {'phone': phone},
      );
      if (result.isNotEmpty) {
        final row = result.first;
        return {
          'id': row[0].toString(),
          'name': row[1].toString(),
          'phone': row[2].toString(),
          'role': row[3].toString(),
          'is_vip': row[4] as bool,
        };
      }
      return null;
    } catch (e) {
      return null;
    } finally {
      await conn?.close();
    }
  }

  // إضافة منشأة جديدة
  static Future<bool> addBusiness({
    required String name,
    required String type,
    required String phone,
    required double monthlyFee,
  }) async {
    Connection? conn;
    try {
      conn = await _getConnection();
      await conn.execute(
        Sql.named(
          'INSERT INTO businesses (name, type, phone, latitude, longitude, is_active, monthly_fee) '
          'VALUES (@name, @type, @phone, 15.3694, 44.1910, true, @fee)'
        ),
        parameters: {
          'name': name,
          'type': type,
          'phone': phone,
          'fee': monthlyFee,
        },
      );
      return true;
    } catch (e) {
      return false;
    } finally {
      await conn?.close();
    }
  }

  // جلب كافة المنشآت
  static Future<List<Map<String, dynamic>>> fetchBusinesses() async {
    Connection? conn;
    try {
      conn = await _getConnection();
      final result = await conn.execute(
        Sql.named('SELECT id, name, type, phone, is_active, monthly_fee FROM businesses WHERE is_active = true ORDER BY id DESC')
      );
      return result.map((row) {
        return {
          'id': row[0],
          'name': row[1],
          'type': row[2],
          'phone': row[3],
          'is_active': row[4],
          'monthly_fee': row[5],
        };
      }).toList();
    } catch (e) {
      return [];
    } finally {
      await conn?.close();
    }
  }

  static Future<bool> checkServerHealth() async {
    try {
      final conn = await _getConnection();
      await conn.close();
      return true;
    } catch (e) {
      return false;
    }
  }
}
