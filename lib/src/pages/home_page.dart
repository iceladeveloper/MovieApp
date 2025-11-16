import 'package:flutter/material.dart';
import 'movie_detail_page.dart';
import 'movie.dart';
import 'search_page.dart';
import 'account_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  // Datos de ejemplo (listas horizontales)
  final List<Map<String, dynamic>> continuarViendo = [
    {'title': 'Amor Oculto', 'image': 'assets/amor_oculto.jpg'},
    {'title': 'Young Sheldon', 'image': 'assets/young_sheldon.jpg'},
    {'title': 'The Big Bang Theory', 'image': 'assets/big_bang.jpg'},
  ];

  final List<Map<String, dynamic>> topMexico = [
    {'title': 'One Piece', 'image': 'assets/one_piece.jpg'},
    {'title': 'Harry Potter', 'image': 'assets/harry_potter.jpg'},
    {'title': 'Malcolm', 'image': 'assets/malcolm.jpg'},
  ];

  final List<Map<String, dynamic>> sugerencias = [
    {'title': 'Shrek 2', 'image': 'assets/shrek2.jpg'},
    {'title': 'Harry Potter', 'image': 'assets/harry_potter.jpg'},
    {'title': 'Game of Thrones', 'image': 'assets/game_of_thrones.jpg'},
  ];

  // Catálogo desde Firebase
  List<Movie> peliculasFirebase = [];
  List<Movie> seriesFirebase = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMovies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMovies() async {
    final pelis = await fetchMovies('peliculas');
    final seriesList = await fetchMovies('series');
    setState(() {
      peliculasFirebase = pelis;
      seriesFirebase = seriesList;
      loading = false;
    });
  }

  Future<List<Movie>> fetchMovies(String collection) async {
    final snapshot = await FirebaseFirestore.instance.collection(collection).get();
    return snapshot.docs
        .map((doc) => Movie.fromMap(doc.id, doc.data()))
        .toList();
  }

  Widget _buildHorizontalList(List<Map<String, dynamic>> items) {
    double screenWidth = MediaQuery.of(context).size.width;
    double imageWidth = screenWidth * 0.3;
    double imageHeight = imageWidth * 9 / 16;

    return SizedBox(
      height: imageHeight + 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: imageWidth,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        item['image'],
                        fit: BoxFit.cover,
                        width: imageWidth,
                        height: imageHeight,
                      ),
                    ),
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
                Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHomeTab() {
    double screenWidth = MediaQuery.of(context).size.width;
    double featuredHeight = screenWidth * 9 / 16;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen destacada
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

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Continuar viendo',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent),
            ),
          ),
          const SizedBox(height: 8),
          _buildHorizontalList(continuarViendo),
          const SizedBox(height: 20),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Top en México',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent),
            ),
          ),
          const SizedBox(height: 8),
          _buildHorizontalList(topMexico),
          const SizedBox(height: 20),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Sugerencias a tus gustos',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent),
            ),
          ),
          const SizedBox(height: 8),
          _buildHorizontalList(sugerencias),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildCatalogTab(List<Movie> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => MovieDetailPage(movie: item)));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> get _bottomPages => [
        Scaffold(
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
              loading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCatalogTab(peliculasFirebase),
              loading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCatalogTab(seriesFirebase),
            ],
          ),
        ),
        const SearchPage(),
        const AccountPage(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bottomPages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.greenAccent.shade100,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey.shade700,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Mi cuenta'),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
