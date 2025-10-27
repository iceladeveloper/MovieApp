

import 'package:flutter/material.dart';
import 'package:movie_widgets/src/pages/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      initialRoute: 'Inicio',       
      routes: {
          'Inicio': (BuildContext context) => HomePage(),
      }
    );
  }
}