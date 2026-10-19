import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/lesson_repository.dart';
import '../models/lesson.dart';
import '../theme.dart';
import '../widgets/back_bar.dart';
import '../widgets/bouncy.dart';
import '../widgets/fun_card.dart';
import '../widgets/section_hero.dart';
import 'quiz_screen.dart';

/// Colour and icon per lesson, so a quiz card matches the lesson it came from.
const _quizStyles = <String, (IconData, Color)>{
  'motion': (Icons.directions_run_rounded, AppColors.practice),
  'forces': (Icons.back_hand_rounded, AppColors.sky),
  'gravity': (Icons.public_rounded, AppColors.grape),
  'machines': (Icons.settings_rounded, AppColors.learn),
};

/// Each game mode gathers one question type from every lesson.
const _modes = <(QuestionKind, String, String, IconData, Color)>[
  (
    QuestionKind.mcq,
    'Multiple Choice',
    'Pick the right answer',
    Icons.checklist_rounded,
    AppColors.learn
  ),
  (
    QuestionKind.blank,
    'Fill the Blank',
    'Complete the sentence',
    Icons.edit_note_rounded,
    AppColors.play
  ),
  (
    QuestionKind.oddOneOut,
    'Odd One Out',
    'Spot what does not belong',
    Icons.search_off_rounded,
    AppColors.grape
  ),
  (
    QuestionKind.match,
    'Match Up',
    'Pair each word to its meaning',
    Icons.compare_arrows_rounded,
    AppColors.sunshine
  ),
];

class PracticeView extends StatefulWidget {
  const PracticeView({super.key});

  @override
  State<PracticeView> createState() => _PracticeViewState();
}

class _PracticeViewState extends State<PracticeView> {
  late Future<List<Lesson>> _lessons;

  @override
  void initState() {
    super.initState();
    _lessons = lessonRepository.fetchAll();
  }

  void _open(String quizId, String title, Color color, List<Question> qs) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          quizId: quizId,
          title: title,
          color: color,
          questions: qs,
        ),
      ),
    );
  }

  /// A fresh shuffle each time, so the daily challenge is not the same five
  /// questions in the same order.
  List<Question> _mixed(List<Lesson> lessons, int count) {
    final pool = [for (final lesson in lessons) ...lesson.questions];
    pool.shuffle(math.Random());
    return pool.take(count).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BackBar(),
      body: FutureBuilder<List<Lesson>>(
        future: _lessons,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final lessons = snapshot.data!;
          final all = [for (final lesson in lessons) ...lesson.questions];

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
            children: [
              const SectionHero(
                icon: Icons.edit_rounded,
                title: 'Practice',
                subtitle: 'Answer questions and earn points.',
                color: AppColors.practice,
                colorDeep: AppColors.practiceDeep,
              ),
              const SizedBox(height: 18),
              _DailyChallenge(
                onTap: () => _open(
                  'daily',
                  'Daily Challenge',
                  AppColors.sunshine,
                  _mixed(lessons, math.min(5, all.length)),
                ),
              ),
              const SizedBox(height: 22),
              const _Heading('Game modes'),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.24,
                children: [
                  for (final mode in _modes)
                    Builder(
                      builder: (context) {
                        final items = [
                          for (final lesson in lessons)
                            ...lesson.questions.where((q) => q.kind == mode.$1),
                        ]..shuffle(math.Random());
                        return _ModeCard(
                          title: mode.$2,
                          blurb: mode.$3,
                          icon: mode.$4,
                          color: mode.$5,
                          count: items.length,
                          onTap: items.isEmpty
                              ? null
                              : () => _open(
                                    mode.$1.name,
                                    mode.$2,
                                    mode.$5,
                                    items,
                                  ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 22),
              const _Heading('Practice a lesson'),
              const SizedBox(height: 12),
              for (final lesson in lessons) ...[
                Builder(
                  builder: (context) {
                    final style = _quizStyles[lesson.id] ??
                        (Icons.quiz_rounded, AppColors.practice);
                    return FunCard(
                      icon: Icon(style.$1, size: 28, color: style.$2),
                      title: lesson.title,
                      meta: '${lesson.questions.length} questions',
                      color: style.$2,
                      onTap: lesson.questions.isEmpty
                          ? null
                          : () => _open(
                                lesson.id,
                                lesson.title,
                                style.$2,
                                lesson.questions,
                              ),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
              FunCard(
                icon: const Icon(Icons.emoji_events_rounded,
                    size: 28, color: AppColors.sunshine),
                title: 'Mixed Challenge',
                meta: 'All ${all.length} questions',
                color: AppColors.sunshine,
                onTap: all.isEmpty
                    ? null
                    : () => _open(
                          'mixed',
                          'Mixed Challenge',
                          AppColors.sunshine,
                          _mixed(lessons, all.length),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String blurb;
  final IconData icon;
  final Color color;
  final int count;
  final VoidCallback? onTap;

  const _ModeCard({
    required this.title,
    required this.blurb,
    required this.icon,
    required this.color,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Bouncy(
      onTap: onTap ?? () {},
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.78)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: glow(color, opacity: 0.3, blur: 18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 19, color: Colors.white),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    blurb,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count ${count == 1 ? 'round' : 'rounds'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyChallenge extends StatelessWidget {
  final VoidCallback onTap;
  const _DailyChallenge({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Bouncy(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.sunshine, Color(0xFFFF9E1B)],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: glow(AppColors.sunshine, opacity: 0.4),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.bolt_rounded,
                  size: 30, color: Colors.white),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Challenge',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '5 questions, mixed topics',
                    style: TextStyle(color: Colors.white70, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'Go!',
                style: TextStyle(
                  color: Color(0xFFE07C00),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    );
  }
}
