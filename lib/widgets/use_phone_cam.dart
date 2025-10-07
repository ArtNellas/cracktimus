import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../screens/camera_screen.dart';

class UsePhoneCamButton extends StatelessWidget {
  const UsePhoneCamButton({super.key});

  static const primaryBlue = Color(0xFF1E63FF);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () async {
            final ok = await _ensureCameraPermission(context);
            if (!context.mounted || !ok) return;

            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CameraScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          child: const Text('USE PHONE CAMERA'),
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
    if (!context.mounted) return false;

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
