import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:physics_quest/data/lesson_repository.dart';
import 'package:physics_quest/models/lesson.dart';

const _answerKeys = <String, Map<String, String>>{
  'motion': {
    'q1': '6 metres per second',
    'q2': 'A tree outside',
    'q3': 'Acceleration',
    'q7': '24 metres',
    'q8': 'Maya',
    'q9': 'The object is not moving',
    'q10': 'Object A has the greater speed',
    'q11': 'An average speed of 3 metres per second in each interval',
    'q12': 'It speeds up',
    'q13': 'Distance travelled and elapsed time',
  },
  'forces': {
    'q1': 'A push or a pull',
    'q2': 'The rope stays still',
    'q3': 'Friction',
    'q7': '5 N to the right',
    'q8': 'It keeps moving at the same speed and direction',
    'q9': 'The empty cart',
    'q10': 'A student pushes a chair',
    'q11': 'It increases air resistance',
    'q12': '30 N in the opposite direction',
    'q13': 'The cart, track surface, and push duration',
  },
  'gravity': {
    'q1': 'Your mass',
    'q2': 'Newtons',
    'q3': 'Land at the same time',
    'q7': 'The objects attract each other',
    'q8': 'It becomes stronger',
    'q9': '4 kilograms',
    'q10': '30 N',
    'q11': 'Its weight becomes half as large',
    'q12': 'It still pulls on the astronauts',
    'q13': 'Downward',
  },
  'machines': {
    'q1': 'Easier',
    'q2': 'Less force over more distance',
    'q3': '50 N',
    'q7': 'The fulcrum',
    'q8': 'The direction of the applied force',
    'q9': 'Effort',
    'q10': 'Farther from the fulcrum on the effort end',
    'q11': '2 metres',
    'q12': 'Some energy becomes heat because of friction',
    'q13': 'A 3-metre ramp',
  },
};

const _spanishAnswerKeys = <String, Map<String, String>>{
  'motion': {
    'q1': '6 metros por segundo',
    'q2': 'Un árbol fuera del tren',
    'q3': 'Aceleración',
    'q7': '24 metros',
    'q8': 'Maya',
    'q9': 'El objeto no se mueve',
    'q10': 'El objeto A tiene mayor velocidad',
    'q11': 'Una velocidad media de 3 metros por segundo en cada intervalo',
    'q12': 'Aumenta su velocidad',
    'q13': 'Distancia recorrida y tiempo transcurrido',
  },
  'forces': {
    'q1': 'Un empujón o un tirón',
    'q2': 'La cuerda permanece en reposo',
    'q3': 'Fricción',
    'q7': '5 N hacia la derecha',
    'q8': 'Sigue moviéndose a la misma velocidad y en la misma dirección',
    'q9': 'El carrito vacío',
    'q10': 'Un estudiante empuja una silla',
    'q11': 'Aumenta la resistencia del aire',
    'q12': '30 N en sentido contrario',
    'q13': 'El carrito, la superficie de la pista y la duración del empujón',
  },
  'gravity': {
    'q1': 'Tu masa',
    'q2': 'Newtons',
    'q3': 'Llegan al suelo al mismo tiempo',
    'q7': 'Los objetos se atraen entre sí',
    'q8': 'Se hace más fuerte',
    'q9': '4 kilogramos',
    'q10': '30 N',
    'q11': 'Su peso se reduce a la mitad',
    'q12': 'Todavía atrae a los astronautas',
    'q13': 'Hacia abajo',
  },
  'machines': {
    'q1': 'Más fácil',
    'q2': 'Menos fuerza a lo largo de más distancia',
    'q3': '50 N',
    'q7': 'El fulcro',
    'q8': 'La dirección de la fuerza aplicada',
    'q9': 'Esfuerzo',
    'q10': 'Más lejos del fulcro, en el extremo del esfuerzo',
    'q11': '2 metros',
    'q12': 'Parte de la energía se convierte en calor por la fricción',
    'q13': 'Una rampa de 3 metros',
  },
};

Map<String, Object> _questionFields(Question question) => {
  'id': question.id,
  'prompt': question.prompt,
  'promptEs': question.promptEs,
  'options': question.options,
  'optionsEs': question.optionsEs,
  'answer': question.answer,
  'points': question.points,
  'kind': question.kind.name,
  'pairs': [for (final pair in question.pairs) pair.toJson()],
  'explanation': question.explanation,
  'explanationEs': question.explanationEs,
};

