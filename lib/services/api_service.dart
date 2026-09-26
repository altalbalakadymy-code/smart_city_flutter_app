import 'dart:convert';
import 'package:http/http.dart' as http;
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

  // فحص حالة السيرفر التي تطلبها home_screen
  static Future<bool> checkServerHealth() async {
    try {
      final conn = await _getConnection();
      await conn.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  // إضافة بائع جديد التي تطلبها create_vendor_screen
  static Future<bool> createVendor(Map<String, dynamic> vendorData) async {
    Connection? connection;
    try {
      connection = await _getConnection();
      await connection.execute(
        Sql.named(
          'INSERT INTO businesses (name, type, phone, is_active) '
          'VALUES (@name, @type, @phone, true)'
        ),
        parameters: {
          'name': vendorData['name'] ?? 'متجر جديد',
          'type': vendorData['category'] ?? vendorData['type'] ?? 'STORE',
          'phone': vendorData['phone'] ?? '',
        },
      );
      return true;
    } catch (e) {
      return false;
    } finally {
      await connection?.close();
    }
  }

  // جلب كافة المنشآت
  static Future<List<Map<String, dynamic>>> fetchBusinesses() async {
    Connection? connection;
    try {
      connection = await _getConnection();
      final result = await connection.execute(
        Sql.named('SELECT id, owner_id, name, type, phone, latitude, longitude, is_active, monthly_fee FROM businesses WHERE is_active = true')
      );
      
      return result.map((row) {
        return {
          'id': row[0],
          'owner_id': row[1],
          'name': row[2],
          'type': row[3],
          'phone': row[4],
          'latitude': row[5],
          'longitude': row[6],
          'is_active': row[7],
          'monthly_fee': row[8],
        };
      }).toList();
    } catch (e) {
      return [];
    } finally {
      await connection?.close();
    }
  }
}
