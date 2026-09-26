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

  // جلب كافة المنشآت والأنشطة للقطاعات الـ 9
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

  // جلب الكتالوج والسلع التابعة لمنشأة معينة
  static Future<List<Map<String, dynamic>>> fetchCatalogByBusiness(int businessId) async {
    Connection? connection;
    try {
      connection = await _getConnection();
      final result = await connection.execute(
        Sql.named('SELECT id, business_id, title, price, vip_discount_pct, shelf_id FROM catalog_services WHERE business_id = @id'),
        parameters: {'id': businessId},
      );

      return result.map((row) {
        return {
          'id': row[0],
          'business_id': row[1],
          'title': row[2],
          'price': row[3],
          'vip_discount_pct': row[4],
          'shelf_id': row[5],
        };
      }).toList();
    } catch (e) {
      return [];
    } finally {
      await connection?.close();
    }
  }

  // إضافة حجز وتذكرة QR مؤكدة
  static Future<bool> createBooking({
    required int userId,
    required int businessId,
    required String category,
    required double totalPrice,
    required String qrPass,
  }) async {
    Connection? connection;
    try {
      connection = await _getConnection();
      await connection.execute(
        Sql.named(
          'INSERT INTO service_bookings (user_id, business_id, category, total_price, qr_pass, status) '
          'VALUES (@userId, @businessId, @category, @totalPrice, @qrPass, @status)'
        ),
        parameters: {
          'userId': userId,
          'businessId': businessId,
          'category': category,
          'totalPrice': totalPrice,
          'qrPass': qrPass,
          'status': 'CONFIRMED',
        },
      );
      return true;
    } catch (e) {
      return false;
    } finally {
      await connection?.close();
    }
  }
}
