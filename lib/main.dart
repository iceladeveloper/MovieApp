import 'package:flutter/material.dart';
import 'src/pages/home_page.dart';
import 'src/pages/detail_page.dart'; // Importa DetailPage y DetailPageArguments
import 'src/pages/splash_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineMóvil',
      debugShowCheckedModeBanner: false,
      
      // La ruta inicial debe ser la pantalla de carga (splash)
      initialRoute: 'splash',       
      
      routes: {
          'splash': (BuildContext context) => const SplashScreen(), // 1. Muestra Splash
          'Inicio': (BuildContext context) => const HomePage(), // 2. Navega a Home
          // RUTA DE DETALLE (usa DetailPageArguments)
          'detalle': (BuildContext context) {
            // Usa ModalRoute para obtener los argumentos pasados (requiere DetailPageArguments)
            final args = ModalRoute.of(context)!.settings.arguments as DetailPageArguments;
            return DetailPage(arguments: args);
          },
      },
      
      theme: ThemeData(
         primarySwatch: Colors.blue, 
         appBarTheme: const AppBarTheme(
           backgroundColor: Colors.black, 
         )
      ),
    );
  }
}