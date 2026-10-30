import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/lesson_repository.dart';
import '../models/lesson.dart';
import '../services/lesson_narration.dart';
import '../services/speech.dart';
import '../theme.dart';
import '../widgets/back_bar.dart';
import '../widgets/bouncy.dart';
import '../widgets/lesson_art.dart';
import '../widgets/vocabulary_text.dart';

class LessonScreen extends StatefulWidget {
  final String lessonId;
  final IconData icon;

  const LessonScreen({super.key, required this.lessonId, required this.icon});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final _scroll = ScrollController();
  late Future<Lesson> _lesson;
  double _read = 0;

  @override
  void initState() {
    super.initState();
    _lesson = lessonRepository.fetch(widget.lessonId);
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    final max = _scroll.position.maxScrollExtent;
    final value = max <= 0 ? 1.0 : (_scroll.offset / max).clamp(0.0, 1.0);
    if (value != _read) setState(() => _read = value);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Section content is data, but the interactive demos stay in code and are
  /// matched by name.
  Widget _demoFor(String name) => switch (name) {
    'pushPull' => const _PushPullDemo(),
    'forceSize' => const _ForceSizeDemo(),
    'tugOfWar' => const _TugOfWar(),
    'forceTypes' => const ForceTypesDemo(),
    'speedFormula' => const SpeedFormulaDemo(),
    'raceTrack' => const _RaceDemo(),
    'speedChange' => const SpeedChangeDemo(),
    'massWeight' => const _MassWeightDemo(),
    'planetWeight' => const _PlanetWeightDemo(),
    'dropRace' => const _DropRaceDemo(),
    'lever' => const _LeverDemo(),
    'rampForce' => const _RampDemo(),
    'pulley' => const _PulleyDemo(),
    _ => const SizedBox.shrink(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lessonBackground,
      appBar: const BackBar(),
      body: FutureBuilder<Lesson>(
        future: _lesson,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final lesson = snapshot.data!;
          return Column(
            children: [
              _ReadingBar(value: _read),
              Expanded(
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
                  children: [
                    _LessonHero(
                      title: lesson.title,
                      subtitle: lesson.subtitle,
                      icon: widget.icon,
                    ),
                    const SizedBox(height: 18),
                    if (lesson.glossary.isNotEmpty) ...[
                      const _VocabularyHint(),
                      const SizedBox(height: 14),
                    ],
                    for (final section in lesson.sections)
                      _Section(
                        index: section.index,
                        title: section.title,
                        titleEs: section.titleEs,
                        body: section.body,
                        bodyEs: section.bodyEs,
                        glossary: lesson.glossary,
                        art: LessonArtKind.values.byName(section.art),
                        child: _demoFor(section.demo),
                      ),
                    const SizedBox(height: 4),
                    KeyPointsCard(
                      points: lesson.keyPoints,
                      pointsEs: lesson.keyPointsEs,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReadingBar extends StatelessWidget {
  final double value;
  const _ReadingBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: value,
          minHeight: 6,
          backgroundColor: AppColors.line,
          valueColor: const AlwaysStoppedAnimation(AppColors.learn),
        ),
      ),
    );
  }
}

class _LessonHero extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _LessonHero({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.learn, AppColors.learnDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: glow(AppColors.learn, opacity: 0.4, blur: 26),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, size: 32, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.3,
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

class _Section extends StatefulWidget {
  final int index;
  final String title;
  final String titleEs;
  final String body;
  final String bodyEs;
  final List<GlossaryTerm> glossary;
  final LessonArtKind? art;
  final Widget? child;

  const _Section({
    required this.index,
    required this.title,
    required this.titleEs,
    required this.body,
    required this.glossary,
    this.bodyEs = '',
    this.art,
    this.child,
  });

  @override
  State<_Section> createState() => _SectionState();
}

class _SectionState extends State<_Section> {
  bool _showSpanish = false;

  void _flip() => setState(() => _showSpanish = !_showSpanish);

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 450);

    return AnimatedSize(
      duration: duration,
      curve: Curves.easeInOutCubic,
      alignment: Alignment.topCenter,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: _showSpanish ? 1 : 0),
        duration: duration,
        curve: Curves.easeInOutCubic,
        builder: (context, value, child) {
          final spanish = value >= 0.5;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(math.pi * value);

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(spanish ? math.pi : 0),
              child: _buildFace(spanish),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFace(bool spanish) {
    final accent = spanish ? AppColors.practice : AppColors.learn;
    final title = spanish
        ? (widget.titleEs.isEmpty ? 'Traducción al español' : widget.titleEs)
        : widget.title;
    final body = spanish && widget.bodyEs.isNotEmpty
        ? widget.bodyEs
        : widget.body;

    return Container(
      key: ValueKey('section-${widget.index}-${spanish ? 'es' : 'en'}'),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: spanish ? const Color(0xFFFFF8F1) : AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: spanish
              ? AppColors.practice.withValues(alpha: 0.24)
              : AppColors.line,
        ),
        boxShadow: glow(accent, opacity: 0.12, blur: 18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${widget.index}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
              ),
              _SpeakButton(
                label: spanish ? 'ES' : 'EN',
                semanticsLabel: spanish
                    ? 'Escuchar en español'
                    : 'Listen in English',
                color: accent,
                onTap: () => TermSpeaker.instance.speak(body, spanish: spanish),
              ),
              if (!spanish) ...[
                const SizedBox(width: 6),
                _SpeakButton(
                  label: 'ES',
                  semanticsLabel: 'Escuchar traducción en español',
                  color: AppColors.practice,
                  onTap: () => TermSpeaker.instance.speak(
                    widget.bodyEs.isEmpty ? widget.body : widget.bodyEs,
                    spanish: true,
                  ),
                ),
              ],
              const SizedBox(width: 6),
              IconButton(
                key: ValueKey('section-${widget.index}-flip-top'),
                tooltip: spanish ? 'Volver al inglés' : 'Ver en español',
                onPressed: _flip,
                icon: const Icon(Icons.flip_rounded, size: 21),
                style: IconButton.styleFrom(
                  foregroundColor: accent,
                  backgroundColor: accent.withValues(alpha: 0.08),
                  side: BorderSide(color: accent.withValues(alpha: 0.24)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (spanish) ...[
            Row(
              children: [
                Icon(Icons.translate_rounded, size: 17, color: accent),
                const SizedBox(width: 7),
                Text(
                  'Traducción al español',
                  style: TextStyle(
                    color: accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ] else if (widget.art != null) ...[
            LessonArt(kind: widget.art!),
            const SizedBox(height: 12),
          ],
          if (spanish)
            Text(body, style: const TextStyle(fontSize: 14.5, height: 1.5))
          else
            VocabularyText(text: body, terms: widget.glossary),
          if (!spanish && widget.child != null) ...[
            const SizedBox(height: 18),
            widget.child!,
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: ValueKey('section-${widget.index}-flip'),
              onPressed: _flip,
              icon: const Icon(Icons.flip_rounded, size: 20),
              label: Text(
                spanish ? 'Volver al inglés' : 'Ver en español',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: accent,
                backgroundColor: accent.withValues(alpha: 0.06),
                side: BorderSide(color: accent.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VocabularyHint extends StatelessWidget {
  const _VocabularyHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.sunshine.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.sunshine.withValues(alpha: 0.45)),
      ),
      child: const Row(
        children: [
          Icon(Icons.touch_app_rounded, size: 21, color: Color(0xFF9A6200)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tap highlighted words for Spanish meaning and audio.\n'
              'Toca las palabras resaltadas.',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded play area with a floor line, used by every interactive demo.
class _Stage extends StatelessWidget {
  final Widget child;
  final double height;
  const _Stage({required this.child, this.height = 130});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 26,
            child: Container(
              height: 3,
              color: AppColors.learn.withValues(alpha: 0.2),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Crate extends StatelessWidget {
  const _Crate();

  @override
  Widget build(BuildContext context) {
    const size = 46.0;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.sunshine, Color(0xFFEE9B18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: glow(AppColors.sunshine, opacity: 0.4, blur: 14),
      ),
      child: Icon(
        Icons.inventory_2_rounded,
        size: size * 0.5,
        color: Colors.white,
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  final double length;
  final Color color;
  final bool pointRight;
  const _Arrow({
    required this.length,
    required this.color,
    this.pointRight = true,
  });

  @override
  Widget build(BuildContext context) {
    final arrow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: length,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Icon(Icons.play_arrow_rounded, size: 26, color: color),
      ],
    );
    return pointRight
        ? arrow
        : Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..scaleByDouble(-1.0, 1.0, 1.0, 1.0),
            child: arrow,
          );
  }
}

class _PushPullDemo extends StatefulWidget {
  const _PushPullDemo();

  @override
  State<_PushPullDemo> createState() => _PushPullDemoState();
}

class _PushPullDemoState extends State<_PushPullDemo> {
  double _x = 0;
  bool _pushing = true;

  void _move(bool push) {
    setState(() {
      _pushing = push;
      _x = (_x + (push ? 0.4 : -0.4)).clamp(-0.72, 0.72);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Stage(
          child: AnimatedAlign(
            alignment: Alignment(_x, 0.42),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Arrow(
                  length: 32,
                  color: AppColors.learn,
                  pointRight: _pushing,
                ),
                const SizedBox(width: 4),
                const _Crate(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _Pill(
                label: 'Push',
                icon: Icons.east_rounded,
                color: AppColors.learn,
                onTap: () => _move(true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Pill(
                label: 'Pull',
                icon: Icons.west_rounded,
                color: AppColors.grape,
                onTap: () => _move(false),
              ),
            ),
            const SizedBox(width: 10),
            _Pill(
              icon: Icons.refresh_rounded,
              color: AppColors.inkSoft,
              onTap: () => setState(() {
                _x = 0;
                _pushing = true;
              }),
            ),
          ],
        ),
      ],
    );
  }
}

class _ForceSizeDemo extends StatefulWidget {
  const _ForceSizeDemo();

  @override
  State<_ForceSizeDemo> createState() => _ForceSizeDemoState();
}

class _ForceSizeDemoState extends State<_ForceSizeDemo> {
  double _force = 4;

  @override
  Widget build(BuildContext context) {
    final n = _force.round();
    return Column(
      children: [
        _Stage(
          child: AnimatedAlign(
            alignment: Alignment(-0.75 + (_force / 10) * 1.45, 0.42),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Arrow(length: 12 + _force * 5, color: AppColors.learn),
                const SizedBox(width: 4),
                const _Crate(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.tune_rounded, size: 20, color: AppColors.inkSoft),
            Expanded(
              child: Slider(
                value: _force,
                min: 0,
                max: 10,
                divisions: 10,
                activeColor: AppColors.learn,
                inactiveColor: AppColors.line,
                onChanged: (v) => setState(() => _force = v),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.learn.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                '$n N',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.learn,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        Text(
          n == 0
              ? 'No force at all — the crate stays put.'
              : n < 4
              ? 'A gentle push. It barely moves.'
              : n < 8
              ? 'A firmer push moves it further.'
              : 'A big force sends it a long way.',
          style: const TextStyle(fontSize: 13, color: AppColors.inkSoft),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _TugOfWar extends StatefulWidget {
  const _TugOfWar();

  @override
  State<_TugOfWar> createState() => _TugOfWarState();
}

class _TugOfWarState extends State<_TugOfWar> {
  int _left = 40;
  int _right = 40;

  @override
  Widget build(BuildContext context) {
    final diff = _right - _left;
    final balanced = diff == 0;
    final verdictColor = balanced ? AppColors.play : AppColors.practice;

    return Column(
      children: [
        _Stage(
          height: 120,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 42,
                child: Container(
                  height: 4,
                  color: AppColors.inkSoft.withValues(alpha: 0.35),
                ),
              ),
              AnimatedAlign(
                alignment: Alignment((diff / 80).clamp(-0.7, 0.7), -0.28),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: verdictColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: glow(verdictColor, opacity: 0.4, blur: 12),
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(0, 0.75),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: verdictColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    balanced
                        ? 'Balanced — nothing moves'
                        : diff > 0
                        ? 'Unbalanced — moves right'
                        : 'Unbalanced — moves left',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Stepper(
          label: 'Left team',
          value: _left,
          color: AppColors.grape,
          onChanged: (v) => setState(() => _left = v),
        ),
        const SizedBox(height: 10),
        _Stepper(
          label: 'Right team',
          value: _right,
          color: AppColors.learn,
          onChanged: (v) => setState(() => _right = v),
        ),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final ValueChanged<int> onChanged;

  const _Stepper({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        _Pill(
          icon: Icons.remove_rounded,
          color: color,
          onTap: () => onChanged((value - 10).clamp(0, 90)),
        ),
        SizedBox(
          width: 62,
          child: Text(
            '$value N',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        _Pill(
          icon: Icons.add_rounded,
          color: color,
          onTap: () => onChanged((value + 10).clamp(0, 90)),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String? label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _Pill({
    this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Bouncy(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: label == null ? 12 : 16,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(
                label!,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ForceType {
  final IconData icon;
  final String name;
  final String nameEs;
  final String detail;
  final String detailEs;
  final String example;
  final String exampleEs;
  final Color color;

  const _ForceType({
    required this.icon,
    required this.name,
    required this.nameEs,
    required this.detail,
    required this.detailEs,
    required this.example,
    required this.exampleEs,
    required this.color,
  });

  String get keyName => name.toLowerCase().replaceAll(' ', '-');
  String get narrationEn => '$name. $detail $example';
  String get narrationEs => '$nameEs. $detailEs $exampleEs';
}

const _forceTypes = <_ForceType>[
  _ForceType(
    icon: Icons.public_rounded,
    name: 'Gravity',
    nameEs: 'Gravedad',
    detail:
        'Gravity is a non-contact force that pulls objects with mass '
        'toward one another. Near Earth, it pulls objects toward the ground.',
    detailEs:
        'La gravedad es una fuerza sin contacto que atrae entre sí a los '
        'objetos con masa. Cerca de la Tierra, atrae los objetos hacia el suelo.',
    example:
        'Example: An apple falls because Earth’s gravity pulls it downward.',
    exampleEs:
        'Ejemplo: Una manzana cae porque la gravedad de la Tierra la atrae hacia abajo.',
    color: AppColors.learn,
  ),
  _ForceType(
    icon: Icons.swipe_rounded,
    name: 'Friction',
    nameEs: 'Fricción',
    detail:
        'Friction is a contact force between two surfaces. It opposes '
        'sliding, slows moving objects, and provides grip.',
    detailEs:
        'La fricción es una fuerza de contacto entre dos superficies. '
        'Se opone al deslizamiento, frena los objetos en movimiento y proporciona agarre.',
    example:
        'Example: Your shoes use friction with the floor so you can walk without slipping.',
    exampleEs:
        'Ejemplo: Tus zapatos usan la fricción con el suelo para que puedas caminar sin resbalar.',
    color: AppColors.practice,
  ),
  _ForceType(
    icon: Icons.back_hand_rounded,
    name: 'Applied force',
    nameEs: 'Fuerza aplicada',
    detail:
        'An applied force is a push or pull produced directly by a person '
        'or another object. It can start, stop, or change motion.',
    detailEs:
        'Una fuerza aplicada es un empujón o un tirón producido directamente '
        'por una persona u otro objeto. Puede iniciar, detener o cambiar el movimiento.',
    example:
        'Example: You apply force when you push a door open or pull a wagon.',
    exampleEs:
        'Ejemplo: Aplicas fuerza cuando empujas una puerta para abrirla o tiras de un carrito.',
    color: AppColors.grape,
  ),
  _ForceType(
    icon: Icons.air_rounded,
    name: 'Air resistance',
    nameEs: 'Resistencia del aire',
    detail:
        'Air resistance is friction caused by air. It acts opposite to '
        'motion and becomes stronger when an object moves faster or exposes a larger area.',
    detailEs:
        'La resistencia del aire es una forma de fricción causada por el aire. '
        'Actúa en sentido contrario al movimiento y aumenta cuando un objeto se mueve '
        'más rápido o presenta una superficie mayor.',
    example:
        'Example: A parachute opens wide to increase air resistance and slow a fall.',
    exampleEs:
        'Ejemplo: Un paracaídas se abre para aumentar la resistencia del aire y frenar una caída.',
    color: AppColors.sky,
  ),
];

class ForceTypesDemo extends StatefulWidget {
  const ForceTypesDemo({super.key});

  @override
  State<ForceTypesDemo> createState() => _ForceTypesState();
}

class _ForceTypesState extends State<ForceTypesDemo> {
  int? _open;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _forceTypes.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _ForceTypeTile(
            type: _forceTypes[i],
            open: _open == i,
            onTap: () => setState(() => _open = _open == i ? null : i),
          ),
        ],
      ],
    );
  }
}

class _ForceTypeTile extends StatelessWidget {
  final _ForceType type;
  final bool open;
  final VoidCallback onTap;

  const _ForceTypeTile({
    required this.type,
    required this.open,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: open
            ? type.color.withValues(alpha: 0.12)
            : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: open ? type.color.withValues(alpha: 0.45) : Colors.transparent,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            expanded: open,
            label:
                '${type.name}. ${type.nameEs}. ${open ? 'Collapse details' : 'Expand details'}',
            child: ExcludeSemantics(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  key: ValueKey('force-type-${type.keyName}'),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(type.icon, size: 24, color: type.color),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                type.nameEs,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: type.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedRotation(
                          turns: open ? 0.5 : 0,
                          duration: const Duration(milliseconds: 220),
                          child: Icon(
                            Icons.expand_more_rounded,
                            size: 22,
                            color: type.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: open
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ForceLanguageDetail(
                    label: 'English',
                    detail: type.detail,
                    example: type.example,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  _ForceLanguageDetail(
                    label: 'Español',
                    detail: type.detailEs,
                    example: type.exampleEs,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _ForceAudioButton(
                          key: ValueKey('force-type-audio-en-${type.keyName}'),
                          label: 'Listen EN',
                          color: type.color,
                          onPressed: () => TermSpeaker.instance.speak(
                            type.narrationEn,
                            spanish: false,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ForceAudioButton(
                          key: ValueKey('force-type-audio-es-${type.keyName}'),
                          label: 'Escuchar ES',
                          color: type.color,
                          onPressed: () => TermSpeaker.instance.speak(
                            type.narrationEs,
                            spanish: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _ForceLanguageDetail extends StatelessWidget {
  final String label;
  final String detail;
  final String example;

  const _ForceLanguageDetail({
    required this.label,
    required this.detail,
    required this.example,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          detail,
          style: const TextStyle(
            fontSize: 13.5,
            height: 1.4,
            color: AppColors.inkSoft,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          example,
          style: const TextStyle(
            fontSize: 13,
            height: 1.35,
            color: AppColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ForceAudioButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ForceAudioButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.volume_up_rounded, size: 18),
      label: Text(
        label,
        maxLines: 1,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        backgroundColor: color.withValues(alpha: 0.06),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class KeyPointsCard extends StatefulWidget {
  final List<String> points;
  final List<String> pointsEs;

  const KeyPointsCard({
    super.key,
    required this.points,
    required this.pointsEs,
  });

  @override
  State<KeyPointsCard> createState() => _KeyPointsState();
}

class _KeyPointsState extends State<KeyPointsCard> {
  static const _terracotta = Color(0xFFC9623E);
  static const _terracottaDeep = Color(0xFF87341F);
  static const _terracottaBack = Color(0xFFD77A45);
  static const _terracottaBackDeep = Color(0xFF984023);

  bool _showSpanish = false;

  bool get _hasSpanish => widget.pointsEs.isNotEmpty;

  void _flip() {
    if (!_hasSpanish) return;
    setState(() => _showSpanish = !_showSpanish);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 450);

    return AnimatedSize(
      duration: duration,
      curve: Curves.easeInOutCubic,
      alignment: Alignment.topCenter,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: _showSpanish ? 1 : 0),
        duration: duration,
        curve: Curves.easeInOutCubic,
        builder: (context, value, child) {
          final spanish = value >= 0.5;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(math.pi * value);

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(spanish ? math.pi : 0),
              child: _buildFace(spanish),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFace(bool spanish) {
    final points = spanish && _hasSpanish ? widget.pointsEs : widget.points;
    final startColor = spanish ? _terracottaBack : _terracotta;
    final endColor = spanish ? _terracottaBackDeep : _terracottaDeep;

    return Container(
      key: ValueKey('key-points-${spanish ? 'es' : 'en'}'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: glow(startColor, opacity: 0.3, blur: 22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  spanish ? 'Recuerda esto' : 'Remember this',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                key: const ValueKey('key-points-flip-top'),
                tooltip: spanish ? 'Back to English' : 'Ver en español',
                onPressed: _hasSpanish ? _flip : null,
                icon: const Icon(Icons.flip_rounded, size: 21),
                style: IconButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _KeyPointsAudioButton(
                  key: const ValueKey('key-points-audio-en'),
                  label: 'Listen EN',
                  semanticsLabel: 'Listen to key points in English',
                  onPressed: () => TermSpeaker.instance.speak(
                    keyPointsNarration(widget.points, spanish: false),
                    spanish: false,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _KeyPointsAudioButton(
                  key: const ValueKey('key-points-audio-es'),
                  label: 'Escuchar ES',
                  semanticsLabel: 'Escuchar los puntos clave en español',
                  onPressed: _hasSpanish
                      ? () => TermSpeaker.instance.speak(
                          keyPointsNarration(widget.pointsEs, spanish: true),
                          spanish: true,
                        )
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final point in points)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 17,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const ValueKey('key-points-flip'),
              onPressed: _hasSpanish ? _flip : null,
              icon: const Icon(Icons.flip_rounded, size: 20),
              label: Text(
                spanish ? 'Back to English' : 'Ver en español',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyPointsAudioButton extends StatelessWidget {
  final String label;
  final String semanticsLabel;
  final VoidCallback? onPressed;

  const _KeyPointsAudioButton({
    super.key,
    required this.label,
    required this.semanticsLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.volume_up_rounded, size: 18),
        label: Text(
          label,
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.white.withValues(alpha: 0.12),
          disabledForegroundColor: Colors.white38,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _SpeakButton extends StatelessWidget {
  final String label;
  final String semanticsLabel;
  final Color color;
  final VoidCallback onTap;

  const _SpeakButton({
    super.key,
    required this.label,
    required this.semanticsLabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Bouncy(
        onTap: onTap,
        child: ExcludeSemantics(
          child: Container(
            width: 46,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.volume_up_rounded,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 3),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Distance and time are set by hand; the dot then crosses a track whose
/// length is the distance, taking the chosen time. Speed is the result.
class SpeedFormulaDemo extends StatefulWidget {
  const SpeedFormulaDemo({super.key});

  @override
  State<SpeedFormulaDemo> createState() => _SpeedFormulaDemoState();
}

class _SpeedFormulaDemoState extends State<SpeedFormulaDemo>
    with SingleTickerProviderStateMixin {
  double _distance = 100;
  double _time = 20;

  late final AnimationController _run = AnimationController(
    vsync: this,
    duration: _lap,
  )..repeat();

  // Real seconds would be far too slow to watch, so the clock runs 6x fast.
  Duration get _lap => Duration(milliseconds: (_time * 1000 / 6).round());

  double get _speed => _distance.round() / _time.round();

  String get _spokenEquation => speedEquationNarration(
    distanceMetres: _distance.round(),
    timeSeconds: _time.round(),
  );

  String get _spokenEquationEs => speedEquationNarrationEs(
    distanceMetres: _distance.round(),
    timeSeconds: _time.round(),
  );

  @override
  void dispose() {
    _run.dispose();
    super.dispose();
  }

  void _retime() {
    _run
      ..stop()
      ..duration = _lap
      ..forward(from: 0)
      ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    final trackFraction = _distance / 200;
    return Column(
      children: [
        Container(
          height: 84,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(22),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth * trackFraction;
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    width: trackWidth,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.learn.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Positioned(
                    left: trackWidth - 3,
                    child: Container(
                      width: 3,
                      height: 34,
                      color: AppColors.ink.withValues(alpha: 0.35),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _run,
                    builder: (context, _) => Positioned(
                      left: (trackWidth - 22) * _run.value,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.learn,
                          shape: BoxShape.circle,
                          boxShadow: glow(AppColors.learn, blur: 12),
                        ),
                        child: const Icon(
                          Icons.directions_run_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        _ValueSlider(
          label: 'Distance',
          value: _distance,
          min: 20,
          max: 200,
          unit: 'm',
          color: AppColors.learn,
          onChanged: (v) => setState(() {
            _distance = v;
          }),
        ),
        _ValueSlider(
          label: 'Time',
          value: _time,
          min: 5,
          max: 40,
          unit: 's',
          color: AppColors.practice,
          onChanged: (v) {
            setState(() => _time = v);
            _retime();
          },
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
          decoration: BoxDecoration(
            color: AppColors.learn.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_distance.round()} m ÷ ${_time.round()} s '
                  '= ${_speed.toStringAsFixed(1)} m/s',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.learnDeep,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _SpeakButton(
                key: const ValueKey('speed-equation-audio'),
                label: 'EN',
                semanticsLabel: 'Listen to the equation in English',
                color: AppColors.learn,
                onTap: () =>
                    TermSpeaker.instance.speak(_spokenEquation, spanish: false),
              ),
              const SizedBox(width: 6),
              _SpeakButton(
                key: const ValueKey('speed-equation-audio-es'),
                label: 'ES',
                semanticsLabel: 'Escuchar la ecuación en español',
                color: AppColors.practice,
                onTap: () => TermSpeaker.instance.speak(
                  _spokenEquationEs,
                  spanish: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ValueSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final Color color;
  final ValueChanged<double> onChanged;

  const _ValueSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.18),
              overlayColor: color.withValues(alpha: 0.12),
              trackHeight: 5,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 52,
          child: Text(
            '${value.round()} $unit',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _Racer {
  final String name;
  final IconData icon;
  final Color color;
  const _Racer(this.name, this.icon, this.color);
}

class _RaceCase {
  final double boltDistance;
  final double boltTime;
  final double novaDistance;
  final double novaTime;
  const _RaceCase(
    this.boltDistance,
    this.boltTime,
    this.novaDistance,
    this.novaTime,
  );
}

/// Guess first, then watch. Two of the cases are traps where the racer who
/// covers more ground is the slower one, which is the whole point of the
/// section.
const _raceCases = <_RaceCase>[
  _RaceCase(120, 15, 80, 20),
  _RaceCase(200, 20, 60, 5),
  _RaceCase(60, 12, 90, 15),
  _RaceCase(150, 30, 100, 10),
];

class _RaceDemo extends StatefulWidget {
  const _RaceDemo();

  @override
  State<_RaceDemo> createState() => _RaceDemoState();
}

class _RaceDemoState extends State<_RaceDemo>
    with SingleTickerProviderStateMixin {
  static const _racers = [
    _Racer('Bolt', Icons.smart_toy_rounded, AppColors.learn),
    _Racer('Nova', Icons.smart_toy_rounded, AppColors.practice),
  ];

  int _caseIndex = 0;
  int? _picked;

  late final AnimationController _replay = AnimationController(
    vsync: this,
    duration: Duration.zero,
  );

  _RaceCase get _race => _raceCases[_caseIndex];

  double _distance(int i) => i == 0 ? _race.boltDistance : _race.novaDistance;
  double _time(int i) => i == 0 ? _race.boltTime : _race.novaTime;
  double _speed(int i) => _distance(i) / _time(i);

  int get _faster => _speed(0) > _speed(1) ? 0 : 1;

  @override
  void dispose() {
    _replay.dispose();
    super.dispose();
  }

  void _answer(int choice) {
    setState(() => _picked = choice);
    // Slowed to 150 ms per second so the difference in pace is watchable.
    final longest = _time(0) > _time(1) ? _time(0) : _time(1);
    _replay
      ..duration = Duration(milliseconds: (longest * 150).round())
      ..forward(from: 0);
  }

  void _next() {
    setState(() {
      _caseIndex = (_caseIndex + 1) % _raceCases.length;
      _picked = null;
    });
    _replay.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    final answered = _picked != null;
    final correct = _picked == _faster;
    final longest = _time(0) > _time(1) ? _time(0) : _time(1);
    final furthest = _distance(0) > _distance(1) ? _distance(0) : _distance(1);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(22),
          ),
          child: AnimatedBuilder(
            animation: _replay,
            builder: (context, _) {
              final elapsed = answered ? _replay.value * longest : 0.0;
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.timer_rounded,
                        size: 16,
                        color: AppColors.inkSoft,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${elapsed.toStringAsFixed(1)} s',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < 2; i++) ...[
                    if (i > 0) const SizedBox(height: 14),
                    _RaceLane(
                      racer: _racers[i],
                      distance: _distance(i),
                      time: _time(i),
                      elapsed: elapsed,
                      trackMetres: furthest,
                      running: answered,
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        if (!answered) ...[
          const Text(
            'Who was faster?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < 2; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _PaceButton(
                    label: _racers[i].name,
                    color: _racers[i].color,
                    selected: false,
                    onTap: () => _answer(i),
                  ),
                ),
              ],
            ],
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: (correct ? AppColors.play : AppColors.practice).withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      correct
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 20,
                      color: correct ? AppColors.playDeep : AppColors.practice,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_racers[_faster].name} was faster',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: correct
                            ? AppColors.playDeep
                            : AppColors.practice,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (var i = 0; i < 2; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${_racers[i].name}: ${_distance(i).round()} m '
                      '÷ ${_time(i).round()} s = '
                      '${_speed(i).toStringAsFixed(1)} m/s',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: _racers[i].color,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _PaceButton(
            label: 'Try another race',
            color: AppColors.grape,
            selected: true,
            onTap: _next,
          ),
        ],
      ],
    );
  }
}

class _RaceLane extends StatelessWidget {
  final _Racer racer;
  final double distance;
  final double time;
  final double elapsed;
  final double trackMetres;
  final bool running;

  const _RaceLane({
    required this.racer,
    required this.distance,
    required this.time,
    required this.elapsed,
    required this.trackMetres,
    required this.running,
  });

  @override
  Widget build(BuildContext context) {
    final done = elapsed >= time;
    final covered = running ? (elapsed / time).clamp(0.0, 1.0) * distance : 0.0;
    final finishFraction = distance / trackMetres;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(racer.icon, size: 15, color: racer.color),
            const SizedBox(width: 5),
            Text(
              '${racer.name} — ${distance.round()} m in ${time.round()} s',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: racer.color,
              ),
            ),
            const Spacer(),
            Text(
              done && running ? 'finished' : '${covered.round()} m',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: done && running ? AppColors.playDeep : AppColors.inkSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 28,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final full = constraints.maxWidth - 26;
              final finishX = full * finishFraction;
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: racer.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Positioned(
                    left: finishX + 12,
                    child: Icon(
                      Icons.flag_rounded,
                      size: 18,
                      color: racer.color.withValues(alpha: 0.7),
                    ),
                  ),
                  Positioned(
                    left: finishX * (covered / distance).clamp(0.0, 1.0),
                    child: Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: racer.color,
                        shape: BoxShape.circle,
                        boxShadow: glow(racer.color, blur: 10),
                      ),
                      child: Icon(racer.icon, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

enum _Pace { speedUp, steady, slowDown }

class SpeedChangeDemo extends StatefulWidget {
  const SpeedChangeDemo({super.key});

  @override
  State<SpeedChangeDemo> createState() => _SpeedChangeDemoState();
}

class _SpeedChangeDemoState extends State<SpeedChangeDemo>
    with SingleTickerProviderStateMixin {
  static const _animationDuration = Duration(milliseconds: 6500);

  _Pace _pace = _Pace.speedUp;
  late final AnimationController _run;

  @override
  void initState() {
    super.initState();
    _run = AnimationController(vsync: this, duration: _animationDuration)
      ..addStatusListener(_handleStatus)
      ..forward();
  }

  @override
  void dispose() {
    _run
      ..removeStatusListener(_handleStatus)
      ..dispose();
    super.dispose();
  }

  void _handleStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() {});
    }
  }

  void _togglePlayback() {
    if (_run.isAnimating) {
      _run.stop(canceled: false);
    } else if (_run.isCompleted) {
      _run.forward(from: 0);
    } else {
      _run.forward();
    }
    setState(() {});
  }

  void _selectPace(_Pace pace) {
    setState(() => _pace = pace);
    _run.forward(from: 0);
  }

  String get _playbackLabel {
    if (_run.isAnimating) return 'Pause animation';
    if (_run.isCompleted) return 'Replay animation';
    return 'Continue animation';
  }

  IconData get _playbackIcon {
    if (_run.isAnimating) return Icons.pause_rounded;
    if (_run.isCompleted) return Icons.replay_rounded;
    return Icons.play_arrow_rounded;
  }

  String _phaseLabel(double t) {
    if (t < 0.05) return 'Starting';
    if (t < 0.4) return 'Building';
    if (t < 0.75) return 'Halfway';
    if (t < 1) return 'Almost finished';
    return 'Finished';
  }

  /// Position over time. Curving the graph is what makes the change of speed
  /// visible: a straight ramp would look identical in all three cases.
  double _position(double t) => switch (_pace) {
    _Pace.speedUp => t * t,
    _Pace.steady => t,
    _Pace.slowDown => t * (2 - t),
  };

  /// Gradient of the position curve, which is what the graph's steepness shows.
  double _rate(double t) => switch (_pace) {
    _Pace.speedUp => 2 * t,
    _Pace.steady => 1,
    _Pace.slowDown => 2 - 2 * t,
  };

  @override
  Widget build(BuildContext context) {
    final color = switch (_pace) {
      _Pace.speedUp => AppColors.play,
      _Pace.steady => AppColors.learn,
      _Pace.slowDown => AppColors.practice,
    };
    return Column(
      children: [
        AnimatedBuilder(
          animation: _run,
          builder: (context, _) {
            final t = _run.value;
            return Column(
              children: [
                SizedBox(
                  height: 40,
                  child: LayoutBuilder(
                    builder: (context, constraints) => Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Positioned(
                          left: (constraints.maxWidth - 28) * _position(t),
                          child: Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              boxShadow: glow(color, blur: 12),
                            ),
                            child: const Icon(
                              Icons.directions_bike_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Semantics(
                  key: const ValueKey('speed-change-graph'),
                  image: true,
                  label: switch (_pace) {
                    _Pace.speedUp =>
                      'Distance over time graph. The line becomes steeper as the bicycle speeds up.',
                    _Pace.steady =>
                      'Distance over time graph. The straight line keeps the same steepness.',
                    _Pace.slowDown =>
                      'Distance over time graph. The line becomes flatter as the bicycle slows down.',
                  },
                  child: ExcludeSemantics(
                    child: Container(
                      height: 174,
                      padding: const EdgeInsets.fromLTRB(8, 10, 14, 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _DistanceTimePainter(
                          t: t,
                          position: _position,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _phaseLabel(t),
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: t,
                          minHeight: 7,
                          backgroundColor: color.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Text(
                      '${(t * 100).round()}%',
                      style: const TextStyle(
                        color: AppColors.inkSoft,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.speed_rounded, size: 18, color: color),
                    const SizedBox(width: 6),
                    Text(
                      'Speed now: ${(_rate(t) * 4).toStringAsFixed(1)} m/s',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        const Text(
          'Read the graph: time moves left to right, distance moves bottom '
          'to top, and a steeper line means a higher speed.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5,
            height: 1.35,
            color: AppColors.inkSoft,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const ValueKey('speed-change-playback'),
            onPressed: _togglePlayback,
            icon: Icon(_playbackIcon, size: 20),
            label: Text(
              _playbackLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              backgroundColor: color.withValues(alpha: 0.06),
              side: BorderSide(color: color.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final pace in _Pace.values) ...[
              if (pace != _Pace.speedUp) const SizedBox(width: 8),
              Expanded(
                child: _PaceButton(
                  label: switch (pace) {
                    _Pace.speedUp => 'Speed up',
                    _Pace.steady => 'Steady',
                    _Pace.slowDown => 'Slow down',
                  },
                  color: switch (pace) {
                    _Pace.speedUp => AppColors.play,
                    _Pace.steady => AppColors.learn,
                    _Pace.slowDown => AppColors.practice,
                  },
                  selected: _pace == pace,
                  onTap: () => _selectPace(pace),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Text(
          switch (_pace) {
            _Pace.speedUp => 'The line gets steeper, so the speed is rising.',
            _Pace.steady => 'A straight line means the speed never changes.',
            _Pace.slowDown =>
              'The line flattens out, so the speed is dropping.',
          },
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.inkSoft),
        ),
      ],
    );
  }
}

/// Draws distance against time and traces the curve as the ride happens, so
/// the steepness of the line can be compared with the bike's actual speed.
class _DistanceTimePainter extends CustomPainter {
  final double t;
  final double Function(double) position;
  final Color color;

  const _DistanceTimePainter({
    required this.t,
    required this.position,
    required this.color,
  });

  static const _padLeft = 38.0;
  static const _padBottom = 26.0;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(
      _padLeft,
      6,
      size.width,
      size.height - _padBottom,
    );
    Offset at(double u) => Offset(
      plot.left + plot.width * u,
      plot.bottom - plot.height * position(u),
    );

    final grid = Paint()
      ..color = AppColors.ink.withValues(alpha: 0.07)
      ..strokeWidth = 1;
    for (var i = 1; i <= 4; i++) {
      final y = plot.bottom - plot.height * i / 4;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), grid);
      final x = plot.left + plot.width * i / 4;
      canvas.drawLine(Offset(x, plot.top), Offset(x, plot.bottom), grid);
    }

    final axis = Paint()
      ..color = AppColors.inkSoft.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(plot.bottomLeft, plot.bottomRight, axis);
    canvas.drawLine(plot.topLeft, plot.bottomLeft, axis);

    // Faint preview of where the ride ends up.
    final full = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i <= 60; i++) {
      final p = at(i / 60);
      full.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      full,
      Paint()
        ..color = color.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final traced = Path()..moveTo(at(0).dx, at(0).dy);
    final steps = (60 * t).ceil();
    for (var i = 1; i <= steps; i++) {
      final p = at(t * i / steps);
      traced.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      traced,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final head = at(t);
    final guide = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(plot.left, head.dy), head, guide);
    canvas.drawLine(Offset(head.dx, plot.bottom), head, guide);
    canvas.drawCircle(head, 6, Paint()..color = color);
    canvas.drawCircle(head, 2.5, Paint()..color = Colors.white);

    _label(canvas, 'Distance', Offset(2, plot.top - 2));
    _label(canvas, 'Time', Offset(plot.right - 28, plot.bottom + 8));
  }

  void _label(Canvas canvas, String text, Offset at) {
    TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.inkSoft,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )
      ..layout()
      ..paint(canvas, at);
  }

  @override
  bool shouldRepaint(covariant _DistanceTimePainter old) =>
      old.t != t || old.color != color;
}

class _PaceButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _PaceButton({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Bouncy(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

/// One mass, two readings. Moving the slider changes both numbers, but only
/// the newtons depend on where you are standing.
class _MassWeightDemo extends StatefulWidget {
  const _MassWeightDemo();

  @override
  State<_MassWeightDemo> createState() => _MassWeightDemoState();
}

class _MassWeightDemoState extends State<_MassWeightDemo> {
  double _mass = 20;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ReadingCard(
                icon: Icons.scale_rounded,
                caption: 'Mass',
                value: '${_mass.round()} kg',
                note: 'the same everywhere',
                color: AppColors.grape,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ReadingCard(
                icon: Icons.south_rounded,
                caption: 'Weight on Earth',
                value: '${(_mass * 9.8).round()} N',
                note: 'changes with gravity',
                color: AppColors.sky,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _ValueSlider(
          label: 'Mass',
          value: _mass,
          min: 1,
          max: 80,
          unit: 'kg',
          color: AppColors.grape,
          onChanged: (v) => setState(() => _mass = v),
        ),
        const Text(
          'Weight = mass × 9.8 N for every kilogram.',
          style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
        ),
      ],
    );
  }
}

class _ReadingCard extends StatelessWidget {
  final IconData icon;
  final String caption;
  final String value;
  final String note;
  final Color color;

  const _ReadingCard({
    required this.icon,
    required this.caption,
    required this.value,
    required this.note,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            note,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _World {
  final String name;
  final double gravity;
  final Color color;
  const _World(this.name, this.gravity, this.color);
}

const _worlds = <_World>[
  _World('Moon', 1.6, Color(0xFF7C82AD)),
  _World('Mars', 3.7, Color(0xFFC4553A)),
  _World('Earth', 9.8, AppColors.learn),
  _World('Jupiter', 24.8, Color(0xFFC97A0C)),
];

/// Keeps the mass locked while the planet changes, so the only thing moving
/// is the weight.
class _PlanetWeightDemo extends StatefulWidget {
  const _PlanetWeightDemo();

  @override
  State<_PlanetWeightDemo> createState() => _PlanetWeightDemoState();
}

class _PlanetWeightDemoState extends State<_PlanetWeightDemo> {
  int _world = 2;
  double _mass = 40;

  @override
  Widget build(BuildContext context) {
    final world = _worlds[_world];
    final weight = _mass * world.gravity;
    final heaviest = _mass * _worlds.last.gravity;

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < _worlds.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: _PaceButton(
                  label: _worlds[i].name,
                  color: _worlds[i].color,
                  selected: _world == i,
                  onTap: () => setState(() => _world = i),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Mass',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkSoft,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_mass.round()} kg',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grape,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.lock_rounded,
                    size: 14,
                    color: AppColors.inkSoft,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'Weight',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkSoft,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${weight.round()} N',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: world.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: weight / heaviest),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  builder: (context, v, _) => LinearProgressIndicator(
                    value: v,
                    minHeight: 12,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation(world.color),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${_mass.round()} kg × ${world.gravity} N/kg '
                '= ${weight.round()} N',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: world.color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        _ValueSlider(
          label: 'Mass',
          value: _mass,
          min: 5,
          max: 100,
          unit: 'kg',
          color: AppColors.grape,
          onChanged: (v) => setState(() => _mass = v),
        ),
      ],
    );
  }
}

/// Air is the only difference between the two runs, which is what makes the
/// feather lose on Earth and tie on the Moon.
class _DropRaceDemo extends StatefulWidget {
  const _DropRaceDemo();

  @override
  State<_DropRaceDemo> createState() => _DropRaceDemoState();
}

class _DropRaceDemoState extends State<_DropRaceDemo>
    with SingleTickerProviderStateMixin {
  bool _air = true;

  late final AnimationController _fall = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  @override
  void dispose() {
    _fall.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _air ? AppColors.sky : AppColors.grape;
    return Column(
      children: [
        Container(
          height: 170,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _air ? AppColors.surfaceSoft : const Color(0xFF2B2450),
            borderRadius: BorderRadius.circular(22),
          ),
          child: AnimatedBuilder(
            animation: _fall,
            builder: (context, _) {
              final t = _fall.value;
              // Free fall is t squared; air makes the feather drift almost
              // linearly and finish late.
              final hammer = t * t;
              final feather = _air ? t * 0.55 : t * t;
              return LayoutBuilder(
                builder: (context, constraints) {
                  // Leaves room for the icon plus its caption at the bottom.
                  final span = constraints.maxHeight - 62;
                  return Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Positioned(
                        left: constraints.maxWidth * 0.22,
                        top: span * hammer,
                        child: _Faller(
                          icon: Icons.hardware_rounded,
                          label: 'hammer',
                          color: accent,
                          dark: !_air,
                        ),
                      ),
                      Positioned(
                        left: constraints.maxWidth * 0.62,
                        top: span * feather.clamp(0.0, 1.0),
                        child: _Faller(
                          icon: Icons.air_rounded,
                          label: 'feather',
                          color: accent,
                          dark: !_air,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PaceButton(
                label: 'With air',
                color: AppColors.sky,
                selected: _air,
                onTap: () => setState(() {
                  _air = true;
                  _fall.forward(from: 0);
                }),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PaceButton(
                label: 'No air',
                color: AppColors.grape,
                selected: !_air,
                onTap: () => setState(() {
                  _air = false;
                  _fall.forward(from: 0);
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _PaceButton(
          label: 'Drop them',
          color: AppColors.play,
          selected: true,
          onTap: () => _fall.forward(from: 0),
        ),
        const SizedBox(height: 10),
        Text(
          _air
              ? 'Air pushes back on the feather, so it lags behind.'
              : 'With no air to slow it, the feather keeps up exactly.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.inkSoft),
        ),
      ],
    );
  }
}

class _Faller extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool dark;

  const _Faller({
    required this.icon,
    required this.label,
    required this.color,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: glow(color, blur: 10),
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: dark ? Colors.white70 : AppColors.inkSoft,
          ),
        ),
      ],
    );
  }
}

/// Sliding the fulcrum changes both arms at once, which is why the effort
/// drops so sharply as it approaches the load.
class _LeverDemo extends StatefulWidget {
  const _LeverDemo();

  @override
  State<_LeverDemo> createState() => _LeverDemoState();
}

class _LeverDemoState extends State<_LeverDemo> {
  static const _load = 200.0;
  double _fulcrum = 0.5;

  double get _effort => _load * (1 - _fulcrum) / _fulcrum;

  @override
  Widget build(BuildContext context) {
    final easy = _effort <= _load;
    return Column(
      children: [
        Container(
          height: 130,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(22),
          ),
          child: CustomPaint(
            size: Size.infinite,
            painter: _LeverPainter(
              fulcrum: _fulcrum,
              tilt: (_effort / _load).clamp(0.0, 2.0),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _ValueSlider(
          label: 'Fulcrum',
          value: _fulcrum * 100,
          min: 20,
          max: 80,
          unit: '%',
          color: AppColors.grape,
          onChanged: (v) => setState(() => _fulcrum = v / 100),
        ),
        Row(
          children: [
            Expanded(
              child: _ReadingCard(
                icon: Icons.fitness_center_rounded,
                caption: 'Load',
                value: '${_load.round()} N',
                note: 'always the same',
                color: AppColors.learn,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ReadingCard(
                icon: Icons.back_hand_rounded,
                caption: 'Effort you need',
                value: '${_effort.round()} N',
                note: easy ? 'easier than lifting' : 'harder than lifting',
                color: easy ? AppColors.play : AppColors.practice,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LeverPainter extends CustomPainter {
  final double fulcrum;
  final double tilt;

  const _LeverPainter({required this.fulcrum, required this.tilt});

  @override
  void paint(Canvas canvas, Size size) {
    final pivot = Offset(size.width * fulcrum, size.height * 0.62);
    final left = size.width * 0.06;
    final right = size.width * 0.94;
    final angle = (0.22 * (tilt - 1)).clamp(-0.3, 0.3);

    canvas.drawLine(
      Offset(0, size.height - 12),
      Offset(size.width, size.height - 12),
      Paint()
        ..color = AppColors.ink.withValues(alpha: 0.12)
        ..strokeWidth = 3,
    );

    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(angle);
    final beam = RRect.fromRectAndRadius(
      Rect.fromLTRB(left - pivot.dx, -5, right - pivot.dx, 5),
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
    _block(canvas, Offset(right - pivot.dx - 16, -20), AppColors.learn, 'load');
    _block(
      canvas,
      Offset(left - pivot.dx + 16, -20),
      AppColors.practice,
      'effort',
    );
    canvas.restore();

    canvas.drawPath(
      Path()
        ..moveTo(pivot.dx, pivot.dy + 4)
        ..lineTo(pivot.dx - 13, size.height - 12)
        ..lineTo(pivot.dx + 13, size.height - 12)
        ..close(),
      Paint()..color = AppColors.grape,
    );
    _caption(
      canvas,
      'fulcrum',
      Offset(pivot.dx, size.height - 4),
      AppColors.grape,
    );
  }

  void _block(Canvas canvas, Offset centre, Color color, String label) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: centre, width: 30, height: 24),
        const Radius.circular(6),
      ),
      Paint()..color = color,
    );
    _caption(canvas, label, centre - const Offset(0, 24), color);
  }

  void _caption(Canvas canvas, String text, Offset centre, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      centre - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _LeverPainter old) =>
      old.fulcrum != fulcrum || old.tilt != tilt;
}

/// The height is locked, so lengthening the ramp is the only way to soften
/// the slope, and the push falls in exact proportion.
class _RampDemo extends StatefulWidget {
  const _RampDemo();

  @override
  State<_RampDemo> createState() => _RampDemoState();
}

class _RampDemoState extends State<_RampDemo> {
  static const _weight = 300.0;
  static const _height = 1.0;
  double _length = 3;

  double get _push => _weight * _height / _length;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 130,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(22),
          ),
          child: CustomPaint(
            size: Size.infinite,
            painter: _RampPainter(lengthFraction: _length / 6),
          ),
        ),
        const SizedBox(height: 10),
        _ValueSlider(
          label: 'Ramp',
          value: _length,
          min: 1,
          max: 6,
          unit: 'm',
          color: AppColors.play,
          onChanged: (v) => setState(() => _length = v),
        ),
        Row(
          children: [
            Expanded(
              child: _ReadingCard(
                icon: Icons.fitness_center_rounded,
                caption: 'Crate weight',
                value: '${_weight.round()} N',
                note: 'lifted 1 m either way',
                color: AppColors.learn,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ReadingCard(
                icon: Icons.trending_up_rounded,
                caption: 'Push needed',
                value: '${_push.round()} N',
                note: 'over ${_length.toStringAsFixed(1)} m',
                color: AppColors.play,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RampPainter extends CustomPainter {
  final double lengthFraction;

  const _RampPainter({required this.lengthFraction});

  @override
  bool shouldRepaint(covariant _RampPainter old) =>
      old.lengthFraction != lengthFraction;

  @override
  void paint(Canvas canvas, Size size) {
    final ground = size.height - 14;
    const rise = 46.0;
    final right = size.width * 0.92;
    final left = right - (size.width * 0.86) * lengthFraction;
    final topY = ground - rise;

    canvas.drawLine(
      Offset(0, ground),
      Offset(size.width, ground),
      Paint()
        ..color = AppColors.ink.withValues(alpha: 0.12)
        ..strokeWidth = 3,
    );

    final slope = Path()
      ..moveTo(left, ground)
      ..lineTo(right, topY)
      ..lineTo(right, ground)
      ..close();
    canvas.drawPath(slope, Paint()..color = const Color(0xFFBFA079));
    canvas.drawPath(
      slope,
      Paint()
        ..color = const Color(0xFF8E6C46)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Fixed height marker.
    final markX = right + 12;
    canvas.drawLine(
      Offset(markX, topY),
      Offset(markX, ground),
      Paint()
        ..color = AppColors.grape
        ..strokeWidth = 2,
    );
    _caption(canvas, '1 m', Offset(markX, topY - 8), AppColors.grape);

    final mid = Offset((left + right) / 2, (ground + topY) / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: mid - const Offset(0, 13),
          width: 28,
          height: 22,
        ),
        const Radius.circular(6),
      ),
      Paint()..color = AppColors.learn,
    );

    final dir = (Offset(right, topY) - Offset(left, ground));
    final unit = dir / dir.distance;
    canvas.drawLine(
      mid - unit * 44 - const Offset(0, 13),
      mid - unit * 20 - const Offset(0, 13),
      Paint()
        ..color = AppColors.play
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  void _caption(Canvas canvas, String text, Offset centre, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      centre - Offset(painter.width / 2, painter.height / 2),
    );
  }
}

/// Each strand carries a share of the load, so the pull divides while the
/// length of rope you haul multiplies.
class _PulleyDemo extends StatefulWidget {
  const _PulleyDemo();

  @override
  State<_PulleyDemo> createState() => _PulleyDemoState();
}

class _PulleyDemoState extends State<_PulleyDemo> {
  static const _load = 200.0;
  int _strands = 1;

  @override
  Widget build(BuildContext context) {
    final pull = _load / _strands;
    return Column(
      children: [
        Container(
          height: 140,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(22),
          ),
          child: CustomPaint(
            size: Size.infinite,
            painter: _PulleyPainter(strands: _strands),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var n = 1; n <= 4; n++) ...[
              if (n > 1) const SizedBox(width: 8),
              Expanded(
                child: _PaceButton(
                  label: '$n',
                  color: AppColors.grape,
                  selected: _strands == n,
                  onTap: () => setState(() => _strands = n),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Rope strands holding the crate',
          style: TextStyle(fontSize: 12.5, color: AppColors.inkSoft),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ReadingCard(
                icon: Icons.back_hand_rounded,
                caption: 'You pull',
                value: '${pull.round()} N',
                note: '${_load.round()} N ÷ $_strands',
                color: AppColors.play,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ReadingCard(
                icon: Icons.straighten_rounded,
                caption: 'Rope to haul',
                value: '$_strands m',
                note: 'to raise it 1 m',
                color: AppColors.practice,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PulleyPainter extends CustomPainter {
  final int strands;

  const _PulleyPainter({required this.strands});

  @override
  bool shouldRepaint(covariant _PulleyPainter old) => old.strands != strands;

  @override
  void paint(Canvas canvas, Size size) {
    const beamY = 12.0;
    final crateY = size.height - 46;
    final centre = size.width * 0.58;
    const spread = 15.0;
    final freeX = size.width * 0.16;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.08, 0, size.width * 0.84, beamY),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF8E6C46),
    );

    final rope = Paint()
      ..color = AppColors.sunshine
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    void wheel(double x) {
      canvas.drawCircle(
        Offset(x, beamY + 7),
        8,
        Paint()..color = AppColors.grape,
      );
      canvas.drawCircle(
        Offset(x, beamY + 7),
        3.5,
        Paint()..color = Colors.white,
      );
    }

    // One strand per share of the load, drawn as parallel lines.
    for (var i = 0; i < strands; i++) {
      final x = centre + (i - (strands - 1) / 2) * spread;
      canvas.drawLine(Offset(x, beamY + 7), Offset(x, crateY), rope);
      wheel(x);
    }

    // The free end you actually hold.
    canvas.drawLine(Offset(freeX, beamY + 7), Offset(freeX, crateY + 8), rope);
    canvas.drawLine(
      Offset(freeX, beamY + 7),
      Offset(centre - (strands - 1) / 2 * spread, beamY + 7),
      rope,
    );
    wheel(freeX);
    canvas.drawCircle(
      Offset(freeX, crateY + 8),
      9,
      Paint()..color = AppColors.play,
    );
    _caption(canvas, 'pull', Offset(freeX, crateY + 28), AppColors.play);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centre, crateY + 16),
          width: 66,
          height: 32,
        ),
        const Radius.circular(8),
      ),
      Paint()..color = AppColors.learn,
    );
    _caption(canvas, '200 N', Offset(centre, crateY + 16), Colors.white);
    _caption(
      canvas,
      '$strands ${strands == 1 ? 'strand' : 'strands'}',
      Offset(centre, crateY + 44),
      AppColors.learn,
    );
  }

  void _caption(Canvas canvas, String text, Offset centre, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      centre - Offset(painter.width / 2, painter.height / 2),
    );
  }
}
