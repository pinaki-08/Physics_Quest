import 'package:flutter_test/flutter_test.dart';
import 'package:physics_quest/models/lesson.dart';
import 'package:physics_quest/services/vocabulary_matcher.dart';

const _force = GlossaryTerm(
  en: 'Force',
  es: 'Fuerza',
  definitionEn: 'A push or a pull.',
  definitionEs: 'Un empujón o un tirón.',
  audioEn: '',
  audioEs: '',
);

const _balancedForces = GlossaryTerm(
  en: 'Balanced forces',
  es: 'Fuerzas equilibradas',
  definitionEn: 'Equal forces in opposite directions.',
  definitionEs: 'Fuerzas iguales en direcciones opuestas.',
  audioEn: '',
  audioEs: '',
);

void main() {
  test('matches a glossary term case-insensitively', () {
    final matches = findVocabularyMatches(
      'Speed describes how quickly something moves.',
      const [
        GlossaryTerm(
          en: 'speed',
          es: 'velocidad',
          definitionEn: '',
          definitionEs: '',
          audioEn: '',
          audioEs: '',
        ),
      ],
    );

    expect(matches, hasLength(1));
    expect(matches.single.start, 0);
    expect(matches.single.end, 5);
  });

  test('matches a simple plural and highlights only its first occurrence', () {
    final matches = findVocabularyMatches(
      'Forces can change motion. Other forces can cancel out.',
      const [_force],
    );

    expect(matches, hasLength(1));
    expect(matches.single.start, 0);
    expect(matches.single.end, 6);
  });

  test('prefers a longer phrase over an overlapping single term', () {
    final matches = findVocabularyMatches(
      'Balanced forces do not change motion.',
      const [_force, _balancedForces],
    );

    expect(matches, hasLength(1));
    expect(matches.single.term.en, 'Balanced forces');
  });
}
