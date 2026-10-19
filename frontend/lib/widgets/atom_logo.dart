import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Spinning atom: three tilted orbits with electrons around a glowing nucleus.
class AtomLogo extends StatefulWidget {
  final double size;
  final Color color;

  const AtomLogo({super.key, this.size = 46, this.color = Colors.white});

  @override
  State<AtomLogo> createState() => _AtomLogoState();
}

class _AtomLogoState extends State<AtomLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        size: Size.square(widget.size),
        painter: _AtomPainter(t: _controller.value, color: widget.color),
      ),
    );
  }
}

class _AtomPainter extends CustomPainter {
  final double t;
  final Color color;

  _AtomPainter({required this.t, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final rx = size.width * 0.46;
    final ry = size.width * 0.17;
    final angle = t * 2 * math.pi;

    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045
      ..color = color.withValues(alpha: 0.55);

    canvas.translate(center.dx, center.dy);

    for (var i = 0; i < 3; i++) {
      final tilt = i * math.pi / 3;

      canvas.save();
      canvas.rotate(tilt);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
        orbitPaint,
      );
      canvas.restore();

      final local = Offset(
        rx * math.cos(angle + i * 2 * math.pi / 3),
        ry * math.sin(angle + i * 2 * math.pi / 3),
      );
      final electron = Offset(
        local.dx * math.cos(tilt) - local.dy * math.sin(tilt),
        local.dx * math.sin(tilt) + local.dy * math.cos(tilt),
      );
      canvas.drawCircle(
        electron,
        size.width * 0.075,
        Paint()..color = color,
      );
    }

    canvas.drawCircle(
      Offset.zero,
      size.width * 0.15,
      Paint()..color = color.withValues(alpha: 0.35),
    );
    canvas.drawCircle(
      Offset.zero,
      size.width * 0.1,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_AtomPainter oldDelegate) => oldDelegate.t != t;
}

/// Gradient wordmark used for the app title.
class GradientTitle extends StatelessWidget {
  final String text;
  final double fontSize;

  const GradientTitle(this.text, {super.key, this.fontSize = 26});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [AppColors.learn, AppColors.grape, AppColors.bubblegum],
      ).createShader(bounds),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
