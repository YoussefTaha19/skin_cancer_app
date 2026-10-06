import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.109.224:5000';

  static Future<Map<String, dynamic>> predictImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('خطأ في السيرفر (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('فشل الاتصال بالسيرفر. تأكد من تشغيل السيرفر واتصال الشبكة.');
    }
  }

  static Future<bool> testConnection() async {
    try {
      var response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}