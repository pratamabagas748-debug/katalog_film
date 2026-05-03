import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../viewmodels/movie_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';
import 'detail_view.dart';
import 'movie_search_delegate.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeVM = Provider.of<ThemeViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sedang Tren', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              showSearch(context: context, delegate: MovieSearchDelegate());
            },
          ),
          IconButton(
            icon: Icon(themeVM.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
            onPressed: () => themeVM.toggleTheme(),
          ),
        ],
      ),
      body: Consumer<MovieViewModel>(
        builder: (context, viewModel, child) {
          Widget content;
          if (viewModel.state == ViewState.loading && viewModel.movies.isEmpty) {
            content = GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 16, mainAxisSpacing: 16,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                ),
              ),
            );
          } else if (viewModel.state == ViewState.error && viewModel.movies.isEmpty) {
            content = Center(child: Text('Oops: ${viewModel.errorMessage}'));
          } else if (viewModel.movies.isEmpty) {
            content = const Center(child: Text('Tidak ada film.'));
          } else {
            content = RefreshIndicator(
              onRefresh: () => viewModel.fetchMovies(),
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 50) {
                    viewModel.loadMorePopularMovies();
                  }
                  return false;
                },
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: viewModel.movies.length + (viewModel.isFetchingMorePopular ? 2 : 0),
                  itemBuilder: (context, index) {
                    if (index >= viewModel.movies.length) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
                      );
                    }
                    
                    final movie = viewModel.movies[index];
                    final heroTag = 'home_poster_${movie.id}';
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => DetailView(movie: movie, heroTag: heroTag)));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Hero(
                                tag: heroTag,
                                child: CachedNetworkImage(
                                  imageUrl: movie.posterUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(color: Theme.of(context).cardColor),
                                  errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50),
                                ),
                              ),
                              Positioned(
                                bottom: 0, left: 0, right: 0,
                                child: Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    movie.title,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 2, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8, right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        movie.voteAverage.toStringAsFixed(1),
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (viewModel.genres.isNotEmpty)
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: viewModel.genres.length,
                    itemBuilder: (context, index) {
                      final genre = viewModel.genres[index];
                      final isSelected = viewModel.selectedGenreId == genre['id'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(genre['name']),
                          selected: isSelected,
                          onSelected: (selected) {
                            viewModel.setGenre(genre['id']);
                          },
                          showCheckmark: false,
                          selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? Theme.of(context).colorScheme.primary : null,
                            fontWeight: isSelected ? FontWeight.bold : null,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }
}
