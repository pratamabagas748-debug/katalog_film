import 'package:flutter/material.dart';
import 'home_view.dart';
import 'top_rated_view.dart';
import 'favorites_view.dart';
import 'watchlist_view.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeView(),
    const TopRatedView(),
    const FavoritesView(),
    const WatchlistView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: const Color(0xFFE50914),
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.movie_filter_outlined),
              activeIcon: Icon(Icons.movie_filter_rounded),
              label: 'Tren',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_border_rounded),
              activeIcon: Icon(Icons.star_rounded),
              label: 'Terbaik',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border_rounded),
              activeIcon: Icon(Icons.favorite_rounded),
              label: 'Favorit',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_border_rounded),
              activeIcon: Icon(Icons.bookmark_rounded),
              label: 'Watchlist',
            ),
          ],
        ),
      ),
    );
  }
}
