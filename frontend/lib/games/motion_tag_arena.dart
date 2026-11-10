import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import 'motion_tag_model.dart';

const tagPlayerColor = Color(0xFFB8754E);
const tagBlueColor = Color(0xFF487CA6);

String tagNumber(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(1);

String _meters(double value) =>
    '${tagNumber(value)} ${value.abs() == 1 ? 'meter' : 'meters'}';

class MotionTagArena extends StatelessWidget {
  const MotionTagArena({
    super.key,
    required this.round,
    required this.playing,
    this.spanish = false,
  });

  final MotionTagRound round;
  final bool playing;
  final bool spanish;

  @override
  Widget build(BuildContext context) {
    final ahead = round.gap >= 0;
    final gap = tagNumber(round.gap.abs());
    final description =
        'Motion Tag track. Your robot at ${_meters(round.playerPosition)}, '
        'speed ${_meters(round.speed)} per second, direction ${round.direction.name}. '
        'Blue robot at ${_meters(round.bluePosition)}, speed '
        '${_meters(round.mission.blueSpeed)} per second, direction right. '
        '${ahead ? 'Blue is ${_meters(round.gap.abs())} ahead.' : 'You are ${_meters(round.gap.abs())} ahead.'} '
        '${playing ? 'Playing.' : 'Paused.'} ${round.mission.instruction} '
        '${round.won ? 'Goal complete.' : ''}'
        '${round.mission.goal == TagGoal.catchUp ? '' : ' Steady gap held for ${tagNumber(round.held)} of 3 seconds.'}'
        '${spanish ? ' ${round.mission.instructionEs} Distancia: $gap metros.' : ''}';
    return Semantics(
      key: const ValueKey('tag-arena'),
      container: true,
      image: true,
      label: description,
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const span = 14.0;
            final scale = (constraints.maxWidth - 56) / span;
            final camera = round.playerPosition < 0
                ? round.playerPosition
                : math.max(0.0, round.playerPosition - span * 0.28);
            double x(double position) => 28 + (position - camera) * scale;
            final playerX = x(round.playerPosition);
            final blueX = x(round.bluePosition);
            final blueY = constraints.maxHeight * 0.37;
            final playerY = constraints.maxHeight * 0.77;
            final blueVisible = blueX >= 22 && blueX <= constraints.maxWidth - 22;
            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TrackPainter(
                      camera: camera,
                      scale: scale,
                      blueY: blueY,
                      playerY: playerY,
                    ),
                  ),
                ),
                Positioned(
                  left: x(round.bluePosition - round.mission.maxGap),
                  top: playerY - 25,
                  width: (round.mission.maxGap - round.mission.minGap) * scale,
                  height: 50,
                  child: DecoratedBox(
                    key: const ValueKey('tag-goal-zone'),
                    decoration: BoxDecoration(
                      color: (round.inPosition
                              ? const Color(0xFF7BA482)
                              : tagBlueColor)
                          .withValues(alpha: 0.18),
                      border: Border.all(
                        color: round.inPosition
                            ? const Color(0xFF6C9571)
                            : tagBlueColor.withValues(alpha: 0.45),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  top: 6,
                  child: Row(
                    children: [
                      Text(
                        round.won
                            ? (spanish ? '¡Bien!' : 'Nice!')
                            : playing
                            ? (spanish ? 'En movimiento' : 'Playing')
                            : (spanish ? 'En pausa' : 'Press Play'),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          '${spanish ? 'Distancia' : 'Gap'}: $gap m',
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: playerX - 26,
                  top: playerY - 40,
                  width: 52,
                  child: Text(
                    spanish ? 'TÚ' : 'YOU',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: tagPlayerColor),
                  ),
                ),
                Positioned(
                  key: const ValueKey('tag-player'),
                  left: playerX - 22,
                  top: playerY - 22,
                  width: 44,
                  height: 44,
                  child: CustomPaint(
                    painter: _RobotPainter(
                      color: tagPlayerColor,
                      position: round.playerPosition,
                      left: round.direction == TagDirection.left,
                    ),
                  ),
                ),
                if (blueVisible) ...[
                  Positioned(
                    left: blueX - 26,
                    top: blueY - 40,
                    width: 52,
                    child: Text(
                      spanish ? 'AZUL' : 'BLUE',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: tagBlueColor),
                    ),
                  ),
                  Positioned(
                    key: const ValueKey('tag-blue'),
                    left: blueX - 22,
                    top: blueY - 22,
                    width: 44,
                    height: 44,
                    child: CustomPaint(
                      painter: _RobotPainter(
                        color: tagBlueColor,
                        position: round.bluePosition,
                        blue: true,
                      ),
                    ),
                  ),
                ] else
                  Positioned(
                    key: const ValueKey('tag-blue-offscreen'),
                    left: blueX < 22 ? 4 : constraints.maxWidth - 42,
                    top: blueY - 18,
                    width: 38,
                    height: 38,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: tagBlueColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        blueX < 22 ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                        color: tagBlueColor,
                      ),
                    ),
                  ),
                if (round.mission.goal != TagGoal.catchUp)
                  Positioned(
                    right: 8,
                    bottom: 4,
                    child: Semantics(
                      key: const ValueKey('tag-progress'),
                      label: 'Steady gap progress',
                      child: Row(
                        children: [
                          for (var star = 1; star <= 3; star++)
                            Icon(
                              round.held >= star
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 18,
                              color: const Color(0xFF6C9571),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TrackPainter extends CustomPainter {
  const _TrackPainter({
    required this.camera,
    required this.scale,
    required this.blueY,
    required this.playerY,
  });

  final double camera;
  final double scale;
  final double blueY;
  final double playerY;

  @override
  bool shouldRepaint(covariant _TrackPainter old) =>
      old.camera != camera || old.scale != scale || old.blueY != blueY || old.playerY != playerY;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE8EFED));
    for (final y in [blueY, playerY]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, y - 26, size.width, 52),
          const Radius.circular(20),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.45),
      );
    }
    final first = (camera / 2).floor() * 2;
    for (var meter = first; meter <= camera + 16; meter += 2) {
      final x = 28 + (meter - camera) * scale;
      canvas.drawLine(
        Offset(x, 28),
        Offset(x, size.height - 8),
        Paint()
          ..color = AppColors.ink.withValues(alpha: 0.07)
          ..strokeWidth = 1,
      );
    }
  }
}

class _RobotPainter extends CustomPainter {
  const _RobotPainter({
    required this.color,
    required this.position,
    this.blue = false,
    this.left = false,
  });

  final Color color;
  final double position;
  final bool blue;
  final bool left;

  @override
  bool shouldRepaint(covariant _RobotPainter old) =>
      old.color != color || old.position != position || old.blue != blue || old.left != left;

  @override
  void paint(Canvas canvas, Size size) {
    if (left) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    final body = Paint()..color = color;
    canvas.drawLine(
      const Offset(22, 5),
      const Offset(22, 10),
      Paint()
        ..color = color
        ..strokeWidth = 2,
    );
    canvas.drawCircle(const Offset(22, 4), 3, body);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8, 9, 28, 26),
        Radius.circular(blue ? 12 : 6),
      ),
      body,
    );
    for (final x in [16.0, 28.0]) {
      canvas.drawCircle(Offset(x, 20), 4, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(x + 1, 20), 2, Paint()..color = AppColors.ink);
    }
    final smile = Path()
      ..moveTo(16, 27)
      ..quadraticBezierTo(22, 32, 28, 27);
    canvas.drawPath(
      smile,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(6, 32, 32, 7),
        const Radius.circular(3),
      ),
      body,
    );
    for (final x in [11.0, 33.0]) {
      final center = Offset(x, 39);
      canvas.drawCircle(center, 5, Paint()..color = AppColors.ink);
      canvas.drawLine(
        center,
        center + Offset(math.cos(position * 3) * 3, math.sin(position * 3) * 3),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1.5,
      );
    }
  }
}
