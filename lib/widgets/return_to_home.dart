import 'package:flutter/material.dart';

class ReturnToHomeButton extends StatelessWidget {
  const ReturnToHomeButton({super.key});

  static const primaryBlue = Color(0xFF1E63FF);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate back to the home screen (main screen)
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          borderRadius: BorderRadius.circular(36),
          child: const Center(
            child: Icon(
              Icons.home,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
      ),
    );
  }
}
