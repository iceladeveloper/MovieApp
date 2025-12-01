import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/movie_service.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../models/movie.dart';

const Color _backgroundColor = Color(0xFF121212);
const Color _cardColor = Color(0xFF1E1E1E);
const Color _primaryColor = Color(0xFF4CAF50);
const Color _deleteColor = Colors.redAccent;
const Color _textColor = Colors.white;

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // Controlador para el campo de búsqueda
  final TextEditingController _searchController = TextEditingController();
  // Estado para la lista de resultados de búsqueda de la API
  List<Movie> _searchResults = [];
  // Estado para manejar el mensaje de error o info
  String? _infoMessage;
  // Estado para manejar la carga de la API
  bool _isLoadingSearch = false;

  // Función de búsqueda en la API de OMDB
  void _searchOmdb(BuildContext context) async {
    final searchTerm = _searchController.text.trim();
    if (searchTerm.isEmpty) {
      setState(() {
        _searchResults = [];
        _infoMessage = 'Por favor, introduce un término de búsqueda.';
      });
      return;
    }

    setState(() {
      _isLoadingSearch = true;
      _infoMessage = null;
      _searchResults = [];
    });

    try {
      final movieService = Provider.of<MovieService>(context, listen: false);
      final results = await movieService.searchMovies(searchTerm);
      
      setState(() {
        _searchResults = results as List<Movie>;
        if (results?.isEmpty ?? true) {
          _infoMessage = 'No se encontraron resultados para "$searchTerm".';
        }
      });
    } catch (e) {
      setState(() {
        _infoMessage = 'Error al buscar: ${e.toString().split(':')[1].trim()}';
      });
    } finally {
      setState(() {
        _isLoadingSearch = false;
      });
    }
  }

  // Muestra un SnackBar (notificación temporal)
  void _showSnackBar(BuildContext context, String message, {Color color = _primaryColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Función para agregar una película a Firestore
  void _addMovieToCatalog(BuildContext context, Movie movie) async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    
    // Primero, obtener los detalles completos de la película, ya que el resultado de búsqueda (Movie) 
    // solo tiene información básica.
    try {
      final movieService = Provider.of<MovieService>(context, listen: false);
      // Obtener el objeto Movie completo antes de guardarlo.
      final fullMovieDetail = await movieService.getMovieDetail(movie.imdbID);

      await firestoreService.addMovie(fullMovieDetail!);
      _showSnackBar(context, '${movie.title} agregado con éxito al catálogo!', color: _primaryColor);
      
      // Opcional: limpiar la búsqueda
      setState(() {
        _searchController.clear();
        _searchResults = [];
      });

    } catch (e) {
      _showSnackBar(context, 'Error al agregar ${movie.title}. Posiblemente ya existe.', color: _deleteColor);
    }
  }

  // Función para eliminar una película de Firestore
  void _deleteMovie(BuildContext context, String imdbId, String title) async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    try {
      await firestoreService.deleteMovie(imdbId);
      _showSnackBar(context, '$title eliminado con éxito.', color: _deleteColor);
    } catch (e) {
      _showSnackBar(context, 'Error al eliminar $title: ${e.toString()}', color: _deleteColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Servicios para escuchar y modificar
    final firestoreService = Provider.of<FirestoreService>(context);
    final authService = Provider.of<AuthService>(context);

    // Si el usuario no es admin o no está logeado, lo devolvemos al catálogo.
    if (!authService.isAdmin) {
      // Usar WidgetsBinding para evitar un error de "setState durante la construcción"
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Muestra un mensaje y redirige al catálogo.
        _showSnackBar(context, 'Acceso denegado. Solo administradores.', color: _deleteColor);
        Navigator.of(context).pushReplacementNamed('catalog');
      });
      // Retornar un contenedor vacío mientras la redirección ocurre
      return const Scaffold(backgroundColor: _backgroundColor, body: Center(child: Text('Redirigiendo...', style: TextStyle(color: _textColor))));
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: _cardColor,
        elevation: 0,
        actions: [
          // Botón de Cerrar Sesión (Admin)
          IconButton(
            icon: const Icon(Icons.logout, color: _deleteColor),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('catalog');
              }
            },
          ),
        ],
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección 1: Búsqueda de Películas (OMDB)
            _buildSearchSection(context),
            const SizedBox(height: 30),

            // Separador y título de la lista de resultados
            const Text(
              'Resultados de la Búsqueda (OMDB)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryColor),
            ),
            const Divider(color: Colors.white24),
            
            // Lista de Resultados de Búsqueda
            _buildSearchResults(),
            const SizedBox(height: 40),

            // Sección 3: Películas en el Catálogo (Firestore)
            const Text(
              'Catálogo Actual (Firestore)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryColor),
            ),
            const Divider(color: Colors.white24),
            
            // Usa StreamBuilder para ver las películas que ya están guardadas
            StreamBuilder<List<Movie>>(
              stream: firestoreService.getMovies(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: _primaryColor));
                }
                if (snapshot.hasError) {
                  return Text('Error al cargar el catálogo: ${snapshot.error}', style: const TextStyle(color: _deleteColor));
                }
                
                final catalogMovies = snapshot.data ?? [];

                if (catalogMovies.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text('El catálogo está vacío. ¡Busca y agrega tu primera película!', style: TextStyle(color: Colors.white70)),
                    ),
                  );
                }

                // Lista de Películas en el Catálogo con opción de Eliminar
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // Importante para SingleChildScrollView
                  itemCount: catalogMovies.length,
                  itemBuilder: (context, index) {
                    final movie = catalogMovies[index];
                    return _buildCatalogItem(context, movie);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // WIDGETS DE CONSTRUCCIÓN
  // =========================================================================

  Widget _buildSearchSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: _textColor),
                decoration: InputDecoration(
                  labelText: 'Buscar Película por Título',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'Ej. Harry Potter, Inception',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: _cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _primaryColor, width: 2),
                  ),
                ),
                onSubmitted: (_) => _searchOmdb(context),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: _isLoadingSearch ? null : () => _searchOmdb(context),
              icon: _isLoadingSearch
                  ? const SizedBox(
                      width: 15, height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2, color: _cardColor),
                    )
                  : const Icon(Icons.search, color: _cardColor),
              label: Text('Buscar', style: TextStyle(color: _cardColor)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        if (_infoMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _infoMessage!,
              style: TextStyle(color: _deleteColor),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isLoadingSearch) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: CircularProgressIndicator(color: _primaryColor),
      ));
    }

    if (_searchResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final movie = _searchResults[index];
        return Card(
          color: _cardColor,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: SizedBox(
              width: 50,
              height: 75,
              child: Image.network(
                movie.poster,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie, color: Colors.white54),
              ),
            ),
            title: Text(movie.title, style: const TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
            subtitle: Text('Año: ${movie.year} | IMDb ID: ${movie.imdbID}', style: const TextStyle(color: Colors.white70)),
            trailing: ElevatedButton(
              onPressed: () => _addMovieToCatalog(context, movie),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Agregar', style: TextStyle(color: _cardColor)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCatalogItem(BuildContext context, Movie movie) {
    return Card(
      color: _cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: SizedBox(
          width: 50,
          height: 75,
          child: Image.network(
            movie.poster,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie, color: Colors.white54),
          ),
        ),
        title: Text(movie.title, style: const TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
        subtitle: Text('ID: ${movie.imdbID}', style: const TextStyle(color: Colors.white70)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_forever, color: _deleteColor),
          tooltip: 'Eliminar del Catálogo',
          onPressed: () => _deleteMovie(context, movie.imdbID, movie.title),
        ),
      ),
    );
  }
}