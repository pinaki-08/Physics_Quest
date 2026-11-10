import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import 'force_balance_model.dart';

const balanceWindColor = Color(0xFF477CA8);
const balancePushColor = Color(0xFFB8754E);

String balanceNumber(double value) => (value - value.roundToDouble()).abs() < 0.000001
    ? value.round().toString()
    : value.toStringAsFixed(1);

class ForceBalanceArena extends StatelessWidget {
  const ForceBalanceArena({
    super.key,
    required this.round,
    required this.playing,
    this.spanish = false,
  });

  final ForceBalanceRound round;
  final bool playing;
  final bool spanish;

  String _direction(double force) => force > 0 ? 'right' : force < 0 ? 'left' : 'none';

  @override
  Widget build(BuildContext context) {
    final description =
        'Force balance. Wind: ${balanceNumber(round.wind.abs())} newtons ${_direction(round.wind)}. '
        'Your push: ${balanceNumber(round.playerForce.abs())} newtons ${_direction(round.playerForce)}. '
        'Overall push: ${balanceNumber(round.netForce.abs())} newtons ${_direction(round.netForce)}. '
        'Box position ${balanceNumber(round.position)} meters. '
        'Velocity ${balanceNumber(round.velocity)} meters per second. '
        '${playing ? 'Playing.' : 'Paused.'} ${round.cue.english}'
        '${round.mode == BalanceMode.practice ? ' Steady progress ${balanceNumber(round.held)} of 3 seconds.' : ''}'
        '${spanish ? ' ${round.cue.spanish}' : ''}';
    return Semantics(
      key: const ValueKey('balance-arena'),
      container: true,
      image: true,
      label: description,
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = (constraints.maxWidth - 64) / (round.railLimit * 2);
            final mid = constraints.maxWidth / 2;
            final boxX = mid + round.position * scale;
            final boxY = constraints.maxHeight * 0.70;
            final arrowScale = math.min(150.0, constraints.maxWidth * 0.32) /
                ForceBalanceRound.maxStrength;
            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _FieldPainter(
                      greenLeft: mid - round.greenLimit * scale,
                      greenRight: mid + round.greenLimit * scale,
                      boxY: boxY,
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  top: 6,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${spanish ? 'Viento' : 'Wind'} ${balanceNumber(round.wind.abs())} N',
                          key: const ValueKey('balance-wind-label'),
                          style: const TextStyle(fontSize: 13, color: balanceWindColor, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${spanish ? 'Tu fuerza' : 'Your push'} ${balanceNumber(round.playerForce.abs())} N',
                          key: const ValueKey('balance-player-force-label'),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 13, color: balancePushColor, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                if (round.wind != 0)
                  Positioned(
                    left: round.wind > 0 ? 10 : constraints.maxWidth - 42,
                    top: constraints.maxHeight * 0.44,
                    width: 32,
                    height: 32,
                    child: CustomPaint(
                      painter: _FanPainter(angle: round.elapsed * 6),
                    ),
                  ),
                if (round.wind != 0)
                  _arrow(
                    key: 'balance-wind-arrow',
                    force: round.wind,
                    x: boxX,
                    y: constraints.maxHeight * 0.30,
                    length: round.wind.abs() * arrowScale,
                    color: balanceWindColor,
                  ),
                if (round.playerForce != 0)
                  _arrow(
                    key: 'balance-push-arrow',
                    force: round.playerForce,
                    x: boxX,
                    y: constraints.maxHeight * 0.46,
                    length: round.playerForce.abs() * arrowScale,
                    color: balancePushColor,
                  ),
                Positioned(
                  key: const ValueKey('balance-box'),
                  left: boxX - 22,
                  top: boxY - 21,
                  width: 44,
                  height: 42,
                  child: const CustomPaint(painter: _BoxPainter()),
                ),
                Positioned(
                  left: 6,
                  right: 6,
                  bottom: 4,
                  child: Row(
                    children: [
                      Text(
                        spanish ? 'Zona verde' : 'Green zone',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF496650), fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          round.velocity.abs() < 0.000001
                              ? (spanish ? 'Caja quieta' : 'Box still')
                              : round.velocity > 0
                              ? (spanish ? 'Se mueve a la derecha' : 'Moving right')
                              : (spanish ? 'Se mueve a la izquierda' : 'Moving left'),
                          key: const ValueKey('balance-motion-label'),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 11, color: AppColors.ink),
                        ),
                      ),
                      if (round.mode == BalanceMode.practice) ...[
                        const SizedBox(width: 6),
                        for (var star = 1; star <= 3; star++)
                          Icon(
                            round.held >= star ? Icons.star_rounded : Icons.star_outline_rounded,
                            size: 15,
                            color: const Color(0xFF6C9571),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _arrow({
    required String key,
    required double force,
    required double x,
    required double y,
    required double length,
    required Color color,
  }) {
    return Positioned(
      key: ValueKey(key),
      left: force > 0 ? x : x - length,
      top: y,
      width: length,
      height: 12,
      child: CustomPaint(painter: _ArrowPainter(right: force > 0, color: color)),
    );
  }
}

class _FieldPainter extends CustomPainter {
  const _FieldPainter({required this.greenLeft, required this.greenRight, required this.boxY});
  final double greenLeft;
  final double greenRight;
  final double boxY;

  @override
  bool shouldRepaint(covariant _FieldPainter old) =>
      old.greenLeft != greenLeft || old.greenRight != greenRight || old.boxY != boxY;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE9F0EF));
    canvas.drawRect(
      Rect.fromLTRB(greenLeft, 26, greenRight, size.height),
      Paint()..color = const Color(0xFFCCE0C8),
    );
    for (final x in [greenLeft, greenRight]) {
      canvas.drawLine(
        Offset(x, 26),
        Offset(x, size.height),
        Paint()..color = const Color(0xFF84A67C)..strokeWidth = 2,
      );
    }
    canvas.drawLine(
      Offset(25, boxY + 22),
      Offset(size.width - 25, boxY + 22),
      Paint()..color = const Color(0xFF93A4A4)..strokeWidth = 3,
    );
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter({required this.right, required this.color});
  final bool right;
  final Color color;

  @override
  bool shouldRepaint(covariant _ArrowPainter old) => old.right != right || old.color != color;

  @override
  void paint(Canvas canvas, Size size) {
    final head = math.min(7.0, size.width * 0.65);
    final tip = Offset(right ? size.width : 0, size.height / 2);
    final base = Offset(right ? size.width - head : head, size.height / 2);
    canvas.drawLine(
      Offset(right ? 0 : size.width, size.height / 2),
      base,
      Paint()..color = color..strokeWidth = 4..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(base.dx, 0)
        ..lineTo(base.dx, size.height)
        ..close(),
      Paint()..color = color,
    );
  }
}

class _BoxPainter extends CustomPainter {
  const _BoxPainter();

  @override
  bool shouldRepaint(covariant _BoxPainter old) => false;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(2, 3, 40, 36), const Radius.circular(5)),
      Paint()..color = const Color(0xFFC18C64),
    );
    canvas.drawRect(const Rect.fromLTWH(18, 3, 8, 36), Paint()..color = const Color(0xFFF0D7AE));
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(6, 22, 10, 9), const Radius.circular(2)),
      Paint()..color = const Color(0xFFF4E9D4),
    );
  }
}

class _FanPainter extends CustomPainter {
  const _FanPainter({required this.angle});
  final double angle;

  @override
  bool shouldRepaint(covariant _FanPainter old) => old.angle != angle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    canvas.drawCircle(center, 15, Paint()..color = balanceWindColor.withValues(alpha: 0.15));
    for (var blade = 0; blade < 3; blade++) {
      final rotation = angle + blade * math.pi * 2 / 3;
      canvas.drawLine(
        center,
        center + Offset(math.cos(rotation) * 11, math.sin(rotation) * 11),
        Paint()..color = balanceWindColor..strokeWidth = 6..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(center, 3, Paint()..color = balanceWindColor);
  }
}
