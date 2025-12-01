// El modelo Movie está diseñado para ser usado tanto por la API de OMDB
// (para búsqueda) como por Firestore (para el catálogo guardado).

class Movie {
  // Campos principales usados en la tarjeta de catálogo
  final String title;
  final String year;
  final String imdbID;
  final String poster;

  // Campos adicionales para la pantalla de detalle (se llenan en getMovieDetail)
  final String? released;
  final String? runtime;
  final String? genre;
  final String? director;
  final String? writer;
  final String? actors;
  final String? plot;
  final String? language;
  final String? country;
  final String? awards;
  final String? imdbRating;

  // Constructor base para la inmutabilidad
  Movie({
    required this.title,
    required this.year,
    required this.imdbID,
    required this.poster,
    this.released,
    this.runtime,
    this.genre,
    this.director,
    this.writer,
    this.actors,
    this.plot,
    this.language,
    this.country,
    this.awards,
    this.imdbRating,
  });

  // =========================================================================
  // METODOS DE CONVERSION (Deserialización / Lectura)
  // =========================================================================

  // Constructor para crear una Movie a partir de una respuesta JSON de la API de OMDB
  // La API puede devolver campos nulos o no existentes, por eso usamos el operador ?.
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['Title'] ?? 'N/A',
      year: json['Year'] ?? 'N/A',
      imdbID: json['imdbID'] ?? '',
      poster: json['Poster'] ?? 'https://placehold.co/300x450/1E1E1E/FFFFFF?text=No+Poster',
      
      // Campos detallados (pueden ser nulos si es un resultado de búsqueda simple)
      released: json['Released'],
      runtime: json['Runtime'],
      genre: json['Genre'],
      director: json['Director'],
      writer: json['Writer'],
      actors: json['Actors'],
      plot: json['Plot'],
      language: json['Language'],
      country: json['Country'],
      awards: json['Awards'],
      imdbRating: json['imdbRating'],
    );
  }

  // Constructor para crear una Movie a partir de un Map de Firestore
  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      title: map['title'] ?? 'N/A',
      year: map['year'] ?? 'N/A',
      imdbID: map['imdbID'] ?? '',
      poster: map['poster'] ?? 'https://placehold.co/300x450/1E1E1E/FFFFFF?text=No+Poster',
      
      released: map['released'],
      runtime: map['runtime'],
      genre: map['genre'],
      director: map['director'],
      writer: map['writer'],
      actors: map['actors'],
      plot: map['plot'],
      language: map['language'],
      country: map['country'],
      awards: map['awards'],
      imdbRating: map['imdbRating'],
    );
  }

  // Constructor para crear una Movie a partir de una respuesta JSON de la API de OMDB.
  // Este método maneja tanto los resultados de búsqueda (simples) como los detalles completos.
  factory Movie.fromDetailJson(Map<String, dynamic> json) {
    // Definimos el URL de placeholder para el póster
    final defaultPoster = 'https://placehold.co/300x450/1E1E1E/FFFFFF?text=No+Poster';

    return Movie(
      // Campos requeridos (siempre deben existir o ser reemplazados por 'N/A')
      title: json['Title'] ?? 'N/A',
      year: json['Year'] ?? 'N/A',
      imdbID: json['imdbID'] ?? '',
      // Si el póster es "N/A" o nulo, usamos el placeholder
      poster: (json['Poster'] == 'N/A' || json['Poster'] == null) 
          ? defaultPoster 
          : json['Poster'],
      
      // Campos detallados (se usan para detalle de película y se guardan en Firestore)
      released: json['Released'],
      runtime: json['Runtime'],
      genre: json['Genre'],
      director: json['Director'],
      writer: json['Writer'],
      actors: json['Actors'],
      plot: json['Plot'],
      language: json['Language'],
      country: json['Country'],
      awards: json['Awards'],
      imdbRating: json['imdbRating'],
    );
  }

  String? get rated => null;

  // =========================================================================
  // METODO DE CONVERSION (Serialización / Escritura)
  // =========================================================================

  // Método para convertir la clase Movie a un Map para subir a Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'year': year,
      'imdbID': imdbID,
      'poster': poster,
      'released': released,
      'runtime': runtime,
      'genre': genre,
      'director': director,
      'writer': writer,
      'actors': actors,
      'plot': plot,
      'language': language,
      'country': country,
      'awards': awards,
      'imdbRating': imdbRating,
      // Se pueden añadir campos de fecha de creación, etc.
    };
  }

  static Future<Movie?> fromFirestore(Map<String, dynamic> data, String id) async {}

  Object? toFirestore() {}
}