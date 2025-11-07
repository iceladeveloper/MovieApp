import 'dart:convert';
import 'package:http/http.dart' as http; // Paquete HTTP para peticiones

// Clase de servicio para manejar la lógica de la petición HTTP a PokéAPI
class PokemonService {
  final String _baseUrl = 'https://pokeapi.co/api/v2/';

  // Método para obtener la lista principal de Pokémon (nombres y URLs)
  Future<List<Map<String, dynamic>>?> fetchPokemonList({int limit = 50, int offset = 0}) async {
    final url = Uri.parse('$_baseUrl/pokemon?limit=$limit&offset=$offset');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Decodifica la respuesta JSON
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        // Extraer la lista de resultados.
        final List<dynamic>? results = jsonResponse['results'];
        
        if (results != null) {
          // Retorna la lista de Maps.
          return results.cast<Map<String, dynamic>>();
        }
        return [];

      } else {
        print('Error de la API de Pokémon: Código de estado ${response.statusCode}');
        return null; 
      }
    } catch (e) {
      print('Error de conexión o decodificación: $e');
      return null;
    }
  }

  // Método para obtener los detalles específicos de un Pokémon (usado para DetailPage)
  Future<Map<String, dynamic>?> fetchPokemonDetails(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}