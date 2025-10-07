import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../widgets/results_button.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key, required this.imagePath});
  final String imagePath;

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  static const _bg = Color(0xFF0B1020);

  // Fake "model" duration
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
    // Lottie loading with debug info
    return SizedBox(
      width: 180,
      height: 180,
      child: Lottie.asset(
        'assets/icons/lottie_files/Loading.json',
        repeat: true,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) {
          print('Loading Lottie error: $error');
          print('Stack trace: $stack');
          return const Center(child: CircularProgressIndicator(strokeWidth: 6));
        },
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
              ] else ...[
                const SizedBox(height: 8),
                const Text(
                  'DONE!',
                  style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                ResultsButton(imagePath: widget.imagePath),
              ],
            ],
          ),
        ),
      ),
    );
  }
}