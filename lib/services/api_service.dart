import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // استخدم عنوان IP جهازك (شوف الخطوة تحت)
  static const String baseUrl = 'http://192.168.1.105:5000';
  
  // دالة للتنبؤ
  static Future<Map<String, dynamic>> predictImage(File imageFile) async {
    try {
      // إنشاء طلب متعدد الأجزاء
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict'),
      );
      
      // إضافة الصورة
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      
      // إرسال الطلب
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('خطأ في السيرفر: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('فشل الاتصال: $e');
    }
  }
  
  // دالة لاختبار الاتصال
  static Future<bool> testConnection() async {
    try {
      var response = await http.get(
        Uri.parse('$baseUrl/health'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}