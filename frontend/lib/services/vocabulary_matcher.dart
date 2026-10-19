import '../models/lesson.dart';

class VocabularyMatch {
  final int start;
  final int end;
  final GlossaryTerm term;

  const VocabularyMatch({
    required this.start,
    required this.end,
    required this.term,
  });
}

List<VocabularyMatch> findVocabularyMatches(
  String text,
  List<GlossaryTerm> terms,
) {
  final matches = <VocabularyMatch>[];
  final longestTermsFirst = [...terms]
    ..sort((a, b) => b.en.length.compareTo(a.en.length));

  for (final term in longestTermsFirst) {
    final english = term.en.trim();
    if (english.isEmpty) continue;

    final pluralSuffix = english.toLowerCase().endsWith('s') ? '' : 's?';
    final pattern = RegExp(
      '\\b${RegExp.escape(english)}$pluralSuffix\\b',
      caseSensitive: false,
    );

    for (final candidate in pattern.allMatches(text)) {
      final overlaps = matches.any(
        (match) => candidate.start < match.end && match.start < candidate.end,
      );
      if (overlaps) continue;

      matches.add(
        VocabularyMatch(start: candidate.start, end: candidate.end, term: term),
      );
      break;
    }
  }

  matches.sort((a, b) => a.start.compareTo(b.start));
  return matches;
}
