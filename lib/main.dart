import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CracktimusApp());
}

class CracktimusApp extends StatelessWidget {
  const CracktimusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cracktimus',
      home: HomeScreen(),
    );
  }
}
