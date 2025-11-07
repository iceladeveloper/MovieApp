import 'package:flutter/material.dart';
import '../services/pokemon_service.dart';

// Argumentos que se pasan al navegar a esta página
class DetailPageArguments {
  final String pokemonName;
  final String detailUrl;

  DetailPageArguments({required this.pokemonName, required this.detailUrl});
}

class DetailPage extends StatefulWidget {
  final DetailPageArguments arguments;
  const DetailPage({super.key, required this.arguments});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final PokemonService _pokemonService = PokemonService();
  Map<String, dynamic>? _pokemonDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  void _fetchDetails() async {
    setState(() {
      _isLoading = true;
    });

    final details = await _pokemonService.fetchPokemonDetails(widget.arguments.detailUrl);

    setState(() {
      _pokemonDetails = details;
      _isLoading = false;
    });
  }

  // Helper para mostrar habilidades
  String _formatAbilities(List<dynamic>? abilities) {
    if (abilities == null) return 'No disponibles';
    return abilities.map((a) => a['ability']['name']).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    String capitalizedName = 
        '${widget.arguments.pokemonName[0].toUpperCase()}${widget.arguments.pokemonName.substring(1)}';

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text(capitalizedName),
        backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: _buildBody(capitalizedName),
    );
  }

  Widget _buildBody(String name) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
    }

    if (_pokemonDetails == null) {
      return const Center(
          child: Text(
            'Error al cargar detalles del Pokémon.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ));
    }

    // Datos del Pokémon
    final String imageUrl = _pokemonDetails!['sprites']['other']['official-artwork']['front_default'] ?? '';
    final double weight = (_pokemonDetails!['weight'] ?? 0) / 10.0; // Convertir de decigramos a kg
    final double height = (_pokemonDetails!['height'] ?? 0) / 10.0; // Convertir de decímetros a metros
    final List<dynamic>? abilities = _pokemonDetails!['abilities'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Imagen central del Pokémon
          Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(15),
            ),
            child: imageUrl.isNotEmpty
                ? Image.network(imageUrl, fit: BoxFit.contain)
                : const Icon(Icons.catching_pokemon, size: 100, color: Colors.white54),
          ),
          const SizedBox(height: 20),

          // Nombre
          Text(
            name,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),

          // Ficha de detalles (peso, altura, habilidades)
          Card(
            color: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDetailRow('Peso:', '$weight kg'),
                  _buildDetailRow('Altura:', '$height m'),
                  _buildDetailRow('Habilidades:', _formatAbilities(abilities)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Descripción simulada
          const Text(
            'Este es un ejemplo de la descripción detallada del Pokémon. En una aplicación real de streaming, aquí iría la sinopsis de la película o serie seleccionada, junto con información de reparto y clasificación.',
            textAlign: TextAlign.justify,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}