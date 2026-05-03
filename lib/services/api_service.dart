import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String _apiKey = '32878f87e5047bd6d3233c665bce16b6'; 
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    try {
      // Menggunakan language=en-US agar judul dan genre tetap dalam bahasa aslinya
      final response = await http.get(Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey&language=en-US&page=$page&include_adult=false'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return _filterAdultContent(results.map((e) => Movie.fromJson(e)).toList());
      } else {
        return _getMockPopularMovies(); 
      }
    } catch (e) {
      return _getMockPopularMovies(); 
    }
  }

  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/movie/top_rated?api_key=$_apiKey&language=en-US&page=$page&include_adult=false'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return _filterAdultContent(results.map((e) => Movie.fromJson(e)).toList());
      } else {
        return _getMockTopRatedMovies(); 
      }
    } catch (e) {
      return _getMockTopRatedMovies(); 
    }
  }

  Future<List<Map<String, dynamic>>> getGenres() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/genre/movie/list?api_key=$_apiKey&language=en-US'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List genres = data['genres'];
        return genres.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/discover/movie?api_key=$_apiKey&language=en-US&page=$page&with_genres=$genreId&include_adult=false'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return _filterAdultContent(results.map((e) => Movie.fromJson(e)).toList());
      } else {
        return []; 
      }
    } catch (e) {
      return []; 
    }
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&language=en-US&query=$query&page=$page&include_adult=false'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return _filterAdultContent(results.map((e) => Movie.fromJson(e)).toList());
      } else {
        return []; 
      }
    } catch (e) {
      return []; 
    }
  }

  Future<String?> getMovieTrailer(int movieId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/movie/$movieId/videos?api_key=$_apiKey&language=en-US'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        if (results.isNotEmpty) {
          final trailer = results.firstWhere(
            (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
            orElse: () => results.first,
          );
          return trailer['key'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getMovieCast(int movieId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/movie/$movieId/credits?api_key=$_apiKey&language=en-US'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List cast = data['cast'];
        return cast.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<String> getMovieOverviewInIndonesian(int movieId, String fallbackOverview) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/movie/$movieId?api_key=$_apiKey&language=id-ID'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final overview = data['overview'];
        if (overview != null && overview.toString().trim().isNotEmpty) {
          return overview.toString();
        }
      }
      return fallbackOverview;
    } catch (e) {
      return fallbackOverview;
    }
  }

  Future<List<Movie>> getSimilarMovies(int movieId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/movie/$movieId/similar?api_key=$_apiKey&language=en-US&page=1&include_adult=false'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return _filterAdultContent(results.map((e) => Movie.fromJson(e)).toList());
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPersonDetails(int personId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/person/$personId?api_key=$_apiKey&language=en-US'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Movie>> getPersonMovies(int personId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/person/$personId/movie_credits?api_key=$_apiKey&language=en-US'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['cast'];
        return _filterAdultContent(results.map((e) => Movie.fromJson(e)).toList());
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Filter ekstra di sisi aplikasi untuk memblokir film yang tidak ditandai dewasa oleh TMDB (seperti dokumenter)
  List<Movie> _filterAdultContent(List<Movie> movies) {
    // Blacklist kata (lebih agresif, tidak hanya \b)
    final blacklist = [
      'porn', 'sex', 'erotic', 'kamasutra', 'nympho', 'lust', 'desire', 'seduction', 
      '18+', 'nsfw', 'sensual', 'playboy', 'kinky', 'bdsm', 'fetish', 'incest',
      'stepmom', 'stepbro', 'stepdad', 'stepsis', 'escort', 'brothel', 'prostitute',
      'kamasutra', 'orgasm', 'nudity', 'naked', 'melena', 'malena', 'malèna',
      'hot', 'balinsasayaw', "les exploits d'un jeune don juan",
      "l'infermiera di notte", 'rita', 'nefeli', "je m'appelle agneta", 'tayuan'
    ];
    
    // Blacklist ID film yang sering lolos dari filter (seperti dokumenter "After Porn Ends")
    final blockedIds = [
      447200, // After Porn Ends 2
      392044, // After Porn Ends 3
      117565, // After Porn Ends
      10874,  // Malèna
      // Tambahkan ID lain di sini jika ditemukan
    ];
    
    return movies.where((movie) {
      if (blockedIds.contains(movie.id)) return false;

      final title = movie.title.toLowerCase();
      final overview = movie.overview.toLowerCase();
      
      for (final word in blacklist) {
        if (title.contains(word) || overview.contains(word)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<Movie> _getMockPopularMovies() {
    return [
      Movie(id: 693134, title: "Dune: Part Two", overview: "Paul Atreides bersatu...", posterPath: "https://dummyimage.com/500x750/cccccc/000000.jpg&text=Dune+Part+Two", voteAverage: 8.3),
      Movie(id: 1011985, title: "Kung Fu Panda 4", overview: "Po bersiap...", posterPath: "https://dummyimage.com/500x750/cccccc/000000.jpg&text=Kung+Fu+Panda+4", voteAverage: 7.1),
      Movie(id: 823464, title: "Godzilla x Kong", overview: "Setelah pertarungan...", posterPath: "https://dummyimage.com/500x750/cccccc/000000.jpg&text=Godzilla+x+Kong", voteAverage: 7.2),
      Movie(id: 359410, title: "Road House", overview: "Mantan petarung UFC...", posterPath: "https://dummyimage.com/500x750/cccccc/000000.jpg&text=Road+House", voteAverage: 7.0),
      Movie(id: 1096197, title: "No Way Up", overview: "Karakter-karakter...", posterPath: "https://dummyimage.com/500x750/cccccc/000000.jpg&text=No+Way+Up", voteAverage: 6.3),
      Movie(id: 787699, title: "Wonka", overview: "Willy Wonka...", posterPath: "https://dummyimage.com/500x750/cccccc/000000.jpg&text=Wonka", voteAverage: 7.2),
      Movie(id: 1016084, title: "Madame Web", overview: "Dipaksa untuk menghadapi...", posterPath: "https://dummyimage.com/500x750/cccccc/000000.jpg&text=Madame+Web", voteAverage: 5.6),
      Movie(id: 609681, title: "The Marvels", overview: "Carol Danvers...", posterPath: "https://dummyimage.com/500x750/cccccc/000000.jpg&text=The+Marvels", voteAverage: 6.2),
      Movie(id: 866398, title: "The Beekeeper", overview: "Kampanye balas...", posterPath: "https://dummyimage.com/500x750/cccccc/000000.jpg&text=The+Beekeeper", voteAverage: 7.5),
      Movie(id: 1072790, title: "Anyone But You", overview: "Setelah kencan...", posterPath: "https://dummyimage.com/500x750/cccccc/000000.jpg&text=Anyone+But+You", voteAverage: 7.1),
    ];
  }

  List<Movie> _getMockTopRatedMovies() {
    return [
      Movie(id: 238, title: "The Godfather", overview: "Mencakup tahun 1945...", posterPath: "https://dummyimage.com/500x750/cccccc/000000.jpg&text=The+Godfather", voteAverage: 8.7),
      Movie(id: 278, title: "The Shawshank Redemption", overview: "Dijebak pada tahun...", posterPath: "https://dummyimage.com/500x750/cccccc/000000.jpg&text=The+Shawshank+Redemption", voteAverage: 8.7),
      Movie(id: 240, title: "The Godfather Part II", overview: "Dalam kisah lanjutan...", posterPath: "https://dummyimage.com/500x750/cccccc/000000.jpg&text=The+Godfather+Part+II", voteAverage: 8.6),
      Movie(id: 424, title: "Schindler's List", overview: "Kisah nyata tentang...", posterPath: "https://dummyimage.com/500x750/cccccc/000000.jpg&text=Schindler's+List", voteAverage: 8.6),
      Movie(id: 19404, title: "Dilwale Dulhania Le Jayenge", overview: "Raj adalah pria kaya...", posterPath: "https://dummyimage.com/500x750/cccccc/000000.jpg&text=DDLJ", voteAverage: 8.5),
      Movie(id: 129, title: "Spirited Away", overview: "Seorang gadis muda...", posterPath: "https://dummyimage.com/500x750/cccccc/000000.jpg&text=Spirited+Away", voteAverage: 8.5),
      Movie(id: 389, title: "12 Angry Men", overview: "Sidang pengadilan...", posterPath: "https://dummyimage.com/500x750/cccccc/000000.jpg&text=12+Angry+Men", voteAverage: 8.5),
      Movie(id: 372058, title: "Your Name.", overview: "Dua anak SMA...", posterPath: "https://dummyimage.com/500x750/cccccc/000000.jpg&text=Your+Name", voteAverage: 8.5),
      Movie(id: 496243, title: "Parasite", overview: "Semuanya menganggur...", posterPath: "https://dummyimage.com/500x750/cccccc/000000.jpg&text=Parasite", voteAverage: 8.5),
      Movie(id: 155, title: "The Dark Knight", overview: "Batman meningkatkan...", posterPath: "https://dummyimage.com/500x750/cccccc/000000.jpg&text=The+Dark+Knight", voteAverage: 8.5),
    ];
  }
}
