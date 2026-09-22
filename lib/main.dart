import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()..loadTasks()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadThemeMode()),
      ],
      child: const TodoApp(),
    ),
  );
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;

    final lightBase = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      useMaterial3: true,
    );
    final darkBase = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'مهامي',
      debugShowCheckedModeBanner: false,
      // خط Cairo العربي عبر google_fonts (له fallback تلقائي لو ما في إنترنت)
      theme: lightBase.copyWith(
        textTheme: GoogleFonts.cairoTextTheme(lightBase.textTheme),
      ),
      darkTheme: darkBase.copyWith(
        textTheme: GoogleFonts.cairoTextTheme(darkBase.textTheme),
      ),
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
