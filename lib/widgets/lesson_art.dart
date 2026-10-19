import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

enum LessonArtKind { pushPull, newtonMeter, tugOfWar, gravity }

enum _Beast { bear, fox, panda, cat }

class _Look {
  final Color coat;
  final Color shade;
  final Color belly;
  final Color ear;
  final Color outline;
  final Color limb;
  final bool pointyEars;
  final bool longSnout;
  final bool whiskers;
  final bool patches;
  final bool bushyTail;
  final bool slimTail;

  const _Look({
    required this.coat,
    required this.shade,
    required this.belly,
    required this.ear,
    required this.outline,
    Color? limb,
    this.pointyEars = false,
    this.longSnout = false,
    this.whiskers = false,
    this.patches = false,
    this.bushyTail = false,
    this.slimTail = false,
  }) : limb = limb ?? coat;
}

const _inkDark = Color(0xFF3B3355);

const _looks = <_Beast, _Look>{
  _Beast.bear: _Look(
    coat: Color(0xFFB5773F),
    shade: Color(0xFF8A5624),
    belly: Color(0xFFE9CB9C),
    ear: Color(0xFF8A5624),
    outline: Color(0xFF6B4116),
  ),
  _Beast.fox: _Look(
    coat: Color(0xFFF07A3C),
    shade: Color(0xFFC85520),
    belly: Color(0xFFFFF1E4),
    ear: _inkDark,
    outline: Color(0xFF9E3E0C),
    pointyEars: true,
    longSnout: true,
    whiskers: true,
    bushyTail: true,
  ),
  _Beast.panda: _Look(
    coat: Color(0xFFFFFFFF),
    shade: Color(0xFFDCDAEC),
    belly: Color(0xFFFFFFFF),
    ear: _inkDark,
    outline: Color(0xFFB3AECF),
    limb: _inkDark,
    patches: true,
  ),
  _Beast.cat: _Look(
    coat: Color(0xFFA98BEA),
    shade: Color(0xFF7E5ECB),
    belly: Color(0xFFF3EAFF),
    ear: Color(0xFFFFB8D8),
    outline: Color(0xFF5F41A8),
    pointyEars: true,
    whiskers: true,
    slimTail: true,
  ),
};

/// Wide illustration panel drawn at the top of each lesson section.
/// Loops a gentle idle animation and plays a scene-specific action on tap.
class LessonArt extends StatefulWidget {
  final LessonArtKind kind;
  const LessonArt({super.key, required this.kind});

  @override
  State<LessonArt> createState() => _LessonArtState();
}

