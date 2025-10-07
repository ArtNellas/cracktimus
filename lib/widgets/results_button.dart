import 'package:flutter/material.dart';
import '../screens/results_screen.dart';

class ResultsButton extends StatelessWidget {
  const ResultsButton({super.key, required this.imagePath});

  final String imagePath;
  static const primaryBlue = Color(0xFF1E63FF);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          // Placeholder outputs. Swap with real predictions later.
          const crackPresent = true;
          const grade = CrackGrade.moderate;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ResultsScreen(
                imagePath: imagePath,
                crackPresent: crackPresent,
                grade: grade,
                // Example overlays just to visualize boxes (0..1 relative coords)
                overlays: const [
                  BoxOverlay(fracRect: Rect.fromLTWH(0.36, 0.10, 0.28, 0.18), color: Colors.red),
                  BoxOverlay(fracRect: Rect.fromLTWH(0.40, 0.37, 0.22, 0.16), color: Colors.amber),
                  BoxOverlay(fracRect: Rect.fromLTWH(0.44, 0.62, 0.22, 0.18), color: Colors.blue),
                ],
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: const Text('See Results'),
      ),
    );
  }
}
