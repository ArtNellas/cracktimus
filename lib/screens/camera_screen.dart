import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lottie/lottie.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, this.initialDirection = CameraLensDirection.back});
  final CameraLensDirection initialDirection;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with TickerProviderStateMixin {
  static const background = Color(0xFF0B1020);

  // <- update filename if needed (.lottie OR .json)
  static const String _flipLottiePath = 'assets/icons/lottie_files/camera_flip.lottie';

  List<CameraDescription> _cameras = const [];
  CameraController? _controller;
  CameraDescription? _current;

  late final AnimationController _flipCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

  bool _busy = false;
  bool? _flipAssetAvailable;

  @override
  void initState() {
    super.initState();
    _checkFlipAsset();
    _init();
  }

  Future<void> _checkFlipAsset() async {
    try {
      await rootBundle.load(_flipLottiePath);
      if (mounted) setState(() => _flipAssetAvailable = true);
    } catch (_) {
      if (mounted) setState(() => _flipAssetAvailable = false);
    }
  }

  Future<void> _init() async {
    try {
      _cameras = await availableCameras();
      await _switchTo(widget.initialDirection);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera init failed: $e')),
      );
    }
  }

  CameraDescription? _find(CameraLensDirection dir) {
    try {
      return _cameras.firstWhere((c) => c.lensDirection == dir);
    } catch (_) {
      return _cameras.isNotEmpty ? _cameras.first : null;
    }
  }

  Future<void> _switchTo(CameraLensDirection dir) async {
    final target = _find(dir);
    if (target == null) return;
    if (_current?.name == target.name) return;

    final prev = _controller;
    final next = CameraController(
      target,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    setState(() => _controller = next);
    try {
      await next.initialize();
      if (!mounted) return;
      setState(() => _current = target);
    } finally {
      await prev?.dispose();
    }
  }

  Future<void> _toggleCamera() async {
    try {
      await _flipCtrl.forward(from: 0);
    } catch (_) {}
    final next = _current?.lensDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    await _switchTo(next);
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized || _busy) return;
    setState(() => _busy = true);
    try {
      final xfile = await _controller!.takePicture();
      if (!mounted) return;
      Navigator.of(context).pop(xfile);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to capture: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _flipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    // Flip button content (safe fallback if asset missing)
    Widget flipIcon;
    if (_flipAssetAvailable == true) {
      flipIcon = Lottie.asset(
        _flipLottiePath,
        controller: _flipCtrl,
        repeat: false,
        height: 40,
        width: 40,
      );
    } else {
      flipIcon = const Icon(Icons.cameraswitch_rounded, color: Colors.white, size: 32);
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text('Camera'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ToggleButtons(
              isSelected: [
                _current?.lensDirection == CameraLensDirection.back,
                _current?.lensDirection == CameraLensDirection.front,
              ],
              borderRadius: BorderRadius.circular(12),
              constraints: const BoxConstraints(minHeight: 36, minWidth: 56),
              selectedColor: Colors.white,
              color: Colors.white70,
              fillColor: const Color(0x331E63FF),
              onPressed: (index) =>
                  _switchTo(index == 0 ? CameraLensDirection.back : CameraLensDirection.front),
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('Back')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('Front')),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    color: const Color(0xFF0B1020),
                    alignment: Alignment.center,
                    child: (controller != null && controller.value.isInitialized)
                        ? AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: CameraPreview(controller),
                          )
                        : const CircularProgressIndicator(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _toggleCamera,
                    tooltip: 'Switch camera',
                    iconSize: 40,
                    icon: SizedBox(height: 40, width: 40, child: Center(child: flipIcon)),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: _busy ? null : _capture,
                    child: Container(
                      width: 74,
                      height: 74,
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
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
