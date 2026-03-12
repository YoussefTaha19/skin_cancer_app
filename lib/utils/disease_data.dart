import 'package:flutter/material.dart';

class DiseaseData {
  static const List<Map<String, dynamic>> diseases = [
    {
      'code': 'akiec',
      'name': 'Actinic Keratoses',
      'description': 'آفات جلدية سابقة للتسرطن تظهر على المناطق المعرضة للشمس. تعتبر مرحلة مبكرة من سرطان الجلد.',
      'risk': 'عالي',
      'riskColor': Colors.orange,
      'treatment': 'العلاج بالتبريد، كريمات موضعية، أو الاستئصال الجراحي.',
    },
    {
      'code': 'bcc',
      'name': 'Basal Cell Carcinoma',
      'description': 'سرطان الخلايا القاعدية. أكثر أنواع سرطان الجلد شيوعاً، ينمو ببطء ونادراً ما ينتشر.',
      'risk': 'متوسط',
      'riskColor': Colors.orange,
      'treatment': 'الاستئصال الجراحي، العلاج بالتبريد، أو الكريمات الموضعية.',
    },
    {
      'code': 'bkl',
      'name': 'Benign Keratosis',
      'description': 'آفات جلدية حميدة مثل التقران الدهني. غير سرطانية ولا تشكل خطراً.',
      'risk': 'منخفض',
      'riskColor': Colors.green,
      'treatment': 'غير مطلوب عادة، يمكن إزالتها لأسباب تجميلية.',
    },
    {
      'code': 'df',
      'name': 'Dermatofibroma',
      'description': 'أورام جلدية ليفية حميدة. تظهر عادة على الأطراف وهي غير ضارة.',
      'risk': 'منخفض',
      'riskColor': Colors.green,
      'treatment': 'غير مطلوب عادة، يمكن استئصالها إذا تسببت في أعراض.',
    },
    {
      'code': 'mel',
      'name': 'Melanoma',
      'description': 'أخطر أنواع سرطان الجلد. يتطور في الخلايا المنتجة للميلانين ويمكن أن ينتشر بسرعة.',
      'risk': 'مرتفع جداً',
      'riskColor': Colors.red,
      'treatment': 'استئصال جراحي واسع، علاج مناعي، علاج كيميائي، أو علاج إشعاعي.',
    },
    {
      'code': 'nv',
      'name': 'Melanocytic Nevus',
      'description': 'الشامات العادية. تجمعات حميدة من الخلايا الصباغية.',
      'risk': 'منخفض',
      'riskColor': Colors.green,
      'treatment': 'غير مطلوب. يُنصح بمراقبة أي تغيرات في الشكل أو اللون.',
    },
    {
      'code': 'vasc',
      'name': 'Vascular Lesions',
      'description': 'آفات وعائية مثل الأورام الوعائية. عادة ما تكون حميدة.',
      'risk': 'منخفض',
      'riskColor': Colors.green,
      'treatment': 'غير مطلوب عادة، يمكن علاجها بالليزر إذا لزم الأمر.',
    },
  ];

  // معلومات التطبيق (معدلة حسب طلبك)
  static const Map<String, String> appInfo = {
    'name': 'كشف سرطان الجلد',
    'version': '1.0.0',
    'developer': 'welliam Youssef  🔻',  // 👈 عدلت الاسم هنا
    'description': 'تطبيق للكشف المبكر عن سرطان الجلد باستخدام الذكاء الاصطناعي',
    'supported_diseases': '7 أنواع',
  };
}