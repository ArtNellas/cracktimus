import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'results_screen.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key, required this.imagePath});
  final String imagePath;

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  static const _bg = Color(0xFF0B1020);
  static const _primaryBlue = Color(0xFF1E63FF);

  // Fake “model” duration
  static const Duration _fakeDuration = Duration(seconds: 4);

  Timer? _timer;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_fakeDuration, () {
      if (!mounted) return;
      setState(() => _done = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _loader() {
    // Lottie if available; otherwise a spinner (no red error box).
    return SizedBox(
      width: 180,
      height: 180,
      child: Lottie.asset(
        'assets/icons/lottie_files/Loading.lottie',
        repeat: true,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            const Center(child: CircularProgressIndicator(strokeWidth: 6)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: Text(_done ? 'Loading Complete' : 'Analyzing'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Image preview tile (no stretch)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF0A1327),
                  padding: const EdgeInsets.all(18),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (!_done) ...[
                _loader(),
                const SizedBox(height: 12),
                const Text(
                  'Analyzing…',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This is a temporary loader while the ML model runs.',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                const SizedBox(height: 8),
                const Text(
                  'DONE!',
                  style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                SizedBox(
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
                            imagePath: widget.imagePath,
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
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    child: const Text('See Results'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
