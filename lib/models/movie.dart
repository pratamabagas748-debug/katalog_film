class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final double voteAverage;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Tanpa Judul',
      overview: json['overview'] ?? 'Tidak ada sinopsis',
      posterPath: json['poster_path'] ?? '',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'posterPath': posterPath,
      'voteAverage': voteAverage,
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'],
      title: map['title'],
      overview: map['overview'],
      posterPath: map['posterPath'],
      voteAverage: map['voteAverage'],
    );
  }

  String get posterUrl {
    if (posterPath.isEmpty) {
      return 'https://via.placeholder.com/500x750?text=Tidak+Ada+Gambar';
    }
    if (posterPath.startsWith('http')) {
      return posterPath;
    }
    // Menggunakan image proxy i0.wp.com (Jetpack Photon) sebagai alternatif
    // atau gunakan URL langsung jika tidak diblokir ISP:
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }
}
