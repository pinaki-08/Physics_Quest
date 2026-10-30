import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../services/speech.dart';
import '../services/vocabulary_matcher.dart';
import '../theme.dart';

class VocabularyText extends StatelessWidget {
  final String text;
  final List<GlossaryTerm> terms;
  final TextStyle style;
  final String? blankFill;
  final String blankLabel;
  final Future<void> Function(String text, {required bool spanish})? onSpeak;

  const VocabularyText({
    super.key,
    required this.text,
    required this.terms,
    this.style = const TextStyle(fontSize: 14.5, height: 1.5),
    this.onSpeak,
    this.blankFill,
    this.blankLabel = 'blank',
  });

  List<InlineSpan> _plainSpans(String value) {
    final parts = value.split('___');
    return [
      for (var index = 0; index < parts.length; index++) ...[
        TextSpan(text: parts[index]),
        if (index < parts.length - 1)
          TextSpan(
            text: blankFill ?? '          ',
            semanticsLabel: blankFill ?? blankLabel,
            style: TextStyle(
              color: blankFill == null
                  ? Colors.transparent
                  : AppColors.learnDeep,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.inkSoft,
              decorationThickness: 2,
            ),
          ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final matches = findVocabularyMatches(text, terms);
    if (matches.isEmpty && !text.contains('___')) {
      return Text(text, style: style);
    }

    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in matches) {
      if (match.start > cursor) {
        spans.addAll(_plainSpans(text.substring(cursor, match.start)));
      }
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: _HighlightedVocabulary(
            label: text.substring(match.start, match.end),
            term: match.term,
            style: style,
            onTap: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              useSafeArea: true,
              constraints: const BoxConstraints(maxWidth: 560),
              builder: (_) => _VocabularyCard(
                term: match.term,
                onSpeak: onSpeak ?? TermSpeaker.instance.speak,
              ),
            ),
          ),
        ),
      );
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.addAll(_plainSpans(text.substring(cursor)));
    }
    return Text.rich(TextSpan(style: style, children: spans));
  }
}

class _HighlightedVocabulary extends StatelessWidget {
  final String label;
  final GlossaryTerm term;
  final TextStyle style;
  final VoidCallback onTap;

  const _HighlightedVocabulary({
    required this.label,
    required this.term,
    required this.style,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final keyName = term.en.toLowerCase().replaceAll(' ', '-');
    return Semantics(
      button: true,
      label:
          '${term.en}. Spanish: ${term.es}. '
          'Tap for meaning and pronunciation.',
      child: ExcludeSemantics(
        child: Material(
          key: ValueKey('vocabulary-$keyName'),
          color: AppColors.sunshine.withValues(alpha: 0.24),
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: style.copyWith(
                        color: AppColors.learnDeep,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.volume_up_rounded,
                    size: 12,
                    color: AppColors.learnDeep,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VocabularyCard extends StatelessWidget {
  final GlossaryTerm term;
  final Future<void> Function(String text, {required bool spanish}) onSpeak;

  const _VocabularyCard({required this.term, required this.onSpeak});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.school_rounded,
                size: 20,
                color: AppColors.learn,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Physics vocabulary · Vocabulario',
                  style: TextStyle(
                    color: AppColors.inkSoft,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            term.en,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (term.definitionEn.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              term.definitionEn,
              style: const TextStyle(
                color: AppColors.inkSoft,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              const Icon(
                Icons.translate_rounded,
                size: 19,
                color: AppColors.practice,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  term.es,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (term.definitionEs.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              term.definitionEs,
              style: const TextStyle(
                color: AppColors.inkSoft,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  key: const ValueKey('vocabulary-audio-en'),
                  onPressed: () => onSpeak(term.en, spanish: false),
                  icon: const Icon(Icons.volume_up_rounded, size: 19),
                  label: const Text('Hear EN'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.learn,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  key: const ValueKey('vocabulary-audio-es'),
                  onPressed: () => onSpeak(term.es, spanish: true),
                  icon: const Icon(Icons.volume_up_rounded, size: 19),
                  label: const Text('Escuchar ES'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.practice,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
