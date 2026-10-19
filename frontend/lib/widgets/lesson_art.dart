import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

enum LessonArtKind {
  pushPull,
  newtonMeter,
  tugOfWar,
  gravity,
  reference,
  speedometer,
  raceTrack,
  acceleration,
  earthPull,
  massVsWeight,
  planetRow,
  dropTest,
  effortTrade,
  lever,
  ramp,
  pulley,
}

enum _Bot { amber, coral, slate, violet }

class _Suit {
  final Color shell;
  final Color shade;
  final Color trim;
  final Color visor;
  final Color outline;

  const _Suit({
    required this.shell,
    required this.shade,
    required this.trim,
    required this.visor,
    required this.outline,
  });
}

const _inkDark = Color(0xFF3B3355);

const _suits = <_Bot, _Suit>{
  _Bot.amber: _Suit(
    shell: Color(0xFFF2A63C),
    shade: Color(0xFFC97A0C),
    trim: Color(0xFFFFE2B4),
    visor: Color(0xFF2F6BD8),
    outline: Color(0xFF9E5F05),
  ),
  _Bot.coral: _Suit(
    shell: Color(0xFFF2705C),
    shade: Color(0xFFC8412C),
    trim: Color(0xFFFFE0DA),
    visor: Color(0xFF23324F),
    outline: Color(0xFF9E3324),
  ),
  _Bot.slate: _Suit(
    shell: Color(0xFFD7DCEC),
    shade: Color(0xFFA9B1CC),
    trim: Color(0xFFF6F8FF),
    visor: Color(0xFF2F6BD8),
    outline: Color(0xFF8A93B4),
  ),
  _Bot.violet: _Suit(
    shell: Color(0xFFA98BEA),
    shade: Color(0xFF7E5ECB),
    trim: Color(0xFFEFE7FF),
    visor: Color(0xFF33D6C0),
    outline: Color(0xFF5F41A8),
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
      case LessonArtKind.reference:
        _reference(canvas);
      case LessonArtKind.speedometer:
        _speedometer(canvas);
      case LessonArtKind.raceTrack:
        _raceTrack(canvas);
      case LessonArtKind.acceleration:
        _acceleration(canvas);
      case LessonArtKind.earthPull:
        _earthPull(canvas);
      case LessonArtKind.massVsWeight:
        _massVsWeight(canvas);
      case LessonArtKind.planetRow:
        _planetRow(canvas);
      case LessonArtKind.dropTest:
        _dropTest(canvas);
      case LessonArtKind.effortTrade:
        _effortTrade(canvas);
      case LessonArtKind.lever:
        _lever(canvas);
      case LessonArtKind.ramp:
        _ramp(canvas);
      case LessonArtKind.pulley:
        _pulley(canvas);
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

  /// Brushed metal: light catches the upper-left, shade falls to the rim.
  Paint _plate(Rect r, _Suit suit) => Paint()
    ..shader = RadialGradient(
      center: const Alignment(-0.4, -0.5),
      radius: 1.05,
      colors: [
        Color.lerp(suit.shell, Colors.white, 0.34)!,
        suit.shell,
        suit.shade,
      ],
      stops: const [0, 0.5, 1],
    ).createShader(r);

  Paint _keyline(_Suit suit, [double width = 2.2]) => Paint()
    ..color = suit.outline
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeJoin = StrokeJoin.round;

  /// Robot head: antenna, wraparound visor and a small speaker grille.
  void _botHead(
    Canvas c, {
    required Offset at,
    required double r,
    required double dir,
    required _Bot bot,
  }) {
    final suit = _suits[bot]!;
    final k = r / 16;

    // Antenna, with a blinking tip. Kept short so it stays inside the panel.
    final blink = 0.55 + 0.45 * math.sin(idle * math.pi * 4);
    c.drawLine(
      at + Offset(dir * 2 * k, -r * 0.95),
      at + Offset(dir * 2 * k, -r * 1.16),
      Paint()
        ..color = suit.outline
        ..strokeWidth = 2.2 * k
        ..strokeCap = StrokeCap.round,
    );
    c.drawCircle(
      at + Offset(dir * 2 * k, -r * 1.24),
      3 * k,
      Paint()..color = AppColors.practice.withValues(alpha: blink),
    );

    // Ear pods.
    for (final s in const [-1.0, 1.0]) {
      final pod = Rect.fromCenter(
        center: at + Offset(s * r * 1.02, 0),
        width: r * 0.34,
        height: r * 0.72,
      );
      c.drawRRect(
        RRect.fromRectAndRadius(pod, Radius.circular(3 * k)),
        Paint()..color = suit.shade,
      );
    }

    // Rounded head plate.
    final head = RRect.fromRectAndRadius(
      Rect.fromCenter(center: at, width: r * 1.96, height: r * 1.82),
      Radius.circular(7 * k),
    );
    c.drawRRect(head, _plate(head.outerRect, suit));
    c.drawRRect(head, _keyline(suit));

    // Visor across the eyes.
    final visor = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: at + Offset(dir * 1.2 * k, -2.4 * k),
        width: r * 1.44,
        height: r * 0.78,
      ),
      Radius.circular(5 * k),
    );
    c.drawRRect(visor, Paint()..color = _inkDark);
    c.drawRRect(
      visor,
      Paint()
        ..color = suit.trim
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4 * k,
    );
    for (final s in const [-1.0, 1.0]) {
      c.drawCircle(
        at + Offset(dir * 1.2 * k + s * 5 * k, -2.4 * k),
        2.5 * k,
        Paint()..color = suit.visor,
      );
      c.drawCircle(
        at + Offset(dir * 1.2 * k + s * 5 * k - 0.8 * k, -3.4 * k),
        1 * k,
        Paint()..color = Colors.white.withValues(alpha: 0.8),
      );
    }

    // Speaker grille for a mouth.
    final grille = Rect.fromCenter(
      center: at + Offset(dir * 1.2 * k, 7.5 * k),
      width: r * 0.78,
      height: r * 0.34,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(grille, Radius.circular(2.5 * k)),
      Paint()..color = suit.trim,
    );
    for (var i = -1; i <= 1; i++) {
      c.drawLine(
        Offset(grille.center.dx + i * 3 * k, grille.top + 1.4 * k),
        Offset(grille.center.dx + i * 3 * k, grille.bottom - 1.4 * k),
        Paint()
          ..color = suit.outline.withValues(alpha: 0.55)
          ..strokeWidth = 1.1 * k,
      );
    }
  }

  static Offset _quad(Offset a, Offset b, Offset d, double t) {
    final u = 1 - t;
    return a * (u * u) + b * (2 * u * t) + d * (t * t);
  }

  void _bot(
    Canvas c, {
    required double x,
    required double dir,
    required _Bot bot,
    required Offset hand,
  }) {
    final suit = _suits[bot]!;

    _shadow(c, Offset(x, 92), 54);

    // Tread feet.
    for (final s in const [-1.0, 1.0]) {
      final foot = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x + s * 12, 88), width: 19, height: 12),
        const Radius.circular(4),
      );
      c.drawRRect(foot, Paint()..color = suit.shade);
      c.drawRRect(foot, _keyline(suit, 1.6));
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(x + s * 12, 85.5), width: 13, height: 4),
          const Radius.circular(2),
        ),
        Paint()..color = suit.trim,
      );
    }

    // Neck.
    c.drawRect(
      Rect.fromCenter(center: Offset(x + dir * 2, 44), width: 9, height: 8),
      Paint()..color = suit.shade,
    );

    // Chassis with a chest panel.
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x, 67), width: 42, height: 48),
      const Radius.circular(12),
    );
    c.drawRRect(body, _plate(body.outerRect, suit));
    c.drawRRect(body, _keyline(suit));
    final panel = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x + dir * 2, 68), width: 24, height: 26),
      const Radius.circular(7),
    );
    c.drawRRect(panel, Paint()..color = suit.trim);
    c.drawRRect(panel, _keyline(suit, 1.4));
    c.drawCircle(Offset(x + dir * 2, 63), 4, Paint()..color = suit.visor);
    for (var i = 0; i < 2; i++) {
      c.drawLine(
        Offset(x + dir * 2 - 7, 72 + i * 5),
        Offset(x + dir * 2 + 7, 72 + i * 5),
        Paint()
          ..color = suit.outline.withValues(alpha: 0.4)
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round,
      );
    }

    // Segmented arm reaching to the hand position.
    final shoulder = Offset(x + dir * 16, 60);
    final elbow = Offset.lerp(shoulder, hand, 0.5)! + Offset(0, -4);
    final limb = Paint()
      ..color = suit.shade
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    c.drawLine(shoulder, elbow, limb);
    c.drawLine(elbow, hand, limb);
    c.drawCircle(elbow, 5, Paint()..color = suit.trim);
    c.drawCircle(hand, 7, Paint()..color = suit.shell);
    c.drawCircle(hand, 7, _keyline(suit, 1.6));
    c.drawCircle(hand, 3, Paint()..color = suit.trim);
    c.drawCircle(shoulder, 6.5, Paint()..color = suit.shade);

    _botHead(c, at: Offset(x + dir * 2, 27), r: 21, dir: dir, bot: bot);
  }

  void _crate(Canvas c, Rect r) {
    _shadow(c, Offset(r.center.dx, r.bottom + 2), r.width * 1.05);
    // Corner radius tracks the crate size so small crates stay square.
    final rr = RRect.fromRectAndRadius(r, Radius.circular(r.width * 0.16));
    c.drawRRect(rr, Paint()..color = AppColors.sunshine);
    c.save();
    c.clipRRect(rr);
    c.drawRect(
      Rect.fromLTWH(r.left, r.top, r.width, r.height * 0.22),
      Paint()..color = Colors.white.withValues(alpha: 0.3),
    );
    final plank = Paint()
      ..color = _deepAmber.withValues(alpha: 0.55)
      ..strokeWidth = 2;
    c.drawLine(Offset(r.left + r.width / 3, r.top + r.height * 0.22),
        Offset(r.left + r.width / 3, r.bottom), plank);
    c.drawLine(Offset(r.left + r.width * 2 / 3, r.top + r.height * 0.22),
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
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final w = painter.width + 13;
    final h = painter.height + 8;
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
    _bot(c, x: 50, dir: 1, bot: _Bot.amber, hand: const Offset(88, 62));
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

    _bot(
      c,
      x: 44,
      dir: 1,
      bot: _Bot.violet,
      hand: const Offset(76, 48),
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
    _bot(
      c,
      x: 44,
      dir: -1,
      bot: _Bot.coral,
      hand: const Offset(76, 60),
    );
    c.restore();
    c.save();
    c.translate(196, 90);
    c.rotate(0.14 * (yank > 0 ? yank : 0.0));
    c.translate(-196, -90);
    _bot(
      c,
      x: 196,
      dir: 1,
      bot: _Bot.slate,
      hand: const Offset(164, 60),
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

    // Parachuting bot: canopy, cords, then the head tucked into the basket.
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

    _botHead(
      c,
      at: Offset(183 + botDx, 56),
      r: 11,
      dir: 1,
      bot: _Bot.violet,
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

  // ---------- motion scenes ----------

  void _tree(Canvas c, double x, double scale) {
    final trunk = Rect.fromLTWH(x - 4 * scale, 92 - 34 * scale, 8 * scale, 34 * scale);
    c.drawRRect(
      RRect.fromRectAndRadius(trunk, Radius.circular(3 * scale)),
      Paint()..color = const Color(0xFF9A6B45),
    );
    final leaves = Paint()..color = AppColors.play;
    c.drawCircle(Offset(x, 92 - 40 * scale), 15 * scale, leaves);
    c.drawCircle(Offset(x - 11 * scale, 92 - 32 * scale), 11 * scale, leaves);
    c.drawCircle(Offset(x + 11 * scale, 92 - 32 * scale), 11 * scale, leaves);
    c.drawCircle(
      Offset(x - 5 * scale, 92 - 46 * scale),
      7 * scale,
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );
  }

  void _dashedLine(Canvas c, Offset from, Offset to, Color color) {
    final delta = to - from;
    final steps = (delta.distance / 7).floor();
    final step = delta / steps.toDouble();
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < steps; i += 2) {
      c.drawLine(from + step * i.toDouble(), from + step * (i + 1).toDouble(), paint);
    }
  }

  /// Places a full-body animal at an arbitrary size and footline. The paw is
  /// derived inside the scaled space, since passing design-space coordinates
  /// would stretch the arm.
  void _botAt(
    Canvas c, {
    required double x,
    required double feetY,
    required double scale,
    required double dir,
    required _Bot bot,
  }) {
    c.save();
    c.translate(0, feetY - 92 * scale);
    c.scale(scale);
    final inner = x / scale;
    _bot(
      c,
      x: inner,
      dir: dir,
      bot: bot,
      hand: Offset(inner + dir * 17, 52),
    );
    c.restore();
  }

  void _reference(Canvas c) {
    // The bot walks; the tree stays put. Distance between them is the point.
    // Starts clear of the tree so the gap between them is the whole point.
    final travel = 64 + 126 * action;
    final bob = math.sin(action * math.pi * 12) * 1.4;

    _sky(c, const Color(0xFFDDF0FF), const Color(0xFFF9FCFF));
    _sun(c, const Offset(216, 18));
    _cloud(c, Offset(96 + idle * 20, 20), 0.7);
    _groundBand(c, const Color(0xFFA6E6BC), const Color(0xFF74CE97));

    _tree(c, 24, 1);
    _dashedLine(c, const Offset(24, 26), const Offset(24, 90),
        AppColors.ink.withValues(alpha: 0.25));

    _arrow(c, const Offset(30, 84), Offset(travel - 18, 84), AppColors.learn,
        width: 4);

    c.save();
    c.translate(0, bob);
    _botAt(
      c,
      x: travel,
      feetY: 92,
      scale: 0.62,
      dir: 1,
      bot: _Bot.coral,
    );
    c.restore();

    _badge(c, 'reference', const Offset(30, 14), AppColors.grape);
  }

  void _speedometer(Canvas c) {
    // Needle and arc are driven by the same value so they always agree.
    final swing = 0.5 - 0.5 * math.cos(action * math.pi * 2);

    _sky(c, const Color(0xFFE7E1FF), const Color(0xFFFBFAFF));
    _groundBand(c, const Color(0xFFCFC4FF), const Color(0xFFB6A6F5));

    const hub = Offset(170, 80);
    const radius = 44.0;
    c.drawArc(
      Rect.fromCircle(center: hub, radius: radius),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12,
    );
    if (swing > 0.02) {
      c.drawArc(
        Rect.fromCircle(center: hub, radius: radius),
        math.pi,
        math.pi * swing,
        false,
        Paint()
          ..color = AppColors.learn
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12,
      );
    }

    for (var i = 0; i <= 5; i++) {
      final a = math.pi + math.pi * i / 5;
      final dir = Offset(math.cos(a), math.sin(a));
      c.drawLine(
        hub + dir * (radius - 18),
        hub + dir * (radius - 12),
        Paint()
          ..color = AppColors.ink.withValues(alpha: 0.3)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }

    final angle = math.pi + math.pi * swing;
    c.drawLine(
      hub,
      hub + Offset(math.cos(angle), math.sin(angle)) * (radius - 14),
      Paint()
        ..color = AppColors.practice
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
    c.drawCircle(hub, 5, Paint()..color = AppColors.practice);
    c.drawCircle(hub, 2, Paint()..color = Colors.white);

    // A runner on the left so the dial is clearly about something moving.
    final stride = math.sin(action * math.pi * 8) * 3;
    _botAt(
      c,
      x: 62 + stride,
      feetY: 92,
      scale: 0.6,
      dir: 1,
      bot: _Bot.violet,
    );
    for (var i = 1; i <= 3; i++) {
      final len = 6 + 12 * swing;
      c.drawLine(
        Offset(34 - i * 3, 52 + i * 9),
        Offset(34 - i * 3 - len, 52 + i * 9),
        Paint()
          ..color = AppColors.learn.withValues(alpha: 0.5 * swing)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _raceTrack(Canvas c) {
    // Same time on the clock, different distance covered, so Bolt is faster.
    const fastSpan = 168.0;
    const slowSpan = 96.0;
    final fastX = 30 + fastSpan * action;
    final slowX = 30 + slowSpan * action;

    _sky(c, const Color(0xFFDDF0FF), const Color(0xFFF9FCFF));
    _groundBand(c, const Color(0xFFA6E6BC), const Color(0xFF74CE97));
    c.drawRect(const Rect.fromLTWH(0, 48, 240, 4),
        Paint()..color = Colors.white.withValues(alpha: 0.7));

    // Finish line, checked.
    for (var row = 0; row < 12; row++) {
      for (var col = 0; col < 2; col++) {
        if ((row + col).isEven) {
          c.drawRect(
            Rect.fromLTWH(206 + col * 7, 8 + row * 8.5, 7, 8.5),
            Paint()..color = AppColors.ink.withValues(alpha: 0.55),
          );
        }
      }
    }

    _botAt(
      c,
      x: fastX,
      feetY: 48,
      scale: 0.42,
      dir: 1,
      bot: _Bot.coral,
    );
    _botAt(
      c,
      x: slowX,
      feetY: 92,
      scale: 0.42,
      dir: 1,
      bot: _Bot.slate,
    );

    _badge(c, 'Bolt', const Offset(24, 14), AppColors.learn);
    _badge(c, 'Nova', const Offset(26, 60), AppColors.practice);
  }

  void _acceleration(Canvas c) {
    // Speed rises then falls; the position is the integral of that, so the
    // rabbit visibly pulls away and then eases to a stop.
    final t = action;
    final speeding = t < 0.5;
    final v = speeding ? t / 0.5 : 1 - (t - 0.5) / 0.5;
    final u = t - 0.5;
    final progress = speeding ? 2 * t * t : (0.25 + u - u * u) / 0.5;
    final x = 30 + 160 * progress;

    _sky(c, const Color(0xFFFFE9F2), const Color(0xFFFFFBFD));
    _groundBand(c, const Color(0xFFFFC9DE), const Color(0xFFF79FC1));

    // Speed bar across the top.
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(24, 12, 192, 9),
        const Radius.circular(5),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(24, 12, 192 * v, 9),
        const Radius.circular(5),
      ),
      Paint()..color = speeding ? AppColors.play : AppColors.practice,
    );

    for (var i = 1; i <= 3; i++) {
      final len = 4 + 20 * v;
      c.drawLine(
        Offset(x - 16 - i * 2, 48 + i * 11),
        Offset(x - 16 - i * 2 - len, 48 + i * 11),
        Paint()
          ..color = (speeding ? AppColors.play : AppColors.practice)
              .withValues(alpha: 0.55 * v)
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round,
      );
    }

    final lean = speeding ? 0.10 * v : -0.10 * v;
    c.save();
    c.translate(x, 92);
    c.rotate(lean);
    c.translate(-x, -92);
    _botAt(
      c,
      x: x,
      feetY: 92,
      scale: 0.6,
      dir: 1,
      bot: _Bot.amber,
    );
    c.restore();
  }

  // ---------- gravity scenes ----------

  void _starfield(Canvas c) {
    final twinkle = 0.5 + 0.5 * math.sin(idle * math.pi * 4);
    const spots = [
      Offset(24, 18),
      Offset(70, 12),
      Offset(118, 26),
      Offset(172, 14),
      Offset(212, 30),
      Offset(46, 40),
    ];
    for (var i = 0; i < spots.length; i++) {
      final a = i.isEven ? twinkle : 1 - twinkle;
      c.drawCircle(
        spots[i],
        1.6 + 0.9 * a,
        Paint()..color = Colors.white.withValues(alpha: 0.5 + 0.4 * a),
      );
    }
  }

  void _earthPull(Canvas c) {
    // Everything on screen is pulled the same way: towards the ground.
    final drop = action * action;

    _sky(c, const Color(0xFFDDEBFF), const Color(0xFFF8FBFF));
    _cloud(c, Offset(46 + idle * 16, 22), 0.7);
    _groundBand(c, const Color(0xFFA6E6BC), const Color(0xFF74CE97));

    final appleY = 24 + 52 * drop;
    _apple(c, Offset(72, appleY), 11, squash: 1 + 0.25 * drop * drop);
    _arrow(c, Offset(72, appleY + 15), Offset(72, appleY + 30),
        AppColors.practice, width: 4);

    _botAt(c, x: 168, feetY: 92, scale: 0.62, dir: -1, bot: _Bot.amber);
    _arrow(c, const Offset(200, 52), const Offset(200, 82), AppColors.learn,
        width: 5);
    _badge(c, 'gravity', const Offset(202, 34), AppColors.learnDeep);
  }

  void _massVsWeight(Canvas c) {
    // The same crate on two instruments. One reads kilograms, one newtons.
    final sway = math.sin(idle * math.pi * 2) * 2.2;

    _sky(c, const Color(0xFFEDE7FF), const Color(0xFFFCFBFF));
    _groundBand(c, const Color(0xFFCFC4FF), const Color(0xFFB6A6F5));

    // Platform scale: reads mass.
    _crate(c, const Rect.fromLTWH(43, 34, 30, 26));
    final base = RRect.fromRectAndRadius(
      const Rect.fromLTWH(28, 62, 60, 26),
      const Radius.circular(8),
    );
    c.drawRRect(base, Paint()..color = Colors.white);
    c.drawRRect(
      base,
      Paint()
        ..color = AppColors.grape
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(40, 68, 36, 14),
        const Radius.circular(4),
      ),
      Paint()..color = AppColors.grape.withValues(alpha: 0.16),
    );
    _label(c, 'kg', const Offset(58, 75), color: AppColors.grape, size: 12);
    _badge(c, 'mass', const Offset(58, 101), AppColors.grape);

    // Spring scale: reads weight.
    const hookX = 176.0;
    c.drawLine(
      const Offset(hookX, 8),
      const Offset(hookX, 22),
      Paint()
        ..color = _inkDark
        ..strokeWidth = 3,
    );
    for (var i = 0; i < 6; i++) {
      final y = 22 + i * 5.0;
      c.drawLine(
        Offset(hookX - 8, y),
        Offset(hookX + 8, y + 2.5),
        Paint()
          ..color = AppColors.sky
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
    c.drawLine(
      const Offset(hookX, 52),
      Offset(hookX + sway, 60),
      Paint()
        ..color = _inkDark
        ..strokeWidth = 2,
    );
    _crate(c, Rect.fromLTWH(hookX + sway - 15, 60, 30, 26));
    c.drawCircle(const Offset(212, 37), 13, Paint()..color = Colors.white);
    c.drawCircle(
      const Offset(212, 37),
      13,
      Paint()
        ..color = AppColors.sky
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    _label(c, 'N', const Offset(212, 37), color: AppColors.sky, size: 12);
    _badge(c, 'weight', const Offset(176, 101), AppColors.sky);
  }

  void _planetRow(Canvas c) {
    // Arrow length is the pull: same crate, three very different weights.
    const worlds = [
      (label: 'Moon', x: 42.0, r: 15.0, pull: 0.22, color: Color(0xFFB9BCD6)),
      (label: 'Earth', x: 118.0, r: 22.0, pull: 0.62, color: AppColors.learn),
      (label: 'Jupiter', x: 198.0, r: 30.0, pull: 1.0, color: _deepAmber),
    ];
    final pulse = 0.86 + 0.14 * math.sin(idle * math.pi * 2);

    _sky(c, const Color(0xFF2B2450), const Color(0xFF4A3E7A));
    _starfield(c);

    for (final w in worlds) {
      c.drawCircle(Offset(w.x, 42), w.r + 4,
          Paint()..color = w.color.withValues(alpha: 0.18));
      c.drawCircle(Offset(w.x, 42), w.r, Paint()..color = w.color);
      c.drawCircle(
        Offset(w.x - w.r * 0.3, 42 - w.r * 0.3),
        w.r * 0.3,
        Paint()..color = Colors.white.withValues(alpha: 0.2),
      );
      final len = 8 + 22 * w.pull * pulse;
      _arrow(c, Offset(w.x, 74), Offset(w.x, 74 + len), AppColors.sunshine,
          width: 4);
      _label(c, w.label, Offset(w.x, 103));
    }
  }

  void _label(
    Canvas c,
    String text,
    Offset centre, {
    Color color = Colors.white,
    double size = 11,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(c, centre - Offset(painter.width / 2, painter.height / 2));
  }

  void _dropTest(Canvas c) {
    // No air here, so both objects share one fall curve and land together.
    final fall = action * action;
    final y = 20 + 58 * fall;
    final landed = action > 0.98;

    _sky(c, const Color(0xFF2B2450), const Color(0xFF4A3E7A));
    _starfield(c);
    _groundBand(c, const Color(0xFF6E6395), const Color(0xFF877BB0));

    // Hammer.
    c.drawRect(Rect.fromLTWH(70, y, 5, 26), Paint()..color = _deepAmber);
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(58, y - 8, 30, 12),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFB9BCD6),
    );

    // Feather.
    final quill = Path()
      ..moveTo(168, y - 10)
      ..quadraticBezierTo(150, y + 6, 158, y + 24);
    c.drawPath(
      quill,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    for (var i = 0; i < 6; i++) {
      final t = i / 5;
      final p = _quad(
        Offset(168, y - 10),
        Offset(150, y + 6),
        Offset(158, y + 24),
        t,
      );
      c.drawOval(
        Rect.fromCenter(center: p + Offset(6, 0), width: 14 - 8 * t, height: 5),
        Paint()..color = Colors.white.withValues(alpha: 0.75),
      );
    }

    _dashedLine(c, Offset(20, y + 24), Offset(220, y + 24),
        Colors.white.withValues(alpha: 0.3));

    if (landed) {
      _badge(c, 'same time', const Offset(120, 16), AppColors.play);
    }
  }

  // ---------- simple machine scenes ----------

  void _effortTrade(Canvas c) {
    // Left: a short, brutal lift. Right: the same climb spread over a ramp.
    final lift = 0.5 - 0.5 * math.cos(action * math.pi * 2);

    _sky(c, const Color(0xFFE3F3E9), const Color(0xFFFBFEFC));
    _groundBand(c, const Color(0xFFA6E6BC), const Color(0xFF74CE97));
    _dashedLine(c, const Offset(120, 8), const Offset(120, 90),
        AppColors.ink.withValues(alpha: 0.18));

    // Straight lift: one big arrow, tiny travel.
    final liftY = 64 - 22 * lift;
    _crate(c, Rect.fromLTWH(38, liftY, 30, 26));
    _arrow(c, const Offset(20, 84), const Offset(20, 44), AppColors.practice,
        width: 9);
    _badge(c, 'big push', const Offset(70, 100), AppColors.practiceDeep);

    // Ramp: small arrow, long travel.
    final slope = Path()
      ..moveTo(132, 90)
      ..lineTo(224, 46)
      ..lineTo(224, 90)
      ..close();
    c.drawPath(slope, Paint()..color = const Color(0xFFBFA079));
    c.drawPath(
      slope,
      Paint()
        ..color = const Color(0xFF8E6C46)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final along = Offset.lerp(const Offset(140, 80), const Offset(210, 47), lift)!;
    _crate(c, Rect.fromCenter(center: along, width: 26, height: 22));
    _arrow(c, const Offset(136, 92), const Offset(176, 73), AppColors.play,
        width: 5);
    _badge(c, 'small push', const Offset(178, 100), AppColors.playDeep);
  }

  void _lever(Canvas c) {
    // Fulcrum sits near the load, so a light push lifts a heavy crate.
    final press = 0.5 - 0.5 * math.cos(action * math.pi * 2);
    const pivot = Offset(150, 76);
    final tilt = -0.20 + 0.32 * press;

    _sky(c, const Color(0xFFDDF0FF), const Color(0xFFF9FCFF));
    _sun(c, const Offset(30, 22));
    _groundBand(c, const Color(0xFFA6E6BC), const Color(0xFF74CE97));

    c.save();
    c.translate(pivot.dx, pivot.dy);
    c.rotate(tilt);

    const beam = Rect.fromLTWH(-118, -5, 176, 10);
    final beamShape = RRect.fromRectAndRadius(beam, const Radius.circular(5));
    c.drawRRect(beamShape, Paint()..color = const Color(0xFFBFA079));
    c.drawRRect(
      beamShape,
      Paint()
        ..color = const Color(0xFF8E6C46)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Both sit on the beam, so they rise and fall with it.
    _crate(c, const Rect.fromLTWH(30, -30, 26, 25));
    _arrow(c, const Offset(-102, -42), const Offset(-102, -12),
        AppColors.practice, width: 6);
    c.restore();

    c.drawPath(
      Path()
        ..moveTo(pivot.dx, pivot.dy + 3)
        ..lineTo(pivot.dx - 15, pivot.dy + 22)
        ..lineTo(pivot.dx + 15, pivot.dy + 22)
        ..close(),
      Paint()..color = AppColors.grape,
    );

    _badge(c, 'effort', const Offset(48, 14), AppColors.practiceDeep);
    _badge(c, 'load', const Offset(196, 18), AppColors.learnDeep);
    _badge(c, 'fulcrum', const Offset(150, 101), AppColors.grape);
  }

  void _ramp(Canvas c) {
    // Same height gained either way; the slope just spreads it out.
    final climb = action;

    _sky(c, const Color(0xFFFFF3DE), const Color(0xFFFFFDF8));
    _sun(c, const Offset(30, 20));
    _groundBand(c, const Color(0xFFE9D8B4), const Color(0xFFD2BB8E));

    const foot = Offset(26, 90);
    const top = Offset(196, 40);
    final slope = Path()
      ..moveTo(foot.dx, foot.dy)
      ..lineTo(top.dx, top.dy)
      ..lineTo(top.dx, foot.dy)
      ..close();
    c.drawPath(slope, Paint()..color = const Color(0xFFBFA079));
    c.drawPath(
      slope,
      Paint()
        ..color = const Color(0xFF8E6C46)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Height gained, marked up the back edge.
    _dashedLine(c, const Offset(214, 40), const Offset(214, 90),
        AppColors.ink.withValues(alpha: 0.35));
    _badge(c, 'height', const Offset(214, 24), AppColors.grape);

    final along = Offset.lerp(foot, top, climb)!;
    final lift = along - const Offset(0, 15);
    _crate(c, Rect.fromCenter(center: lift, width: 28, height: 24));

    final dir = (top - foot) / (top - foot).distance;
    _arrow(c, lift - dir * 40, lift - dir * 18, AppColors.play, width: 5);
    _badge(c, 'push', const Offset(60, 26), AppColors.playDeep);
  }

  void _pulley(Canvas c) {
    // Two wheels means two strands, so the paw pulls half the weight.
    final haul = 0.5 - 0.5 * math.cos(action * math.pi * 2);
    final crateY = 74 - 18 * haul;

    _sky(c, const Color(0xFFE7E1FF), const Color(0xFFFBFAFF));
    _groundBand(c, const Color(0xFFCFC4FF), const Color(0xFFB6A6F5));

    // Ceiling beam.
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(40, 6, 170, 10),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF8E6C46),
    );

    void wheel(Offset at) {
      c.drawCircle(at, 11, Paint()..color = AppColors.grape);
      c.drawCircle(at, 6, Paint()..color = Colors.white);
      c.drawCircle(
        at,
        11,
        Paint()
          ..color = const Color(0xFF7B3FD6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    final rope = Paint()
      ..color = AppColors.sunshine
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const fixed = Offset(96, 27);
    final moving = Offset(140, crateY - 16);

    c.drawLine(const Offset(140, 16), Offset(moving.dx - 11, moving.dy), rope);
    c.drawLine(Offset(moving.dx + 11, moving.dy),
        Offset(fixed.dx + 11, fixed.dy), rope);
    c.drawLine(Offset(fixed.dx - 11, fixed.dy),
        Offset(fixed.dx - 11, 74 - 10 * haul), rope);

    wheel(fixed);
    wheel(moving);

    c.drawLine(Offset(moving.dx, moving.dy + 11), Offset(140, crateY), rope);
    _crate(c, Rect.fromLTWH(126, crateY, 30, 26));

    _arrow(c, Offset(85, 62 - 10 * haul), Offset(85, 82 - 10 * haul),
        AppColors.practice, width: 5);
    _badge(c, 'pull', const Offset(66, 46), AppColors.practiceDeep);
    _badge(c, '2 strands', const Offset(196, 60), AppColors.learnDeep);
  }
}
