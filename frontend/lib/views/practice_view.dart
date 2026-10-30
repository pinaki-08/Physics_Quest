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

/// Each activity opens per-lesson practice for one question type.
const _modes = <(QuestionKind, String, String, IconData, Color)>[
  (
    QuestionKind.mcq,
    'Multiple Choice',
    'Choose a topic and answer',
    Icons.checklist_rounded,
    AppColors.learn,
  ),
  (
    QuestionKind.blank,
    'Fill the Blank',
    'Complete the sentence',
    Icons.edit_note_rounded,
    AppColors.play,
  ),
  (
    QuestionKind.oddOneOut,
    'Odd One Out',
    'Spot what does not belong',
    Icons.search_off_rounded,
    AppColors.grape,
  ),
  (
    QuestionKind.match,
    'Match Up',
    'Pair each word to its meaning',
    Icons.compare_arrows_rounded,
    AppColors.sunshine,
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

  void _open(
    String quizId,
    String title,
    Color color,
    List<Question> qs, {
    List<GlossaryTerm> glossary = const [],
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          quizId: quizId,
          title: title,
          color: color,
          questions: qs,
          glossary: glossary,
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
                  glossary: [for (final lesson in lessons) ...lesson.glossary],
                ),
              ),
              const SizedBox(height: 22),
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
                        ];
                        return _ModeCard(
                          title: mode.$2,
                          blurb: mode.$3,
                          icon: mode.$4,
                          color: mode.$5,
                          count: items.length,
                          onTap: items.isEmpty
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => _PracticeTopicsView(
                                        lessons: lessons,
                                        kind: mode.$1,
                                        icon: mode.$4,
                                      ),
                                    ),
                                  );
                                },
                        );
                      },
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PracticeTopicsView extends StatelessWidget {
  final List<Lesson> lessons;
  final QuestionKind kind;
  final IconData icon;

  const _PracticeTopicsView({
    required this.lessons,
    required this.kind,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lessonBackground,
      appBar: const BackBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
        children: [
          SectionHero(
            icon: icon,
            title: kind.title,
            subtitle: kind == QuestionKind.mcq
                ? 'Choose a lesson to practice its MCQs.'
                : 'Choose a lesson to start.',
            color: AppColors.learn,
            colorDeep: AppColors.learnDeep,
          ),
          const SizedBox(height: 18),
          for (final lesson in lessons) ...[
            Builder(
              builder: (context) {
                final questions = lesson.questions
                    .where((question) => question.kind == kind)
                    .toList();
                return FunCard(
                  key: ValueKey('${kind.name}-topic-${lesson.id}'),
                  icon: const Icon(
                    Icons.quiz_rounded,
                    size: 28,
                    color: AppColors.learn,
                  ),
                  title: lesson.title,
                  meta:
                      '${questions.length} ${switch (kind) {
                        QuestionKind.mcq => 'MCQs',
                        QuestionKind.match => 'matching sets',
                        _ => 'questions',
                      }}',
                  color: AppColors.learn,
                  locked: questions.isEmpty,
                  onTap: questions.isEmpty
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => QuizScreen(
                              quizId: '${kind.name}-${lesson.id}',
                              title: lesson.title,
                              color: AppColors.learn,
                              questions: questions,
                              glossary: lesson.glossary,
                            ),
                          ),
                        ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ],
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
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
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
              child: const Icon(
                Icons.bolt_rounded,
                size: 30,
                color: Colors.white,
              ),
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
