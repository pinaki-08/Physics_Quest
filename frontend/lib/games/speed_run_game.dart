import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme.dart';
import 'game_shell.dart';

class _Zone {
  final double start;
  final double end;
  final double limit;
  const _Zone(this.start, this.end, this.limit);
}

class _Track {
  final String name;
  final List<_Zone> zones;
  const _Track(this.name, this.zones);

  double get length => zones.last.end;

  /// Time a perfect driver needs, with a margin for speeding up and braking.
  double get par {
    var t = 0.0;
    for (final z in zones) {
      t += (z.end - z.start) / z.limit;
    }
    return (t * 1.22 * 2).round() / 2;
  }

  double limitAt(double x) {
    for (final z in zones) {
      if (x >= z.start && x < z.end) return z.limit;
    }
    return zones.last.limit;
  }

  _Zone? nextZone(double x) {
    for (final z in zones) {
      if (z.start > x) return z;
    }
    return null;
  }
}

const _tracks = <_Track>[
  _Track('Town Loop', [
    _Zone(0, 90, 18),
    _Zone(90, 150, 7),
    _Zone(150, 240, 18),
  ]),
  _Track('School Run', [
    _Zone(0, 60, 20),
    _Zone(60, 100, 6),
    _Zone(100, 180, 16),
    _Zone(180, 220, 8),
  ]),
  _Track('Coast Road', [
    _Zone(0, 120, 22),
    _Zone(120, 160, 9),
    _Zone(160, 300, 20),
  ]),
  _Track('Old Bridge', [
    _Zone(0, 50, 12),
    _Zone(50, 130, 24),
    _Zone(130, 170, 6),
    _Zone(170, 260, 18),
  ]),
];

/// Motion & Speed. Real-time driving: build speed, read the road ahead and
/// brake in time, because the car cannot change speed instantly. Arriving on
/// the target time means averaging distance over time across every zone.
class SpeedRunGame extends StatefulWidget {
  const SpeedRunGame({super.key});

  @override
  State<SpeedRunGame> createState() => _SpeedRunGameState();
}

