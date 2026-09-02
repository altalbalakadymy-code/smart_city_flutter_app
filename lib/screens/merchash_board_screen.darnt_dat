import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MerchantDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> merchantUser;

  const MerchantDashboardScreen({super.key, required this.merchantUser});

  @override
  State<MerchantDashboardScreen> createState() => _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen> {
  final String _baseUrl = "https://smartcitybackend-production-9d26.up.railway.app";
  List<dynamic> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    final bId = widget.merchantUser['business_id'];
    if (bId == null) {
      setState(() => isLoading = false);
      return;
    }

    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse("$_baseUrl/api/v1/merchant/items/$bId"));
      if (res.statusCode == 200) {
        setState(() {
          items = jsonDecode(res.body);
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  void _showAddItemDialog() {
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final imageCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String itemType = 'product';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDState) => AlertDialog(
          backgroundColor: const Color(0xFF1C2541),
          title: const Text('إضافة منتج أو خدمة جديدة', style: TextStyle(color: Color(0xFF00F5D4), fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: itemType,
                  dropdownColor: const Color(0xFF1C2541),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'النوع',
                    labelStyle: const TextStyle(color: Colors.white60),
                    filled: true,
                    fillColor: const Color(0xFF0B132B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'product', child: Text('منتج / سلعة')),
                    DropdownMenuItem(value: 'service', child: Text('خدمة تخصصية')),
                  ],
                  onChanged: (v) {
                    if (v != null) setDState(() => itemType = v);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: itemType == 'product' ? 'اسم المنتج' : 'اسم الخدمة',
                    labelStyle: const TextStyle(color: Colors.white60),
                    filled: true,
                    fillColor: const Color(0xFF0B132B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'السعر (\$)',
                    labelStyle: const TextStyle(color: Colors.white60),
                    filled: true,
                    fillColor: const Color(0xFF0B132B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'رابط صورة المنتج (URL)',
                    hintText: 'https://example.com/item.png',
                    hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
                    labelStyle: const TextStyle(color: Colors.white60),
                    filled: true,
                    fillColor: const Color(0xFF0B132B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'وصف ومميزات العنصر',
                    labelStyle: const TextStyle(color: Colors.white60),
                    filled: true,
                    fillColor: const Color(0xFF0B132B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F5D4)),
              onPressed: () async {
                final title = titleCtrl.text.trim();
                final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                if (title.isEmpty) return;
                Navigator.pop(ctx);

                await http.post(
                  Uri.parse("$_baseUrl/api/v1/merchant/items"),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "business_id": widget.merchantUser['business_id'],
                    "title": title,
                    "item_type": itemType,
                    "price": price,
                    "image_url": imageCtrl.text.trim(),
                    "description": descCtrl.text.trim(),
                  }),
                );
                _fetchItems();
              },
              child: const Text('نشر في المتجر', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteItem(int id) async {
    await http.delete(Uri.parse("$_baseUrl/api/v1/merchant/items/$id"));
    _fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    final businessName = widget.merchantUser['business_name'] ?? 'متجري الذكي';

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        title: Text('لوحة تحكم: $businessName'),
        backgroundColor: const Color(0xFF1C2541),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchItems,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00F5D4),
        onPressed: _showAddItemDialog,
        icon: const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF0B132B)),
        label: const Text('إضافة منتج / خدمة', style: TextStyle(color: Color(0xFF0B132B), fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00F5D4)))
          : items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 70, color: Colors.white.withOpacity(0.3)),
                      const SizedBox(height: 12),
                      const Text('لم تقم بإضافة أي منتجات أو خدمات بعد', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      const Text('اضغط على الزر بالأسفل لإضافة أول عنصر في متجرك', style: TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final itm = items[i];
                    final isService = itm['item_type'] == 'service';
                    final hasImage = (itm['image_url'] != null && itm['image_url'].toString().startsWith('http'));

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2541),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: (isService ? const Color(0xFF8338EC) : const Color(0xFF00F5D4)).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: hasImage
                                ? Image.network(
                                    itm['image_url'],
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 70,
                                      height: 70,
                                      color: const Color(0xFF0B132B),
                                      child: Icon(isService ? Icons.design_services : Icons.shopping_bag, color: Colors.white54),
                                    ),
                                  )
                                : Container(
                                    width: 70,
                                    height: 70,
                                    color: const Color(0xFF0B132B),
                                    child: Icon(isService ? Icons.design_services : Icons.shopping_bag, color: Colors.white54),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  itm['title'] ?? '',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  itm['description'] ?? '',
                                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (isService ? const Color(0xFF8338EC) : const Color(0xFF00F5D4)).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isService ? 'خدمة' : 'منتج',
                                        style: TextStyle(color: isService ? const Color(0xFF8338EC) : const Color(0xFF00F5D4), fontSize: 10),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('\$${itm['price']}', style: const TextStyle(color: Color(0xFFFFB703), fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Color(0xFFFF5964)),
                            onPressed: () => _deleteItem(itm['id']),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
