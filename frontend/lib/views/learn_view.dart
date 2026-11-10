import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/back_bar.dart';
import '../widgets/fun_card.dart';
import '../widgets/section_hero.dart';
import 'lesson_screen.dart';

class LearnView extends StatelessWidget {
  const LearnView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BackBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
        children: [
          const SectionHero(
            icon: Icons.auto_stories_rounded,
            title: 'Learn',
            subtitle: 'Read a lesson and build your basics.',
            color: AppColors.learn,
            colorDeep: AppColors.learnDeep,
          ),
          const SizedBox(height: 22),
          const _Heading('Your lessons'),
          const SizedBox(height: 12),
          FunCard(
            icon: const Icon(
              Icons.directions_run_rounded,
              size: 28,
              color: AppColors.learn,
            ),
            title: 'Motion & Speed',
            meta: '7 min',
            color: AppColors.learn,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const LessonScreen(
                  lessonId: 'motion',
                  icon: Icons.directions_run_rounded,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FunCard(
            icon: const Icon(
              Icons.back_hand_rounded,
              size: 28,
              color: AppColors.learn,
            ),
            title: 'Forces',
            meta: '8 min',
            color: AppColors.learn,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const LessonScreen(
                  lessonId: 'forces',
                  icon: Icons.back_hand_rounded,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FunCard(
            icon: const Icon(
              Icons.public_rounded,
              size: 28,
              color: AppColors.learn,
            ),
            title: 'Gravity & Weight',
            meta: '8 min',
            color: AppColors.learn,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const LessonScreen(
                  lessonId: 'gravity',
                  icon: Icons.public_rounded,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FunCard(
            icon: const Icon(
              Icons.settings_rounded,
              size: 28,
              color: AppColors.learn,
            ),
            title: 'Simple Machines',
            meta: '9 min',
            color: AppColors.learn,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const LessonScreen(
                  lessonId: 'machines',
                  icon: Icons.settings_rounded,
                ),
              ),
            ),
          ),
        ],
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