class _LessonArtState extends State<LessonArt> with TickerProviderStateMixin {
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  )..repeat();
  late final AnimationController _action = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  int _cycles = 0;
  double _lastAction = 0;

  @override
  void initState() {
    super.initState();
    // Count wraps so scenes that alternate direction keep swapping on their own.
    _action.addListener(() {
      if (_action.value < _lastAction) _cycles++;
      _lastAction = _action.value;
    });
    _action.repeat();
  }

  void _play() {
    _action
      ..reset()
      ..repeat();
  }

  @override
  void dispose() {
    _idle.dispose();
    _action.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _play,
      child: Center(
        // Fixed height keeps the four panels from dominating the page.
        child: SizedBox(
          height: 200,
          child: AspectRatio(
            aspectRatio: 240 / 110,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AnimatedBuilder(
                animation: Listenable.merge([_idle, _action]),
                builder: (context, _) => CustomPaint(
                  painter: _LessonArtPainter(
                    kind: widget.kind,
                    idle: _idle.value,
                    action: _action.value,
                    flip: _cycles.isOdd,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonArtPainter extends CustomPainter {
  final LessonArtKind kind;
  final double idle;
  final double action;
  final bool flip;

  const _LessonArtPainter({
    required this.kind,
    required this.idle,
    required this.action,
    required this.flip,
  });

  static const _deepAmber = Color(0xFFEE9B18);
  static const _blush = Color(0xFFFF8FB4);

  @override
  void paint(Canvas canvas, Size size) {
    // Everything below is drawn in a 240 x 110 design space.
    canvas.scale(size.width / 240);
    switch (kind) {
      case LessonArtKind.pushPull:
        _pushPull(canvas);
      case LessonArtKind.newtonMeter:
        _newtonMeter(canvas);
      case LessonArtKind.tugOfWar:
        _tugOfWar(canvas);
      case LessonArtKind.gravity:
        _gravity(canvas);
    }
  }

  @override
  bool shouldRepaint(covariant _LessonArtPainter old) =>
      old.kind != kind ||
      old.idle != idle ||
      old.action != action ||
      old.flip != flip;

  // ---------- building blocks ----------

  void _sky(Canvas c, Color top, Color bottom) {
    const rect = Rect.fromLTWH(0, 0, 240, 110);
    c.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(rect),
    );
  }

  void _sun(Canvas c, Offset at) {
    c.drawCircle(at, 22, Paint()..color = AppColors.sunshine.withValues(alpha: 0.2));
    c.drawCircle(at, 14, Paint()..color = AppColors.sunshine.withValues(alpha: 0.85));
  }

  void _cloud(Canvas c, Offset at, double scale) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.8);
    c.drawCircle(at, 11 * scale, p);
    c.drawCircle(at + Offset(13 * scale, 3 * scale), 8 * scale, p);
    c.drawCircle(at + Offset(-12 * scale, 3 * scale), 7 * scale, p);
  }

  void _groundBand(Canvas c, Color body, Color lip) {
    c.drawRect(const Rect.fromLTWH(0, 92, 240, 18), Paint()..color = body);
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 90, 240, 6),
        const Radius.circular(3),
      ),
      Paint()..color = lip,
    );
  }

  void _shadow(Canvas c, Offset centre, double width) {
    c.drawOval(
      Rect.fromCenter(center: centre, width: width, height: width * 0.24),
      Paint()..color = AppColors.ink.withValues(alpha: 0.13),
    );
  }

  /// Airbrushed fur: light catches the upper-left, shade falls away to the rim.
  Paint _fur(Rect r, _Look look) => Paint()
    ..shader = RadialGradient(
      center: const Alignment(-0.4, -0.5),
      radius: 1.05,
      colors: [
        Color.lerp(look.coat, Colors.white, 0.32)!,
        look.coat,
        look.shade,
      ],
      stops: const [0, 0.5, 1],
    ).createShader(r);

  Paint _keyline(_Look look, [double width = 2.2]) => Paint()
    ..color = look.outline
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeJoin = StrokeJoin.round;

  /// Animal face with species-correct ears, snout and markings.
  void _face(
    Canvas c, {
    required Offset at,
    required double r,
    required double dir,
    required _Beast beast,
  }) {
    final look = _looks[beast]!;
    final k = r / 16;
    final ink = Paint()..color = _inkDark;

    // Ears sit behind the skull.
    for (final s in const [-1.0, 1.0]) {
      if (look.pointyEars) {
        final b1 = at + Offset(s * r * 0.24, -r * 0.76);
        final b2 = at + Offset(s * r * 0.92, -r * 0.50);
        final tip = at + Offset(s * r * 0.80, -r * 1.52);
        final earPath = Path()
          ..moveTo(b1.dx, b1.dy)
          ..lineTo(tip.dx, tip.dy)
          ..lineTo(b2.dx, b2.dy)
          ..close();
        c.drawPath(earPath, _fur(earPath.getBounds(), look));
        c.drawPath(earPath, _keyline(look, 1.8));
        final i1 = Offset.lerp(b1, tip, 0.30)!;
        final i2 = Offset.lerp(b2, tip, 0.30)!;
        final it = Offset.lerp(tip, at, 0.22)!;
        c.drawPath(
          Path()
            ..moveTo(i1.dx, i1.dy)
            ..lineTo(it.dx, it.dy)
            ..lineTo(i2.dx, i2.dy)
            ..close(),
          Paint()..color = look.ear,
        );
      } else {
        final centre = at + Offset(s * r * 0.70, -r * 0.74);
        final earRect = Rect.fromCircle(center: centre, radius: r * 0.44);
        c.drawOval(earRect, look.patches ? (Paint()..color = look.ear) : _fur(earRect, look));
        c.drawOval(earRect, _keyline(look, 1.8));
        if (!look.patches) {
          c.drawCircle(centre, r * 0.24, Paint()..color = look.ear);
        }
      }
    }

    // One clean skull, very slightly wider than tall.
    final skullRect = Rect.fromCenter(center: at, width: r * 2.06, height: r * 1.94);
    c.drawOval(skullRect, _fur(skullRect, look));
    c.drawOval(skullRect, _keyline(look));

    final eyeL = at + Offset((dir * 2 - 6.6) * k, -3 * k);
    final eyeR = at + Offset((dir * 2 + 6.6) * k, -3 * k);
    if (look.patches) {
      for (final eye in [eyeL, eyeR]) {
        c.save();
        c.translate(eye.dx, eye.dy);
        c.rotate(eye == eyeL ? -0.25 : 0.25);
        c.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 11 * k, height: 13.5 * k),
          Paint()..color = look.ear,
        );
        c.restore();
      }
    }

    // Snout: a tapered wedge for the fox, a broad muzzle for everyone else.
    late Offset nose;
    if (look.longSnout) {
      final tip = at + Offset(dir * r * 1.14, r * 0.40);
      final snout = Path()
        ..moveTo(at.dx + dir * r * 0.05, at.dy + r * 0.04)
        ..quadraticBezierTo(at.dx + dir * r * 0.72, at.dy + r * 0.08, tip.dx, tip.dy)
        ..quadraticBezierTo(at.dx + dir * r * 0.58, at.dy + r * 0.76, at.dx + dir * r * 0.02, at.dy + r * 0.64)
        ..close();
      c.drawPath(snout, Paint()..color = look.belly);
      c.drawPath(snout, _keyline(look, 1.6));
      nose = tip + Offset(-dir * r * 0.09, -r * 0.03);
    } else {
      final muzzle = Rect.fromCenter(
        center: at + Offset(dir * 2 * k, 8.5 * k),
        width: 23 * k,
        height: 15 * k,
      );
      c.drawOval(muzzle, Paint()..color = look.belly);
      c.drawOval(muzzle, _keyline(look, 1.6));
      nose = at + Offset(dir * 2 * k, 4.4 * k);
    }

    // Big glossy nose, like the reference art.
    final noseRect = Rect.fromCenter(
      center: nose,
      width: 8.5 * k,
      height: 6.5 * k,
    );
    c.drawOval(noseRect, ink);
    c.drawOval(
      Rect.fromCenter(
        center: nose + Offset(-1.6 * k, -1.6 * k),
        width: 3 * k,
        height: 2 * k,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );

    final mouth = Paint()
      ..color = _inkDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * k
      ..strokeCap = StrokeCap.round;
    c.drawLine(nose + Offset(0, 3.4 * k), nose + Offset(0, 5.4 * k), mouth);
    for (final s in const [-1.0, 1.0]) {
      c.drawArc(
        Rect.fromCenter(
          center: nose + Offset(s * 2.6 * k, 5 * k),
          width: 5.2 * k,
          height: 4.4 * k,
        ),
        0,
        math.pi,
        false,
        mouth,
      );
    }

    if (look.whiskers) {
      final w = Paint()
        ..color = _inkDark.withValues(alpha: 0.3)
        ..strokeWidth = 1 * k
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 3; i++) {
        final y = nose.dy + (i - 1) * 2.2 * k;
        c.drawLine(Offset(nose.dx + dir * 4 * k, y),
            Offset(nose.dx + dir * 14 * k, y + (i - 1) * 1.6 * k), w);
      }
    }

    for (final eye in [eyeL, eyeR]) {
      c.drawCircle(eye, 3.6 * k, Paint()..color = Colors.white);
      c.drawCircle(eye, 3.6 * k, _keyline(look, 1.2));
      c.drawCircle(eye + Offset(dir * 0.6 * k, 0.4 * k), 2.2 * k, ink);
      c.drawCircle(eye + Offset(dir * 1.3 * k, -1.1 * k), 1 * k, Paint()..color = Colors.white);
    }

    final blush = Paint()..color = _blush.withValues(alpha: 0.35);
    for (final s in const [-1.0, 1.0]) {
      c.drawOval(
        Rect.fromCenter(
          center: at + Offset(s * 13.5 * k, 3 * k),
          width: 7.5 * k,
          height: 4.5 * k,
        ),
        blush,
      );
    }
  }

  static Offset _quad(Offset a, Offset b, Offset d, double t) {
    final u = 1 - t;
    return a * (u * u) + b * (2 * u * t) + d * (t * t);
  }

  void _animal(
    Canvas c, {
    required double x,
    required double dir,
    required _Beast beast,
    required Offset paw,
  }) {
    final look = _looks[beast]!;

    _shadow(c, Offset(x, 92), 54);

    // Tail: overlapping circles along a curve so it tapers naturally.
    if (look.bushyTail || look.slimTail) {
      final p0 = Offset(x - dir * 12, 72);
      final p1 = Offset(x - dir * 40, 74);
      final p2 = Offset(x - dir * 32, 42);
      for (var i = 0; i <= 7; i++) {
        final t = i / 7;
        final rr = look.bushyTail ? 4.5 + 4.4 * t : 4.2 - 1.9 * t;
        c.drawCircle(
          _quad(p0, p1, p2, t),
          rr,
          Paint()..color = (look.bushyTail && t > 0.78) ? look.belly : look.coat,
        );
      }
    }

    for (final s in const [-1.0, 1.0]) {
      final foot = Rect.fromCenter(center: Offset(x + s * 12, 88), width: 19, height: 13);
      c.drawOval(foot, Paint()..color = look.limb);
      c.drawOval(foot, _keyline(look, 1.8));
      c.drawOval(
        Rect.fromCenter(center: foot.center + Offset(dir * 2, 1), width: 10, height: 6),
        Paint()..color = look.belly,
      );
    }

    // Heavy rounded body with a big belly, shaded like the reference render.
    final body = Rect.fromCenter(center: Offset(x, 67), width: 42, height: 50);
    c.drawOval(body, _fur(body, look));
    c.drawOval(body, _keyline(look));
    final belly = Rect.fromCenter(center: Offset(x + dir * 3, 74), width: 27, height: 31);
    c.drawOval(belly, Paint()..color = look.belly);
    c.drawArc(belly, -0.6, 2.6, false, _keyline(look, 1.4));

    // Raised arm with claws.
    c.drawLine(
      Offset(x + dir * 14, 62),
      paw,
      Paint()
        ..color = look.limb
        ..style = PaintingStyle.stroke
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round,
    );
    c.drawCircle(paw, 7.5, Paint()..color = look.limb);
    c.drawCircle(paw, 7.5, _keyline(look, 1.8));
    for (var i = -1; i <= 1; i++) {
      c.drawCircle(
        paw + Offset(dir * 6.5, i * 4.5),
        1.8,
        Paint()..color = look.belly,
      );
    }

    _face(c, at: Offset(x + dir * 2, 27), r: 21, dir: dir, beast: beast);
  }

  void _crate(Canvas c, Rect r) {
    _shadow(c, Offset(r.center.dx, r.bottom + 2), r.width * 1.05);
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(10));
    c.drawRRect(rr, Paint()..color = AppColors.sunshine);
    c.save();
    c.clipRRect(rr);
    c.drawRect(
      Rect.fromLTWH(r.left, r.top, r.width, 10),
      Paint()..color = Colors.white.withValues(alpha: 0.3),
    );
    final plank = Paint()
      ..color = _deepAmber.withValues(alpha: 0.55)
      ..strokeWidth = 2;
    c.drawLine(Offset(r.left + r.width / 3, r.top + 10),
        Offset(r.left + r.width / 3, r.bottom), plank);
    c.drawLine(Offset(r.left + r.width * 2 / 3, r.top + 10),
        Offset(r.left + r.width * 2 / 3, r.bottom), plank);
    c.restore();
    c.drawRRect(
      rr,
      Paint()
        ..color = _deepAmber
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  void _arrow(Canvas c, Offset from, Offset to, Color color, {double width = 7}) {
    final delta = to - from;
    final unit = delta / delta.distance;
    final shaftEnd = to - unit * 12;
    c.drawLine(
      from,
      shaftEnd,
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
    final normal = Offset(-unit.dy, unit.dx) * 9;
    c.drawPath(
      Path()
        ..moveTo(to.dx, to.dy)
        ..lineTo(shaftEnd.dx + normal.dx, shaftEnd.dy + normal.dy)
        ..lineTo(shaftEnd.dx - normal.dx, shaftEnd.dy - normal.dy)
        ..close(),
      Paint()..color = color,
    );
  }

  void _badge(Canvas c, String text, Offset centre, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final w = painter.width + 20;
    final h = painter.height + 11;
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: centre, width: w, height: h),
        Radius.circular(h / 2),
      ),
      Paint()..color = color,
    );
    painter.paint(c, centre - Offset(painter.width / 2, painter.height / 2));
  }

  void _apple(Canvas c, Offset centre, double r, {double squash = 1, double fade = 1}) {
    final rect = Rect.fromCenter(
      center: centre,
      width: r * 2 / squash,
      height: r * 2 * squash,
    );
    c.drawOval(rect, Paint()..color = AppColors.practice.withValues(alpha: fade));
    c.drawCircle(
      centre + Offset(-r * 0.34, -r * 0.34),
      r * 0.25,
      Paint()..color = Colors.white.withValues(alpha: 0.45 * fade),
    );
    c.drawLine(
      centre + Offset(0, -r * squash),
      centre + Offset(1, -r * squash - 5),
      Paint()
        ..color = _deepAmber.withValues(alpha: fade)
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round,
    );
    c.drawOval(
      Rect.fromCenter(
        center: centre + Offset(r * 0.55, -r * squash - 3),
        width: r * 0.95,
        height: r * 0.5,
      ),
      Paint()..color = AppColors.play.withValues(alpha: fade),
    );
  }

  /// Distance covered by a shove: constant force, then friction to a stop.
  static double _shove(double t) {
    const tp = 0.38;
    const total = tp / 2;
    if (t <= 0) return 0;
    if (t >= 1) return 1;
    if (t < tp) return (t * t / 2) / total;
    final u = t - tp;
    return (tp * tp / 2 + tp * u - 0.5 * (tp / (1 - tp)) * u * u) / total;
  }

  void _star(Canvas c, Offset at, double r, Color color) {
    final path = Path()
      ..moveTo(at.dx, at.dy - r)
      ..quadraticBezierTo(at.dx, at.dy, at.dx + r, at.dy)
      ..quadraticBezierTo(at.dx, at.dy, at.dx, at.dy + r)
      ..quadraticBezierTo(at.dx, at.dy, at.dx - r, at.dy)
      ..quadraticBezierTo(at.dx, at.dy, at.dx, at.dy - r)
      ..close();
    c.drawPath(path, Paint()..color = color);
  }

  // ---------- scenes ----------

  void _pushPull(Canvas c) {
    // One tap = a push, then a pull back. Each is force-then-friction, ending at rest.
    final pushing = action < 0.5;
    final half = (pushing ? action : action - 0.5) / 0.5;
    final moved = _shove(half);
    final dx = 36 * (pushing ? moved : 1 - moved);
    final dir = pushing ? 1.0 : -1.0;
    final speed = action == 0
        ? 0.0
        : (((_shove(half + 0.02) - _shove(half - 0.02)) / 0.04) / 2.7).clamp(0.0, 1.0);
    final effort = action == 0 ? 0.0 : math.max(0.0, 1 - half / 0.38);
    final bob = math.sin(idle * math.pi * 2) * 1.6;

    _sky(c, const Color(0xFFD7EEFF), const Color(0xFFF7FCFF));
    _sun(c, const Offset(26, 20));
    _cloud(c, Offset(206 - idle * 26, 24), 0.8);
    _groundBand(c, const Color(0xFFA6E6BC), const Color(0xFF74CE97));

    c.save();
    c.translate(dx, bob);
    c.translate(50, 90);
    c.rotate(0.1 * effort * dir);
    c.translate(-50, -90);
    _animal(c, x: 50, dir: 1, beast: _Beast.bear, paw: const Offset(88, 62));
    c.restore();
    _crate(c, Rect.fromLTWH(94 + dx, 52, 50, 38));

    // Dust kicked up behind the crate, thickest when it is moving fastest.
    final trailX = (pushing ? 92 : 146) + dx;
    for (var i = 0; i < 3; i++) {
      c.drawCircle(
        Offset(trailX - dir * i * 8, 88 - i * 3),
        3 + i.toDouble(),
        Paint()..color = Colors.white.withValues(alpha: 0.6 * speed / (1 + i)),
      );
    }

    final ax = 141 + dx;
    final tint = pushing ? AppColors.learn : AppColors.grape;
    if (pushing) {
      _arrow(c, Offset(ax - 37, 34), Offset(ax + 37, 34), tint);
    } else {
      _arrow(c, Offset(ax + 37, 34), Offset(ax - 37, 34), tint);
    }
    _badge(c, pushing ? 'push' : 'pull', Offset(ax, 13), tint);
  }

  void _newtonMeter(Canvas c) {
    // Damped harmonic motion of a mass on a spring: x = A e^(-λt) cos(ωt).
    double disp(double t) =>
        t <= 0 ? 0 : math.exp(-3.0 * t) * math.cos(t * math.pi * 4.6);
    final stretch = disp(action) * 11 + math.sin(idle * math.pi * 2) * 0.8;
    final vel = action == 0 ? 0.0 : (disp(action + 0.02) - disp(action - 0.02)) / 0.04;
    final blur = (vel.abs() / 16).clamp(0.0, 1.0);
    final reading = (10 + stretch * 0.9).round().clamp(0, 30);

    _sky(c, const Color(0xFFEDE6FF), const Color(0xFFFBF9FF));
    _star(c, const Offset(206, 84), 5, AppColors.grape.withValues(alpha: 0.5));

    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(70, 6, 106, 9),
        const Radius.circular(5),
      ),
      Paint()..color = AppColors.inkSoft.withValues(alpha: 0.45),
    );
    final wire = Paint()
      ..color = AppColors.inkSoft
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    c.drawLine(const Offset(120, 15), const Offset(120, 24), wire);

    final tube = RRect.fromRectAndRadius(
      const Rect.fromLTWH(104, 24, 32, 46),
      const Radius.circular(15),
    );
    c.drawRRect(tube, Paint()..color = Colors.white);
    c.drawRRect(
      tube,
      Paint()
        ..color = AppColors.learn
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    c.save();
    c.clipRRect(tube);
    final step = 4.5 + stretch * 0.3;
    final spring = Path()..moveTo(112, 30);
    for (var i = 0; i < 6; i++) {
      spring.lineTo(i.isEven ? 128 : 112, 30 + i * step + step / 2);
    }
    c.drawPath(
      spring,
      Paint()
        ..color = AppColors.inkSoft
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6,
    );
    for (var i = 0; i < 4; i++) {
      c.drawLine(
        Offset(106, 54 + i * 4),
        Offset(113, 54 + i * 4),
        Paint()
          ..color = AppColors.inkSoft.withValues(alpha: 0.5)
          ..strokeWidth = 1.6,
      );
    }
    final needleY = (58 + stretch * 0.7).clamp(30.0, 66.0);
    c.drawLine(
      Offset(104, needleY),
      Offset(136, needleY),
      Paint()
        ..color = AppColors.practice
        ..strokeWidth = 3.4,
    );
    c.restore();

    c.drawLine(Offset(120, 70), Offset(120, 74 + stretch), wire);
    // Motion smear in the direction of travel, then the apple itself.
    if (blur > 0.05) {
      _apple(c, Offset(120, 86 + stretch - vel * 0.06), 13,
          squash: 1 + blur * 0.2, fade: 0.25 * blur);
    }
    _apple(c, Offset(120, 86 + stretch), 13, squash: 1 + blur * 0.22);

    _animal(
      c,
      x: 44,
      dir: 1,
      beast: _Beast.cat,
      paw: const Offset(76, 48),
    );

    _badge(c, '$reading N', const Offset(199, 58), AppColors.learn);
    _arrow(c, const Offset(172, 58), const Offset(146, 58), AppColors.learn, width: 5);
  }

  void _tugOfWar(Canvas c) {
    // A heave that decays away, with the rope pulling taut as the knot travels.
    final heave = action == 0
        ? 0.0
        : math.sin(action * math.pi) * math.exp(-1.1 * action) +
            math.exp(-4.5 * action) * math.sin(action * math.pi * 7) * 0.22;
    final yank = heave * (flip ? -1 : 1);
    final knot = yank * 24 + math.sin(idle * math.pi * 2) * 1.2;
    final sag = 18 * (1 - yank.abs() * 0.75);
    final extra = (yank.abs() * 32).round();
    final leftN = 50 + (yank < 0 ? extra : 0);
    final rightN = 50 + (yank > 0 ? extra : 0);

    _sky(c, const Color(0xFFD9F0FF), const Color(0xFFF8FCFF));
    _sun(c, const Offset(120, 30));
    _groundBand(c, const Color(0xFFA6E6BC), const Color(0xFF74CE97));

    c.drawPath(
      Path()
        ..moveTo(76, 60)
        ..quadraticBezierTo(120 + knot, 60 + sag, 164, 60),
      Paint()
        ..color = const Color(0xFFC9A87C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    c.save();
    c.translate(knot * 0.16, 0);
    c.save();
    c.translate(44, 90);
    c.rotate(-0.14 * (yank < 0 ? yank.abs() : 0.0));
    c.translate(-44, -90);
    _animal(
      c,
      x: 44,
      dir: -1,
      beast: _Beast.fox,
      paw: const Offset(76, 60),
    );
    c.restore();
    c.save();
    c.translate(196, 90);
    c.rotate(0.14 * (yank > 0 ? yank : 0.0));
    c.translate(-196, -90);
    _animal(
      c,
      x: 196,
      dir: 1,
      beast: _Beast.panda,
      paw: const Offset(164, 60),
    );
    c.restore();
    c.restore();

    c.drawLine(
      Offset(120 + knot, 71),
      Offset(120 + knot, 46),
      Paint()
        ..color = AppColors.ink
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    c.drawPath(
      Path()
        ..moveTo(121 + knot, 46)
        ..lineTo(139 + knot, 52)
        ..lineTo(121 + knot, 58)
        ..close(),
      Paint()..color = extra == 0 ? AppColors.play : AppColors.practice,
    );

    _arrow(c, const Offset(98, 36), Offset(70 - (leftN - 50) * 0.4, 36),
        AppColors.grape, width: 5);
    _arrow(c, const Offset(142, 36), Offset(170 + (rightN - 50) * 0.4, 36),
        AppColors.learn, width: 5);
    _badge(c, '$leftN N', const Offset(84, 15), AppColors.grape);
    _badge(c, '$rightN N', const Offset(156, 15), AppColors.learn);
  }

  void _gravity(Canvas c) {
    // Free fall: y grows with t², so the apple visibly accelerates, then squashes.
    const landAt = 0.88;
    final falling = idle < landAt;
    final p = falling ? idle / landAt : 1.0;
    final impact = falling ? 0.0 : (idle - landAt) / (1 - landAt);
    final appleY = 26 + 50 * p * p;
    final squash = falling
        ? 1 + 0.3 * p * p
        : 1 - 0.4 * math.sin(impact * math.pi);

    // Pendulum sway: the basket lags behind the canopy.
    final w = idle * math.pi * 2;
    final gust = math.sin(action * math.pi) * 13 * (flip ? -1 : 1);
    final topDx = math.sin(w) * 5 + gust;
    final botDx = math.sin(w - 0.7) * 8 + gust * 0.75;
    final tilt = (topDx - botDx) * 0.012;

    _sky(c, const Color(0xFFDCE9FF), const Color(0xFFF5FAFF));

    const centre = Offset(120, 184);
    c.drawCircle(centre, 102, Paint()..color = AppColors.learn.withValues(alpha: 0.16));
    c.drawCircle(centre, 96, Paint()..color = AppColors.learn);
    c.save();
    c.clipPath(Path()..addOval(Rect.fromCircle(center: centre, radius: 96)));
    final land = Paint()..color = AppColors.play;
    c.drawOval(const Rect.fromLTWH(34, 92, 60, 34), land);
    c.drawOval(const Rect.fromLTWH(122, 98, 78, 30), land);
    c.drawOval(
      const Rect.fromLTWH(26, 88, 188, 14),
      Paint()..color = Colors.white.withValues(alpha: 0.16),
    );
    c.restore();

    if (falling) {
      for (var i = 1; i <= 2; i++) {
        final ghostP = math.max(0.0, p - i * 0.055);
        _apple(c, Offset(55, 26 + 50 * ghostP * ghostP), 13,
            squash: 1 + 0.3 * p * p, fade: 0.16 * p / i);
      }
    }
    _apple(c, Offset(55, appleY), 13, squash: squash);
    if (falling) {
      _arrow(c, Offset(55, appleY + 18), Offset(55, appleY + 30 + 8 * p),
          AppColors.practice, width: 5);
    }

    // Parachuting cat: canopy, cords, then the face tucked into the basket.
    c.save();
    c.translate(183 + topDx, 37);
    c.rotate(tilt);
    c.translate(-183, -37);
    const domeRect = Rect.fromLTWH(146, 6, 74, 62);
    final dome = Path()
      ..addArc(domeRect, math.pi, math.pi)
      ..close();
    c.drawPath(dome, Paint()..color = AppColors.sunshine);
    c.save();
    c.clipPath(dome);
    c.drawRect(const Rect.fromLTWH(158, 4, 12, 40), Paint()..color = AppColors.practice);
    c.drawRect(const Rect.fromLTWH(196, 4, 12, 40), Paint()..color = AppColors.practice);
    c.restore();
    c.restore();

    final cord = Paint()
      ..color = AppColors.ink.withValues(alpha: 0.45)
      ..strokeWidth = 2;
    c.drawLine(Offset(148 + topDx, 38), Offset(171 + botDx, 66), cord);
    c.drawLine(Offset(218 + topDx, 38), Offset(195 + botDx, 66), cord);

    _face(
      c,
      at: Offset(183 + botDx, 56),
      r: 11,
      dir: 1,
      beast: _Beast.cat,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(168 + botDx, 64, 30, 17),
        const Radius.circular(6),
      ),
      Paint()..color = Colors.white,
    );

    final twinkle = 0.6 + 0.4 * math.sin(idle * math.pi * 4);
    _star(c, const Offset(104, 20), 7 * twinkle, AppColors.sunshine);
    _star(c, const Offset(126, 44), 4.5, Colors.white);
    _star(c, const Offset(90, 52), 4 * twinkle, AppColors.sunshine);
  }
}
