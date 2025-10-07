import 'package:flutter/material.dart';
import '../widgets/start_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0B1020);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logos/crack_logo.png', width: 140, height: 140),
                const SizedBox(height: 28),
                Image.asset('assets/logos/cracks_word.png', width: 300, fit: BoxFit.contain),
                const SizedBox(height: 14),
                const Text(
                  'Is that crack safe?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.3, letterSpacing: 0.2),
                ),
                const SizedBox(height: 40),
                const StartButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
