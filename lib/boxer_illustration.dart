import 'package:flutter/material.dart';
import 'models.dart';
import 'theme.dart';

class BoxerIllustration extends StatefulWidget {
  const BoxerIllustration({
    super.key,
    required this.pose,
    this.height = 280,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  final Pose pose;
  final double height;
  final BoxFit fit;
  final Alignment alignment;

  @override
  State<BoxerIllustration> createState() => _BoxerIllustrationState();
}

class _BoxerIllustrationState extends State<BoxerIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _scale = Tween(begin: .985, end: 1.015).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _asset => switch (widget.pose) {
        Pose.jab || Pose.cross || Pose.hook =>
          'assets/images/athlete_cross.jpg',
        _ => 'assets/images/athlete_guard.jpg',
      };

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
            ScaleTransition(
              scale: _scale,
              child: Image.asset(
                _asset,
                fit: widget.fit,
                alignment: widget.alignment,
                filterQuality: FilterQuality.high,
              ),
            ),
          ],
        ),
      );
}
