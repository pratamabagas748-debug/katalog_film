import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie.dart';
import '../viewmodels/movie_viewmodel.dart';
import 'person_detail_view.dart';

class DetailView extends StatelessWidget {
  final Movie movie;
  final String heroTag;

  const DetailView({super.key, required this.movie, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 400.0,
            pinned: true,
            // Membuat tombol kembali (back) menjadi sangat jelas dan tidak menyatu dengan gambar
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: heroTag,
                    child: CachedNetworkImage(
                      imageUrl: movie.posterUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Theme.of(context).scaffoldBackgroundColor),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 100),
                    ),
                  ),
                  // Gradient Overlay for smooth transition
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Theme.of(context).scaffoldBackgroundColor,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          movie.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Consumer<MovieViewModel>(
                        builder: (context, viewModel, child) {
                          return Row(
                            children: [
                              FutureBuilder<bool>(
                                future: viewModel.isWatchlist(movie.id),
                                builder: (context, snapshot) {
                                  final isWatchlist = snapshot.data ?? false;
                                  return GestureDetector(
                                    onTap: () {
                                      viewModel.toggleWatchlist(movie);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(isWatchlist ? 'Dihapus dari Watchlist' : 'Ditambahkan ke Watchlist!'),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isWatchlist ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isWatchlist ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                                        color: isWatchlist ? Colors.blue : Colors.grey,
                                        size: 28,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              FutureBuilder<bool>(
                                future: viewModel.isFavorite(movie.id),
                                builder: (context, snapshot) {
                                  final isFav = snapshot.data ?? false;
                                  return GestureDetector(
                                    onTap: () {
                                      viewModel.toggleFavorite(movie);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(isFav ? 'Dihapus dari Favorit' : 'Disimpan ke Favorit!'),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isFav ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                        color: isFav ? Colors.redAccent : Colors.grey,
                                        size: 28,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${movie.voteAverage.toStringAsFixed(1)} / 10',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Populer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Consumer<MovieViewModel>(
                    builder: (context, viewModel, child) {
                      return FutureBuilder<String?>(
                        future: viewModel.getMovieTrailer(movie.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final trailerKey = snapshot.data;
                          if (trailerKey == null) return const SizedBox.shrink();

                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final url = Uri.parse('https://www.youtube.com/watch?v=$trailerKey');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Tidak dapat membuka trailer')),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                              label: const Text(
                                'Tonton Trailer',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Sinopsis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer<MovieViewModel>(
                    builder: (context, viewModel, child) {
                      return FutureBuilder<String>(
                        future: viewModel.getTranslatedOverview(movie.id, movie.overview),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return Text(
                            snapshot.data ?? movie.overview,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Pemeran (Cast)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<MovieViewModel>(
                    builder: (context, viewModel, child) {
                      return FutureBuilder<List<Map<String, dynamic>>>(
                        future: viewModel.getMovieCast(movie.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('Data pemeran tidak tersedia.');
                          }

                          final castList = snapshot.data!.take(10).toList();

                          return SizedBox(
                            height: 150,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: castList.length,
                              itemBuilder: (context, index) {
                                final cast = castList[index];
                                final profilePath = cast['profile_path'];
                                final imageUrl = profilePath != null 
                                  ? 'https://image.tmdb.org/t/p/w200$profilePath'
                                  : 'https://via.placeholder.com/200x300?text=No+Image';

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (_) => PersonDetailView(person: cast),
                                    ));
                                  },
                                  child: Container(
                                    width: 100,
                                    margin: const EdgeInsets.only(right: 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              color: Colors.grey.withOpacity(0.3),
                                            ),
                                            errorWidget: (context, url, error) => Container(
                                              color: Colors.grey.withOpacity(0.3),
                                              child: const Icon(Icons.person, color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          cast['name'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          cast['character'] ?? '',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Film Serupa',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Consumer<MovieViewModel>(
                    builder: (context, viewModel, child) {
                      return FutureBuilder<List<Movie>>(
                        future: viewModel.getSimilarMovies(movie.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('Tidak ada film serupa.');
                          }

                          final similarMovies = snapshot.data!;
                          return SizedBox(
                            height: 250,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: similarMovies.length,
                              itemBuilder: (context, index) {
                                final simMovie = similarMovies[index];
                                final simHeroTag = 'similar_${movie.id}_${simMovie.id}';
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(context, MaterialPageRoute(
                                      builder: (_) => DetailView(movie: simMovie, heroTag: simHeroTag),
                                    ));
                                  },
                                  child: Container(
                                    width: 140,
                                    margin: const EdgeInsets.only(right: 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Hero(
                                            tag: simHeroTag,
                                            child: CachedNetworkImage(
                                              imageUrl: simMovie.posterUrl,
                                              height: 200,
                                              width: 140,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Container(color: Colors.grey.withOpacity(0.2)),
                                              errorWidget: (context, url, error) => Container(color: Colors.grey.withOpacity(0.2), child: const Icon(Icons.movie)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          simMovie.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
