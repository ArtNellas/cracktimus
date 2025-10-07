import 'package:flutter/material.dart';

class CameraButton extends StatelessWidget {
  const CameraButton({super.key, this.size = 78, required this.onPressed});
  
  final double size;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(width: 6, color: const Color(0xFF4C84FF)),
        ),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        ),
      ),
    );
  }
}
