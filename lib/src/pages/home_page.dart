import 'package:flutter/material.dart';
import '../services/pokemon_service.dart'; // Importamos el servicio HTTP
import 'detail_page.dart'; // Importamos la página de detalle y sus argumentos

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  
  // 1. SERVICIO Y ESTADO DE LA API
  final PokemonService _pokemonService = PokemonService();
  List<Map<String, dynamic>> _pokemonList = []; // Lista para almacenar datos de la API
  bool _isLoading = true; // Indicador de carga
  
  late TabController _tabController;

  // Listas estáticas (usando assets) - deben tener 'isAsset' para funcionar
  final List<Map<String, dynamic>> continuarViendo = [
    {'title': 'Amor Oculto', 'image': 'assets/amor_oculto.jpg', 'isAsset': true, 'url': ''},
    {'title': 'Young Sheldon', 'image': 'assets/young_sheldon.jpg', 'isAsset': true, 'url': ''},
    {'title': 'The Big Bang Theory', 'image': 'assets/big_bang.jpg', 'isAsset': true, 'url': ''},
  ];

  final List<Map<String, dynamic>> sugerencias = [
    {'title': 'Shrek 2', 'image': 'assets/shrek2.jpg', 'isAsset': true, 'url': ''},
    {'title': 'Harry Potter', 'image': 'assets/harry_potter.jpg', 'isAsset': true, 'url': ''},
    {'title': 'Game of Thrones', 'image': 'assets/game_of_thrones.jpg', 'isAsset': true, 'url': ''},
  ];

  int _selectedIndex = 0;

  // 2. CARGAR DATOS EN INITSTATE
  @override
  void initState() {
    super.initState();
    _fetchPokemonList(); // Iniciar la carga de datos de la API
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  // Función para obtener la lista de Pokémon
  void _fetchPokemonList() async {
    setState(() {
      _isLoading = true;
    });
    // Traer los primeros 15 Pokémon para la lista horizontal
    final data = await _pokemonService.fetchPokemonList(limit: 15); 

    // Función para generar la URL de la imagen del Pokémon
    String getPokemonImageUrl(String url) {
        final uri = Uri.parse(url);
        final id = uri.pathSegments.elementAt(uri.pathSegments.length - 2); 
        return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
    }

    if (data != null) {
      // Mapeamos los datos de la API al formato que nuestro widget espera
      final List<Map<String, dynamic>> pokemonMapped = data.map((item) {
        return {
          'title': item['name'],
          'image': getPokemonImageUrl(item['url']), 
          'isAsset': false, // Indica que es una imagen de red
          'url': item['url'], // URL para los detalles
        };
      }).toList();

      setState(() {
        _pokemonList = pokemonMapped;
        _isLoading = false;
      });
    } else {
       setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Lista horizontal con imágenes
  Widget _buildHorizontalList(List<Map<String, dynamic>> items, {required String title}) {
    double screenWidth = MediaQuery.of(context).size.width;
    double imageWidth = screenWidth * 0.3;
    double imageHeight = imageWidth * 1.5; // Ajustamos la relación a 3:2 (más como un poster)

    // Sección de Título y Carga/Error
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Muestra Carga o Lista
        if (_isLoading && items == _pokemonList) 
          const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 30.0),
            child: CircularProgressIndicator(color: Colors.greenAccent),
          ))
        else if (!_isLoading && items == _pokemonList && items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            child: Text(
              'Error al cargar el catálogo de la API. Revisa tu conexión o el código.', 
              style: TextStyle(color: Colors.redAccent),
            ),
          )
        else
          SizedBox(
            height: imageHeight + 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                final isAsset = item['isAsset'] ?? true;
                
                return Container(
                  width: imageWidth,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          InkWell( // Envuelve la imagen para hacerla clicable
                            onTap: () {
                              // Navegación a la página de detalle, solo si es de la API
                              if (!isAsset) {
                                Navigator.pushNamed(
                                  context,
                                  'detalle',
                                  arguments: DetailPageArguments(
                                    pokemonName: item['title'],
                                    detailUrl: item['url'],
                                  ),
                                );
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: isAsset
                                  ? Image.asset( // Si es asset (listas estáticas)
                                      item['image'],
                                      fit: BoxFit.cover,
                                      width: imageWidth,
                                      height: imageHeight,
                                    )
                                  : Image.network( // Si es de red (API)
                                      item['image'],
                                      fit: BoxFit.cover,
                                      width: imageWidth,
                                      height: imageHeight,
                                      // Placeholder mientras carga
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          width: imageWidth,
                                          height: imageHeight,
                                          color: Colors.grey[800],
                                          child: const Center(
                                            child: CircularProgressIndicator(color: Colors.greenAccent),
                                          ),
                                        );
                                      },
                                      // Muestra un icono de error si la imagen falla
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: imageWidth,
                                          height: imageHeight,
                                          color: Colors.grey[800],
                                          child: const Icon(Icons.error, color: Colors.white54),
                                        );
                                      },
                                    ),
                            ),
                          ),
                          // Ícono de "play" centrado sobre la imagen
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black38,
                                  shape: BoxShape.circle,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          // Muestra el título, capitalizando si viene de la API
                          isAsset 
                              ? item['title']
                              : '${item['title'][0].toUpperCase()}${item['title'].substring(1)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  /// Tab de inicio
  Widget _buildHomeTab() {
    double screenWidth = MediaQuery.of(context).size.width;
    double featuredHeight = screenWidth * 9 / 16;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen destacada (se mantiene estática)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: featuredHeight,
                color: Colors.grey[900],
                child: Image.asset(
                  'assets/harry_potter_big.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: featuredHeight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Continuar viendo (Lista Estática)
          _buildHorizontalList(continuarViendo, title: 'Continuar viendo'),
          const SizedBox(height: 20),

          // Top en México (¡AHORA USA DATOS DE LA API!)
          _buildHorizontalList(_pokemonList, title: 'Top en México (Cargado por API)'),
          const SizedBox(height: 20),

          // Sugerencias a tus gustos (Lista Estática)
          _buildHorizontalList(sugerencias, title: 'Sugerencias a tus gustos'),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: TabBar(
          controller: _tabController,
          indicatorColor: Colors.greenAccent,
          labelColor: Colors.greenAccent,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Inicio'),
            Tab(text: 'Películas'),
            Tab(text: 'Series'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          const Center(
              child: Text('Películas', style: TextStyle(color: Colors.white))),
          const Center(
              child: Text('Series', style: TextStyle(color: Colors.white))),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black, 
        type: BottomNavigationBarType.fixed, 
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Mi cuenta'),
        ],
        onTap: (index) {
          if (index < _tabController.length) {
            _tabController.animateTo(index);
          }
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}