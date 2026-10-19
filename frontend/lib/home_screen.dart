import 'package:flutter/material.dart';

import 'theme.dart';
import 'views/learn_view.dart';
import 'views/play_view.dart';
import 'views/practice_view.dart';
import 'widgets/atom_logo.dart';
import 'widgets/bouncy.dart';
import 'widgets/card_art.dart';

class _Choice {
  final CardArtKind art;
  final String title;
  final String blurb;
  final Color color;
  final Color colorDeep;
  final WidgetBuilder screen;

  const _Choice({
    required this.art,
    required this.title,
    required this.blurb,
    required this.color,
    required this.colorDeep,
    required this.screen,
  });
}

final _choices = <_Choice>[
  _Choice(
    art: CardArtKind.planet,
    title: 'Learn',
    blurb: 'Read lessons and build your basics',
    color: AppColors.learn,
    colorDeep: AppColors.learnDeep,
    screen: (_) => const LearnView(),
  ),
  _Choice(
    art: CardArtKind.target,
    title: 'Practice',
    blurb: 'Try questions and earn stars',
    color: AppColors.practice,
    colorDeep: AppColors.practiceDeep,
    screen: (_) => const PracticeView(),
  ),
  _Choice(
    art: CardArtKind.rocket,
    title: 'Play',
    blurb: 'Games and experiments',
    color: AppColors.play,
    colorDeep: AppColors.playDeep,
    screen: (_) => const PlayView(),
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bg, AppColors.surfaceSoft, AppColors.bgTint],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _Greeting(),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: ConstrainedBox(
                      // Centres the cards, but still scrolls on short screens.
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight - 32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var i = 0; i < _choices.length; i++) ...[
                                _Entrance(
                                  controller: _controller,
                                  order: i,
                                  child: _ChoiceCard(choice: _choices[i]),
                                ),
                                if (i < _choices.length - 1)
                                  const SizedBox(height: 18),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.learn, AppColors.grape],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: glow(AppColors.grape, opacity: 0.4, blur: 18),
          ),
          child: const AtomLogo(size: 40),
        ),
        const SizedBox(width: 12),
        const Expanded(child: GradientTitle('Physics Quest')),
      ],
    );
  }
}

/// Staggered slide-and-fade so the three cards arrive one after another.
class _Entrance extends StatelessWidget {
  final AnimationController controller;
  final int order;
  final Widget child;

  const _Entrance({
    required this.controller,
    required this.order,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = order * 0.16;
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(start, start + 0.6, curve: Curves.easeOutBack),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, inner) => Opacity(
        opacity: animation.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 34 * (1 - animation.value)),
          child: inner,
        ),
      ),
      child: child,
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final _Choice choice;
  const _ChoiceCard({required this.choice});

  @override
  Widget build(BuildContext context) {
    return Bouncy(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: choice.screen)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [choice.color, choice.colorDeep],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: glow(choice.color, opacity: 0.45, blur: 26),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Container(
              width: 84,
              height: 84,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(26),
              ),
              child: CardArt(kind: choice.art, size: 68),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    choice.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    choice.blurb,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_rounded,
                  size: 22, color: choice.colorDeep),
            ),
          ],
        ),
      ),
    );
  }
}
