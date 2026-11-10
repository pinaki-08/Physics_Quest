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
    Color(0xFF425F78),
  ),
  (
    QuestionKind.blank,
    'Fill the Blank',
    'Complete the sentence',
    Icons.edit_note_rounded,
    Color(0xFF496650),
  ),
  (
    QuestionKind.oddOneOut,
    'Odd One Out',
    'Spot what does not belong',
    Icons.search_off_rounded,
    Color(0xFF8A5D4A),
  ),
  (
    QuestionKind.match,
    'Match Up',
    'Pair each word to its meaning',
    Icons.compare_arrows_rounded,
    Color(0xFF7D673B),
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
              const SizedBox(height: 22),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final scaledTitleSize = MediaQuery.textScalerOf(
                        context,
                      ).scale(24);
                      final columns =
                          constraints.maxWidth < 320 || scaledTitleSize > 32
                          ? 1
                          : 2;
                      final cardHeight =
                          columns == 2 && constraints.maxWidth < 640
                          ? 300.0
                          : 240.0;
                      return GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          mainAxisExtent:
                              cardHeight +
                              math.max(0, scaledTitleSize - 24) * 4,
                        ),
                        children: [
                          for (final mode in _modes)
                            Builder(
                              builder: (context) {
                                final items = [
                                  for (final lesson in lessons)
                                    ...lesson.questions.where(
                                      (q) => q.kind == mode.$1,
                                    ),
                                ];
                                return _ModeCard(
                                  key: ValueKey(
                                    'practice-mode-${mode.$1.name}',
                                  ),
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
                                              builder: (_) =>
                                                  _PracticeTopicsView(
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
                      );
                    },
                  ),
                ),
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
                : kind == QuestionKind.match
                ? 'Complete one matching round at a time.'
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
                final pairCounts = {
                  for (final question in questions) question.pairs.length,
                };
                final meta = switch (kind) {
                  QuestionKind.mcq => '${questions.length} MCQs',
                  QuestionKind.match when pairCounts.length == 1 =>
                    '${questions.length} rounds, ${pairCounts.single} pairs each',
                  QuestionKind.match => '${questions.length} matching rounds',
                  _ => '${questions.length} questions',
                };
                return FunCard(
                  key: ValueKey('${kind.name}-topic-${lesson.id}'),
                  icon: const Icon(
                    Icons.quiz_rounded,
                    size: 28,
                    color: AppColors.learn,
                  ),
                  title: lesson.title,
                  meta: meta,
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
    super.key,
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
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              color.withValues(alpha: 0.10),
              AppColors.surface,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
              ),
              Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      blurb,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$count ${count == 1 ? 'round' : 'rounds'}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
