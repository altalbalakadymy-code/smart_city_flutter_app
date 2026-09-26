import 'dart:async';
import 'package:postgres/postgres.dart';
import '../core/api_config.dart';

class ApiService {
  static final List<Map<String, dynamic>> _inMemoryBusinesses = [
    {'id': 1, 'name': 'هايبر ماركت المدينة', 'type': 'STORE', 'phone': '771000001', 'details': 'حجز وتثبيت السلع للاستلام الذاتي قبل النفاد', 'price': 12000.0, 'rating': 4.9},
    {'id': 2, 'name': 'مطعم رويال فود', 'type': 'RESTAURANT', 'phone': '771000002', 'details': 'طلب وتجهيز الوجبات مسبقاً (Pre-order) بدون انتظار', 'price': 4500.0, 'rating': 4.8},
    {'id': 3, 'name': 'مركز الشفاء الطبي التخصصي', 'type': 'CLINIC', 'phone': '771000003', 'details': 'حجز مواعيد دقيقة (Time Slots) واستشارات تمهيدية', 'price': 8000.0, 'rating': 5.0},
    {'id': 4, 'name': 'شركة النورس للنقل البري', 'type': 'BUS', 'phone': '771000004', 'details': 'حجز مقاعد وإصدار تذاكر صعود رقمية مشفرة', 'price': 15000.0, 'rating': 4.7},
    {'id': 5, 'name': 'محطة وايتات مياه الكوثر', 'type': 'WATER', 'phone': '771000005', 'details': 'صهاريج مياه للشرب حسب الموقع الجغرافي وسعة الخزان', 'price': 18000.0, 'rating': 4.6},
    {'id': 6, 'name': 'سوق القات النموذجي التخصصي', 'type': 'QAT', 'phone': '771000006', 'details': 'مزارعون معتمدون وتثبيت باقات القات للاستلام اليدوي', 'price': 7000.0, 'rating': 4.9},
    {'id': 7, 'name': 'فندق الأفق الملكي', 'type': 'HOTEL', 'phone': '771000007', 'details': 'حجز الغرف والأجنحة الفندقية المؤكدة بكود رقمي', 'price': 25000.0, 'rating': 4.9},
    {'id': 8, 'name': 'شركة الصقر لتأجير السيارات', 'type': 'CAR', 'phone': '771000008', 'details': 'حجز سيارات سياحية وعائلية بموجب الوثائق الرسمية', 'price': 30000.0, 'rating': 4.8},
    {'id': 9, 'name': 'المستشار للعقارات والمنازل', 'type': 'REALTY', 'phone': '771000009', 'details': 'حجز مواعيد معاينة الشقق والفلل والتواصل مع المالك', 'price': 120000.0, 'rating': 4.7},
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
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'phone': phone,
      'role': role,
      'is_vip': false,
    };
  }

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
    return {
      'id': '101',
      'name': 'مستخدم المنصة',
      'phone': phone,
      'role': 'CLIENT',
      'is_vip': true,
    };
  }

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

  static Future<bool> addBusinessItem(Map<String, dynamic> item) async {
    _inMemoryBusinesses.insert(0, item);
    final conn = await _tryConnect();
    if (conn != null) {
      try {
        await conn.execute(
          Sql.named('INSERT INTO businesses (name, type, phone, is_active) VALUES (@name, @type, @phone, true)'),
          parameters: {
            'name': item['name'] ?? item['business_name'] ?? 'نشاط جديد',
            'type': item['type'] ?? item['category'] ?? 'STORE',
            'phone': item['phone'] ?? '770000000',
          },
        );
        await conn.close();
      } catch (_) {}
    }
    return true;
  }

  static Future<bool> checkServerHealth() async {
    final conn = await _tryConnect();
    if (conn != null) {
      await conn.close();
      return true;
    }
    return false;
  }

  // ===================== قطاع باصات النقل =====================
  static Future<List<Map<String, dynamic>>> fetchBusRoutes() async {
    final conn = await _tryConnect();
    if (conn != null) {
      try {
        await conn.execute('''
          CREATE TABLE IF NOT EXISTS bus_routes (
            id SERIAL PRIMARY KEY,
            route_name VARCHAR(100) NOT NULL,
            company_name VARCHAR(150) NOT NULL,
            departure_time VARCHAR(50) NOT NULL,
            price NUMERIC(10, 2) NOT NULL,
            bus_type VARCHAR(100) NOT NULL
          )
        ''');
        final res = await conn.execute(Sql.named('SELECT id, route_name, company_name, departure_time, price, bus_type FROM bus_routes ORDER BY id DESC'));
        await conn.close();
        if (res.isNotEmpty) {
          return res.map((r) => {
            'id': r[0],
            'route_name': r[1].toString(),
            'company_name': r[2].toString(),
            'departure_time': r[3].toString(),
            'price': (r[4] as num).toDouble(),
            'bus_type': r[5].toString(),
          }).toList();
        }
      } catch (_) {}
    }
    return [
      {'id': 1, 'route_name': 'صنعاء - عدن', 'company_name': 'شركة النورس للنقل الدولي VIP', 'departure_time': '07:30 صباحاً', 'price': 15000.0, 'bus_type': 'مرسيدس VIP ملكي'},
      {'id': 2, 'route_name': 'صنعاء - مأرب', 'company_name': 'سفريات البرق السريع', 'departure_time': '08:00 صباحاً', 'price': 12000.0, 'bus_type': 'حافلة حديثة مكيفة'},
      {'id': 3, 'route_name': 'صنعاء - المكلا', 'company_name': 'شركة الرويشان للنقل البري', 'departure_time': '06:00 صباحاً', 'price': 25000.0, 'bus_type': 'VIP درجة أولى'},
    ];
  }

  static Future<bool> addBusRoute({
    required String routeName,
    required String companyName,
    required String departureTime,
    required double price,
    required String busType,
  }) async {
    final conn = await _tryConnect();
    if (conn != null) {
      try {
        await conn.execute('''
          CREATE TABLE IF NOT EXISTS bus_routes (
            id SERIAL PRIMARY KEY,
            route_name VARCHAR(100) NOT NULL,
            company_name VARCHAR(150) NOT NULL,
            departure_time VARCHAR(50) NOT NULL,
            price NUMERIC(10, 2) NOT NULL,
            bus_type VARCHAR(100) NOT NULL
          )
        ''');
        await conn.execute(
          Sql.named('INSERT INTO bus_routes (route_name, company_name, departure_time, price, bus_type) VALUES (@route, @company, @time, @price, @type)'),
          parameters: {'route': routeName, 'company': companyName, 'time': departureTime, 'price': price, 'type': busType},
        );
        await conn.close();
        return true;
      } catch (_) {
        return false;
      }
    }
    return true;
  }

  // ===================== قطاع العيادات والأطباء =====================
  static Future<List<Map<String, dynamic>>> fetchDoctors() async {
    final conn = await _tryConnect();
    if (conn != null) {
      try {
        await conn.execute('''
          CREATE TABLE IF NOT EXISTS clinic_doctors (
            id SERIAL PRIMARY KEY,
            name VARCHAR(120) NOT NULL,
            specialty VARCHAR(100) NOT NULL,
            clinic_name VARCHAR(150) NOT NULL,
            consultation_fee NUMERIC(10, 2) NOT NULL,
            available_slots VARCHAR(255) NOT NULL,
            phone VARCHAR(50) NOT NULL
          )
        ''');
        final res = await conn.execute(Sql.named('SELECT id, name, specialty, clinic_name, consultation_fee, available_slots, phone FROM clinic_doctors ORDER BY id DESC'));
        await conn.close();
        if (res.isNotEmpty) {
          return res.map((r) => {
            'id': r[0],
            'name': r[1].toString(),
            'specialty': r[2].toString(),
            'clinic_name': r[3].toString(),
            'consultation_fee': (r[4] as num).toDouble(),
            'available_slots': r[5].toString().split(','),
            'phone': r[6]?.toString() ?? '770000000',
          }).toList();
        }
      } catch (_) {}
    }
    return [
      {'id': 1, 'name': 'د. أحمد شرف الدين', 'specialty': 'باطنية وقلب', 'clinic_name': 'مستشفى الشفاء التخصصي', 'consultation_fee': 8000.0, 'available_slots': ['04:00 م', '04:30 م', '05:00 م', '05:30 م'], 'phone': '771234567'},
      {'id': 2, 'name': 'د. سامية عبدالرحمن', 'specialty': 'طب وجراحة العيون', 'clinic_name': 'مركز النور للعيون', 'consultation_fee': 7000.0, 'available_slots': ['09:00 ص', '09:30 ص', '10:00 ص'], 'phone': '772223344'},
      {'id': 3, 'name': 'د. فيصل المعمري', 'specialty': 'جراحة العظام والمفاصل', 'clinic_name': 'المركز الاستشاري للعظام', 'consultation_fee': 9000.0, 'available_slots': ['05:00 م', '05:40 م', '06:20 م'], 'phone': '773334455'},
    ];
  }

  static Future<bool> addDoctor({
    required String name,
    required String specialty,
    required String clinicName,
    required double fee,
    required String slots,
    required String phone,
  }) async {
    final conn = await _tryConnect();
    if (conn != null) {
      try {
        await conn.execute('''
          CREATE TABLE IF NOT EXISTS clinic_doctors (
            id SERIAL PRIMARY KEY,
            name VARCHAR(120) NOT NULL,
            specialty VARCHAR(100) NOT NULL,
            clinic_name VARCHAR(150) NOT NULL,
            consultation_fee NUMERIC(10, 2) NOT NULL,
            available_slots VARCHAR(255) NOT NULL,
            phone VARCHAR(50) NOT NULL
          )
        ''');
        await conn.execute(
          Sql.named('INSERT INTO clinic_doctors (name, specialty, clinic_name, consultation_fee, available_slots, phone) VALUES (@name, @spec, @clinic, @fee, @slots, @phone)'),
          parameters: {'name': name, 'spec': specialty, 'clinic': clinicName, 'fee': fee, 'slots': slots, 'phone': phone},
        );
        await conn.close();
        return true;
      } catch (_) {
        return false;
      }
    }
    return true;
  }

  // ===================== قطاع وايتات مياه الشرب =====================
  static Future<List<Map<String, dynamic>>> fetchWaterTankers() async {
    final conn = await _tryConnect();
    if (conn != null) {
      try {
        await conn.execute('''
          CREATE TABLE IF NOT EXISTS water_tankers (
            id SERIAL PRIMARY KEY,
            driver_name VARCHAR(120) NOT NULL,
            station_name VARCHAR(150) NOT NULL,
            water_type VARCHAR(100) NOT NULL,
            capacity_liters INT NOT NULL,
            price NUMERIC(10, 2) NOT NULL,
            phone VARCHAR(50) NOT NULL,
            latitude NUMERIC(10, 6) NOT NULL,
            longitude NUMERIC(10, 6) NOT NULL
          )
        ''');
        final res = await conn.execute(Sql.named('SELECT id, driver_name, station_name, water_type, capacity_liters, price, phone, latitude, longitude FROM water_tankers ORDER BY id DESC'));
        await conn.close();
        if (res.isNotEmpty) {
          return res.map((r) => {
            'id': r[0],
            'driver_name': r[1].toString(),
            'station_name': r[2].toString(),
            'water_type': r[3].toString(),
            'capacity_liters': r[4] as int,
            'price': (r[5] as num).toDouble(),
            'phone': r[6]?.toString() ?? '770000000',
            'latitude': (r[7] as num).toDouble(),
            'longitude': (r[8] as num).toDouble(),
          }).toList();
        }
      } catch (_) {}
    }
    return [
      {'id': 1, 'driver_name': 'أبو صخر الماوري', 'station_name': 'محطة آبار حِدة العذبة', 'water_type': 'مياه شرب نقية مكررة', 'capacity_liters': 6000, 'price': 18000.0, 'phone': '775112233', 'latitude': 15.3400, 'longitude': 44.1800},
      {'id': 2, 'driver_name': 'عبدالكريم الصرابي', 'station_name': 'مشروع مياه الروضة النقي', 'water_type': 'مياه غيلية عذبة طبيعية', 'capacity_liters': 3000, 'price': 10000.0, 'phone': '774998877', 'latitude': 15.3900, 'longitude': 44.2100},
      {'id': 3, 'driver_name': 'صالح القحوم', 'station_name': 'مياه الكوثر الصافية', 'water_type': 'مياه شرب نقية مكررة', 'capacity_liters': 10000, 'price': 28000.0, 'phone': '771665544', 'latitude': 15.3600, 'longitude': 44.1950},
    ];
  }

  static Future<bool> addWaterTanker({
    required String driverName,
    required String stationName,
    required String waterType,
    required int capacity,
    required double price,
    required String phone,
    required double lat,
    required double lng,
  }) async {
    final conn = await _tryConnect();
    if (conn != null) {
      try {
        await conn.execute('''
          CREATE TABLE IF NOT EXISTS water_tankers (
            id SERIAL PRIMARY KEY,
            driver_name VARCHAR(120) NOT NULL,
            station_name VARCHAR(150) NOT NULL,
            water_type VARCHAR(100) NOT NULL,
            capacity_liters INT NOT NULL,
            price NUMERIC(10, 2) NOT NULL,
            phone VARCHAR(50) NOT NULL,
            latitude NUMERIC(10, 6) NOT NULL,
            longitude NUMERIC(10, 6) NOT NULL
          )
        ''');
        await conn.execute(
          Sql.named('INSERT INTO water_tankers (driver_name, station_name, water_type, capacity_liters, price, phone, latitude, longitude) VALUES (@driver, @station, @type, @cap, @price, @phone, @lat, @lng)'),
          parameters: {'driver': driverName, 'station': stationName, 'type': waterType, 'cap': capacity, 'price': price, 'phone': phone, 'lat': lat, 'lng': lng},
        );
        await conn.close();
        return true;
      } catch (_) {
        return false;
      }
    }
    return true;
  }

  // ===================== قطاع المطاعم وتجهيز الوجبات (Pre-order) =====================
  static Future<List<Map<String, dynamic>>> fetchRestaurantMeals() async {
    final conn = await _tryConnect();
    if (conn != null) {
      try {
        await conn.execute('''
          CREATE TABLE IF NOT EXISTS restaurant_meals (
            id SERIAL PRIMARY KEY,
            restaurant_name VARCHAR(150) NOT NULL,
            meal_title VARCHAR(150) NOT NULL,
            category VARCHAR(80) NOT NULL,
            price NUMERIC(10, 2) NOT NULL,
            prep_time_mins INT NOT NULL,
            phone VARCHAR(50) NOT NULL
          )
        ''');
        final res = await conn.execute(Sql.named('SELECT id, restaurant_name, meal_title, category, price, prep_time_mins, phone FROM restaurant_meals ORDER BY id DESC'));
        await conn.close();
        if (res.isNotEmpty) {
          return res.map((r) => {
            'id': r[0],
            'restaurant_name': r[1].toString(),
            'meal_title': r[2].toString(),
            'category': r[3].toString(),
            'price': (r[4] as num).toDouble(),
            'prep_time_mins': r[5] as int,
            'phone': r[6]?.toString() ?? '770000000',
          }).toList();
        }
      } catch (_) {}
    }
    return [
      {'id': 1, 'restaurant_name': 'مطعم الشيباني الملكي', 'meal_title': 'فحسة لحم بلدي مع الملوج الحار', 'category': 'شعبي يمني', 'price': 4500.0, 'prep_time_mins': 15, 'phone': '777111222'},
      {'id': 2, 'restaurant_name': 'مطاعم الخطيب السياحية', 'meal_title': 'نصف حبة مندي لحم مع الرز البسمتي', 'category': 'مشويات ومندي', 'price': 6500.0, 'prep_time_mins': 20, 'phone': '777333444'},
      {'id': 3, 'restaurant_name': 'برجر ستيشن الذكي', 'meal_title': 'وجبة دبل برجر أنجوس مع البطاطس المقرمشة', 'category': 'وجبات سريعة', 'price': 3800.0, 'prep_time_mins': 12, 'phone': '777555666'},
    ];
  }

  static Future<bool> addRestaurantMeal({
    required String restaurantName,
    required String mealTitle,
    required String category,
    required double price,
    required int prepTime,
    required String phone,
  }) async {
    final conn = await _tryConnect();
    if (conn != null) {
      try {
        await conn.execute('''
          CREATE TABLE IF NOT EXISTS restaurant_meals (
            id SERIAL PRIMARY KEY,
            restaurant_name VARCHAR(150) NOT NULL,
            meal_title VARCHAR(150) NOT NULL,
            category VARCHAR(80) NOT NULL,
            price NUMERIC(10, 2) NOT NULL,
            prep_time_mins INT NOT NULL,
            phone VARCHAR(50) NOT NULL
          )
        ''');
        await conn.execute(
          Sql.named('INSERT INTO restaurant_meals (restaurant_name, meal_title, category, price, prep_time_mins, phone) VALUES (@rest, @meal, @cat, @price, @time, @phone)'),
          parameters: {'rest': restaurantName, 'meal': mealTitle, 'cat': category, 'price': price, 'time': prepTime, 'phone': phone},
        );
        await conn.close();
        return true;
      } catch (_) {
        return false;
      }
    }
    return true;
  }

  // ===================== قطاع المتاجر الشاملة =====================
  static Future<List<Map<String, dynamic>>> fetchRetailProducts() async {
    final conn = await _tryConnect();
    if (conn != null) {
      try {
        await conn.execute('''
          CREATE TABLE IF NOT EXISTS retail_products (
            id SERIAL PRIMARY KEY,
            store_name VARCHAR(150) NOT NULL,
            store_category VARCHAR(100) NOT NULL,
            product_title VARCHAR(150) NOT NULL,
            description TEXT NOT NULL DEFAULT '',
            image_url TEXT NOT NULL DEFAULT '',
            price NUMERIC(10, 2) NOT NULL,
            stock_quantity INT NOT NULL,
            hold_hours INT NOT NULL,
            phone VARCHAR(50) NOT NULL
          )
        ''');
        final res = await conn.execute(Sql.named('SELECT id, store_name, store_category, product_title, description, image_url, price, stock_quantity, hold_hours, phone FROM retail_products ORDER BY id DESC'));
        await conn.close();
        if (res.isNotEmpty) {
          return res.map((r) => {
            'id': r[0],
            'store_name': r[1].toString(),
            'store_category': r[2].toString(),
            'product_title': r[3].toString(),
            'description': r[4].toString(),
            'image_url': r[5].toString(),
            'price': (r[6] as num).toDouble(),
            'stock_quantity': r[7] as int,
            'hold_hours': r[8] as int,
            'phone': r[9]?.toString() ?? '770000000',
          }).toList();
        }
      } catch (_) {}
    }
    return [
      {'id': 1, 'store_name': 'عالم الإلكترونيات الذكي', 'store_category': 'إلكترونيات وهواتف', 'product_title': 'هاتف سامسونج الترا 256 جيجا', 'description': 'نسخة الشرق الأوسط شريحتين مع ضمان سنة كاملة وشاحن سريع أصلي.', 'image_url': 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=500&q=80', 'price': 480000.0, 'stock_quantity': 4, 'hold_hours': 24, 'phone': '771122334'},
      {'id': 2, 'store_name': 'بوتيك الأناقة الراقية', 'store_category': 'ملابس وموضة', 'product_title': 'بدلة رسمية كلاسيكية رجالي', 'description': 'قماش صوف إيطالي فاخر متوفر بمقاسات متعددة مناسبة للمناسبات الرسمية.', 'image_url': 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=500&q=80', 'price': 35000.0, 'stock_quantity': 8, 'hold_hours': 48, 'phone': '772233445'},
    ];
  }

  static Future<bool> addRetailProduct({
    required String storeName,
    required String storeCategory,
    required String productTitle,
    required String description,
    required String imageUrl,
    required double price,
    required int stock,
    required int holdHours,
    required String phone,
  }) async {
    final conn = await _tryConnect();
    if (conn != null) {
      try {
        await conn.execute('''
          CREATE TABLE IF NOT EXISTS retail_products (
            id SERIAL PRIMARY KEY,
            store_name VARCHAR(150) NOT NULL,
            store_category VARCHAR(100) NOT NULL,
            product_title VARCHAR(150) NOT NULL,
            description TEXT NOT NULL DEFAULT '',
            image_url TEXT NOT NULL DEFAULT '',
            price NUMERIC(10, 2) NOT NULL,
            stock_quantity INT NOT NULL,
            hold_hours INT NOT NULL,
            phone VARCHAR(50) NOT NULL
          )
        ''');
        await conn.execute(
          Sql.named('INSERT INTO retail_products (store_name, store_category, product_title, description, image_url, price, stock_quantity, hold_hours, phone) VALUES (@store, @cat, @title, @desc, @img, @price, @stock, @hours, @phone)'),
          parameters: {'store': storeName, 'cat': storeCategory, 'title': productTitle, 'desc': description, 'img': imageUrl, 'price': price, 'stock': stock, 'hours': holdHours, 'phone': phone},
        );
        await conn.close();
        return true;
      } catch (_) {
        return false;
      }
    }
    return true;
  }

  // ===================== قطاع أسواق القات والمقاوته =====================
  static Future<List<Map<String, dynamic>>> fetchQatMarkets() async {
    final conn = await _tryConnect();
    if (conn != null) {
      try {
        await conn.execute('''
          CREATE TABLE IF NOT EXISTS qat_vendors_lots (
            id SERIAL PRIMARY KEY,
            market_name VARCHAR(150) NOT NULL,
            vendor_name VARCHAR(150) NOT NULL,
            stall_number VARCHAR(50) NOT NULL,
            qat_type VARCHAR(100) NOT NULL,
            description TEXT NOT NULL DEFAULT '',
            image_url TEXT NOT NULL DEFAULT '',
            price NUMERIC(10, 2) NOT NULL,
            available_bundles INT NOT NULL,
            phone VARCHAR(50) NOT NULL
          )
        ''');
        final res = await conn.execute(Sql.named('SELECT id, market_name, vendor_name, stall_number, qat_type, description, image_url, price, available_bundles, phone FROM qat_vendors_lots ORDER BY id DESC'));
        await conn.close();
        if (res.isNotEmpty) {
          return res.map((r) => {
            'id': r[0],
            'market_name': r[1].toString(),
            'vendor_name': r[2].toString(),
            'stall_number': r[3].toString(),
            'qat_type': r[4].toString(),
            'description': r[5].toString(),
            'image_url': r[6].toString(),
            'price': (r[7] as num).toDouble(),
            'available_bundles': r[8] as int,
            'phone': r[9]?.toString() ?? '770000000',
          }).toList();
        }
      } catch (_) {}
    }
    return [
      {
        'id': 1,
        'market_name': 'سوق مذبح المركزي النموذجي',
        'vendor_name': 'أبو عادل الهمداني',
        'stall_number': 'بسطة 14 - الجناح الشرقي',
        'qat_type': 'همداني غيلي سوبر',
        'description': 'قطفة فجر اليوم، رطب صافي ورأس حبة ناعم جداً مروي ماء بئر عذب.',
        'image_url': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80',
        'price': 12000.0,
        'available_bundles': 5,
        'phone': '771444555',
      },
      {
        'id': 2,
        'market_name': 'سوق مذبح المركزي النموذجي',
        'vendor_name': 'الحاج مصلح الصبري',
        'stall_number': 'بسطة 22 - مدخل السوق الرئيسي',
        'qat_type': 'صبري ممتاز رطب',
        'description': 'باقة صبري بلدي درجة أولى حبة خضراء حالية خالية من أي رش.',
        'image_url': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500&q=80',
        'price': 8000.0,
        'available_bundles': 8,
        'phone': '772555666',
      },
      {
        'id': 3,
        'market_name': 'سوق شميلة الموحد',
        'vendor_name': 'عبدالرحمن الأرحبي',
        'stall_number': 'موقع 7 - الممر الأوسط',
        'qat_type': 'أرحبي ذيباني مختار',
        'description': 'قات أرحبي نخب أول قاع البئر، حبة ثقيلة تعميرة ممتازة.',
        'image_url': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&q=80',
        'price': 15000.0,
        'available_bundles': 4,
        'phone': '773666777',
      },
      {
        'id': 4,
        'market_name': 'سوق السنينة النموذجي',
        'vendor_name': 'جميل الحرازي',
        'stall_number': 'ركن 3 - جوار الإدارة',
        'qat_type': 'حرازي فاخر قطفة ندى',
        'description': 'قطفة مبكرة حبة رطبة خفيفة ومذاق نقي جداً، تثبيت فوري للاستلام.',
        'image_url': 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=500&q=80',
        'price': 9500.0,
        'available_bundles': 6,
        'phone': '774777888',
      },
    ];
  }

  static Future<bool> addQatVendorLot({
    required String marketName,
    required String vendorName,
    required String stallNumber,
    required String qatType,
    required String description,
    required String imageUrl,
    required double price,
    required int bundles,
    required String phone,
  }) async {
    final conn = await _tryConnect();
    if (conn != null) {
      try {
        await conn.execute('''
          CREATE TABLE IF NOT EXISTS qat_vendors_lots (
            id SERIAL PRIMARY KEY,
            market_name VARCHAR(150) NOT NULL,
            vendor_name VARCHAR(150) NOT NULL,
            stall_number VARCHAR(50) NOT NULL,
            qat_type VARCHAR(100) NOT NULL,
            description TEXT NOT NULL DEFAULT '',
            image_url TEXT NOT NULL DEFAULT '',
            price NUMERIC(10, 2) NOT NULL,
            available_bundles INT NOT NULL,
            phone VARCHAR(50) NOT NULL
          )
        ''');
        await conn.execute(
          Sql.named(
            'INSERT INTO qat_vendors_lots (market_name, vendor_name, stall_number, qat_type, description, image_url, price, available_bundles, phone) '
            'VALUES (@mkt, @ven, @stl, @type, @desc, @img, @price, @bnd, @phone)'
          ),
          parameters: {
            'mkt': marketName,
            'ven': vendorName,
            'stl': stallNumber,
            'type': qatType,
            'desc': description,
            'img': imageUrl,
            'price': price,
            'bnd': bundles,
            'phone': phone,
          },
        );
        await conn.close();
        return true;
      } catch (_) {
        return false;
      }
    }
    return true;
  }
}
