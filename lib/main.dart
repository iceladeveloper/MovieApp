

import 'package:flutter/material.dart';
import 'package:movie_widgets/src/pages/home_page.dart';
//Importación de la página del home screen o Splash Screen
import 'src/pages/splash_screen.dart'; 

void main() => runApp(const MyApp()); // Usamos 'const' en runApp para buenas prácticas


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      initialRoute: 'splash', //cambiamos el inicio de nuestra app hacia el splash screen     
      routes: {
         //Ruta que se iniciará al abrir la app
         'splash': (BuildContext context) => const SplashScreen(),

         //Ruta hacia la página principal
         'Inicio': (BuildContext context) => HomePage(),
      }
    );
  }
}