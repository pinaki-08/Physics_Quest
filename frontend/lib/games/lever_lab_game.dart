import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import 'game_shell.dart';

/// Simple Machines. Each round hands the player a load heavier than they can
/// lift, so the only way through is to place the fulcrum correctly.
/// effort = load x (1 - f) / f, where f is the fulcrum position along the bar.
class LeverLabGame extends StatefulWidget {
  const LeverLabGame({super.key});

  @override
  State<LeverLabGame> createState() => _LeverLabGameState();
}

class _LeverLabGameState extends State<LeverLabGame>
    with SingleTickerProviderStateMixin {
  static const _rounds = 5;
  static const _maxFulcrum = 0.85;

  final _rng = math.Random();
  late final AnimationController _lift = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  int _round = 0;
  int _solved = 0;
  double _load = 400;
  double _strength = 100;
  double _fulcrum = 0.5;
  bool? _worked;
  bool _over = false;

  double get _effort => _load * (1 - _fulcrum) / _fulcrum;

  @override
  void initState() {
    super.initState();
    _deal();
  }

  @override
  void dispose() {
    _lift.dispose();
    super.dispose();
  }

  void _deal() {
    final load = (300 + _rng.nextInt(7) * 100).toDouble();
    // The fulcrum cannot go past _maxFulcrum, so strength has to clear the
    // effort that position gives or the round would be impossible to win.
    final easiest = load * (1 - _maxFulcrum) / _maxFulcrum;
    final strength =
        ((easiest * (1.2 + _rng.nextDouble() * 0.7)) / 10).round() * 10.0;
    setState(() {
      _load = load;
      _strength = strength;
      _fulcrum = 0.5;
      _worked = null;
    });
    _lift.reverse();
  }

  void _tryLift() {
    final ok = _effort <= _strength;
    setState(() {
      _worked = ok;
      _round++;
      if (ok) _solved++;
      _over = _round >= _rounds;
    });
    if (ok) _lift.forward();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = (_effort / _strength).clamp(0.0, 4.0);
    final ok = _effort <= _strength;
    return GameShell(
      title: 'Lever Lab',
      instruction:
          'Slide the fulcrum until the effort drops below your strength.',
      color: AppColors.learn,
      scoreboard: Row(
        children: [
          GameStat(
            icon: Icons.flag_rounded,
            label: 'Round',
            value: '${math.min(_round + 1, _rounds)}/$_rounds',
          ),
          GameStat(
            icon: Icons.emoji_events_rounded,
            label: 'Lifted',
            value: '$_solved',
          ),
        ],
      ),
      children: [
        GameStage(
          height: 180,
          child: AnimatedBuilder(
            animation: _lift,
            builder: (context, _) => CustomPaint(
              size: Size.infinite,
              painter: _LeverPainter(
                fulcrum: _fulcrum,
                lifted: _lift.value,
                straining: _worked == false,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _Chip(
                label: 'Load',
                value: '${_load.round()} N',
                colour: AppColors.sunshine,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Chip(
                label: 'Your strength',
                value: '${_strength.round()} N',
                colour: AppColors.grape,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const SizedBox(
              width: 62,
              child: Text(
                'Fulcrum',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.learn,
                  thumbColor: AppColors.learn,
                  inactiveTrackColor: AppColors.learn.withValues(alpha: 0.18),
                  trackHeight: 5,
                ),
                child: Slider(
                  value: _fulcrum,
                  min: 0.2,
                  max: _maxFulcrum,
                  onChanged: _worked != null
                      ? null
                      : (v) => setState(() => _fulcrum = v),
                ),
              ),
            ),
            SizedBox(
              width: 46,
              child: Text(
                '${(_fulcrum * 100).round()}%',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.learn,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: (ok ? AppColors.play : AppColors.practice)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Text(
                'Effort needed: ${_effort.round()} N',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ok ? AppColors.playDeep : AppColors.practice,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: (ratio / 4).clamp(0.0, 1.0),
                  minHeight: 9,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation(
                    ok ? AppColors.play : AppColors.practice,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                ok
                    ? 'Light enough — you can lift this.'
                    : 'Too heavy by ${(_effort - _strength).round()} N.',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.inkSoft,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_over)
          GameButton(
            label: 'Play again  ($_solved of $_rounds lifted)',
            icon: Icons.replay_rounded,
            color: AppColors.learn,
            onTap: () {
              setState(() {
                _round = 0;
                _solved = 0;
                _over = false;
              });
              _deal();
            },
          )
        else if (_worked != null)
          GameButton(
            label: _worked! ? 'Lifted! Next round' : 'Missed it — next round',
            icon: Icons.arrow_forward_rounded,
            color: AppColors.learn,
            onTap: _deal,
          )
        else
          GameButton(
            label: 'Lift it',
            icon: Icons.fitness_center_rounded,
            color: AppColors.learn,
            onTap: _tryLift,
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String value;
  final Color colour;

  const _Chip({
    required this.label,
    required this.value,
    required this.colour,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colour,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeverPainter extends CustomPainter {
  final double fulcrum;
  final double lifted;
  final bool straining;

  const _LeverPainter({
    required this.fulcrum,
    required this.lifted,
    required this.straining,
  });

  @override
  bool shouldRepaint(covariant _LeverPainter old) =>
      old.fulcrum != fulcrum ||
      old.lifted != lifted ||
      old.straining != straining;

  @override
  void paint(Canvas canvas, Size size) {
    final groundY = size.height - 30;
    final left = 30.0;
    final right = size.width - 30;
    final pivotX = left + (right - left) * fulcrum;
    final pivotY = groundY - 26;

    canvas.drawLine(
      Offset(0, groundY),
      Offset(size.width, groundY),
      Paint()
        ..color = AppColors.ink.withValues(alpha: 0.12)
        ..strokeWidth = 3,
    );

    // Effort side dips as the load rises on the far side.
    final tilt = (0.18 - 0.34 * lifted) + (straining ? 0.05 : 0);

    canvas.save();
    canvas.translate(pivotX, pivotY);
    canvas.rotate(tilt);
    final beam = RRect.fromRectAndRadius(
      Rect.fromLTRB(left - pivotX, -5, right - pivotX, 5),
      const Radius.circular(5),
    );
    canvas.drawRRect(beam, Paint()..color = const Color(0xFFBFA079));
    canvas.drawRRect(
      beam,
      Paint()
        ..color = const Color(0xFF8E6C46)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Load on the right end.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(right - pivotX - 44, -36, 38, 32),
        const Radius.circular(7),
      ),
      Paint()..color = AppColors.sunshine,
    );
    // Effort arrow pressing the left end down.
    final ex = left - pivotX + 22;
    canvas.drawLine(
      Offset(ex, -40),
      Offset(ex, -12),
      Paint()
        ..color = AppColors.practice
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      Path()
        ..moveTo(ex, -8)
        ..lineTo(ex - 7, -20)
        ..lineTo(ex + 7, -20)
        ..close(),
      Paint()..color = AppColors.practice,
    );
    canvas.restore();

    canvas.drawPath(
      Path()
        ..moveTo(pivotX, pivotY + 3)
        ..lineTo(pivotX - 16, groundY)
        ..lineTo(pivotX + 16, groundY)
        ..close(),
      Paint()..color = AppColors.learn,
    );

    _label(canvas, 'effort', Offset(left + 10, 18), AppColors.practice);
    _label(canvas, 'load', Offset(right - 20, 18), const Color(0xFFE07C00));
  }

  void _label(Canvas canvas, String text, Offset centre, Color colour) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: colour,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, centre - Offset(painter.width / 2, painter.height / 2));
  }
}
