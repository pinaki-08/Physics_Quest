import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme.dart';
import 'game_shell.dart';

/// Forces. Gusts push a cargo pod off centre and the player thrusts back.
/// Holding a button applies a real force, so the pod accelerates rather than
/// teleporting, and balanced forces visibly hold it still.
class ForceBalanceGame extends StatefulWidget {
  const ForceBalanceGame({super.key});

  @override
  State<ForceBalanceGame> createState() => _ForceBalanceGameState();
}

class _ForceBalanceGameState extends State<ForceBalanceGame>
    with SingleTickerProviderStateMixin {
  static const _mass = 20.0;
  static const _push = 45.0;
  static const _safe = 0.72;

  final _rng = math.Random();
  late final Ticker _ticker;

  double _x = 0;
  double _v = 0;
  double _wind = 0;
  double _gustIn = 2;
  double _survived = 0;
  int _best = 0;
  int _hold = 0;
  int _milestone = 0;
  double _flash = 0;
  bool _running = false;
  Duration _last = Duration.zero;

  double get _net => _wind + _hold * _push;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _start() {
    setState(() {
      _x = 0;
      _v = 0;
      _wind = 0;
      _gustIn = 1.5;
      _survived = 0;
      _hold = 0;
      _milestone = 0;
      _flash = 0;
      _running = true;
      _last = Duration.zero;
    });
    _ticker.start();
  }

  void _stop() {
    _ticker.stop();
    setState(() {
      _running = false;
      _best = math.max(_best, _survived.round());
    });
  }

  void _tick(Duration elapsed) {
    final dt = _last == Duration.zero
        ? 0.016
        : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (dt <= 0 || dt > 0.2) return;

    _gustIn -= dt;
    if (_gustIn <= 0) {
      // Gusts get stronger and more frequent the longer you last.
      final ramp = 1 + _survived / 18;
      _wind = (_rng.nextDouble() * 60 - 30) * ramp;
      _gustIn = math.max(0.7, 2.2 - _survived / 20);
      _flash = 1;
    }
    _flash = math.max(0, _flash - dt * 2.4);

    final a = _net / _mass;
    _v += a * dt;
    _v *= 0.995;
    _x += _v * dt * 0.02;
    _survived += dt;

    final reached = _survived ~/ 10;
    if (reached > _milestone) _milestone = reached;

    if (_x.abs() >= 1) {
      _x = _x.clamp(-1.0, 1.0);
      _stop();
      return;
    }
    setState(() {});
  }

  void _press(int direction) {
    if (!_running) return;
    setState(() => _hold = direction);
  }

  void _release() => setState(() => _hold = 0);

  @override
  Widget build(BuildContext context) {
    final balanced = _net.abs() < 4;
    return GameShell(
      title: 'Hold the Line',
      instruction: 'Thrust against the gusts and keep the pod in the field.',
      color: AppColors.sky,
      scoreboard: Row(
        children: [
          GameStat(
            icon: Icons.timer_rounded,
            label: 'Seconds',
            value: _survived.toStringAsFixed(1),
          ),
          GameStat(
            icon: Icons.emoji_events_rounded,
            label: 'Best',
            value: '$_best',
          ),
          GameStat(
            icon: Icons.air_rounded,
            label: 'Gust',
            value: '${_wind.abs().round()} N',
          ),
        ],
      ),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 230,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ArenaPainter(
                      x: _x,
                      v: _v,
                      wind: _wind,
                      hold: _hold,
                      push: _push,
                      safe: _safe,
                      time: _survived,
                      flash: _flash,
                      running: _running,
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      _survived.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1,
                        shadows: const [
                          Shadow(color: Colors.black38, blurRadius: 12),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_milestone > 0 && _running)
                  Positioned(
                    top: 62,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.play.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_milestone * 10}s survived',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (!_running)
                  Positioned.fill(
                    child: Container(
                      color: const Color(0xFF14103A).withValues(alpha: 0.66),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _survived == 0
                                ? Icons.sports_esports_rounded
                                : Icons.dangerous_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _survived == 0
                                ? 'Ready'
                                : 'Pod lost at ${_survived.toStringAsFixed(1)}s',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: (balanced ? AppColors.play : AppColors.sunshine)
                .withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            balanced
                ? 'Balanced — the pod holds steady'
                : 'Unbalanced by ${_net.abs().round()} N',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color:
                  balanced ? AppColors.playDeep : const Color(0xFFE07C00),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ThrustButton(
                icon: Icons.arrow_back_rounded,
                label: 'Thrust left',
                active: _hold < 0,
                enabled: _running,
                onDown: () => _press(-1),
                onUp: _release,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ThrustButton(
                icon: Icons.arrow_forward_rounded,
                label: 'Thrust right',
                active: _hold > 0,
                enabled: _running,
                onDown: () => _press(1),
                onUp: _release,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!_running)
          GameButton(
            label: _survived == 0 ? 'Launch pod' : 'Try again',
            icon: Icons.play_arrow_rounded,
            color: AppColors.sky,
            onTap: _start,
          ),
      ],
    );
  }
}

class _ThrustButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool enabled;
  final VoidCallback onDown;
  final VoidCallback onUp;

  const _ThrustButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.enabled,
    required this.onDown,
    required this.onUp,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: enabled ? (_) => onDown() : null,
      onTapUp: enabled ? (_) => onUp() : null,
      onTapCancel: enabled ? onUp : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: active
              ? AppColors.sky
              : AppColors.sky.withValues(alpha: enabled ? 0.14 : 0.06),
          borderRadius: BorderRadius.circular(20),
          boxShadow: active ? glow(AppColors.sky, opacity: 0.5, blur: 18) : null,
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: active ? Colors.white : AppColors.sky),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : AppColors.sky,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArenaPainter extends CustomPainter {
  final double x;
  final double v;
  final double wind;
  final int hold;
  final double push;
  final double safe;
  final double time;
  final double flash;
  final bool running;

  const _ArenaPainter({
    required this.x,
    required this.v,
    required this.wind,
    required this.hold,
    required this.push,
    required this.safe,
    required this.time,
    required this.flash,
    required this.running,
  });

  @override
  bool shouldRepaint(covariant _ArenaPainter old) => true;

  @override
  void paint(Canvas canvas, Size size) {
    final danger = ((x.abs() - 0.45) / (1 - 0.45)).clamp(0.0, 1.0);

    canvas.save();
    // A strong gust rattles the camera, which sells the size of the force.
    if (running) {
      final shake = (wind.abs() / 60) * flash * 5;
      canvas.translate(
        math.sin(time * 47) * shake,
        math.cos(time * 39) * shake * 0.6,
      );
    }

    _backdrop(canvas, size);
    _grid(canvas, size);
    _gustStreaks(canvas, size);

    final mid = size.width / 2;
    final span = size.width / 2 - 34;
    final railY = size.height * 0.68;

    _field(canvas, size, mid, span, railY, danger);
    _rail(canvas, size, mid, span, railY);

    final cx = mid + span * x;
    _pod(canvas, Offset(cx, railY - 26), danger);
    _forces(canvas, Offset(cx, railY - 26));

    canvas.restore();
    _vignette(canvas, size, danger);
  }

  void _backdrop(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment.center,
          radius: 1.1,
          colors: [Color(0xFF33296E), Color(0xFF141033)],
        ).createShader(rect),
    );
    for (var i = 0; i < 26; i++) {
      final sx = (i * 137) % size.width.toInt();
      final sy = (i * 71) % (size.height * 0.6).toInt();
      canvas.drawCircle(
        Offset(sx.toDouble(), sy.toDouble()),
        i.isEven ? 1.4 : 0.9,
        Paint()..color = Colors.white.withValues(alpha: 0.35),
      );
    }
  }

  void _grid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.sky.withValues(alpha: 0.16)
      ..strokeWidth = 1;
    final horizon = size.height * 0.68;
    for (var i = 1; i <= 5; i++) {
      final y = horizon + (size.height - horizon) * (i / 5) * (i / 5);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Verticals fan out from the centre, which reads as depth.
    for (var i = -6; i <= 6; i++) {
      canvas.drawLine(
        Offset(size.width / 2 + i * 12.0, horizon),
        Offset(size.width / 2 + i * (size.width / 9), size.height),
        paint,
      );
    }
  }

  void _gustStreaks(Canvas canvas, Size size) {
    if (wind.abs() < 2) return;
    final dir = wind.sign;
    final strength = (wind.abs() / 60).clamp(0.2, 1.4);
    final paint = Paint()
      ..color = AppColors.grape.withValues(alpha: 0.5 * strength)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 14; i++) {
      final y = ((i * 43) % (size.height * 0.62).toInt()).toDouble() + 12;
      final drift = (time * 220 * strength * dir + i * 91) % (size.width + 120);
      final sx = dir > 0 ? drift - 60 : size.width + 60 - drift;
      final len = 18 + 26 * strength;
      canvas.drawLine(Offset(sx, y), Offset(sx - dir * len, y), paint);
    }
  }

  void _field(Canvas canvas, Size size, double mid, double span, double railY,
      double danger) {
    final edge = Color.lerp(AppColors.play, AppColors.practice, danger)!;
    final left = mid - span * safe;
    final right = mid + span * safe;

    canvas.drawRect(
      Rect.fromLTRB(left, 0, right, size.height),
      Paint()..color = edge.withValues(alpha: 0.07 + 0.1 * danger),
    );

    for (final px in [left, right]) {
      canvas.drawRect(
        Rect.fromLTWH(px - 2, 0, 4, size.height),
        Paint()..color = edge.withValues(alpha: 0.55 + 0.4 * danger),
      );
      canvas.drawRect(
        Rect.fromLTWH(px - 9, railY - 46, 18, 52),
        Paint()..color = const Color(0xFF241C56),
      );
      canvas.drawRect(
        Rect.fromLTWH(px - 9, railY - 46, 18, 52),
        Paint()
          ..color = edge
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      for (var i = 0; i < 4; i++) {
        canvas.drawRect(
          Rect.fromLTWH(px - 6, railY - 40 + i * 11.0, 12, 5),
          Paint()..color = edge.withValues(alpha: 0.75),
        );
      }
    }
  }

  void _rail(Canvas canvas, Size size, double mid, double span, double railY) {
    canvas.drawRect(
      Rect.fromLTWH(20, railY - 1, size.width - 40, 3),
      Paint()..color = AppColors.sky.withValues(alpha: 0.5),
    );
    for (var i = -5; i <= 5; i++) {
      final tx = mid + span * (i / 5);
      canvas.drawRect(
        Rect.fromLTWH(tx - 1, railY + 4, 2, i == 0 ? 10 : 6),
        Paint()
          ..color = Colors.white.withValues(alpha: i == 0 ? 0.65 : 0.28),
      );
    }
  }

  void _pod(Canvas canvas, Offset at, double danger) {
    // Leaning into the motion makes the velocity readable at a glance.
    final tilt = (v * 0.9).clamp(-0.35, 0.35);
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.rotate(tilt);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 30), width: 62, height: 14),
      Paint()
        ..color = AppColors.sky.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    final shell = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 52, height: 44),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      shell,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(AppColors.sunshine, AppColors.practice, danger)!,
            Color.lerp(const Color(0xFFEE9B18), AppColors.practiceDeep,
                danger)!,
          ],
        ).createShader(shell.outerRect),
    );
    canvas.drawRRect(
      shell,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, -4), width: 30, height: 16),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFF241C56),
    );
    canvas.drawCircle(
      const Offset(0, -4),
      4,
      Paint()..color = const Color(0xFF33D6C0),
    );
    for (final s in const [-1.0, 1.0]) {
      canvas.drawRect(
        Rect.fromCenter(center: Offset(s * 20, 12), width: 8, height: 12),
        Paint()..color = const Color(0xFF241C56),
      );
    }
    canvas.restore();

    // Thruster plume fires opposite the direction being pushed.
    if (hold != 0) {
      final side = -hold.toDouble();
      final base = at + Offset(side * 28, 2);
      final flicker = 1 + math.sin(time * 40) * 0.25;
      final flame = Path()
        ..moveTo(base.dx, base.dy - 8)
        ..lineTo(base.dx + side * 26 * flicker, base.dy)
        ..lineTo(base.dx, base.dy + 8)
        ..close();
      canvas.drawPath(flame, Paint()..color = AppColors.sky);
      canvas.drawPath(
        Path()
          ..moveTo(base.dx, base.dy - 4)
          ..lineTo(base.dx + side * 14 * flicker, base.dy)
          ..lineTo(base.dx, base.dy + 4)
          ..close(),
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
    }
  }

  void _forces(Canvas canvas, Offset at) {
    if (wind.abs() > 2) {
      final dir = wind.sign;
      final len = 16 + wind.abs() * 0.7;
      _arrow(
        canvas,
        at + Offset(-dir * (34 + len), -14),
        at + Offset(-dir * 34, -14),
        AppColors.grape,
      );
      _label(canvas, '${wind.abs().round()} N',
          at + Offset(-dir * (44 + len * 0.5), -34), AppColors.grape);
    }
    if (hold != 0) {
      final len = 16 + push * 0.7;
      _arrow(
        canvas,
        at + Offset(hold * -(34 + len), 16),
        at + Offset(hold * -34.0, 16),
        AppColors.sky,
      );
    }
  }

  void _arrow(Canvas canvas, Offset from, Offset to, Color color) {
    final delta = to - from;
    if (delta.distance < 1) return;
    final unit = delta / delta.distance;
    final shaftEnd = to - unit * 9;
    canvas.drawLine(
      from,
      shaftEnd,
      Paint()
        ..color = color
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    final n = Offset(-unit.dy, unit.dx) * 7;
    canvas.drawPath(
      Path()
        ..moveTo(to.dx, to.dy)
        ..lineTo(shaftEnd.dx + n.dx, shaftEnd.dy + n.dy)
        ..lineTo(shaftEnd.dx - n.dx, shaftEnd.dy - n.dy)
        ..close(),
      Paint()..color = color,
    );
  }

  void _label(Canvas canvas, String text, Offset centre, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final box = Rect.fromCenter(
      center: centre,
      width: painter.width + 12,
      height: painter.height + 6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(7)),
      Paint()..color = color.withValues(alpha: 0.9),
    );
    painter.paint(canvas, centre - Offset(painter.width / 2, painter.height / 2));
  }

  void _vignette(Canvas canvas, Size size, double danger) {
    if (danger <= 0.02) return;
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.85,
          colors: [
            Colors.transparent,
            AppColors.practice.withValues(alpha: 0.55 * danger),
          ],
          stops: const [0.55, 1],
        ).createShader(rect),
    );
  }
}
