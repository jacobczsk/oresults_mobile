import 'package:flutter/material.dart';
import 'competitions_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const OResultsMobile());
}

class OResultsMobile extends StatelessWidget {
  const OResultsMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OResults Mobile',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue, brightness: Brightness.light),
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue, brightness: Brightness.dark),
        textTheme: GoogleFonts.interTextTheme(
            ThemeData(brightness: Brightness.dark).textTheme),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const CompetitionsPage(),
    );
  }
}