class _SpeedRunGameState extends State<SpeedRunGame>
    with SingleTickerProviderStateMixin {
  static const _accel = 7.0;
  static const _brake = 11.0;
  static const _drag = 1.4;
  static const _topSpeed = 26.0;
  static const _metresOnScreen = 70.0;

  late final Ticker _ticker;

  int _index = 0;
  int _score = 0;
  double _pos = 0;
  double _vel = 0;
  double _time = 0;
  double _speeding = 0;
  bool _throttle = false;
  bool _braking = false;
  bool _driving = false;
  bool _done = false;
  int _roundPoints = 0;
  Duration _last = Duration.zero;

  _Track get _track => _tracks[_index];
  double get _limit => _track.limitAt(_pos);
  bool get _over => _vel > _limit + 0.4;
  double get _ghost => math.min(_track.length, _time / _track.par * _track.length);

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

  void _go() {
    setState(() {
      _pos = 0;
      _vel = 0;
      _time = 0;
      _speeding = 0;
      _throttle = false;
      _braking = false;
      _driving = true;
      _done = false;
      _last = Duration.zero;
    });
    _ticker.start();
  }

  void _tick(Duration elapsed) {
    final dt = _last == Duration.zero
        ? 0.016
        : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (dt <= 0 || dt > 0.2) return;

    final a = _braking
        ? -_brake
        : _throttle
            ? _accel
            : -_drag;
    _vel = (_vel + a * dt).clamp(0.0, _topSpeed);
    _pos += _vel * dt;
    _time += dt;
    if (_over) _speeding += dt;

    if (_pos >= _track.length) {
      _pos = _track.length;
      _ticker.stop();
      _finish();
      return;
    }
    setState(() {});
  }

  void _finish() {
    final error = (_time - _track.par).abs();
    final timing = math.max(0.0, 100 - error * 26);
    final fine = _speeding * 34;
    final points = math.max(0, (timing - fine).round());
    setState(() {
      _driving = false;
      _done = true;
      _roundPoints = points;
      _score += points;
    });
  }

  void _next() {
    setState(() {
      _index = (_index + 1) % _tracks.length;
      _done = false;
      _pos = 0;
      _vel = 0;
      _time = 0;
      _speeding = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final track = _track;
    final ahead = track.nextZone(_pos);
    final pace = _time - (_pos / track.length) * track.par;

    return GameShell(
      title: 'Speed Run',
      instruction:
          'Obey every speed limit and cross the line on the target time.',
      color: AppColors.practice,
      scoreboard: Row(
        children: [
          GameStat(
            icon: Icons.map_rounded,
            label: track.name,
            value: '${track.length.round()} m',
          ),
          GameStat(
            icon: Icons.timer_rounded,
            label: 'Target',
            value: '${track.par.toStringAsFixed(1)}s',
          ),
          GameStat(
            icon: Icons.star_rounded,
            label: 'Score',
            value: '$_score',
          ),
        ],
      ),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 210,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RoadPainter(
                      track: track,
                      pos: _pos,
                      ghost: _driving || _done ? _ghost : 0,
                      speed: _vel,
                      span: _metresOnScreen,
                      speeding: _over,
                      braking: _braking,
                      thrusting: _throttle,
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  right: 12,
                  child: _Hud(
                    time: _time,
                    speed: _vel,
                    limit: _limit,
                    over: _over,
                    pos: _pos,
                    length: track.length,
                    pace: _driving ? pace : null,
                  ),
                ),
                if (ahead != null && _driving && ahead.start - _pos < 45)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: _ZoneWarning(
                      limit: ahead.limit,
                      metres: (ahead.start - _pos).round(),
                      slower: ahead.limit < _limit,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _SpeedBar(speed: _vel, limit: _limit, top: _topSpeed),
        const SizedBox(height: 12),
        if (_driving)
          Row(
            children: [
              Expanded(
                child: _PedalButton(
                  icon: Icons.arrow_downward_rounded,
                  label: 'Brake',
                  color: AppColors.practice,
                  active: _braking,
                  onDown: () => setState(() => _braking = true),
                  onUp: () => setState(() => _braking = false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _PedalButton(
                  icon: Icons.keyboard_double_arrow_up_rounded,
                  label: 'Throttle',
                  color: AppColors.play,
                  active: _throttle,
                  onDown: () => setState(() => _throttle = true),
                  onUp: () => setState(() => _throttle = false),
                ),
              ),
            ],
          )
        else if (_done) ...[
          _RoundResult(
            time: _time,
            par: track.par,
            speeding: _speeding,
            points: _roundPoints,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GameButton(
                  label: 'Retry',
                  icon: Icons.replay_rounded,
                  color: AppColors.practice,
                  filled: false,
                  onTap: _go,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GameButton(
                  label: 'Next track',
                  icon: Icons.arrow_forward_rounded,
                  color: AppColors.practice,
                  onTap: _next,
                ),
              ),
            ],
          ),
        ] else
          GameButton(
            label: 'Start ${track.name}',
            icon: Icons.play_arrow_rounded,
            color: AppColors.practice,
            onTap: _go,
          ),
        const SizedBox(height: 12),
        const _Legend(),
      ],
    );
  }
}

class _Hud extends StatelessWidget {
  final double time;
  final double speed;
  final double limit;
  final bool over;
  final double pos;
  final double length;
  final double? pace;

  const _Hud({
    required this.time,
    required this.speed,
    required this.limit,
    required this.over,
    required this.pos,
    required this.length,
    required this.pace,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Pill(
          icon: Icons.timer_rounded,
          text: '${time.toStringAsFixed(1)}s',
          tone: Colors.white,
        ),
        const SizedBox(width: 6),
        _Pill(
          icon: Icons.speed_rounded,
          text: '${speed.toStringAsFixed(0)}/${limit.round()}',
          tone: over ? AppColors.practice : Colors.white,
        ),
        const SizedBox(width: 6),
        _Pill(
          icon: Icons.straighten_rounded,
          text: '${pos.round()}/${length.round()}m',
          tone: Colors.white,
        ),
        const Spacer(),
        if (pace != null)
          _Pill(
            icon: pace! > 0
                ? Icons.trending_down_rounded
                : Icons.trending_up_rounded,
            text: '${pace! > 0 ? '+' : ''}${pace!.toStringAsFixed(1)}',
            tone: pace! > 0 ? AppColors.sunshine : AppColors.play,
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color tone;

  const _Pill({required this.icon, required this.text, required this.tone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: tone),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: tone,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneWarning extends StatelessWidget {
  final double limit;
  final int metres;
  final bool slower;

  const _ZoneWarning({
    required this.limit,
    required this.metres,
    required this.slower,
  });

  @override
  Widget build(BuildContext context) {
    final tone = slower ? AppColors.practice : AppColors.play;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tone,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            slower ? Icons.warning_rounded : Icons.check_circle_rounded,
            size: 15,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            '${limit.round()} m/s in ${metres}m',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeedBar extends StatelessWidget {
  final double speed;
  final double limit;
  final double top;

  const _SpeedBar({
    required this.speed,
    required this.limit,
    required this.top,
  });

  @override
  Widget build(BuildContext context) {
    final over = speed > limit + 0.4;
    return SizedBox(
      height: 34,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            Container(
              width: constraints.maxWidth * (speed / top).clamp(0.0, 1.0),
              height: 14,
              decoration: BoxDecoration(
                color: over ? AppColors.practice : AppColors.play,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            // The limit marker is what you steer the bar towards.
            Positioned(
              left: (constraints.maxWidth * (limit / top).clamp(0.0, 1.0)) - 1,
              child: Container(width: 3, height: 30, color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}

class _PedalButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool active;
  final VoidCallback onDown;
  final VoidCallback onUp;

  const _PedalButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.active,
    required this.onDown,
    required this.onUp,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onDown(),
      onTapUp: (_) => onUp(),
      onTapCancel: onUp,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: active ? color : color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Icon(icon, size: 26, color: active ? Colors.white : color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundResult extends StatelessWidget {
  final double time;
  final double par;
  final double speeding;
  final int points;

  const _RoundResult({
    required this.time,
    required this.par,
    required this.speeding,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final error = time - par;
    final clean = speeding < 0.15;
    final tone = points >= 80
        ? AppColors.play
        : points >= 40
            ? AppColors.sunshine
            : AppColors.practice;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            '+$points points',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: tone == AppColors.play ? AppColors.playDeep : tone,
            ),
          ),
          const SizedBox(height: 8),
          _Line(
            label: 'Your time',
            value: '${time.toStringAsFixed(1)}s',
            note: error.abs() < 0.2
                ? 'right on target'
                : error > 0
                    ? '${error.toStringAsFixed(1)}s late'
                    : '${(-error).toStringAsFixed(1)}s early',
          ),
          _Line(
            label: 'Speeding',
            value: '${speeding.toStringAsFixed(1)}s',
            note: clean ? 'clean run' : 'cost ${(speeding * 34).round()} points',
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  final String note;

  const _Line({
    required this.label,
    required this.value,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12.5, color: AppColors.inkSoft),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note,
              style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Green road is a fast zone, red is a slow zone. Brake early — the car '
      'takes time and distance to slow down.',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12.5, color: AppColors.inkSoft, height: 1.4),
    );
  }
}

class _RoadPainter extends CustomPainter {
  final _Track track;
  final double pos;
  final double ghost;
  final double speed;
  final double span;
  final bool speeding;
  final bool braking;
  final bool thrusting;

  const _RoadPainter({
    required this.track,
    required this.pos,
    required this.ghost,
    required this.speed,
    required this.span,
    required this.speeding,
    required this.braking,
    required this.thrusting,
  });

  @override
  bool shouldRepaint(covariant _RoadPainter old) => true;

  @override
  void paint(Canvas canvas, Size size) {
    final roadY = size.height * 0.66;
    final ppm = size.width / span;
    // Camera keeps the car a third of the way in, and starts behind the line
    // so the car is never clipped by the left edge.
    final camera = pos - span * 0.3;
    double sx(double worldX) => (worldX - camera) * ppm;

    _sky(canvas, size, roadY);
    _hills(canvas, size, roadY, camera * 0.06, const Color(0xFF7FC6A4), 34);
    _hills(canvas, size, roadY, camera * 0.14, const Color(0xFF5FAE8B), 22);

    canvas.drawRect(
      Rect.fromLTWH(0, roadY, size.width, size.height - roadY),
      Paint()..color = const Color(0xFF3A3358),
    );

    // Verge coloured by the limit of each zone.
    for (final z in track.zones) {
      final a = sx(z.start);
      final b = sx(z.end);
      if (b < -20 || a > size.width + 20) continue;
      final fast = z.limit >= 15;
      canvas.drawRect(
        Rect.fromLTRB(a, roadY, b, roadY + 9),
        Paint()..color = fast ? AppColors.play : AppColors.practice,
      );
      _sign(canvas, Offset(a, roadY - 4), z.limit);
    }

    _markers(canvas, size, roadY, camera, ppm);
    _lanes(canvas, size, roadY, camera, ppm);
    _finishGate(canvas, sx(track.length), roadY);

    final gx = sx(ghost);
    if (gx > -60 && gx < size.width + 60) {
      _car(canvas, Offset(gx, roadY - 18), const Color(0xFFB9BCD6),
          ghostly: true, blur: 0, braking: false);
      _tag(canvas, 'TARGET', Offset(gx, roadY - 42), const Color(0xFFB9BCD6),
          size.width);
    }

    final cx = sx(pos);
    _car(
      canvas,
      Offset(cx, roadY - 18),
      speeding ? AppColors.practiceDeep : AppColors.practice,
      ghostly: false,
      blur: (speed / 26).clamp(0.0, 1.0),
      braking: braking,
    );
    _tag(canvas, 'YOU', Offset(cx, roadY - 74), AppColors.practice, size.width);

    if (speeding) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = AppColors.practice.withValues(alpha: 0.14),
      );
    }
  }

  void _sky(Canvas canvas, Size size, double roadY) {
    final rect = Rect.fromLTWH(0, 0, size.width, roadY);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3D2C74), Color(0xFF9B5BA8), Color(0xFFF3A15C)],
        ).createShader(rect),
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, roadY * 0.38),
      24,
      Paint()..color = const Color(0xFFFFD59B).withValues(alpha: 0.9),
    );
  }

  void _hills(Canvas canvas, Size size, double roadY, double shift, Color color,
      double height) {
    final path = Path()..moveTo(0, roadY);
    final wave = size.width / 2.5;
    final offset = -(shift % wave);
    for (var x = -wave + offset; x < size.width + wave; x += wave) {
      path.quadraticBezierTo(x + wave / 2, roadY - height * 2, x + wave, roadY);
    }
    path
      ..lineTo(size.width, roadY)
      ..lineTo(0, roadY)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _sign(Canvas canvas, Offset at, double limit) {
    if (at.dx < -30 || at.dx > 2000) return;
    canvas.drawRect(
      Rect.fromLTWH(at.dx - 1.5, at.dy - 34, 3, 34),
      Paint()..color = const Color(0xFF2B2450),
    );
    canvas.drawCircle(
        Offset(at.dx, at.dy - 44), 12, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(at.dx, at.dy - 44),
      12,
      Paint()
        ..color = AppColors.practice
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    final painter = TextPainter(
      text: TextSpan(
        text: '${limit.round()}',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2B2450),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(at.dx, at.dy - 44) -
          Offset(painter.width / 2, painter.height / 2),
    );
  }

  void _markers(
      Canvas canvas, Size size, double roadY, double camera, double ppm) {
    final first = (camera / 20).floor() * 20;
    for (var m = first; m < camera + span + 20; m += 20) {
      if (m < 0) continue;
      final x = (m - camera) * ppm;
      if (x < -20 || x > size.width + 20) continue;
      canvas.drawRect(
        Rect.fromLTWH(x, roadY + 11, 2, 7),
        Paint()..color = Colors.white.withValues(alpha: 0.3),
      );
      final painter = TextPainter(
        text: TextSpan(
          text: '$m',
          style: TextStyle(
            fontSize: 9,
            color: Colors.white.withValues(alpha: 0.45),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, Offset(x - painter.width / 2, roadY + 19));
    }
  }

  void _lanes(
      Canvas canvas, Size size, double roadY, double camera, double ppm) {
    final y = roadY + (size.height - roadY) * 0.62;
    final first = (camera / 10).floor() * 10;
    for (var m = first; m < camera + span + 10; m += 10) {
      final x = (m - camera) * ppm;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, math.max(6, ppm * 3), 4),
          const Radius.circular(2),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.28),
      );
    }
  }

  void _finishGate(Canvas canvas, double x, double roadY) {
    if (x < -40 || x > 3000) return;
    for (var row = 0; row < 6; row++) {
      for (var col = 0; col < 2; col++) {
        canvas.drawRect(
          Rect.fromLTWH(x + col * 7, roadY - 54 + row * 9.0, 7, 9),
          Paint()
            ..color =
                (row + col).isEven ? Colors.white : const Color(0xFF2B2450),
        );
      }
    }
  }

  void _car(Canvas canvas, Offset at, Color colour,
      {required bool ghostly,
      required double blur,
      required bool braking}) {
    final alpha = ghostly ? 0.4 : 1.0;

    if (blur > 0.1) {
      for (var i = 1; i <= 3; i++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: at - Offset(i * 9.0 * blur, 0),
              width: 40,
              height: 16,
            ),
            const Radius.circular(8),
          ),
          Paint()..color = colour.withValues(alpha: 0.16 * blur / i),
        );
      }
    }

    canvas.drawOval(
      Rect.fromCenter(center: at + const Offset(0, 16), width: 44, height: 7),
      Paint()..color = Colors.black.withValues(alpha: 0.22 * alpha),
    );

    final body = RRect.fromRectAndCorners(
      Rect.fromCenter(center: at, width: 44, height: 19),
      topLeft: const Radius.circular(6),
      topRight: const Radius.circular(11),
      bottomLeft: const Radius.circular(9),
      bottomRight: const Radius.circular(9),
    );
    canvas.drawRRect(body, Paint()..color = colour.withValues(alpha: alpha));

    final canopy = Path()
      ..moveTo(at.dx - 9, at.dy - 8)
      ..quadraticBezierTo(at.dx - 1, at.dy - 21, at.dx + 12, at.dy - 8)
      ..close();
    canvas.drawPath(
      canopy,
      Paint()..color = const Color(0xFF2B2450).withValues(alpha: alpha),
    );

    // Brake light or thruster, so the input is visible on the car itself.
    canvas.drawOval(
      Rect.fromCenter(center: at + const Offset(-24, 1), width: 12, height: 8),
      Paint()
        ..color = (braking ? AppColors.practice : AppColors.sunshine)
            .withValues(alpha: (braking ? 1.0 : 0.75) * alpha),
    );

    for (final dx in const [-12.0, 12.0]) {
      canvas.drawCircle(
        at + Offset(dx, 10),
        5,
        Paint()..color = const Color(0xFF2B2450).withValues(alpha: alpha),
      );
    }
  }

  void _tag(
      Canvas canvas, String text, Offset at, Color colour, double width) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.6,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final w = painter.width + 12;
    final cx = at.dx.clamp(w / 2 + 2, width - w / 2 - 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, at.dy), width: w, height: painter.height + 6),
        const Radius.circular(7),
      ),
      Paint()..color = colour.withValues(alpha: 0.9),
    );
    painter.paint(
      canvas,
      Offset(cx, at.dy) - Offset(painter.width / 2, painter.height / 2),
    );
  }
}
