class BusinessModel {
  final String id;
  final String name;
  final String businessType;
  final String ownerName;
  final String email;
  final bool isActive;
  final double rating;

  BusinessModel({
    required this.id,
    required this.name,
    required this.businessType,
    required this.ownerName,
    required this.email,
    required this.isActive,
    this.rating = 5.0,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['business_name'] ?? 'نشاط غير معروف',
      businessType: json['business_type'] ?? json['type'] ?? 'retail',
      ownerName: json['owner_name'] ?? json['username'] ?? 'مالك النشاط',
      email: json['email'] ?? '',
      isActive: json['is_active'] ?? true,
      rating: (json['rating'] != null) ? (json['rating'] as num).toDouble() : 4.8,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'business_type': businessType,
      'owner_name': ownerName,
      'email': email,
      'is_active': isActive,
      'rating': rating,
    };
  }
}
