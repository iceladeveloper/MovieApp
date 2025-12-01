import 'package:flutter/material.dart';

// Colores y constantes
const Color _primaryColor = Color(0xFF4CAF50); // Verde principal
const Color _textColor = Colors.white;
const Color _backgroundColor = Color(0xFF121212);
const Color _cardColor = Color(0xFF1E1E1E);

class MovieAddScreen extends StatelessWidget {
  const MovieAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Agregar Nueva Película'),
        backgroundColor: _cardColor,
        foregroundColor: _textColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search, color: _primaryColor, size: 80),
              const SizedBox(height: 20),
              Text(
                'Busca una película por título o ID de IMDB.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _textColor.withOpacity(0.8), fontSize: 18),
              ),
              const SizedBox(height: 10),
              const Text(
                '(Implementaremos la lógica de búsqueda de OMDB y guardado en Firestore aquí)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}