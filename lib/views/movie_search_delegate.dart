import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../viewmodels/movie_viewmodel.dart';
import 'detail_view.dart';

class MovieSearchDelegate extends SearchDelegate<Movie?> {
  @override
  String get searchFieldLabel => 'Cari film...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // When user submits the search
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieViewModel>(context, listen: false).searchMovies(query, saveToHistory: true);
    });

    return Consumer<MovieViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.searchState == ViewState.loading) {
          return const Center(child: CircularProgressIndicator());
        } else if (viewModel.searchState == ViewState.error) {
          return Center(child: Text('Oops: ${viewModel.errorMessage}'));
        } else if (viewModel.searchResults.isEmpty) {
          return Center(child: Text('Tidak ditemukan film untuk "$query".'));
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: viewModel.searchResults.length,
          itemBuilder: (context, index) {
            final movie = viewModel.searchResults[index];
            final heroTag = 'search_poster_${movie.id}';
            return ListTile(
              leading: Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: movie.posterUrl,
                    width: 50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(width: 50, color: Colors.grey[300]),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                  ),
                ),
              ),
              title: Text(movie.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(movie.voteAverage.toStringAsFixed(1)),
                ],
              ),
              onTap: () {
                Provider.of<MovieViewModel>(context, listen: false).addRecentSearch(movie.title);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DetailView(movie: movie, heroTag: heroTag)));
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Consumer<MovieViewModel>(
        builder: (context, viewModel, child) {
          final recentSearches = viewModel.recentSearches;
          if (recentSearches.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Ketik judul film untuk mencari.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pencarian Terakhir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextButton(
                      onPressed: () => viewModel.clearRecentSearches(),
                      child: const Text('Hapus Semua', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: recentSearches.length,
                  itemBuilder: (context, index) {
                    final recentQuery = recentSearches[index];
                    return ListTile(
                      leading: const Icon(Icons.history, color: Colors.grey),
                      title: Text(recentQuery),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => viewModel.removeRecentSearch(recentQuery),
                      ),
                      onTap: () {
                        query = recentQuery;
                        showResults(context);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    }
    
    // Call search API as user types (debounce could be added in ViewModel)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieViewModel>(context, listen: false).searchMovies(query);
    });

    return Consumer<MovieViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.searchState == ViewState.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: viewModel.searchResults.length,
          itemBuilder: (context, index) {
            final movie = viewModel.searchResults[index];
            final heroTag = 'search_sugg_poster_${movie.id}';
            return ListTile(
              leading: Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: movie.posterUrl,
                    width: 50,
                    height: 75,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(width: 50, height: 75, color: Colors.grey[300]),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                  ),
                ),
              ),
              title: Text(movie.title),
              subtitle: Text(movie.voteAverage.toStringAsFixed(1)),
              onTap: () {
                Provider.of<MovieViewModel>(context, listen: false).addRecentSearch(movie.title);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DetailView(movie: movie, heroTag: heroTag)));
              },
            );
          },
        );
      },
    );
  }
}
