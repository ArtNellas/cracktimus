import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SavePdfButton extends StatefulWidget {
  const SavePdfButton({
    super.key,
    required this.imagePath,
    required this.crackPresent,
    required this.grade,
    required this.overlays,
  });

  final String imagePath;
  final bool crackPresent;
  final String grade;
  final List<dynamic> overlays; // BoxOverlay list

  @override
  State<SavePdfButton> createState() => _SavePdfButtonState();
}

class _SavePdfButtonState extends State<SavePdfButton>
    with TickerProviderStateMixin {
  late final AnimationController _animController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  bool _isGenerating = false;

  static const String _pdfLottieAsset = 'assets/icons/lottie_files/animation_pdf_editor_fixed_syntax.json';

  @override
  void initState() {
    super.initState();
    // Start the animation to make it visible
    _animController.repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _getPlanOfAction(String grade) {
    switch (grade.toLowerCase()) {
      case 'none':
        return 'No crack detected. No action needed. Optionally monitor over time.';
      case 'slight':
        return 'Hairline/minor. Monitor monthly; sealant or filler is optional.';
      case 'moderate':
        return 'Noticeable damage. Repair is recommended; professionals are optional.';
      case 'severe':
        return 'Significant damage suspected. Contact a professional immediately; reduce load and document the area.';
      default:
        return 'Assessment complete. Please review recommendations.';
    }
  }

  Future<void> _generatePdf() async {
    if (_isGenerating) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      // Trigger animation
      _animController.forward(from: 0);

      // Create PDF document
      final pdf = pw.Document();

      // Load image
      final imageFile = File(widget.imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final image = pw.MemoryImage(imageBytes);

      // Get plan of action
      final planOfAction = _getPlanOfAction(widget.grade);

      // Add page to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Crack Analysis Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Date
              pw.Text(
                'Generated: ${DateTime.now().toString().split('.')[0]}',
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 20),

              // Image with title
              pw.Text(
                'Analyzed Image',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Image(
                  image,
                  height: 300,
                  fit: pw.BoxFit.contain,
                ),
              ),
              pw.SizedBox(height: 30),

              // Results section
              pw.Text(
                'Analysis Results',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 15),

              // Results table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FixedColumnWidth(100),
                  1: const pw.FlexColumnWidth(),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Crack Detected:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(widget.crackPresent ? 'Yes' : 'No'),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Severity Grade:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(widget.grade),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Plan of Action
              pw.Text(
                'Recommended Plan of Action',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Text(
                  planOfAction,
                  style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
                ),
              ),
              pw.SizedBox(height: 30),

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                'Report generated by Cracktimus - Crack Detection App',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                textAlign: pw.TextAlign.center,
              ),
            ];
          },
        ),
      );

      // Open print preview dialog with save option
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'crack_analysis_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF generated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isGenerating ? null : _generatePdf,
          borderRadius: BorderRadius.circular(36),
          child: Center(
            child: SizedBox(
              width: 56,
              height: 56,
              child: _isGenerating
                  ? const CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Lottie.asset(
                      _pdfLottieAsset,
                      controller: _animController,
                      repeat: true,
                      width: 56,
                      height: 56,
                      fit: BoxFit.contain,
                      animate: true,
                      frameRate: FrameRate.max,
                      errorBuilder: (context, error, stack) {
                        print('Lottie error: $error');
                        // If PDF animation fails, use a simple PDF icon with rotation animation
                        return AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _animController.value * 2 * 3.14159,
                              child: const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.white,
                                size: 36,
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}