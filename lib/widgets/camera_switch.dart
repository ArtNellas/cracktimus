import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CameraSwitchButton extends StatelessWidget {
  const CameraSwitchButton({
    super.key,
    required this.onPressed,
    required this.animationController,
    this.size = 40,
  });

  final VoidCallback onPressed;
  final AnimationController animationController;
  final double size;

  // Lottie flip icon assets
  static const String _flipLottieBundle = 'assets/icons/lottie_files/camera_flip.json';

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      iconSize: size,
      tooltip: 'Switch camera',
      icon: SizedBox(
        height: size,
        width: size,
        child: Center(
          child: _buildFlipIcon(),
        ),
      ),
      color: Colors.white,
    );
  }

  /// Build the flip icon with direct Lottie loading:
  Widget _buildFlipIcon() {
    return Lottie.asset(
      _flipLottieBundle,
      controller: animationController,
      repeat: false,
      height: size,
      width: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) {
        print('Lottie loading error: $error');
        print('Stack trace: $stack');
        return const Icon(Icons.cameraswitch_rounded, color: Colors.white, size: 32);
      },
    );
  }
}
