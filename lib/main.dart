import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'viewmodels/movie_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'views/main_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeViewModel>(
      builder: (context, themeVM, child) {
        return MaterialApp(
          title: 'MovieDex',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFE50914), // Netflix Red
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              centerTitle: true,
            ),
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            cardColor: Colors.white,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFE50914),
              brightness: Brightness.dark,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: Color(0xFF141414), // Premium Dark
              foregroundColor: Colors.white,
              centerTitle: true,
            ),
            scaffoldBackgroundColor: const Color(0xFF141414), // Premium Dark
            cardColor: const Color(0xFF1F1F1F),
          ),
          themeMode: themeVM.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const MainScreen(),
        );
      },
    );
  }
}
