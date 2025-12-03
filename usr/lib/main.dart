import 'package:flutter/material.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minesweeper XP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Tahoma', // Classic XP font feel
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const GameScreen(),
      },
    );
  }
}
