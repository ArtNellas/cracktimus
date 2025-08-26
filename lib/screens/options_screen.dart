import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'camera_screen.dart';

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  static const _background = Color(0xFF0B1020);
  static const _primaryBlue = Color(0xFF1E63FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(fontSize: 44, height: 1.15, fontWeight: FontWeight.w700),
                    children: [
                      TextSpan(text: 'Select an\n', style: TextStyle(color: Colors.white)),
                      TextSpan(text: 'Option:', style: TextStyle(color: _primaryBlue)),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Upload from gallery (placeholder)
                _FullWidthButton(
                  label: 'Upload an image',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Upload an image tapped')),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Use Phone Camera (asks permission then opens CameraScreen)
                _FullWidthButton(
                  label: 'Use Phone Camera',
                  onPressed: () async {
                    final ok = await _ensureCameraPermission(context);
                    if (!ok) return;
                    if (!context.mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CameraScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _ensureCameraPermission(BuildContext context) async {
    final proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Allow Camera Access?'),
        content: const Text('Cracktimus uses your camera to capture a photo of the crack for analysis.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Not now')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Continue')),
        ],
      ),
    );
    if (proceed != true) return false;

    final status = await Permission.camera.request();
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      final open = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Camera Disabled'),
          content: const Text('Enable camera access in Settings to use this feature.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Open Settings')),
          ],
        ),
      );
      if (open == true) await openAppSettings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission denied')),
      );
    }
    return false;
  }
}

class _FullWidthButton extends StatelessWidget {
  const _FullWidthButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: OptionsScreen._primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
