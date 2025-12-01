import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/movie.dart';
import 'auth_service.dart'; // Importamos el AuthService para obtener el userId

class FirestoreService with ChangeNotifier {
  // Instancias de Firebase
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService;
  
  // Constante para el ID de la aplicación (proporcionada por el entorno)
  static const String _appId = 'movie_app_catalog'; 
  
  // Nombre de la colección dentro del path público
  static const String _collectionName = 'movies'; 

  // Estado del servicio
  List<Movie> _movies = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Stream Subscription para escuchar cambios en Firestore
  StreamSubscription<QuerySnapshot>? _moviesSubscription;

  // Getters para acceder al estado
  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor: Se inyecta el AuthService
  FirestoreService(this._authService) {
    // Inicializamos la escucha del catálogo
    _startListeningToMovies();
    
    // Escuchamos cambios en la autenticación (si el usuario cambia de anónimo a admin)
    _authService.addListener(_handleAuthChange);
  }

  // Maneja el cambio de estado de autenticación (Admin login/logout)
  void _handleAuthChange() {
    // Si la autenticación ha cambiado, reiniciamos la escucha del stream 
    // Esto es vital para asegurar que las reglas de seguridad se apliquen correctamente.
    _restartListeningToMovies();
    notifyListeners();
  }

  // Path de la colección pública (donde se guardan las películas)
  // /artifacts/{appId}/public/data/movies
  String get _publicCollectionPath => 
      'artifacts/$_appId/public/data/$_collectionName';

  // Obtiene la referencia a la colección de películas
  CollectionReference get _moviesCollectionRef => 
      _db.collection(_publicCollectionPath);

  // Inicia la escucha en tiempo real de la colección de películas
  void _startListeningToMovies() {
    // Si ya hay una suscripción activa, la cancelamos primero
    _moviesSubscription?.cancel();
    _moviesSubscription = null;

    // Marcamos como cargando antes de iniciar la petición
    _isLoading = true;
    notifyListeners();

    try {
      // Configuramos el listener en tiempo real (onSnapshot)
      _moviesSubscription = _moviesCollectionRef
          // Opcional: ordenar por título para consistencia
          .orderBy('title', descending: false)
          .snapshots()
          .listen((snapshot) {
            
        _movies = snapshot.docs.map((doc) {
          // Mapeamos el mapa de datos de Firestore a nuestro modelo Movie
          return Movie.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        }).cast<Movie>().toList();
        
        // Finalizamos la carga y limpiamos el error
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      }, onError: (error) {
        // Manejo de errores durante la escucha (ej: permisos denegados)
        _isLoading = false;
        _errorMessage = 'Error al escuchar el catálogo: $error';
        print('Firestore Error: $_errorMessage');
        notifyListeners();
      });
      
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al configurar el listener: $e';
      print('Setup Error: $_errorMessage');
      notifyListeners();
    }
  }

  // Reinicia la escucha (usado en login/logout)
  void _restartListeningToMovies() {
    _moviesSubscription?.cancel();
    _startListeningToMovies();
  }

  // ----------------------------------------------------
  // MÉTODOS CRUD (SOLO USADOS POR EL ADMINISTRADOR)
  // ----------------------------------------------------

  // Agrega una nueva película a Firestore
  Future<void> addMovie(Movie movie) async {
    // Aseguramos que el usuario es un administrador autenticado (no anónimo)
    if (_authService.currentUser?.isAnonymous ?? true) {
      throw Exception("Permiso denegado: Solo el administrador puede agregar películas.");
    }
    
    // Obtenemos un ID único para el documento
    final docRef = _moviesCollectionRef.doc(movie.imdbID);
    
    // Guardamos la película usando el ID de IMDB como ID de documento
    await docRef.set(movie.toFirestore());
  }

  // Elimina una película por su IMDB ID
  Future<void> deleteMovie(String imdbId) async {
    if (_authService.currentUser?.isAnonymous ?? true) {
      throw Exception("Permiso denegado: Solo el administrador puede eliminar películas.");
    }

    final docRef = _moviesCollectionRef.doc(imdbId);
    await docRef.delete();
  }
  
  // Obtiene el detalle de una película individual por su IMDB ID
  // Usado por MovieDetailScreen
  Future<Movie?> getMovieById(String imdbId) async {
    try {
      final docSnapshot = await _moviesCollectionRef.doc(imdbId).get();
      
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return Movie.fromFirestore(
          docSnapshot.data() as Map<String, dynamic>, 
          docSnapshot.id
        );
      }
      return null;
    } catch (e) {
      print('Error al obtener detalle de película: $e');
      return null;
    }
  }

  @override
  void dispose() {
    // Cancelamos la suscripción para evitar memory leaks
    _moviesSubscription?.cancel();
    _authService.removeListener(_handleAuthChange);
    super.dispose();
  }

  Stream<List<Movie>>? getMovies() {}
}