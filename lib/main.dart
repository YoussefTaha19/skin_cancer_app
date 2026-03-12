import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/custom_splash_screen.dart';  // 👈 استيراد شاشة الترحيب

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skin Cancer Detector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.cairoTextTheme(),
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CustomSplashScreen(),  // 👈 هنا التعديل: استخدم شاشة الترحيب
    );
  }
}