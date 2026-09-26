  // جلب كافة مسارات الباصات من السيرفر
  static Future<List<Map<String, dynamic>>> fetchBusRoutes() async {
    final conn = await _tryConnect();
    if (conn != null) {
      try {
        final res = await conn.execute(
          Sql.named('SELECT id, route_name, company_name, departure_time, price, bus_type FROM bus_routes ORDER BY id DESC'),
        );
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
    // مسارات احتياطية في حال تعذر الاتصال اللحظي
    return [
      {
        'id': 1,
        'route_name': 'صنعاء - عدن',
        'company_name': 'شركة النورس للنقل الدولي VIP',
        'departure_time': '07:30 صباحاً',
        'price': 15000.0,
        'bus_type': 'مرسيدس VIP ملكي',
      },
      {
        'id': 2,
        'route_name': 'صنعاء - مأرب',
        'company_name': 'سفريات البرق السريع',
        'departure_time': '08:00 صباحاً',
        'price': 12000.0,
        'bus_type': 'حافلة حديثة مكيفة',
      },
      {
        'id': 3,
        'route_name': 'صنعاء - المكلا',
        'company_name': 'شركة الرويشان للنقل البري',
        'departure_time': '06:00 صباحاً',
        'price': 25000.0,
        'bus_type': 'VIP درجة أولى',
      },
    ];
  }

  // إضافة مسار رحلة جديد وحفظه في السيرفر
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
        // إنشاء الجدول تلقائياً إن لم يكن موجوداً
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
          Sql.named(
            'INSERT INTO bus_routes (route_name, company_name, departure_time, price, bus_type) '
            'VALUES (@route, @company, @time, @price, @type)'
          ),
          parameters: {
            'route': routeName,
            'company': companyName,
            'time': departureTime,
            'price': price,
            'type': busType,
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
