import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/movie.dart';
import '../../services/movie_service.dart';

// Colores y constantes
const Color _primaryColor = Color(0xFF4CAF50); // Verde principal
const Color _textColor = Colors.white;
const Color _backgroundColor = Color(0xFF121212);
const Color _cardColor = Color(0xFF1E1E1E);

class MovieDetailScreen extends StatefulWidget {
  final String movieId = 'tt0111161'; // Ejemplo de IMDb ID (The Shawshank Redemption)

  const MovieDetailScreen({super.key});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  // Estado para la película obtenida
  Movie? _movieDetail;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMovieDetail();
  }

  // Función para obtener los detalles de la película usando la OMDB API
  Future<void> _fetchMovieDetail() async {
    // Obtenemos la instancia del servicio sin escuchar para no reconstruir el widget innecesariamente.
    final movieService = Provider.of<MovieService>(context, listen: false);

    try {
      final Movie? movie = await movieService.getMovieDetail(widget.movieId);
      setState(() {
        _movieDetail = movie;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Widget para construir una fila de información (ej. "Director: John Doe")
  Widget _buildInfoRow(String title, String value) {
    if (value.isEmpty || value == 'N/A') return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              color: _textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: _textColor.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(_movieDetail?.title ?? 'Detalle de Película'),
        backgroundColor: _cardColor,
        foregroundColor: _textColor,
      ),
      body: _buildBody(),
    );
  }
  
  // Contenido principal de la pantalla
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _primaryColor));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Error al cargar detalles: $_errorMessage',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
          ),
        ),
      );
    }

    final movie = _movieDetail;

    if (movie == null) {
      return const Center(
        child: Text(
          'Detalles no encontrados.',
          style: TextStyle(color: _textColor, fontSize: 18),
        ),
      );
    }

    // Usamos SingleChildScrollView para asegurar que el contenido es desplazable
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Fila del Poster y Datos principales
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Poster de la Película
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: movie.poster.isNotEmpty && movie.poster != 'N/A'
                    ? Image.network(
                        movie.poster,
                        width: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 150,
                          height: 225, // Relación de aspecto estándar
                          color: Colors.blueGrey,
                          child: const Icon(Icons.movie, color: _textColor, size: 60),
                        ),
                      )
                    : Container(
                        width: 150,
                        height: 225,
                        color: Colors.blueGrey,
                        child: const Icon(Icons.movie, color: _textColor, size: 60),
                      ),
              ),
              const SizedBox(width: 16.0),

              // Información principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      movie.title,
                      style: const TextStyle(
                        color: _textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    _buildInfoRow('Año', movie.year),
                    _buildInfoRow('Clasificación', movie.rated ?? 'Desconocido'),
                    _buildInfoRow('Duración', movie.runtime ?? 'Desconocido'),
                    _buildInfoRow('Género', movie.genre ?? 'Desconocido'),
                    
                    // Rating (IMDB)
                    if (movie.imdbRating!.isNotEmpty && movie.imdbRating != 'N/A')
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 5),
                            Text(
                              'IMDB: ${movie.imdbRating}',
                              style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20.0),
          
          // Trama (Plot)
          _buildSectionTitle('Trama'),
          Text(
            movie.plot ?? 'Trama no disponible.',
            textAlign: TextAlign.justify,
            style: TextStyle(color: _textColor.withOpacity(0.8), fontSize: 16),
          ),

          const SizedBox(height: 20.0),
          
          // Información Adicional
          _buildSectionTitle('Elenco y Equipo'),
          _buildInfoRow('Director', movie.director ?? 'Desconocido'),
          _buildInfoRow('Escritor', movie.writer ?? 'Desconocido'),
          _buildInfoRow('Actores', movie.actors ?? 'Desconocido'),
          
          const SizedBox(height: 20.0),

          // Otros detalles
          _buildSectionTitle('Otros Detalles'),
          _buildInfoRow('País', movie.country ?? 'Desconocido'),
          _buildInfoRow('Idioma', movie.language ?? 'Desconocido'),
          _buildInfoRow('Premios', movie.awards ?? 'Desconocido'),
          _buildInfoRow('Fecha de Estreno', movie.released ?? 'Desconocido'),

          const SizedBox(height: 40.0),
        ],
      ),
    );
  }
  
  // Widget de ayuda para los títulos de sección
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: _primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}