import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../viewmodels/movie_viewmodel.dart';
import 'detail_view.dart';

class TopRatedView extends StatelessWidget {
  const TopRatedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rating Tertinggi', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<MovieViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.topRatedState == ViewState.loading && viewModel.topRatedMovies.isEmpty) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 165,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                ),
              ),
            );
          } else if (viewModel.topRatedState == ViewState.error && viewModel.topRatedMovies.isEmpty) {
            return Center(child: Text('Oops: ${viewModel.errorMessage}'));
          } else if (viewModel.topRatedMovies.isEmpty) {
            return const Center(child: Text('Tidak ada film.'));
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.fetchTopRatedMovies(),
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 50) {
                  viewModel.loadMoreTopRatedMovies();
                }
                return false;
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.all(16),
                itemCount: viewModel.topRatedMovies.length + (viewModel.isFetchingMoreTopRated ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (index >= viewModel.topRatedMovies.length) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 165,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      ),
                    );
                  }

                  final movie = viewModel.topRatedMovies[index];
                  final heroTag = 'top_rated_poster_${movie.id}';
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => DetailView(movie: movie, heroTag: heroTag)));
                    },
                    child: Container(
                      height: 165,
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
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
