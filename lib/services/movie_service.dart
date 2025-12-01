import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

// Definimos el tipo de resultado de la búsqueda
// Es una lista de películas O un mensaje de error.
class SearchResult {
  final List<Movie> movies;
  final String? errorMessage;

  SearchResult({required this.movies, this.errorMessage});

  bool get hasError => errorMessage != null;

  bool? get isEmpty => null;
}

class MovieService with ChangeNotifier {
  final String _apiKey;
  final String _baseUrl = 'https://www.omdbapi.com/';

  MovieService(this._apiKey);

  // Método para buscar películas por título
  Future<SearchResult> searchMovies(String query) async {
    // Si la clave API no está configurada, devolvemos un error
    if (_apiKey.isEmpty || _apiKey == "aa95c5d2") {
      return SearchResult(
        movies: [],
        errorMessage: 'Error de configuración: La clave OMDB API no es válida.',
      );
    }
    
    // Construimos la URL para la búsqueda (s=search, apikey=clave)
    final url = '$_baseUrl?s=$query&apikey=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // La API OMDB devuelve un campo 'Response' y un campo 'Error'
        if (data['Response'] == 'True') {
          final List<dynamic> searchList = data['Search'];
          
          // Mapeamos los resultados a la lista de objetos Movie
          final List<Movie> movies = searchList
              .map((json) => Movie.fromJson(json))
              .toList();

          return SearchResult(movies: movies);
        } else {
          // Si Response es False, devolvemos el error de la API
          return SearchResult(
            movies: [],
            errorMessage: data['Error'] ?? 'No se encontraron películas.',
          );
        }
      } else {
        // Error de HTTP (e.g., 404, 500)
        return SearchResult(
          movies: [],
          errorMessage: 'Error de red: Código ${response.statusCode}',
        );
      }
    } catch (e) {
      // Manejo de errores de conexión o parsing
      if (kDebugMode) {
        print('Error al buscar películas: $e');
      }
      return SearchResult(
        movies: [],
        errorMessage: 'Error de conexión. Verifica tu internet.',
      );
    }
  }

  // Método para obtener el detalle completo de una película por su ID (imdbID)
  Future<Movie?> getMovieDetail(String imdbId) async {
    // Construimos la URL para obtener el detalle (i=imdbID, plot=full)
    final url = '$_baseUrl?i=$imdbId&plot=full&apikey=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['Response'] == 'True') {
          // Convertimos la respuesta de detalle a un objeto Movie
          return Movie.fromDetailJson(data);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener detalle de película: $e');
      }
    }
    return null; // Devuelve null si falla la obtención del detalle
  }
}