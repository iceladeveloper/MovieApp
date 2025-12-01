import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// Este servicio maneja toda la lógica de autenticación de Firebase.
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // =========================================================================
  // CONFIGURACIÓN DE ADMINISTRADORES
  // =========================================================================
  // Lista de correos electrónicos que serán reconocidos como administradores
  // por la lógica de la aplicación (frontend).
  final List<String> _adminEmails = const [
    'admin@cinemovil.com', 
    'zaira.silva@udgvirtual.udg.mx', // NUEVO USUARIO ADMINISTRADOR
  ];

  // =========================================================================
  // ESTADO DE LA AUTENTICACIÓN
  // =========================================================================

  AuthService() {
    // Escucha los cambios de estado de autenticación de Firebase
    _auth.authStateChanges().listen((User? user) {
      // Notifica a los widgets (como CatalogScreen) que el estado de auth ha cambiado
      notifyListeners(); 
    });
  }

  // Devuelve true si hay un usuario logeado actualmente.
  bool get isAuthenticated => _auth.currentUser != null;

  // 1. Verifica si el usuario actual es un administrador.
  bool get isAdmin {
    final currentEmail = _auth.currentUser?.email;
    if (currentEmail == null) {
      return false;
    }
    // Verifica si el correo actual se encuentra en la lista de correos administradores.
    return _adminEmails.contains(currentEmail);
  }

  get currentUser => null;

  // =========================================================================
  // METODOS DE AUTENTICACIÓN
  // =========================================================================

  // Inicia sesión con correo y contraseña
  Future<void> signIn(String username, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: username, password: password);
    } on FirebaseAuthException catch (e) {
      // Relanzar la excepción para que la UI pueda manejar el error específico
      throw Exception(e.message ?? 'Error desconocido de inicio de sesión.');
    } catch (e) {
      throw Exception('Error en el inicio de sesión: $e');
    }
  }

  // Cierra la sesión del usuario actual
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar la sesión: $e');
    }
  }
}