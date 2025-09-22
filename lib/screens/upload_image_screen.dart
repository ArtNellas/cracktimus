import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'photo_preview_screen.dart';
import 'analyze_screen.dart';

class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({super.key});

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  static const background = Color(0xFF0B1020);
  static const primaryBlue = Color(0xFF1E63FF);

  final ImagePicker _picker = ImagePicker();
  XFile? _picked;

  Future<void> _pickFromGallery() async {
    try {
      final XFile? x = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 4000,
        imageQuality: 95,
      );
      if (!mounted) return;
      setState(() => _picked = x);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open gallery: $e')),
      );
    }
  }

  Future<void> _confirmAndAnalyze() async {
    if (_picked == null) return;

    // Optional preview screen (allows user to confirm/retake)
    final String? confirmedPath = await Navigator.of(context).push<String?>(
      MaterialPageRoute(
        builder: (_) => PhotoPreviewScreen(imagePath: _picked!.path),
      ),
    );
    if (!mounted || confirmedPath == null) return;

    // 👉 Push Analyze (loading) screen
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AnalyzeScreen(imagePath: confirmedPath)),
    );
    // After Analyze, we stay on Upload screen; user can pick again or back out.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text('Upload'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _picked == null
                    ? Text(
                        'Pick a photo from your gallery',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(color: Colors.white70),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Image.file(File(_picked!.path), fit: BoxFit.cover),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickFromGallery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Choose from Gallery'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _picked != null ? _confirmAndAnalyze : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.white10,
                      disabledForegroundColor: Colors.white38,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
