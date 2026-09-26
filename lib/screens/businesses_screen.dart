import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BusinessesScreen extends StatefulWidget {
  const BusinessesScreen({super.key});

  @override
  State<BusinessesScreen> createState() => _BusinessesScreenState();
}

class _BusinessesScreenState extends State<BusinessesScreen> {
  late Future<List<Map<String, dynamic>>> _businessesFuture;

  @override
  void initState() {
    super.initState();
    _businessesFuture = ApiService.fetchBusinesses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المنشآت والخدمات الذكية'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _businessesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('لا توجد منشآت نشطة حالياً أو تعذر الاتصال بالسيرفر'),
            );
          }

          final businesses = snapshot.data!;

          return ListView.builder(
            itemCount: businesses.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final item = businesses[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: Icon(
                      _getCategoryIcon(item['type']),
                      color: Colors.teal.shade800,
                    ),
                  ),
                  title: Text(
                    item['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('القطاع: ${item['type']} | هاتف: ${item['phone'] ?? 'غير متوفر'}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم اختيار: ${item['name']}')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String? type) {
    switch (type) {
      case 'CLINIC':
        return Icons.medical_services;
      case 'WATER':
        return Icons.water_drop;
      case 'BUS':
        return Icons.directions_bus;
      case 'STORE':
        return Icons.store;
      case 'RESTAURANT':
        return Icons.restaurant;
      case 'HOTEL':
        return Icons.hotel;
      case 'CAR':
        return Icons.directions_car;
      case 'REALTY':
        return Icons.home_work;
      case 'QAT':
        return Icons.eco;
      default:
        return Icons.business;
    }
  }
}
