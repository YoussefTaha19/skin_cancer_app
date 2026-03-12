import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';

class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({super.key});

  @override
  State<CustomSplashScreen> createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {
  @override
  void initState() {
    super.initState();
    // تأخير 3 ثواني ثم الانتقال للشاشة الرئيسية
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(  // 👈 أضف هذا السطر
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // الشعار
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/icon/splash.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.health_and_safety,
                          size: 80,
                          color: Color(0xFF2196F3),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // اسم التطبيق
                const Text(
                  'كشف سرطان الجلد',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                // وصف
                const Text(
                  'Skin Cancer Detector',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 50),
                // مؤشر تحميل
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ), // 👈 أغلق SingleChildScrollView هنا
        ),
      ),
    );
  }
}