void main() {
  const repository = LocalLessonRepository();

  for (final entry in _answerKeys.entries) {
    final lessonId = entry.key;

    test(
      '$lessonId question bank has ten bilingual exercises of every type',
      () async {
        final lesson = await repository.fetch(lessonId);
        final mcqs = lesson.questions
            .where((question) => question.kind == QuestionKind.mcq)
            .toList();

        expect(mcqs, hasLength(10));
        expect(lesson.questions, hasLength(40));
        expect(
          lesson.questions.map((question) => question.id).toSet(),
          hasLength(40),
        );
        expect(
          lesson.questions.map((question) => question.prompt).toSet(),
          hasLength(40),
        );
        expect(
          lesson.questions
              .where(
                (question) => const ['q4', 'q5', 'q6'].contains(question.id),
              )
              .map((question) => (question.id, question.kind)),
          [
            ('q4', QuestionKind.blank),
            ('q5', QuestionKind.oddOneOut),
            ('q6', QuestionKind.match),
          ],
        );
        for (final kind in QuestionKind.values) {
          expect(
            lesson.questions.where((question) => question.kind == kind),
            hasLength(10),
            reason: '$lessonId/${kind.name}',
          );
        }

        for (final question in lesson.questions) {
          final reason = '$lessonId/${question.id}';
          expect(question.prompt.trim(), isNotEmpty, reason: reason);
          expect(question.explanation.trim(), isNotEmpty, reason: reason);
          expect(question.hasSpanishTranslation, isTrue, reason: reason);
          expect(question.promptEs.trim(), isNotEmpty, reason: reason);
          expect(question.explanationEs.trim(), isNotEmpty, reason: reason);
          if (question.kind == QuestionKind.match) {
            expect(question.pairs, hasLength(4), reason: reason);
            expect(question.options, isEmpty, reason: reason);
            expect(question.points, 20, reason: reason);
            for (final labels in [
              question.pairs.map((pair) => pair.left),
              question.pairs.map((pair) => pair.right),
              question.pairs.map((pair) => pair.leftEs),
              question.pairs.map((pair) => pair.rightEs),
            ]) {
              expect(
                labels.every((label) => label.trim().isNotEmpty),
                isTrue,
                reason: reason,
              );
              expect(
                labels.map((label) => label.trim().toLowerCase()).toSet(),
                hasLength(4),
                reason: reason,
              );
            }
            continue;
          }
          expect(question.options, hasLength(4), reason: reason);
          expect(question.optionsEs, hasLength(4), reason: reason);
          expect(question.options.toSet(), hasLength(4), reason: reason);
          expect(question.optionsEs.toSet(), hasLength(4), reason: reason);
          expect(
            question.options.every((option) => option.trim().isNotEmpty),
            isTrue,
            reason: reason,
          );
          expect(
            question.answer,
            inInclusiveRange(0, question.options.length - 1),
            reason: reason,
          );
          expect(question.points, 10, reason: reason);
          if (question.kind == QuestionKind.blank) {
            expect(question.prompt.split('___'), hasLength(2), reason: reason);
            expect(
              question.promptEs.split('___'),
              hasLength(2),
              reason: reason,
            );
          }
        }
      },
    );

    test('$lessonId question bank matches the reviewed answer key', () async {
      final lesson = await repository.fetch(lessonId);
      final answers = {
        for (final question in lesson.questions)
          if (question.kind == QuestionKind.mcq)
            question.id: question.options[question.answer],
      };

      expect(answers, entry.value);
    });

    test('$lessonId question bank preserves the Spanish answer key', () async {
      final lesson = await repository.fetch(lessonId);
      final answers = {
        for (final question in lesson.questions)
          if (question.kind == QuestionKind.mcq)
            question.id: question.optionsEs[question.answer],
      };
      expect(answers, _spanishAnswerKeys[lessonId]);
    });

    test('$lessonId question bank seed matches bundled content', () async {
      final bundled = await repository.fetch(lessonId);
      final data =
          jsonDecode(
                await File(
                  '../backend/seed/lessons/$lessonId.json',
                ).readAsString(),
              )
              as Map<String, dynamic>;
      final seeded = Lesson.fromJson(data);

      expect(seeded.id, bundled.id);
      expect(
        seeded.questions.map(_questionFields).toList(),
        equals(bundled.questions.map(_questionFields).toList()),
      );
    });
  }

  test(
    'choice exercises retain reviewed calculation and grammar answers',
    () async {
      final cases = [
        ('motion', 'blank-8', '${3 * 4}', '${3 * 4}'),
        ('forces', 'blank-4', '${10 - 4}', '${10 - 4}'),
        ('gravity', 'blank-5', '${4 * 10}', '${4 * 10}'),
        ('machines', 'blank-6', '${200 ~/ 4}', '${200 ~/ 4}'),
        ('motion', 'blank-10', 'is', 'está'),
        ('forces', 'blank-8', 'are', 'están'),
        ('gravity', 'blank-8', 'pulls', 'atrae'),
        ('machines', 'blank-8', 'is', 'es'),
      ];
      for (final (lessonId, id, english, spanish) in cases) {
        final lesson = await repository.fetch(lessonId);
        final question = lesson.questions.singleWhere(
          (question) => question.id == id,
        );
        expect(
          question.options[question.answer],
          english,
          reason: '$lessonId/$id',
        );
        expect(
          question.optionsEs[question.answer],
          spanish,
          reason: '$lessonId/$id',
        );
      }
    },
  );

  test('calculation matching sets contain correct numeric pairs', () async {
    final cases = [
      ('motion', 'match-5', false),
      ('gravity', 'match-5', true),
      ('gravity', 'match-6', true),
      ('machines', 'match-6', false),
      ('machines', 'match-7', true),
    ];
    for (final (lessonId, id, multiply) in cases) {
      final lesson = await repository.fetch(lessonId);
      final question = lesson.questions.singleWhere(
        (question) => question.id == id,
      );
      for (final pair in question.pairs) {
        final numbers = RegExp(r'\d+')
            .allMatches(pair.left)
            .map((match) => int.parse(match.group(0)!))
            .toList();
        final right = int.parse(
          RegExp(r'\d+').firstMatch(pair.right)!.group(0)!,
        );
        final expected = id == 'match-5' && lessonId == 'gravity'
            ? numbers.single * 10
            : multiply
            ? numbers[0] * numbers[1]
            : numbers[0] / numbers[1];
        expect(right, expected, reason: '$lessonId/$id: ${pair.left}');
      }
    }
  });

  test(
    'matching translations round-trip without changing canonical meanings',
    () {
      const pair = MatchPair(
        left: 'Mass',
        right: 'Amount of matter',
        leftEs: 'Masa',
        rightEs: 'Cantidad de materia',
      );
      final parsed = MatchPair.fromJson(pair.toJson());
      expect(parsed.toJson(), pair.toJson());
      expect(parsed.hasSpanishTranslation, isTrue);
      final legacy = MatchPair.fromJson({'left': 'Mass', 'right': 'Matter'});
      expect(legacy.hasSpanishTranslation, isFalse);
    },
  );

  test(
    'force matching calculations preserve magnitude and direction',
    () async {
      final lesson = await repository.fetch('forces');
      for (final id in ['match-5', 'match-8']) {
        final question = lesson.questions.singleWhere(
          (question) => question.id == id,
        );
        for (final pair in question.pairs) {
          final forces = RegExp(r'(\d+) N (left|right)').allMatches(pair.left);
          final total = forces.fold<int>(0, (sum, force) {
            final magnitude = int.parse(force.group(1)!);
            return sum + (force.group(2) == 'right' ? magnitude : -magnitude);
          });
          if (total == 0) {
            expect(
              RegExp(
                r'\b0\b|\bzero\b',
                caseSensitive: false,
              ).hasMatch(pair.right),
              isTrue,
            );
          } else {
            expect(pair.right, contains('${total.abs()} N'));
            expect(pair.right, contains(total > 0 ? 'right' : 'left'));
            expect(pair.rightEs, contains(total > 0 ? 'derecha' : 'izquierda'));
          }
        }
      }
    },
  );

  test(
    'question bank parsing preserves compatibility with untranslated data',
    () {
      final question = Question.fromJson({
        'id': 'legacy',
        'prompt': 'What is speed?',
        'options': ['Distance divided by time', 'Mass'],
        'answer': 0,
      });
      expect(question.promptEs, isEmpty);
      expect(question.optionsEs, isEmpty);
      expect(question.explanationEs, isEmpty);
      expect(question.hasSpanishTranslation, isFalse);
    },
  );

  test(
    'question bank rejects incomplete Spanish choices as a full translation',
    () {
      const question = Question(
        id: 'incomplete',
        prompt: 'Choose a quantity.',
        promptEs: 'Elige una magnitud.',
        options: ['Speed', 'Mass'],
        optionsEs: ['Velocidad'],
        explanationEs: 'La velocidad describe el movimiento.',
      );
      expect(question.hasSpanishTranslation, isFalse);
    },
  );
}
