import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';
  final List<Map<String, dynamic>> results = [
    {'title': 'Matrix Resurrections'},
    {'title': 'Inception'},
    {'title': 'Stranger Things'},
  ]; // Ejemplo, luego puede ser API

  @override
  Widget build(BuildContext context) {
    final filtered = results
        .where((item) =>
            item['title'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Buscar'),
      ),
      backgroundColor: Colors.black87,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar películas o series...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
              ),
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return ListTile(
                  title: Text(
                    item['title'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    // Aquí podrías abrir MovieDetailPage si quieres
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
