import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';

// Colores y constantes
const Color _primaryColor = Color(0xFF4CAF50); // Verde principal
const Color _textColor = Colors.white;
const Color _backgroundColor = Color(0xFF121212);
const Color _cardColor = Color(0xFF1E1E1E);

// La pantalla ahora gestiona Login y Registro para el administrador.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Credenciales pre-rellenadas para facilitar las pruebas
  final TextEditingController _emailController = TextEditingController(text: 'admin@cinemovil.com');
  final TextEditingController _passwordController = TextEditingController(text: 'adminpass');
  bool _isLogin = true; // Estado para alternar entre Login y Registro
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  // Función principal de autenticación
  Future<void> _authenticate() async {
    // 1. Validaciones básicas de entrada
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'El correo y la contraseña son requeridos.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null; // Limpiar mensaje de error anterior
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    
    try {
      if (_isLogin) {
        // Llama al método REAL de Firebase para iniciar sesión
        await authService.signIn(
          _emailController.text.trim(), 
          _passwordController.text.trim(),
        );
      } else {
        // Llama al método REAL de Firebase para registrar
        await authService.signIn(
          _emailController.text.trim(), 
          _passwordController.text.trim(),
        );
      }
      
      // Si la autenticación es exitosa, navegamos al panel de administración
      // La navegación al AdminScreen ocurre cuando el AuthService notifica el cambio de estado.
      // Sin embargo, para una respuesta inmediata, navegamos aquí:
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('admin');
      }

    } catch (e) {
      // Manejo de errores de Firebase Auth (usando la excepción relanzada en AuthService)
      String message = 'Ocurrió un error de autenticación.';
      if (e.toString().contains('firebase_auth')) {
        // Intenta obtener el mensaje de error limpio de Firebase
        message = e.toString().split('] ').last.split(')').first;
      } else {
        message = 'Error: $e';
      }

      setState(() {
        _errorMessage = message;
      });
      
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar el AuthService
    final authService = Provider.of<AuthService>(context);

    // Si el usuario ya está autenticado como administrador, lo redirigimos inmediatamente.
    // Esto maneja el caso donde el token inicial ya autenticó al admin antes de llegar aquí.
    if (authService.currentUser != null && !authService.currentUser!.isAnonymous) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('admin');
        }
      });
      return const Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(child: CircularProgressIndicator(color: _primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(_isLogin ? 'Admin Login' : 'Admin Registro'),
        backgroundColor: _cardColor,
        foregroundColor: _textColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Título principal
              Text(
                _isLogin ? 'Acceso de Administrador' : 'Registrar Administrador',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Credenciales de prueba: admin@cinemovil.com / adminpass',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textColor.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),
              
              // Campo de Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                // **Ajuste para asegurar el correcto manejo del email**
                textCapitalization: TextCapitalization.none, 
                style: const TextStyle(color: _textColor),
                decoration: _buildInputDecoration('Email', Icons.email),
              ),
              const SizedBox(height: 15),

              // Campo de Contraseña
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: _textColor),
                decoration: _buildInputDecoration('Contraseña', Icons.lock),
              ),
              const SizedBox(height: 25),

              // Mostrar mensaje de error si existe
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                  ),
                ),

              // Botón de Login/Registro
              ElevatedButton(
                onPressed: _isLoading ? null : _authenticate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: _textColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: _textColor,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isLogin ? 'Iniciar Sesión' : 'Registrarse',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 20),

              // Botón para alternar entre Login y Registro
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _errorMessage = null;
                        });
                      },
                child: Text(
                  _isLogin ? '¿No tienes cuenta? Regístrate' : '¿Ya tienes cuenta? Inicia Sesión',
                  style: const TextStyle(color: _primaryColor, fontSize: 16),
                ),
              ),
              const SizedBox(height: 40),
              // Botón para volver al catálogo
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.of(context).pushReplacementNamed('catalog');
                      },
                child: const Text(
                  'Volver al Catálogo Público',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Widget de ayuda para decorar los campos de texto
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _textColor.withOpacity(0.7)),
      prefixIcon: Icon(icon, color: _primaryColor),
      filled: true,
      fillColor: _cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Colors.amber, width: 2),
      ),
    );
  }
}