import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'models.dart';
import 'theme.dart';

/// Displays the real movement associated with an exercise.
/// The short clips are bundled with the app, so playback works offline.
class BoxerIllustration extends StatefulWidget {
  const BoxerIllustration({
    super.key,
    required this.pose,
    this.height = 280,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.playing = true,
  });

  final Pose pose;
  final double height;
  final BoxFit fit;
  final Alignment alignment;
  final bool playing;

  @override
  State<BoxerIllustration> createState() => _BoxerIllustrationState();
}

class _BoxerIllustrationState extends State<BoxerIllustration> {
  VideoPlayerController? _controller;
  bool _ready = false;

  String get _videoAsset => switch (widget.pose) {
        Pose.jab => 'assets/videos/jab.mp4',
        Pose.cross => 'assets/videos/cross.mp4',
        Pose.hook => 'assets/videos/hook.mp4',
        Pose.slip => 'assets/videos/slip.mp4',
        Pose.footwork => 'assets/videos/footwork.mp4',
        _ => 'assets/videos/guard.mp4',
      };

  String get _fallbackAsset => switch (widget.pose) {
        Pose.jab || Pose.cross || Pose.hook =>
          'assets/images/athlete_cross.jpg',
        _ => 'assets/images/athlete_guard.jpg',
      };

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  @override
  void didUpdateWidget(covariant BoxerIllustration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pose != widget.pose) {
      _loadVideo();
    } else if (oldWidget.playing != widget.playing) {
      _syncPlayback();
    }
  }

  Future<void> _loadVideo() async {
    final previous = _controller;
    final controller = VideoPlayerController.asset(_videoAsset);
    _controller = controller;
    if (mounted) setState(() => _ready = false);
    await previous?.dispose();
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      if (!mounted || controller != _controller) {
        await controller.dispose();
        return;
      }
      setState(() => _ready = true);
      _syncPlayback();
    } catch (_) {
      if (mounted && controller == _controller) setState(() => _ready = false);
    }
  }

  void _syncPlayback() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    widget.playing ? controller.play() : controller.pause();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -.15),
                  radius: .72,
                  colors: [
                    AppColors.blue.withValues(alpha: .20),
                    AppColors.ink.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            if (_ready && _controller != null)
              FittedBox(
                fit: widget.fit,
                alignment: widget.alignment,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              )
            else
              Image.asset(
                _fallbackAsset,
                fit: widget.fit,
                alignment: widget.alignment,
                filterQuality: FilterQuality.high,
              ),
            Positioned(
              right: 10,
              bottom: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: .72),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      widget.playing ? Icons.motion_photos_on : Icons.pause,
                      color: AppColors.lime,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      widget.playing ? 'MOUVEMENT' : 'EN PAUSE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .7,
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ],
        ),
      );
}
