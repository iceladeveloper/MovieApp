import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  void _navigateToHome() async {
    // Espera 3 segundos
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      // Navega a la HomePage usando la ruta 'Inicio'
      Navigator.pushReplacementNamed(context, 'Inicio');
    }
  }

  @override
  void initState() {
    super.initState();
    _navigateToHome(); // Inicia la navegación
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black, // Fondo oscuro
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Texto de bienvenida
            Text(
              'Cine Móvil',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.greenAccent),
          ],
        ),
      ),
    );
  }
}