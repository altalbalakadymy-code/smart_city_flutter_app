class ApiConfig {
  // الرابط السحابي الثابت للسيرفر
  static const String baseUrl = "https://smartcitybackend-production-9d26.up.railway.app";

  // المسارات الأساسية (API Endpoints)
  static const String healthCheck = "$baseUrl/";
  static const String businessesList = "$baseUrl/api/v1/admin/businesses";
  static const String createVendor = "$baseUrl/api/v1/admin/create-vendor";
  static const String toggleBusiness = "$baseUrl/api/v1/admin/toggle-business";
  static const String docsUrl = "$baseUrl/docs";
}
