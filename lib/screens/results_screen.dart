import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/save_pdf.dart';
import '../widgets/return_to_home.dart';

enum CrackGrade { none, slight, moderate, severe }

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({
    super.key,
    required this.imagePath,
    required this.crackPresent,
    required this.grade,
    this.overlays = const [],
  });

  final String imagePath;
  final bool crackPresent;
  final CrackGrade grade;

  /// Optional list of overlay boxes in fractional coords (0..1).
  final List<BoxOverlay> overlays;

  static const _bg = Color(0xFF0B1020);
  static const _tileBg = Color(0xFF071127);

  Color _gradeColor(CrackGrade g) {
    switch (g) {
      case CrackGrade.none:
        return Colors.grey;
      case CrackGrade.slight:
        return const Color(0xFF4CAF50); // green
      case CrackGrade.moderate:
        return const Color(0xFFFFC107); // amber
      case CrackGrade.severe:
        return const Color(0xFFE53935); // red
    }
  }

  String _gradeText(CrackGrade g) {
    switch (g) {
      case CrackGrade.none:
        return 'None';
      case CrackGrade.slight:
        return 'Slight';
      case CrackGrade.moderate:
        return 'Moderate';
      case CrackGrade.severe:
        return 'Severe';
    }
  }

  String _poa(CrackGrade g) {
    switch (g) {
      case CrackGrade.none:
        return 'No crack detected. No action needed. Optionally monitor over time.';
      case CrackGrade.slight:
        return 'Hairline/minor. Monitor monthly; sealant or filler is optional.';
      case CrackGrade.moderate:
        return 'Noticeable damage. Repair is recommended; professionals are optional.';
      case CrackGrade.severe:
        return 'Significant damage suspected. Contact a professional immediately; reduce load and document the area.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradeColor = _gradeColor(grade);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content with top margin to avoid button overlap
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
              child: Column(
                children: [
                  // Image with overlays
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: double.infinity,
                      color: _tileBg,
                      padding: const EdgeInsets.all(18),
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: LayoutBuilder(
                          builder: (context, box) {
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(File(imagePath), fit: BoxFit.contain),
                                // Draw overlay boxes on top
                                ...overlays.map((b) {
                                  return _FractionalBorder(
                                    rect: b.fracRect,
                                    color: b.color,
                                    borderWidth: 4,
                                  );
                                }),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info rows
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0x142244FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(
                          label: 'Crack:',
                          value: crackPresent ? 'Present' : 'None',
                          valueStyle: TextStyle(
                            color: crackPresent ? const Color(0xFF1E63FF) : Colors.white70,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _InfoRow(
                          label: 'Grade:',
                          value: _gradeText(grade),
                          valueStyle: TextStyle(
                            color: gradeColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('P.O.A.:',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(
                          _poa(grade),
                          style: const TextStyle(color: Colors.white70, height: 1.25),
                        ),
                      ],
                    ),
                  ),
                  
                  // Spacer to push content up
                  const Spacer(),
                ],
              ),
            ),
            // Top-left home button
            Positioned(
              top: 8,
              left: 8,
              child: ReturnToHomeButton(),
            ),
            // Top-right PDF button
            Positioned(
              top: 8,
              right: 8,
              child: SavePdfButton(
                imagePath: imagePath,
                crackPresent: crackPresent,
                grade: _gradeText(grade),
                overlays: overlays,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple "Label: Value" row
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label ',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        Flexible(
          child: Text(
            value,
            style: valueStyle ?? const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Model for overlay rectangles
class BoxOverlay {
  const BoxOverlay({required this.fracRect, required this.color});
  /// Fractional rect in [0..1] (x,y,width,height) relative to the image box.
  final Rect fracRect;
  final Color color;
}

/// Paints a rectangular border using fractional coordinates.
class _FractionalBorder extends StatelessWidget {
  const _FractionalBorder({
    required this.rect,
    required this.color,
    this.borderWidth = 3,
  });

  final Rect rect; // 0..1
  final Color color;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final left = rect.left * w;
        final top = rect.top * h;
        final width = rect.width * w;
        final height = rect.height * h;

        return Positioned(
          left: left,
          top: top,
          width: width,
          height: height,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: color, width: borderWidth),
              ),
            ),
          ),
        );
      },
    );
  }
}
