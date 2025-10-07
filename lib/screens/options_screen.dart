import 'package:flutter/material.dart';

import '../widgets/upload_image_button.dart';
import '../widgets/use_phone_cam.dart';

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

                // Upload from gallery — friendly modal, no Android runtime perms.
                const UploadImageButton(),
                const SizedBox(height: 16),

                // Use camera
                const UsePhoneCamButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
