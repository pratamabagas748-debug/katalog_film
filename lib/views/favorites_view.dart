import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../viewmodels/movie_viewmodel.dart';
import 'detail_view.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<MovieViewModel>(context, listen: false).loadFavorites();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Film Favorit', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<MovieViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.favoriteMovies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.heart_broken_rounded, size: 80, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada film favorit.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.favoriteMovies.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final movie = viewModel.favoriteMovies[index];
              final heroTag = 'fav_poster_${movie.id}';
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailView(movie: movie, heroTag: heroTag),
                    ),
                  ).then((_) {
                    Provider.of<MovieViewModel>(context, listen: false).loadFavorites();
                  });
                },
                child: Container(
                  height: 120,
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
                            width: 80,
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    movie.voteAverage.toStringAsFixed(1),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
                        onPressed: () {
                          viewModel.toggleFavorite(movie);
                        },
                      ),
                      const SizedBox(width: 8),
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
