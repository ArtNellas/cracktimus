import 'package:flutter/material.dart';
import '../screens/options_screen.dart';

class StartButton extends StatelessWidget {
  const StartButton({super.key});

  static const primaryBlue = Color(0xFF1E63FF);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OptionsScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          child: const Text('Start Analysis'),
        ),
      ),
    );
  }
}
