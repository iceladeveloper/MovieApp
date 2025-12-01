import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Importación del archivo generado automáticamente por FlutterFire.
import 'firebase_options.dart'; 

// === CORRECCIÓN DE RUTAS DE SERVICIOS ===
// La ruta es ahora directa desde la raíz de la carpeta 'lib'.
import 'services/auth_service.dart';
import 'services/movie_service.dart';

// === CORRECCIÓN DE RUTAS DE PÁGINAS ===
// La ruta es ahora directa desde la raíz de la carpeta 'lib/src/pages'.
import 'src/pages/splash_screen.dart';
import 'src/pages/login_screen.dart';
import 'src/pages/catalog_screen.dart'; 
import 'src/pages/movie_detail_screen.dart'; 
import 'src/pages/admin_screen.dart'; 

// Clave API de OMDB (Fragmento que confirmaste en la conversación)
const String omdbApiKey = "aa95c5d2"; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inicialización de Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MainApp());
  } catch (e) {
    // Si la inicialización falla, mostramos una pantalla de error simple
    runApp(FirebaseErrorScreen(error: e.toString()));
  }
}

// Pantalla de Error para cuando Firebase no inicializa.
class FirebaseErrorScreen extends StatelessWidget {
  final String error;
  const FirebaseErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 20),
                const Text(
                  'ERROR CRÍTICO: Configuración Incompleta o Fallida.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'La aplicación falló al conectarse o iniciar servicios. Verifica la clave de la API y la configuración de Firebase.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
                const SizedBox(height: 20),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 2. Configuración de Providers y Rutas
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Se inicializan y proveen los servicios a toda la aplicación
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        // Se inyecta la API Key en el MovieService
        ChangeNotifierProvider(create: (_) => MovieService(omdbApiKey)),
        // Provider(create: (_) => FirestoreService()), // Replace 'someRequiredArgument' with the actual argument needed
      ],
      child: MaterialApp(
        title: 'Cinemóvil App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Tema oscuro
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF4CAF50), // Verde principal
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF4CAF50),
            secondary: Colors.amber,
            background: Color(0xFF121212),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E1E1E),
          ),
        ),
        
        // Configuración de Rutas Nombradas
        initialRoute: '/',
        routes: {
          // 1. Ruta Inicial (Splash Screen)
          '/': (context) => const SplashScreen(),
          
          // 2. Rutas de Autenticación
          'login': (context) => const LoginScreen(),
          
          // 3. Ruta Principal (Catálogo Público)
          'catalog': (context) => const CatalogScreen(),

          // 4. Ruta de Administración (Solo para Admin)
          'admin': (context) => const AdminScreen(), 

          // Note: 'detail' requires arguments and must be handled with onGenerateRoute
        },
        
        // Manejo de rutas con argumentos (como los detalles de la película)
        onGenerateRoute: (settings) {
          if (settings.name == 'detail') {
            final args = settings.arguments as String?;
            if (args != null) {
              return MaterialPageRoute(
                builder: (context) {
                  // movie_detail_screen.dart debe recibir el imdbID
                  return MovieDetailScreen();
                },
              );
            }
            // If ID is null, go back to the catalog (safe fallback)
            return MaterialPageRoute(builder: (context) => const CatalogScreen());
          }
          return null;
        },
      ),
    );
  }
}