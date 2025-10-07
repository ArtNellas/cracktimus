import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../screens/upload_image_screen.dart';

class UploadImageButton extends StatelessWidget {
  const UploadImageButton({super.key});

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
            final ok = await _ensurePhotosPermission(context);
            if (!context.mounted || !ok) return;

            // Just open the picker screen; it will handle Analyze navigation.
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UploadImageScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          child: const Text('UPLOAD AN IMAGE'),
        ),
      ),
    );
  }

  /// ANDROID: no runtime permission (uses Photo Picker). iOS: request Photos.
  Future<bool> _ensurePhotosPermission(BuildContext context) async {
    final proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Allow Photo Library Access?'),
        content: const Text('Cracktimus needs access to your photos to select an image for analysis.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Not now')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Continue')),
        ],
      ),
    );
    if (proceed != true) return false;

    if (Platform.isAndroid) return true; // A13+ Photo Picker, older handled by image_picker

    final status = await Permission.photos.request();
    if (!context.mounted) return false;
    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied || status.isRestricted) {
      final open = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Photos Permission Disabled'),
          content: const Text('Enable photo access in Settings to pick an image.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Open Settings')),
          ],
        ),
      );
      if (open == true) await openAppSettings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo access denied')),
      );
    }
    return false;
  }
}
