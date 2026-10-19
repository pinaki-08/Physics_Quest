import 'package:flutter/material.dart';

import '../games/force_balance_game.dart';
import '../games/lever_lab_game.dart';
import '../games/moon_lander_game.dart';
import '../games/speed_run_game.dart';
import '../theme.dart';
import '../widgets/back_bar.dart';
import '../widgets/bouncy.dart';
import '../widgets/section_hero.dart';

class _Game {
  final IconData icon;
  final String title;
  final String topic;
  final String blurb;
  final Color color;
  final Color colorDeep;
  final WidgetBuilder screen;

  const _Game({
    required this.icon,
    required this.title,
    required this.topic,
    required this.blurb,
    required this.color,
    required this.colorDeep,
    required this.screen,
  });
}

final _games = <_Game>[
  _Game(
    icon: Icons.directions_run_rounded,
    title: 'Speed Run',
    topic: 'Motion & Speed',
    blurb: 'Pick the speed that finishes on time',
    color: AppColors.practice,
    colorDeep: AppColors.practiceDeep,
    screen: (_) => const SpeedRunGame(),
  ),
  _Game(
    icon: Icons.compare_arrows_rounded,
    title: 'Hold the Line',
    topic: 'Forces',
    blurb: 'Push back against the gusts',
    color: AppColors.sky,
    colorDeep: const Color(0xFF12A8C6),
    screen: (_) => const ForceBalanceGame(),
  ),
  _Game(
    icon: Icons.rocket_launch_rounded,
    title: 'Soft Landing',
    topic: 'Gravity & Weight',
    blurb: 'Land gently on three worlds',
    color: AppColors.grape,
    colorDeep: const Color(0xFF7B3FD6),
    screen: (_) => const MoonLanderGame(),
  ),
  _Game(
    icon: Icons.balance_rounded,
    title: 'Lever Lab',
    topic: 'Simple Machines',
    blurb: 'Move the fulcrum to lift the load',
    color: AppColors.learn,
    colorDeep: AppColors.learnDeep,
    screen: (_) => const LeverLabGame(),
  ),
];

class PlayView extends StatelessWidget {
  const PlayView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BackBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
        children: [
          const SectionHero(
            icon: Icons.sports_esports_rounded,
            title: 'Play',
            subtitle: 'One game for every lesson you have learned.',
            color: AppColors.play,
            colorDeep: AppColors.playDeep,
          ),
          const SizedBox(height: 22),
          for (final game in _games) ...[
            _GameTile(game: game),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  final _Game game;
  const _GameTile({required this.game});

  @override
  Widget build(BuildContext context) {
    return Bouncy(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: game.screen),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [game.color, game.colorDeep],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: glow(game.color, opacity: 0.34, blur: 20),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(game.icon, size: 28, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    game.blurb,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      game.topic,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_circle_fill_rounded,
                size: 32, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
