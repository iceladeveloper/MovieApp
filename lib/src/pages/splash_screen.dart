// lib/src/pages/splash_screen.dart

import 'package:flutter/material.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Función para manejar la navegación
  _navigateToHome() async {
    // Retraso de 3 segundos para mostrar el logo
    await Future.delayed(const Duration(seconds: 5), () {}); 
    
    // Navegar al HomePage y reemplazar la pantalla actual
  
    if (mounted) {
        Navigator.pushReplacementNamed(context, 'Inicio');
    }
  }
  
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  @override
  Widget build(BuildContext context) {
    // Ruta de la imagen actualizada
    const String logoPath = 'assets/logo_app.png'; 

    return Scaffold(
      // Fondo negro
      backgroundColor: const Color(0xFF1F1B1B), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Texto "Bienvenido"
            const Text(
              'Bienvenido',
              style: TextStyle(
                color: Color(0xFFECFFE1),
                fontSize: 24,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20), // Espacio entre el texto y la imagen
            
            // La imagen (Logo CineMóvil y eslogan)
            Image.asset(
              logoPath,
              // Ajusta el ancho para que el logo se vea centrado y no demasiado grande
              width: 300, 
            ),
          ],
        ),
      ),
    );
  }
}