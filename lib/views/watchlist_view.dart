import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../viewmodels/movie_viewmodel.dart';
import 'detail_view.dart';

class WatchlistView extends StatelessWidget {
  const WatchlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Consumer<MovieViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.watchlistMovies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border_rounded, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada Watchlist',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan film ke daftar tontonan!',
                    style: TextStyle(color: Colors.grey.shade500),
                  )
                ],
              ),
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.watchlistMovies.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final movie = viewModel.watchlistMovies[index];
              final heroTag = 'watch_poster_${movie.id}';
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailView(movie: movie, heroTag: heroTag)),
                  ).then((_) {
                    viewModel.loadWatchlist(); // Refresh after returning
                  });
                },
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Hero(
                        tag: heroTag,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: movie.posterUrl,
                            width: 100,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: Colors.grey.shade300),
                            errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                movie.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    movie.voteAverage.toStringAsFixed(1),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                movie.overview,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              )
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.bookmark_remove_rounded, color: Colors.blue),
                        onPressed: () {
                          viewModel.toggleWatchlist(movie);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${movie.title} dihapus dari Watchlist')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
