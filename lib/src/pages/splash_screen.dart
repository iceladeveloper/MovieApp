import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// RUTA CORREGIDA: Salta dos niveles (src/pages -> lib) y entra a 'services'
import '../../services/auth_service.dart';

// La pantalla Splash debe ser un StatefulWidget para manejar la navegación asíncrona.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  // Lógica de navegación que se ejecuta una vez al inicio.
  void _checkAuthStatus() async {
    // Escucha el AuthService pero no reconstruye el widget (listen: false)
    final authService = Provider.of<AuthService>(context, listen: false);

    // Damos un pequeño delay para que el usuario vea el splash y Firebase se inicialice bien.
    await Future.delayed(const Duration(seconds: 2));

    // Si el widget ya no está montado (el usuario salió de la pantalla), salimos.
    if (!mounted) return;

    // Verificar si es administrador
    if (authService.isAdmin) {
      // Si es admin, lo mandamos a la pantalla de administración
      Navigator.of(context).pushReplacementNamed('admin');
    } else {
      // Si no es administrador (usuario general o no autenticado), lo mandamos al catálogo
      Navigator.of(context).pushReplacementNamed('catalog');
    }
  }

  @override
  void initState() {
    super.initState();
    // Llamamos a la función de verificación inmediatamente después de la construcción inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usamos un Scaffold simple con el color de fondo definido en ThemeData (MainApp)
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono grande de película (o logo)
            Icon(
              Icons.movie_filter,
              color: Theme.of(context).colorScheme.primary, // Color verde
              size: 80,
            ),
            const SizedBox(height: 20),
            // Texto de carga
            Text(
              'Cargando Cinemóvil...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 30),
            // Indicador de progreso
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.secondary, // Color ámbar
              ),
            ),
          ],
        ),
      ),
    );
  }
}