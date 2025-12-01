import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../models/movie.dart'; // Necesario para tipar los datos

const Color _backgroundColor = Color(0xFF121212);
const Color _cardColor = Color(0xFF1E1E1E);
const Color _primaryColor = Color(0xFF4CAF50);

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener los servicios necesarios
    final firestoreService = Provider.of<FirestoreService>(context);
    final authService = Provider.of<AuthService>(context);

    // Determinar si el usuario está autenticado y es administrador
    final isAdmin = authService.isAdmin;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Catálogo Cinemóvil'),
        backgroundColor: _cardColor,
        elevation: 0,
        actions: [
          // Botón de Administración (solo visible para admin)
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: _primaryColor),
              tooltip: 'Ir a Administración',
              onPressed: () {
                // Navega a la ruta 'admin' definida en main.dart
                Navigator.of(context).pushNamed('admin');
              },
            ),
          // Botón de Login (visible si NO está autenticado)
          if (!authService.isAuthenticated)
            TextButton(
              onPressed: () {
                // Navega a la ruta 'login' (para que el admin inicie sesión)
                Navigator.of(context).pushNamed('login');
              },
              child: const Text('Admin Login', style: TextStyle(color: _primaryColor)),
            )
          else
            // Botón de Logout (visible si SÍ está autenticado)
            TextButton(
              onPressed: () async {
                await authService.signOut();
                // Opcional: navegar de vuelta al catálogo después de cerrar sesión
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('catalog');
                }
              },
              child: const Text('Salir', style: TextStyle(color: Colors.redAccent)),
            ),
        ],
      ),
      
      // Usa StreamBuilder para escuchar los cambios en Firestore en tiempo real
      body: StreamBuilder<List<Movie>>(
        // El stream viene directamente de nuestro FirestoreService
        stream: firestoreService.getMovies(),
        builder: (context, snapshot) {
          // 1. Manejar el estado de Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar las películas: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          // 2. Manejar el estado de Carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _primaryColor));
          }

          // 3. Manejar el estado de Datos (Lista de películas)
          final movies = snapshot.data ?? [];

          if (movies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.movie_creation, size: 60, color: Colors.white54),
                  const SizedBox(height: 10),
                  const Text(
                    '¡Aún no hay películas en el catálogo!',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isAdmin 
                      ? 'Ve a la pantalla de Administración para agregar contenido.'
                      : 'Regresa más tarde.',
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  // Solo para el Admin, ofrece un acceso rápido
                  if (isAdmin)
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: _backgroundColor),
                        label: const Text('Ir a Administración', style: TextStyle(color: _backgroundColor)),
                        onPressed: () => Navigator.of(context).pushNamed('admin'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          // 4. Mostrar la lista de películas
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 columnas
              childAspectRatio: 0.7, // Relación de aspecto para pósteres verticales
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return MovieCard(movie: movie);
            },
          );
        },
      ),
    );
  }
}


// Widget para mostrar una tarjeta de película en el GridView
class MovieCard extends StatelessWidget {
  final Movie movie;
  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navega a la ruta 'detail' pasando el imdbID como argumento
        Navigator.of(context).pushNamed(
          'detail', 
          arguments: movie.imdbID,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen del Póster (usa el campo Poster)
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  movie.poster,
                  fit: BoxFit.cover,
                  // Placeholder mientras carga
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: _primaryColor,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  // Placeholder si la imagen falla o es null
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 40),
                    );
                  },
                ),
              ),
            ),
            
            // Información de la película
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Año
                  Text(
                    movie.year,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}