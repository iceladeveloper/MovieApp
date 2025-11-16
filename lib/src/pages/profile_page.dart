import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black87,
      body: const Center(
        child: Text('Aquí se mostrarán los datos del usuario',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
