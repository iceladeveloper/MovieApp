import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Lista horizontal con imágenes, títulos y Stack con ícono
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
                    // Ícono de "play" centrado sobre la imagen
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          decoration: BoxDecoration(
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
                    item['title'],
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

          // Continuar viendo
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Continuar viendo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildHorizontalList(continuarViendo),
          const SizedBox(height: 20),

          // Top en México
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Top en México',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildHorizontalList(topMexico),
          const SizedBox(height: 20),

          // Sugerencias a tus gustos
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Sugerencias a tus gustos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildHorizontalList(sugerencias),
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
          _tabController.animateTo(index);
        },
      ),
    );
  }
}
