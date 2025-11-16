import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'account_page.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  _navigateNext() async {
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    // Revisar si hay usuario logueado
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Si ya está logueado, ir directamente a HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      // Si no está logueado, ir a AccountPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AccountPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1B1B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenido',
              style: TextStyle(
                color: Color(0xFFECFFE1),
                fontSize: 24,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/logo_app.png',
              width: 300,
            ),
          ],
        ),
      ),
    );
  }
}
