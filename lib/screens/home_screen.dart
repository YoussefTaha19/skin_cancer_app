import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simple_web_camera/simple_web_camera.dart';
import '../utils/disease_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String? _errorMessage;

  final String baseUrl = 'http://192.168.1.105:5000';

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              'معلومات التطبيق',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoRow('اسم التطبيق', DiseaseData.appInfo['name']!),
                const Divider(),
                _buildInfoRow('الإصدار', DiseaseData.appInfo['version']!),
                const Divider(),
                _buildInfoRow('المطور', DiseaseData.appInfo['developer']!),
                const Divider(),
                _buildInfoRow('الأمراض المدعومة', DiseaseData.appInfo['supported_diseases']!),
                const SizedBox(height: 16),
                Text(
                  DiseaseData.appInfo['description']!,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  void _showDiseasesList() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              'دليل الأمراض الجلدية',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: DiseaseData.diseases.length,
              itemBuilder: (context, index) {
                final disease = DiseaseData.diseases[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ExpansionTile(
                    leading: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: disease['riskColor'],
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      '${disease['code'].toUpperCase()} - ${disease['name']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('مستوى الخطورة: ${disease['risk']}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              disease['description'],
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'العلاج: ${disease['treatment']}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement();
    input.accept = 'image/*';
    input.click();

    input.onChange.listen((event) {
      final files = input.files;
      if (files!.isEmpty) return;
      
      final reader = html.FileReader();
      reader.readAsArrayBuffer(files[0]);
      reader.onLoadEnd.listen((event) {
        setState(() {
          _selectedImageBytes = reader.result as Uint8List?;
          _selectedImageName = files[0].name;
          _result = null;
          _errorMessage = null;
        });
        _analyzeImage();
      });
    });
  }

  Future<void> _takePhoto() async {
    try {
      var result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SimpleWebCameraPage(
            appBarTitle: "التقاط صورة",
            centerTitle: true,
          ),
        ),
      );
      
      if (result is String) {
        Uint8List bytes = base64Decode(result);
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = 'camera_image.jpg';
          _result = null;
          _errorMessage = null;
        });
        _analyzeImage();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل تشغيل الكاميرا: $e';
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImageBytes == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // 👇 رسائل التتبع
    print('📌 [1] بدأ التحليل');
    print('📌 [2] حجم الصورة: ${_selectedImageBytes!.length} بايت');
    print('📌 [3] رابط السيرفر: $baseUrl/predict');

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict'),
      );
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          _selectedImageBytes!,
          filename: _selectedImageName ?? 'image.jpg',
        ),
      );
      
      print('📌 [4] تم تجهيز الطلب، انتظار الرد...');
      
      var response = await request.send();
      print('📌 [5] تم استلام رد، رمز الحالة: ${response.statusCode}');
      
      var responseData = await response.stream.bytesToString();
      print('📌 [6] محتوى الرد: $responseData');
      
      if (response.statusCode == 200) {
        setState(() {
          _result = json.decode(responseData);
          _isLoading = false;
        });
        print('📌 [7] ✅ النتيجة: ${_result!['class']}');
      } else {
        throw Exception('خطأ في السيرفر: ${response.statusCode}');
      }
    } catch (e) {
      print('📌 [❌] خطأ: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _getClassColor(String className) {
    switch (className) {
      case 'mel':
      case 'akiec':
      case 'bcc':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  String _getClassDescription(String className) {
    switch (className) {
      case 'akiec':
        return 'Actinic Keratoses (سرطان مبكر)';
      case 'bcc':
        return 'Basal Cell Carcinoma (سرطان الخلايا القاعدية)';
      case 'bkl':
        return 'Benign Keratosis (آفة حميدة)';
      case 'df':
        return 'Dermatofibroma (ورم ليفي حميد)';
      case 'mel':
        return 'Melanoma (ميلانوما - الأخطر)';
      case 'nv':
        return 'Melanocytic Nevus (شامة عادية)';
      case 'vasc':
        return 'Vascular Lesion (آفة وعائية)';
      default:
        return className;
    }
  }

  Icon _getClassIcon(String className) {
    switch (className) {
      case 'mel':
        return const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 70);
      case 'akiec':
      case 'bcc':
        return const Icon(Icons.health_and_safety, color: Colors.orange, size: 70);
      case 'nv':
        return const Icon(Icons.favorite, color: Colors.green, size: 70);
      case 'bkl':
        return const Icon(Icons.spa, color: Colors.green, size: 70);
      case 'df':
        return const Icon(Icons.circle, color: Colors.green, size: 70);
      case 'vasc':
        return const Icon(Icons.water_drop, color: Colors.green, size: 70);
      default:
        return const Icon(Icons.help, color: Colors.grey, size: 70);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('كشف سرطان الجلد'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) {
              if (value == 'info') {
                _showAppInfo();
              } else if (value == 'diseases') {
                _showDiseasesList();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'info',
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('معلومات التطبيق'),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'diseases',
                child: ListTile(
                  leading: Icon(Icons.health_and_safety),
                  title: Text('دليل الأمراض'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: _selectedImageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(
                          _selectedImageBytes!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'اختر صورة للتحليل',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('معرض الصور'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('كاميرا'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[700]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              )
            else if (_result != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getClassColor(_result!['class']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getClassColor(_result!['class']),
                  ),
                ),
                child: Row(
                  children: [
                    _getClassIcon(_result!['class']),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _result!['class'].toUpperCase(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _getClassColor(_result!['class']),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getClassDescription(_result!['class']),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}