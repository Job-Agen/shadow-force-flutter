import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'models.dart';
import 'theme.dart';

class BoxerIllustration extends StatefulWidget {
  const BoxerIllustration({super.key, required this.pose, this.height = 280});
  final Pose pose;
  final double height;

  @override
  State<BoxerIllustration> createState() => _BoxerIllustrationState();
}

class _BoxerIllustrationState extends State<BoxerIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 950))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: widget.height,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => CustomPaint(
            painter: _BoxerPainter(widget.pose, Curves.easeInOut.transform(_controller.value)),
          ),
        ),
      );
}

class _BoxerPainter extends CustomPainter {
  _BoxerPainter(this.pose, this.t);
  final Pose pose;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .47);
    final glow = Paint()
      ..color = AppColors.blue.withValues(alpha: .14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35);
    canvas.drawCircle(center, size.shortestSide * .31, glow);

    final line = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final accent = Paint()
      ..color = AppColors.lime
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: .3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final slip = pose == Pose.slip ? (t - .5) * 24 : 0.0;
    final bounce = pose == Pose.breathe ? math.sin(t * math.pi) * 3 : math.sin(t * math.pi) * 6;
    final head = Offset(center.dx + slip, size.height * .20 + bounce);
    final shoulder = Offset(center.dx, size.height * .34 + bounce);
    final hip = Offset(center.dx, size.height * .60 + bounce);

    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, size.height * .89), width: 155, height: 20),
      shadow,
    );
    canvas.drawCircle(head, 28, Paint()..color = const Color(0xFF8E573B));
    canvas.drawArc(Rect.fromCircle(center: head, radius: 30), math.pi, math.pi, false,
        Paint()..color = const Color(0xFF151515)..strokeWidth = 9..style = PaintingStyle.stroke);
    canvas.drawLine(shoulder, hip, line);

    final leftFoot = Offset(center.dx - 48, size.height * .88);
    final rightFoot = Offset(center.dx + (pose == Pose.footwork ? 62 + 18 * t : 48), size.height * .88);
    canvas.drawLine(hip, Offset(center.dx - 22, size.height * .73), line);
    canvas.drawLine(Offset(center.dx - 22, size.height * .73), leftFoot, line);
    canvas.drawLine(hip, Offset(center.dx + 22, size.height * .73), line);
    canvas.drawLine(Offset(center.dx + 22, size.height * .73), rightFoot, line);

    var leadHand = Offset(center.dx - 26, size.height * .28);
    var rearHand = Offset(center.dx + 28, size.height * .29);
    if (pose == Pose.jab) leadHand = Offset(center.dx - 30 - 80 * t, size.height * .30);
    if (pose == Pose.cross) rearHand = Offset(center.dx + 30 + 86 * t, size.height * .29);
    if (pose == Pose.hook) leadHand = Offset(center.dx - 38 - 52 * t, size.height * (.31 + .08 * t));
    if (pose == Pose.strength) {
      leadHand = Offset(center.dx - 58, size.height * .67);
      rearHand = Offset(center.dx + 58, size.height * .67);
    }
    canvas.drawLine(shoulder + const Offset(-12, 4), leadHand, line);
    canvas.drawLine(shoulder + const Offset(12, 4), rearHand, line);
    canvas.drawCircle(leadHand, 12, accent);
    canvas.drawCircle(rearHand, 12, accent);

    if ({Pose.jab, Pose.cross, Pose.hook}.contains(pose)) {
      final active = pose == Pose.jab ? leadHand : rearHand;
      canvas.drawCircle(active, 18 + 6 * t,
          Paint()..color = AppColors.lime.withValues(alpha: .12 + .1 * t));
    }
  }

  @override
  bool shouldRepaint(covariant _BoxerPainter oldDelegate) => oldDelegate.t != t || oldDelegate.pose != pose;
}
