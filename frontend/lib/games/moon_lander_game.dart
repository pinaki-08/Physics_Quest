import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme.dart';
import 'game_shell.dart';

class _World {
  final String name;
  final double gravity;
  final Color colour;
  const _World(this.name, this.gravity, this.colour);
}

const _worlds = [
  _World('Moon', 1.6, Color(0xFF7C82AD)),
  _World('Mars', 3.7, Color(0xFFC4553A)),
  _World('Earth', 9.8, AppColors.learn),
];

enum _Outcome { landed, tooFast, missedPad, tipped, lost }

/// Gravity & Weight. Gravity is real for the chosen world, so the Moon is
/// forgiving and Earth is brutal with the same craft and the same fuel. The
/// pad has to be reached as well as reached gently, so drift has to be
/// cancelled early — sideways speed does not fix itself.
class MoonLanderGame extends StatefulWidget {
  const MoonLanderGame({super.key});

  @override
  State<MoonLanderGame> createState() => _MoonLanderGameState();
}

class _MoonLanderGameState extends State<MoonLanderGame>
    with SingleTickerProviderStateMixin {
  static const _startAltitude = 130.0;
  static const _mainThrust = 15.0;
  static const _sideThrust = 6.0;
  static const _safeDrop = 4.0;
  static const _safeDrift = 2.2;
  static const _padHalfWidth = 9.0;
  static const _startFuel = 100.0;
  static const _viewWidth = 76.0;

  final _rng = math.Random();
  late final Ticker _ticker;

  int _world = 0;
  double _altitude = _startAltitude;
  double _vy = 0;
  double _x = 0;
  double _vx = 0;
  double _fuel = _startFuel;
  bool _burn = false;
  int _steer = 0;
  bool _flying = false;
  _Outcome? _outcome;
  int _score = 0;
  int _landings = 0;
  double _boom = 0;
  Duration _last = Duration.zero;

  _World get _place => _worlds[_world];
  bool get _dropSafe => _vy <= _safeDrop;
  bool get _driftSafe => _vx.abs() <= _safeDrift;
  bool get _overPad => _x.abs() <= _padHalfWidth;

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

  void _launch() {
    final side = _rng.nextBool() ? 1 : -1;
    setState(() {
      _altitude = _startAltitude;
      _vy = 0;
      // Starts off to one side with drift, so steering is always required.
      _x = side * (14 + _rng.nextDouble() * 12);
      _vx = -side * (1 + _rng.nextDouble() * 2.5);
      _fuel = _startFuel;
      _burn = false;
      _steer = 0;
      _flying = true;
      _outcome = null;
      _boom = 0;
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

    var ay = _place.gravity;
    if (_burn && _fuel > 0) {
      ay -= _mainThrust;
      _fuel = math.max(0, _fuel - 24 * dt);
    }
    if (_steer != 0 && _fuel > 0) {
      _vx += _steer * _sideThrust * dt;
      _fuel = math.max(0, _fuel - 9 * dt);
    }
    _vy += ay * dt;
    _altitude -= _vy * dt;
    _x += _vx * dt;

    if (_altitude <= 0) {
      _altitude = 0;
      _ticker.stop();
      _settle();
      return;
    }
    if (_altitude > _startAltitude * 1.7 || _x.abs() > _viewWidth / 2 + 10) {
      _ticker.stop();
      setState(() {
        _flying = false;
        _burn = false;
        _steer = 0;
        _outcome = _Outcome.lost;
      });
      return;
    }
    setState(() {});
  }

  void _settle() {
    final outcome = !_overPad
        ? _Outcome.missedPad
        : !_dropSafe
            ? _Outcome.tooFast
            : !_driftSafe
                ? _Outcome.tipped
                : _Outcome.landed;
    var points = 0;
    if (outcome == _Outcome.landed) {
      // Rewards a gentle touchdown, a centred pad hit and spare fuel.
      final gentle = ((_safeDrop - _vy) / _safeDrop).clamp(0.0, 1.0);
      final centred = (1 - _x.abs() / _padHalfWidth).clamp(0.0, 1.0);
      points = (60 + gentle * 40 + centred * 30 + _fuel * 0.4).round();
      _landings++;
    }
    setState(() {
      _flying = false;
      _burn = false;
      _steer = 0;
      _outcome = outcome;
      _score += points;
      _boom = outcome == _Outcome.landed ? 0 : 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameShell(
      title: 'Soft Landing',
      instruction:
          'Steer onto the pad and touch down under 4 m/s. Watch your fuel.',
      color: AppColors.grape,
      scoreboard: Row(
        children: [
          GameStat(
            icon: Icons.public_rounded,
            label: 'Gravity',
            value: '${_place.gravity}',
          ),
          GameStat(
            icon: Icons.flight_land_rounded,
            label: 'Landings',
            value: '$_landings',
          ),
          GameStat(
            icon: Icons.star_rounded,
            label: 'Score',
            value: '$_score',
          ),
        ],
      ),
      children: [
        Row(
          children: [
            for (var i = 0; i < _worlds.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _WorldChip(
                  world: _worlds[i],
                  selected: _world == i,
                  onTap: _flying ? null : () => setState(() => _world = i),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 280,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _LanderPainter(
                      altitude: _altitude,
                      maxAltitude: _startAltitude,
                      x: _x,
                      vx: _vx,
                      vy: _vy,
                      burning: _burn && _fuel > 0,
                      steer: _steer,
                      ground: _place.colour,
                      padHalfWidth: _padHalfWidth,
                      viewWidth: _viewWidth,
                      onPad: _overPad,
                      crashed: _boom > 0,
                      landed: _outcome == _Outcome.landed,
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: _Telemetry(
                    altitude: _altitude,
                    vy: _vy,
                    vx: _vx,
                    dropSafe: _dropSafe,
                    driftSafe: _driftSafe,
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: _FuelGauge(fuel: _fuel, max: _startFuel),
                ),
                if (!_flying && _outcome != null)
                  Positioned.fill(
                    child: _Verdict(outcome: _outcome!, onGo: _launch),
                  ),
                if (!_flying && _outcome == null)
                  Positioned.fill(
                    child: Container(
                      color: const Color(0xFF14103A).withValues(alpha: 0.6),
                      alignment: Alignment.center,
                      child: const Text(
                        'Ready for descent',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_flying)
          Row(
            children: [
              Expanded(
                child: _Pad(
                  icon: Icons.chevron_left_rounded,
                  label: 'Left',
                  color: AppColors.sky,
                  active: _steer < 0,
                  onDown: () => setState(() => _steer = -1),
                  onUp: () => setState(() => _steer = 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _Pad(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Thrust',
                  color: AppColors.practice,
                  active: _burn,
                  onDown: () => setState(() => _burn = true),
                  onUp: () => setState(() => _burn = false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Pad(
                  icon: Icons.chevron_right_rounded,
                  label: 'Right',
                  color: AppColors.sky,
                  active: _steer > 0,
                  onDown: () => setState(() => _steer = 1),
                  onUp: () => setState(() => _steer = 0),
                ),
              ),
            ],
          )
        else
          GameButton(
            label: _outcome == null ? 'Begin descent' : 'Fly again',
            icon: Icons.rocket_launch_rounded,
            color: AppColors.grape,
            onTap: _launch,
          ),
        const SizedBox(height: 12),
        const Text(
          'Side thrusters change your drift but never cancel it on their own — '
          'straighten up early.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5, color: AppColors.inkSoft, height: 1.4),
        ),
      ],
    );
  }
}

class _Telemetry extends StatelessWidget {
  final double altitude;
  final double vy;
  final double vx;
  final bool dropSafe;
  final bool driftSafe;

  const _Telemetry({
    required this.altitude,
    required this.vy,
    required this.vx,
    required this.dropSafe,
    required this.driftSafe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Row(label: 'ALT', value: '${altitude.round()} m', tone: Colors.white),
        _Row(
          label: 'DROP',
          value: '${vy.abs().toStringAsFixed(1)} m/s',
          tone: dropSafe ? AppColors.play : AppColors.practice,
        ),
        _Row(
          label: 'DRIFT',
          value: '${vx.abs().toStringAsFixed(1)} m/s',
          tone: driftSafe ? AppColors.play : AppColors.practice,
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color tone;

  const _Row({required this.label, required this.value, required this.tone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF14103A).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 38,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: tone,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FuelGauge extends StatelessWidget {
  final double fuel;
  final double max;

  const _FuelGauge({required this.fuel, required this.max});

  @override
  Widget build(BuildContext context) {
    final ratio = (fuel / max).clamp(0.0, 1.0);
    final low = ratio < 0.25;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF14103A).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: [
          Text(
            'FUEL',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 14,
            height: 74,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                FractionallySizedBox(
                  heightFactor: ratio,
                  child: Container(
                    decoration: BoxDecoration(
                      color: low ? AppColors.practice : AppColors.sunshine,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Verdict extends StatelessWidget {
  final _Outcome outcome;
  final VoidCallback onGo;

  const _Verdict({required this.outcome, required this.onGo});

  @override
  Widget build(BuildContext context) {
    final good = outcome == _Outcome.landed;
    final (title, detail) = switch (outcome) {
      _Outcome.landed => ('Touchdown', 'Gentle, centred and on the pad.'),
      _Outcome.tooFast => ('Crashed', 'You hit the ground too fast.'),
      _Outcome.missedPad => ('Missed the pad', 'Cancel your drift earlier.'),
      _Outcome.tipped => ('Tipped over', 'Too much sideways speed on contact.'),
      _Outcome.lost => ('Lost the craft', 'You drifted out of the area.'),
    };
    return Container(
      color: const Color(0xFF14103A).withValues(alpha: 0.72),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            good ? Icons.verified_rounded : Icons.dangerous_rounded,
            size: 42,
            color: good ? AppColors.play : AppColors.practice,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorldChip extends StatelessWidget {
  final _World world;
  final bool selected;
  final VoidCallback? onTap;

  const _WorldChip({
    required this.world,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.55 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:
                selected ? world.colour : world.colour.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                world.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : world.colour,
                ),
              ),
              Text(
                '${world.gravity} N/kg',
                style: TextStyle(
                  fontSize: 11,
                  color: selected ? Colors.white70 : world.colour,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pad extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool active;
  final VoidCallback onDown;
  final VoidCallback onUp;

  const _Pad({
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
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: active ? color : color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          boxShadow: active ? glow(color, opacity: 0.5, blur: 16) : null,
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: active ? Colors.white : color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
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

class _LanderPainter extends CustomPainter {
  final double altitude;
  final double maxAltitude;
  final double x;
  final double vx;
  final double vy;
  final bool burning;
  final int steer;
  final Color ground;
  final double padHalfWidth;
  final double viewWidth;
  final bool onPad;
  final bool crashed;
  final bool landed;

  const _LanderPainter({
    required this.altitude,
    required this.maxAltitude,
    required this.x,
    required this.vx,
    required this.vy,
    required this.burning,
    required this.steer,
    required this.ground,
    required this.padHalfWidth,
    required this.viewWidth,
    required this.onPad,
    required this.crashed,
    required this.landed,
  });

  @override
  bool shouldRepaint(covariant _LanderPainter old) => true;

  @override
  void paint(Canvas canvas, Size size) {
    final groundY = size.height - 34;
    final ppm = size.width / viewWidth;
    double sx(double worldX) => size.width / 2 + worldX * ppm;

    _space(canvas, size);
    _terrain(canvas, size, groundY, sx);
    _pad(canvas, groundY, sx);
    _guides(canvas, size, groundY, sx);

    final top = 30.0;
    final cy = top + (groundY - 22 - top) * (1 - (altitude / maxAltitude).clamp(0.0, 1.0));
    final cx = sx(x);

    if (crashed) {
      _debris(canvas, Offset(cx, cy));
    } else {
      _craft(canvas, Offset(cx, cy));
    }
    if (landed) _cheer(canvas, Offset(cx, cy));
  }

  void _space(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B0824), Color(0xFF2C2160), Color(0xFF4A3A7A)],
        ).createShader(rect),
    );
    for (var i = 0; i < 40; i++) {
      final px = (i * 149) % size.width.toInt();
      final py = (i * 83) % (size.height * 0.8).toInt();
      canvas.drawCircle(
        Offset(px.toDouble(), py.toDouble()),
        i % 5 == 0 ? 1.7 : 0.9,
        Paint()..color = Colors.white.withValues(alpha: i % 3 == 0 ? 0.8 : 0.4),
      );
    }
    canvas.drawCircle(
      Offset(size.width * 0.16, size.height * 0.17),
      20,
      Paint()..color = const Color(0xFF6FA8FF).withValues(alpha: 0.35),
    );
    canvas.drawCircle(
      Offset(size.width * 0.16, size.height * 0.17),
      14,
      Paint()..color = const Color(0xFF6FA8FF).withValues(alpha: 0.75),
    );
  }

  void _terrain(
      Canvas canvas, Size size, double groundY, double Function(double) sx) {
    final path = Path()..moveTo(0, size.height);
    path.lineTo(0, groundY - 16);
    // Jagged rock either side, flat across the landing pad.
    const bumps = [
      (-38.0, 14.0),
      (-30.0, 26.0),
      (-22.0, 8.0),
      (-14.0, 18.0),
      (-9.5, 0.0),
      (9.5, 0.0),
      (16.0, 20.0),
      (24.0, 9.0),
      (31.0, 24.0),
      (38.0, 12.0),
    ];
    for (final b in bumps) {
      path.lineTo(sx(b.$1), groundY - b.$2);
    }
    path
      ..lineTo(size.width, groundY - 14)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = ground);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _pad(Canvas canvas, double groundY, double Function(double) sx) {
    final left = sx(-padHalfWidth);
    final right = sx(padHalfWidth);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(left, groundY - 6, right, groundY),
        const Radius.circular(3),
      ),
      Paint()..color = onPad ? AppColors.play : AppColors.sunshine,
    );
    for (final px in [left, right]) {
      canvas.drawRect(
        Rect.fromLTWH(px - 2, groundY - 20, 4, 14),
        Paint()..color = Colors.white.withValues(alpha: 0.5),
      );
      canvas.drawCircle(
        Offset(px, groundY - 22),
        3.5,
        Paint()..color = onPad ? AppColors.play : AppColors.sunshine,
      );
    }
  }

  /// Vertical line from the craft to the pad, so the drift is obvious.
  void _guides(
      Canvas canvas, Size size, double groundY, double Function(double) sx) {
    final cx = sx(x);
    final dashes = Paint()
      ..color = (onPad ? AppColors.play : AppColors.practice)
          .withValues(alpha: 0.5)
      ..strokeWidth = 1.5;
    for (var y = 40.0; y < groundY - 10; y += 12) {
      canvas.drawLine(Offset(cx, y), Offset(cx, y + 6), dashes);
    }
  }

  void _craft(Canvas canvas, Offset at) {
    // Banking with the drift shows which way it is sliding.
    final tilt = (vx * 0.06).clamp(-0.3, 0.3);
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.rotate(tilt);

    if (burning) {
      final flame = Path()
        ..moveTo(-9, 15)
        ..lineTo(0, 40)
        ..lineTo(9, 15)
        ..close();
      canvas.drawPath(flame, Paint()..color = AppColors.sunshine);
      canvas.drawPath(
        Path()
          ..moveTo(-4, 15)
          ..lineTo(0, 28)
          ..lineTo(4, 15)
          ..close(),
        Paint()..color = Colors.white.withValues(alpha: 0.9),
      );
    }
    if (steer != 0) {
      final side = -steer.toDouble();
      canvas.drawPath(
        Path()
          ..moveTo(side * 13, -4)
          ..lineTo(side * 30, 0)
          ..lineTo(side * 13, 4)
          ..close(),
        Paint()..color = AppColors.sky,
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 30, height: 26),
        const Radius.circular(9),
      ),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, 13), width: 20, height: 8),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFB9BCD6),
    );
    canvas.drawCircle(
      const Offset(0, -4),
      6,
      Paint()..color = AppColors.sky,
    );
    canvas.drawCircle(
      const Offset(-2, -6),
      2,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
    for (final s in const [-1.0, 1.0]) {
      canvas.drawLine(
        Offset(s * 11, 12),
        Offset(s * 19, 23),
        Paint()
          ..color = const Color(0xFFB9BCD6)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        Offset(s * 14, 23),
        Offset(s * 23, 23),
        Paint()
          ..color = const Color(0xFFB9BCD6)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.restore();
  }

  void _debris(Canvas canvas, Offset at) {
    for (var i = 0; i < 10; i++) {
      final a = i * math.pi / 5;
      final r = 16.0 + (i % 3) * 9;
      canvas.drawCircle(
        at + Offset(math.cos(a), math.sin(a) * 0.6) * r,
        4.0 - (i % 3),
        Paint()..color = AppColors.practice.withValues(alpha: 0.85),
      );
    }
    canvas.drawCircle(
        at, 16, Paint()..color = AppColors.sunshine.withValues(alpha: 0.8));
  }

  void _cheer(Canvas canvas, Offset at) {
    for (var i = 0; i < 10; i++) {
      final a = i * math.pi / 5;
      canvas.drawLine(
        at + Offset(math.cos(a), math.sin(a)) * 24,
        at + Offset(math.cos(a), math.sin(a)) * 36,
        Paint()
          ..color = AppColors.play
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
  }
}
