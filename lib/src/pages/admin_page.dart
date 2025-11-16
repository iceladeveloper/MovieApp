import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'movie.dart';
import 'movie_detail_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool loading = true;
  List<Movie> movies = [];

  // Controladores
  final TextEditingController titleController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController directorController = TextEditingController();
  final TextEditingController genreController = TextEditingController();
  final TextEditingController synopsisController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  @override
  void dispose() {
    titleController.dispose();
    yearController.dispose();
    directorController.dispose();
    genreController.dispose();
    synopsisController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadMovies() async {
    final snapshot = await firestore.collection('peliculas').get();
    setState(() {
      movies = snapshot.docs
          .map((doc) => Movie.fromMap(doc.id, doc.data()))
          .toList();
      loading = false;
    });
  }

  Future<void> _addMovie() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.black87,
            title: const Text('Agregar Película', style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(controller: titleController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Título', labelStyle: TextStyle(color: Colors.grey))),
                  TextField(controller: yearController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Año', labelStyle: TextStyle(color: Colors.grey))),
                  TextField(controller: directorController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Director', labelStyle: TextStyle(color: Colors.grey))),
                  TextField(controller: genreController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Género', labelStyle: TextStyle(color: Colors.grey))),
                  TextField(controller: synopsisController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Sinopsis', labelStyle: TextStyle(color: Colors.grey))),
                  TextField(controller: imageUrlController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'URL de Imagen', labelStyle: TextStyle(color: Colors.grey))),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final data = {
                    'title': titleController.text,
                    'year': yearController.text,
                    'director': directorController.text,
                    'genre': genreController.text,
                    'synopsis': synopsisController.text,
                    'imageUrl': imageUrlController.text,
                  };
                  await firestore.collection('peliculas').add(data);
                  Navigator.pop(context);
                  _loadMovies();
                },
                child: const Text('Agregar'),
              ),
            ],
          );
        });
  }

  Future<void> _deleteMovie(String id) async {
    await firestore.collection('peliculas').doc(id).delete();
    _loadMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addMovie,
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return ListTile(
                  leading: movie.imageUrl.isNotEmpty
                      ? Image.network(
                          movie.imageUrl,
                          width: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie),
                        )
                      : const Icon(Icons.movie),
                  title: Text(movie.title, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(movie.genre, style: const TextStyle(color: Colors.grey)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteMovie(movie.id),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MovieDetailPage(movie: movie)));
                  },
                );
              },
            ),
    );
  }
}
