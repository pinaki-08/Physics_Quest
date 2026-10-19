import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

enum CardArtKind { planet, target, rocket }

/// Hand-drawn illustrations for the three section cards. Drawn with a painter
/// so there are no image assets to ship, scale or license.
class CardArt extends StatelessWidget {
  final CardArtKind kind;
  final double size;

  const CardArt({super.key, required this.kind, this.size = 84});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _CardArtPainter(kind),
    );
  }
}

class _CardArtPainter extends CustomPainter {
  final CardArtKind kind;
  _CardArtPainter(this.kind);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100);
    switch (kind) {
      case CardArtKind.planet:
        _planet(canvas);
      case CardArtKind.target:
        _target(canvas);
      case CardArtKind.rocket:
        _rocket(canvas);
    }
  }

  void _planet(Canvas canvas) {
    const center = Offset(50, 52);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.38);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 96, height: 30),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = AppColors.sunshine.withValues(alpha: 0.85),
    );
    canvas.restore();

    canvas.drawCircle(center, 26, Paint()..color = Colors.white);
    canvas.drawCircle(
      const Offset(41, 44),
      9,
      Paint()..color = Colors.white.withValues(alpha: 0.0),
    );

    // Surface bands, clipped to the planet.
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: 26)));
    final band = Paint()..color = AppColors.learnDeep.withValues(alpha: 0.35);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(44, 40), width: 46, height: 12),
      band,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(58, 62), width: 40, height: 10),
      band,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.38);
    canvas.drawArc(
      Rect.fromCenter(center: Offset.zero, width: 96, height: 30),
      0,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = AppColors.sunshine,
    );
    canvas.restore();

    _star(canvas, const Offset(14, 16), 6);
    _star(canvas, const Offset(88, 26), 4.5);
    _star(canvas, const Offset(80, 84), 5);
  }

  void _target(Canvas canvas) {
    const center = Offset(46, 54);
    canvas.drawCircle(center, 30, Paint()..color = Colors.white);
    canvas.drawCircle(
        center, 22, Paint()..color = AppColors.practiceDeep.withValues(alpha: 0.55));
    canvas.drawCircle(center, 14, Paint()..color = Colors.white);
    canvas.drawCircle(center, 6, Paint()..color = AppColors.sunshine);

    // Dart flying in from the top right.
    final shaft = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(92, 12), const Offset(56, 44), shaft);

    final head = Path()
      ..moveTo(46, 54)
      ..lineTo(60, 40)
      ..lineTo(62, 52)
      ..close();
    canvas.drawPath(head, Paint()..color = AppColors.sunshine);

    final fletch = Path()
      ..moveTo(92, 12)
      ..lineTo(80, 14)
      ..lineTo(90, 24)
      ..close();
    canvas.drawPath(fletch, Paint()..color = Colors.white.withValues(alpha: 0.8));

    _star(canvas, const Offset(12, 24), 5);
    _star(canvas, const Offset(20, 88), 4.5);
  }

  void _rocket(Canvas canvas) {
    final body = Path()
      ..moveTo(50, 8)
      ..cubicTo(70, 26, 72, 48, 66, 68)
      ..lineTo(34, 68)
      ..cubicTo(28, 48, 30, 26, 50, 8)
      ..close();
    canvas.drawPath(body, Paint()..color = Colors.white);

    final fin = Paint()..color = AppColors.sunshine;
    canvas.drawPath(
      Path()
        ..moveTo(34, 46)
        ..lineTo(18, 72)
        ..lineTo(34, 68)
        ..close(),
      fin,
    );
    canvas.drawPath(
      Path()
        ..moveTo(66, 46)
        ..lineTo(82, 72)
        ..lineTo(66, 68)
        ..close(),
      fin,
    );

    canvas.drawCircle(
        const Offset(50, 34), 11, Paint()..color = AppColors.playDeep.withValues(alpha: 0.75));
    canvas.drawCircle(
        const Offset(50, 34), 7, Paint()..color = AppColors.sky);

    canvas.drawPath(
      Path()
        ..moveTo(40, 68)
        ..quadraticBezierTo(50, 96, 60, 68)
        ..close(),
      Paint()..color = AppColors.sunshine,
    );
    canvas.drawPath(
      Path()
        ..moveTo(45, 68)
        ..quadraticBezierTo(50, 86, 55, 68)
        ..close(),
      Paint()..color = Colors.white,
    );

    _star(canvas, const Offset(12, 22), 5.5);
    _star(canvas, const Offset(88, 34), 4.5);
    _star(canvas, const Offset(16, 62), 4);
  }

  void _star(Canvas canvas, Offset c, double r) {
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: 0.9));
  }

  @override
  bool shouldRepaint(_CardArtPainter oldDelegate) => oldDelegate.kind != kind;
}
