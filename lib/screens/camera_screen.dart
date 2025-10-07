import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'analyze_screen.dart';
import '../widgets/camera_button.dart';
import '../widgets/camera_switch.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, this.initialDirection = CameraLensDirection.back});
  final CameraLensDirection initialDirection;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  static const background = Color(0xFF0B1020);

  List<CameraDescription> _cameras = const [];
  CameraController? _controller;
  CameraLensDirection _currentDir = CameraLensDirection.back;

  bool _switching = false;
  bool _initializing = true;
  String? _error;

  late final AnimationController _flipCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flipCtrl.dispose();
    _disposeController();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _disposeController();
    } else if (state == AppLifecycleState.resumed) {
      _switchTo(_currentDir);
    }
  }

  Future<void> _init() async {
    try {
      _cameras = await availableCameras();
      _currentDir = widget.initialDirection;
      await _switchTo(_currentDir);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Camera init failed: $e';
        _initializing = false;
      });
    }
  }

  CameraDescription? _find(CameraLensDirection dir) {
    try {
      return _cameras.firstWhere((c) => c.lensDirection == dir);
    } catch (_) {
      return null;
    }
  }

  Future<void> _disposeController() async {
    final old = _controller;
    _controller = null;
    if (old != null) {
      try {
        await old.dispose();
      } catch (_) {}
    }
  }

  Future<void> _switchTo(CameraLensDirection dir) async {
    if (_switching) return;
    _switching = true;
    setState(() {
      _initializing = true;
      _error = null;
    });

    final desc = _find(dir);
    if (desc == null) {
      setState(() {
        _error = dir == CameraLensDirection.front
            ? 'Front camera not available on this device.'
            : 'Back camera not available on this device.';
        _initializing = false;
      });
      _switching = false;
      return;
    }

    // Dispose FIRST to avoid driver conflicts (prevents black preview on switch)
    await _disposeController();

    final format = defaultTargetPlatform == TargetPlatform.android
        ? ImageFormatGroup.yuv420
        : ImageFormatGroup.bgra8888;

    final controller = CameraController(
      desc,
      ResolutionPreset.medium, // If front feels sluggish, try ResolutionPreset.low
      enableAudio: false,
      imageFormatGroup: format,
    );

    try {
      await controller.initialize().timeout(const Duration(seconds: 6));
      if (!mounted) return;
      setState(() {
        _controller = controller;
        _currentDir = dir;
        _initializing = false;
      });
    } on TimeoutException {
      await controller.dispose();
      if (!mounted) return;
      setState(() {
        _error = 'Camera took too long to start. Try again.';
        _initializing = false;
      });
    } catch (e) {
      await controller.dispose();
      if (!mounted) return;
      setState(() {
        _error = 'Could not start camera: $e';
        _initializing = false;
      });
    } finally {
      _switching = false;
    }
  }

  Future<void> _toggleCamera() async {
    if (_switching) return;
    try {
      await _flipCtrl.forward(from: 0);
    } catch (_) {}
    final next = _currentDir == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    await _switchTo(next);
  }

  Future<void> _capture() async {
    final c = _controller;
    if (_switching || _initializing || c == null || !c.value.isInitialized) return;
    try {
      final file = await c.takePicture();
      if (!mounted) return;

      // Push the loading-only Analyze screen (placeholder ML time)
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AnalyzeScreen(imagePath: file.path)),
      );
      // Back on camera after loading screen is closed.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture: $e')),
      );
    }
  }

  /// Correct camera preview AR for current orientation (plugin reports landscape size).
  double _cameraAspectRatio(CameraController c, BoxConstraints box) {
    final isPortrait = box.maxHeight >= box.maxWidth;
    final size = c.value.previewSize!;
    return isPortrait ? (size.height / size.width) : (size.width / size.height);
  }

  /// Cover the container without stretching (like BoxFit.cover for CameraPreview).
  Widget _buildCoverPreview(CameraController c, BoxConstraints box) {
    final parentAR = box.maxWidth / box.maxHeight;
    final previewAR = _cameraAspectRatio(c, box);

    double width, height;
    if (parentAR > previewAR) {
      width = box.maxWidth;
      height = width / previewAR;
    } else {
      height = box.maxHeight;
      width = height * previewAR;
    }

    return ClipRect(
      child: OverflowBox(
        maxWidth: width,
        maxHeight: height,
        child: SizedBox(width: width, height: height, child: CameraPreview(c)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Camera'),
      ),
      body: Stack(
        children: [
          // --- full-bleed preview ---
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  color: Colors.black,
                  child: _initializing
                      ? const Center(child: CircularProgressIndicator())
                      : (_error != null)
                          ? _ErrorView(message: _error!, onRetry: () => _switchTo(_currentDir))
                          : (c != null && c.value.isInitialized)
                              ? LayoutBuilder(builder: (context, box) => _buildCoverPreview(c, box))
                              : _ErrorView(message: 'Camera not ready.', onRetry: () => _switchTo(_currentDir)),
                ),
              ),
            ),
          ),

          // --- controls overlay: bottom in portrait, right-side rail in landscape ---
          if (isPortrait)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.28)],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CameraSwitchButton(
                        onPressed: _toggleCamera,
                        animationController: _flipCtrl,
                        size: 40,
                      ),
                      const SizedBox(width: 28),
                      CameraButton(size: 78, onPressed: _capture),
                    ],
                  ),
                ),
              ),
            )
          else
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: SafeArea(
                left: false,
                child: Container(
                  width: 96,
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.28)],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CameraSwitchButton(
                        onPressed: _toggleCamera,
                        animationController: _flipCtrl,
                        size: 40,
                      ),
                      const SizedBox(height: 24),
                      CameraButton(size: 78, onPressed: _capture),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(message, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
      ]),
    );
  }
}
