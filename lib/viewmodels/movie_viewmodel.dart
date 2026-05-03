import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';
import '../models/movie.dart';
import '../services/api_service.dart';
import '../services/db_service.dart';

enum ViewState { loading, success, error }

class MovieViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DbService _dbService = DbService();
  final GoogleTranslator _translator = GoogleTranslator();
  final Map<String, String> _translatedOverviewsCache = {};

  ViewState _state = ViewState.loading;
  ViewState get state => _state;
  
  ViewState _topRatedState = ViewState.loading;
  ViewState get topRatedState => _topRatedState;

  List<Movie> _movies = [];
  List<Movie> get movies => _movies;

  List<Movie> _topRatedMovies = [];
  List<Movie> get topRatedMovies => _topRatedMovies;

  List<Movie> _favoriteMovies = [];
  List<Movie> get favoriteMovies => _favoriteMovies;

  List<Movie> _watchlistMovies = [];
  List<Movie> get watchlistMovies => _watchlistMovies;

  List<Movie> _searchResults = [];
  List<Movie> get searchResults => _searchResults;
  
  ViewState _searchState = ViewState.success; // Initial state isn't loading
  ViewState get searchState => _searchState;

  List<String> _recentSearches = [];
  List<String> get recentSearches => _recentSearches;

  int _popularPage = 1;
  int _topRatedPage = 1;

  List<Map<String, dynamic>> _genres = [];
  List<Map<String, dynamic>> get genres => _genres;

  int? _selectedGenreId;
  int? get selectedGenreId => _selectedGenreId;

  bool _isFetchingMorePopular = false;
  bool get isFetchingMorePopular => _isFetchingMorePopular;

  bool _isFetchingMoreTopRated = false;
  bool get isFetchingMoreTopRated => _isFetchingMoreTopRated;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  MovieViewModel() {
    fetchGenres();
    fetchMovies();
    fetchTopRatedMovies();
    loadFavorites();
    loadWatchlist();
    loadRecentSearches();
  }

  Future<void> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches = prefs.getStringList('recent_searches') ?? [];
    notifyListeners();
  }

  Future<void> addRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    
    _recentSearches.remove(trimmed);
    _recentSearches.insert(0, trimmed);
    if (_recentSearches.length > 10) {
      _recentSearches.removeLast();
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', _recentSearches);
    notifyListeners();
  }

  Future<void> removeRecentSearch(String query) async {
    _recentSearches.remove(query);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', _recentSearches);
    notifyListeners();
  }

  Future<void> clearRecentSearches() async {
    _recentSearches.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    notifyListeners();
  }

  Future<void> fetchGenres() async {
    _genres = await _apiService.getGenres();
    notifyListeners();
  }

  void setGenre(int? genreId) {
    if (_selectedGenreId == genreId) {
      _selectedGenreId = null; 
    } else {
      _selectedGenreId = genreId;
    }
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    _state = ViewState.loading;
    _popularPage = 1;
    notifyListeners();

    try {
      if (_selectedGenreId != null) {
        _movies = await _apiService.getMoviesByGenre(_selectedGenreId!, page: _popularPage);
      } else {
        _movies = await _apiService.getPopularMovies(page: _popularPage);
      }
      _state = ViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    }
    notifyListeners();
  }

  Future<void> loadMorePopularMovies() async {
    if (_isFetchingMorePopular || _state != ViewState.success) return;
    
    _isFetchingMorePopular = true;
    notifyListeners();

    try {
      _popularPage++;
      List<Movie> newMovies;
      if (_selectedGenreId != null) {
        newMovies = await _apiService.getMoviesByGenre(_selectedGenreId!, page: _popularPage);
      } else {
        newMovies = await _apiService.getPopularMovies(page: _popularPage);
      }
      _movies.addAll(newMovies);
    } catch (e) {
      // Handle error implicitly or show a snackbar in view
    } finally {
      _isFetchingMorePopular = false;
      notifyListeners();
    }
  }

  Future<void> fetchTopRatedMovies() async {
    _topRatedState = ViewState.loading;
    _topRatedPage = 1;
    notifyListeners();

    try {
      _topRatedMovies = await _apiService.getTopRatedMovies(page: _topRatedPage);
      _topRatedState = ViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _topRatedState = ViewState.error;
    }
    notifyListeners();
  }

  Future<void> loadMoreTopRatedMovies() async {
    if (_isFetchingMoreTopRated || _topRatedState != ViewState.success) return;
    
    _isFetchingMoreTopRated = true;
    notifyListeners();

    try {
      _topRatedPage++;
      final newMovies = await _apiService.getTopRatedMovies(page: _topRatedPage);
      _topRatedMovies.addAll(newMovies);
    } catch (e) {
      // Error handling
    } finally {
      _isFetchingMoreTopRated = false;
      notifyListeners();
    }
  }

  Future<void> searchMovies(String query, {bool saveToHistory = false}) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _searchState = ViewState.success;
      notifyListeners();
      return;
    }

    _searchState = ViewState.loading;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchMovies(query);
      _searchState = ViewState.success;
      if (saveToHistory && _searchResults.isNotEmpty) {
        addRecentSearch(query);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _searchState = ViewState.error;
    }
    notifyListeners();
  }


  Future<void> loadFavorites() async {
    _favoriteMovies = await _dbService.getFavorites();
    notifyListeners();
  }

  Future<void> toggleFavorite(Movie movie) async {
    final isFav = await _dbService.isFavorite(movie.id);
    if (isFav) {
      await _dbService.removeFavorite(movie.id);
    } else {
      await _dbService.addFavorite(movie);
    }
    await loadFavorites();
  }

  Future<bool> isFavorite(int id) async {
    return await _dbService.isFavorite(id);
  }

  Future<void> loadWatchlist() async {
    _watchlistMovies = await _dbService.getWatchlist();
    notifyListeners();
  }

  Future<void> toggleWatchlist(Movie movie) async {
    final isWatchlist = await _dbService.isWatchlist(movie.id);
    if (isWatchlist) {
      await _dbService.removeWatchlist(movie.id);
    } else {
      await _dbService.addWatchlist(movie);
    }
    await loadWatchlist();
  }

  Future<bool> isWatchlist(int id) async {
    return await _dbService.isWatchlist(id);
  }

  Future<String?> getMovieTrailer(int id) async {
    return await _apiService.getMovieTrailer(id);
  }

  Future<List<Map<String, dynamic>>> getMovieCast(int id) async {
    return await _apiService.getMovieCast(id);
  }

  Future<String> getTranslatedOverview(int movieId, String fallbackOverview) async {
    // Coba ambil dari TMDB bahasa Indonesia terlebih dahulu
    final tmdbIndo = await _apiService.getMovieOverviewInIndonesian(movieId, fallbackOverview);
    
    // Jika TMDB punya terjemahan (teks berbeda, asumsi TMDB mengembalikan teks Inggris jika gagal)
    if (tmdbIndo != fallbackOverview && tmdbIndo.trim().isNotEmpty) {
      return tmdbIndo;
    }

    // Jika TMDB tidak punya, kita paksa terjemahkan menggunakan Google Translate API
    if (fallbackOverview.isEmpty) return "";
    
    if (_translatedOverviewsCache.containsKey(fallbackOverview)) {
      return _translatedOverviewsCache[fallbackOverview]!;
    }

    try {
      final translation = await _translator.translate(fallbackOverview, to: 'id');
      _translatedOverviewsCache[fallbackOverview] = translation.text;
      return translation.text;
    } catch (e) {
      return fallbackOverview;
    }
  }

  Future<List<Movie>> getSimilarMovies(int movieId) async {
    return await _apiService.getSimilarMovies(movieId);
  }

  Future<Map<String, dynamic>?> getPersonDetails(int personId) async {
    return await _apiService.getPersonDetails(personId);
  }

  Future<List<Movie>> getPersonMovies(int personId) async {
    return await _apiService.getPersonMovies(personId);
  }
}
