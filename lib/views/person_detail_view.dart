import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/movie.dart';
import '../viewmodels/movie_viewmodel.dart';
import 'detail_view.dart';

class PersonDetailView extends StatelessWidget {
  final Map<String, dynamic> person;

  const PersonDetailView({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MovieViewModel>(context, listen: false);
    final personId = person['id'];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(person['name'] ?? 'Detail Pemeran'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Profile Picture
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  imageUrl: person['profile_path'] != null 
                    ? 'https://image.tmdb.org/t/p/w300${person['profile_path']}'
                    : 'https://via.placeholder.com/300x300?text=No+Image',
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(width: 150, height: 150, color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 150, height: 150,
                    color: Colors.grey.withOpacity(0.3),
                    child: const Icon(Icons.person, size: 80, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              person['name'] ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Person Details FutureBuilder
            FutureBuilder<Map<String, dynamic>?>(
              future: viewModel.getPersonDetails(personId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final details = snapshot.data;
                if (details == null) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (details['birthday'] != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text('Lahir: ${details['birthday']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      if (details['place_of_birth'] != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text('Tempat Lahir: ${details['place_of_birth']}', style: TextStyle(color: Colors.grey[700])),
                        ),
                      const Text(
                        'Biografi',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        details['biography']?.isNotEmpty == true 
                            ? details['biography'] 
                            : 'Biografi tidak tersedia.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Film Lainnya',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Person Movies FutureBuilder
            FutureBuilder<List<Movie>>(
              future: viewModel.getPersonMovies(personId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('Tidak ada data film.'),
                  );
                }

                final movies = snapshot.data!;
                return SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      final heroTag = 'person_${personId}_movie_${movie.id}';
                      
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => DetailView(movie: movie, heroTag: heroTag),
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
                                  tag: heroTag,
                                  child: CachedNetworkImage(
                                    imageUrl: movie.posterUrl,
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
                                movie.title,
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
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
