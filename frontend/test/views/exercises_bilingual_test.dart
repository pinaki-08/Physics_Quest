import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:physics_quest/data/lesson_repository.dart';
import 'package:physics_quest/models/lesson.dart';
import 'package:physics_quest/services/lesson_narration.dart';
import 'package:physics_quest/services/speech.dart';
import 'package:physics_quest/theme.dart';
import 'package:physics_quest/views/quiz_screen.dart';
import 'package:physics_quest/widgets/practice_drag_card.dart';
import 'package:physics_quest/widgets/vocabulary_text.dart';

Future<(Question, List<MethodCall>)> _pumpExercise(
  WidgetTester tester,
  QuestionKind kind, {
  TargetPlatform platform = TargetPlatform.android,
  Size size = const Size(390, 844),
  List<Question>? exerciseQuestions,
}) async {
  const channel = MethodChannel('flutter_tts');
  final calls = <MethodCall>[];
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(channel, (call) async {
    calls.add(call);
    if (call.method == 'getVoices') {
      return [
        {'name': 'Paulina', 'locale': 'es-MX'},
        {'name': 'Samantha', 'locale': 'en-US'},
      ];
    }
    return 1;
  });
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await TermSpeaker.instance.stop();
    messenger.setMockMethodCallHandler(channel, null);
  });
  final lesson = await const LocalLessonRepository().fetch('motion');
  final questions =
      exerciseQuestions ??
      lesson.questions.where((question) => question.kind == kind).toList();
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme().copyWith(platform: platform),
      home: QuizScreen(
        quizId: '${kind.name}-motion',
        title: lesson.title,
        color: AppColors.learn,
        questions: questions,
        glossary: lesson.glossary,
      ),
    ),
  );
  await tester.pump();
  return (questions.first, calls);
}

Future<void> _top(WidgetTester tester) async {
  final scrollable = find
      .descendant(
        of: find.byType(ListView).first,
        matching: find.byType(Scrollable),
      )
      .first;
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) await _top(tester);
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      250,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

String _cellEnglish(WidgetTester tester, String key) {
  return tester
      .widget<VocabularyText>(
        find.descendant(
          of: find.byKey(ValueKey(key)),
          matching: find.byType(VocabularyText),
        ),
      )
      .text;
}

List<Object?> _spoken(List<MethodCall> calls) => [
  for (final call in calls)
    if (call.method == 'speak') call.arguments,
];

Future<TestGesture> _startMatchingDrag(
  WidgetTester tester,
  int left, {
  PointerDeviceKind kind = PointerDeviceKind.touch,
}) async {
  final progress = find.byKey(const ValueKey('match-progress'));
  await tester.ensureVisible(progress);
  await tester.pumpAndSettle();
  final handle = find.descendant(
    of: find.byKey(ValueKey('match-left-$left')),
    matching: find.byIcon(Icons.drag_indicator_rounded),
  );
  final gesture = await tester.startGesture(
    tester.getCenter(handle),
    kind: kind,
  );
  if (kind == PointerDeviceKind.touch) {
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
    await tester.pump();
  } else {
    await gesture.moveBy(const Offset(24, 0));
    await tester.pump();
  }
  expect(find.byKey(ValueKey('match-drag-feedback-$left')), findsOneWidget);
  return gesture;
}

Future<void> _dropMatchingPair(
  WidgetTester tester,
  int left,
  int right, {
  PointerDeviceKind kind = PointerDeviceKind.touch,
}) async {
  final gesture = await _startMatchingDrag(tester, left, kind: kind);
  final target = find.byKey(ValueKey('match-drop-target-$right'));
  await gesture.moveTo(tester.getCenter(target));
  await tester.pump();
  final material = tester.widget<Material>(
    find
        .descendant(
          of: find.byKey(ValueKey('match-right-$right')),
          matching: find.byType(Material),
        )
        .first,
  );
  expect(
    material.shape,
    isA<RoundedRectangleBorder>().having(
      (shape) => shape.side.color,
      'hover border',
      AppColors.learnDeep,
    ),
  );
  await gesture.up();
  await tester.pumpAndSettle();
  expect(find.byKey(ValueKey('match-drag-feedback-$left')), findsNothing);
}

Future<TestGesture> _startOddDrag(
  WidgetTester tester,
  int index, {
  PointerDeviceKind kind = PointerDeviceKind.touch,
}) async {
  await tester.ensureVisible(find.byKey(const ValueKey('oddOneOut-tray')));
  await tester.pumpAndSettle();
  final handle = find.descendant(
    of: find.byKey(ValueKey('oddOneOut-option-$index')),
    matching: find.byIcon(Icons.drag_indicator_rounded),
  );
  final gesture = await tester.startGesture(
    tester.getCenter(handle),
    kind: kind,
  );
  if (kind == PointerDeviceKind.touch) {
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
    await tester.pump();
  } else {
    await gesture.moveBy(const Offset(0, 24));
    await tester.pump();
  }
  expect(
    find.byKey(ValueKey('oddOneOut-drag-feedback-$index')),
    findsOneWidget,
  );
  return gesture;
}

Future<void> _dropOddCard(
  WidgetTester tester,
  int index, {
  PointerDeviceKind kind = PointerDeviceKind.touch,
}) async {
  final gesture = await _startOddDrag(tester, index, kind: kind);
  await gesture.moveTo(
    tester.getCenter(find.byKey(const ValueKey('oddOneOut-tray'))),
  );
  await tester.pump();
  final surface = tester.widget<Material>(
    find.byKey(const ValueKey('oddOneOut-tray-surface')),
  );
  expect(
    surface.shape,
    isA<RoundedRectangleBorder>().having(
      (shape) => shape.side.color,
      'tray hover border',
      AppColors.learnDeep.withValues(alpha: 0.6),
    ),
  );
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  for (final (platform, pointer, size) in [
    (TargetPlatform.android, PointerDeviceKind.touch, const Size(390, 844)),
    (TargetPlatform.macOS, PointerDeviceKind.mouse, const Size(1000, 900)),
  ]) {
    testWidgets(
      'odd tray accepts ${pointer.name} drags and groups the remaining words',
      (tester) async {
        final (question, calls) = await _pumpExercise(
          tester,
          QuestionKind.oddOneOut,
          platform: platform,
          size: size,
        );
        final words = [
          for (var index = 0; index < 4; index++)
            _cellEnglish(tester, 'oddOneOut-option-$index'),
        ];
        final correct = words.indexOf(question.options[question.answer]);
        await _dropOddCard(tester, correct, kind: pointer);
        expect(find.byKey(ValueKey('oddOneOut-option-$correct')), findsNothing);
        expect(find.byType(PracticeDragCard), findsNWidgets(3));
        expect(find.text('These 3 cards belong together.'), findsOneWidget);
        expect(find.text('Odd card found'), findsOneWidget);
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('oddOneOut-tray-word')))
              .data,
          question.options[question.answer],
        );
        expect(find.text('+10 points'), findsOneWidget);
        final english =
            'The card "${question.options[question.answer]}" does not belong in this group. '
            '${question.explanation}';
        final spanish =
            'La tarjeta "${question.optionsEs[question.answer]}" no pertenece a este grupo. '
            '${question.explanationEs}';
        await _tap(
          tester,
          find.byKey(const ValueKey('oddOneOut-explanation-audio-en')),
        );
        await _tap(
          tester,
          find.byKey(const ValueKey('oddOneOut-explanation-audio-es')),
        );
        expect(_spoken(calls), [
          scienceTextNarration(english, spanish: false),
          scienceTextNarration(spanish, spanish: true),
        ]);
        await _tap(
          tester,
          find.byKey(const ValueKey('oddOneOut-language-toggle')),
        );
        expect(
          find.text('Estas 3 tarjetas pertenecen al mismo grupo.'),
          findsOneWidget,
        );
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('oddOneOut-tray-word')))
              .data,
          question.optionsEs[question.answer],
        );
        expect(find.text(spanish), findsOneWidget);
        expect(find.byType(PracticeDragCard), findsNWidgets(3));
        await tester.pump(const Duration(seconds: 61));
        await _top(tester);
        expect(find.text('1/10'), findsOneWidget);
        expect(find.text('No timer'), findsOneWidget);
        await _tap(
          tester,
          find.byKey(const ValueKey('oddOneOut-next-question')),
        );
        await _top(tester);
        expect(find.text('2/10'), findsOneWidget);
        expect(find.byType(PracticeDragCard), findsNWidgets(4));
        expect(find.byKey(const ValueKey('oddOneOut-tray-word')), findsNothing);
      },
    );
  }

  testWidgets('odd tray returns wrong cards and preserves retry scoring', (
    tester,
  ) async {
    final (question, _) = await _pumpExercise(tester, QuestionKind.oddOneOut);
    final words = [
      for (var index = 0; index < 4; index++)
        _cellEnglish(tester, 'oddOneOut-option-$index'),
    ];
    final correct = words.indexOf(question.options[question.answer]);
    final wrong = (correct + 1) % 4;
    await _dropOddCard(tester, wrong);
    expect(find.byKey(ValueKey('oddOneOut-option-$wrong')), findsOneWidget);
    expect(find.byKey(const ValueKey('oddOneOut-tray-word')), findsNothing);
    expect(find.textContaining('2 tries left'), findsOneWidget);
    expect(
      tester
          .widget<Draggable<int>>(
            find.byKey(ValueKey('oddOneOut-drag-source-$wrong')),
          )
          .maxSimultaneousDrags,
      0,
    );
    await _dropOddCard(tester, correct);
    expect(find.text('+5 points'), findsOneWidget);
    await _top(tester);
    expect(find.byIcon(Icons.favorite_rounded), findsNWidgets(3));
  });

  testWidgets('odd tray cancelled and outside drops do not cost attempts', (
    tester,
  ) async {
    await _pumpExercise(tester, QuestionKind.oddOneOut);
    final drag = await _startOddDrag(tester, 0);
    await drag.moveTo(const Offset(6, 120));
    await tester.pump();
    await drag.up();
    await tester.pumpAndSettle();
    expect(find.byType(PracticeDragCard), findsNWidgets(4));
    expect(find.byKey(const ValueKey('oddOneOut-tray-word')), findsNothing);
    expect(find.textContaining('tries left'), findsNothing);
    expect(
      tester
          .widget<TextButton>(
            find.byKey(const ValueKey('oddOneOut-move-to-tray')),
          )
          .onPressed,
      isNull,
    );
    final cancelled = await _startOddDrag(tester, 0);
    await cancelled.cancel();
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('oddOneOut-drag-feedback-0')),
      findsNothing,
    );
    expect(find.textContaining('tries left'), findsNothing);
  });

  testWidgets('odd tray language help is independent of tap selection', (
    tester,
  ) async {
    final (question, calls) = await _pumpExercise(
      tester,
      QuestionKind.oddOneOut,
    );
    final words = [
      for (var index = 0; index < 4; index++)
        _cellEnglish(tester, 'oddOneOut-option-$index'),
    ];
    final correct = words.indexOf(question.options[question.answer]);
    await _tap(
      tester,
      find.byKey(ValueKey('oddOneOut-option-$correct-audio-menu')),
    );
    await _tap(
      tester,
      find.byKey(ValueKey('oddOneOut-option-$correct-audio-es')),
    );
    expect(_spoken(calls), [
      scienceTextNarration(question.optionsEs[question.answer], spanish: true),
    ]);
    expect(
      tester
          .widget<TextButton>(
            find.byKey(const ValueKey('oddOneOut-move-to-tray')),
          )
          .onPressed,
      isNull,
    );
    await _tap(tester, find.byKey(const ValueKey('vocabulary-speed')).first);
    expect(find.text('Velocidad'), findsOneWidget);
    await _tap(tester, find.byTooltip('Close'));
    await _tap(
      tester,
      find.byKey(ValueKey('oddOneOut-option-$correct-select')),
    );
    expect(find.text('+10 points'), findsNothing);
    expect(find.byKey(const ValueKey('oddOneOut-check-answer')), findsNothing);
    await _tap(tester, find.byKey(const ValueKey('oddOneOut-language-toggle')));
    expect(
      find.descendant(
        of: find.byKey(ValueKey('oddOneOut-option-$correct')),
        matching: find.text(question.optionsEs[question.answer]),
      ),
      findsOneWidget,
    );
    await _tap(tester, find.byKey(const ValueKey('oddOneOut-move-to-tray')));
    expect(find.text('+10 points'), findsOneWidget);
    expect(find.byKey(const ValueKey('oddOneOut-tray-word')), findsOneWidget);
  });

  testWidgets(
    'odd tray reveals the answer honestly after all attempts are used',
    (tester) async {
      final (question, _) = await _pumpExercise(tester, QuestionKind.oddOneOut);
      final words = [
        for (var index = 0; index < 4; index++)
          _cellEnglish(tester, 'oddOneOut-option-$index'),
      ];
      final correct = words.indexOf(question.options[question.answer]);
      for (var index = 0; index < 4; index++) {
        if (index == correct) continue;
        await _tap(
          tester,
          find.byKey(ValueKey('oddOneOut-option-$index-select')),
        );
        await _tap(
          tester,
          find.byKey(const ValueKey('oddOneOut-move-to-tray')),
        );
      }
      expect(find.text('Odd card revealed'), findsOneWidget);
      expect(find.text('Odd card found'), findsNothing);
      expect(find.textContaining('Out of tries'), findsOneWidget);
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('oddOneOut-tray-word')))
            .data,
        question.options[question.answer],
      );
      await _top(tester);
      expect(find.byIcon(Icons.favorite_rounded), findsNWidgets(2));
    },
  );

  for (final (platform, pointer, size) in [
    (TargetPlatform.android, PointerDeviceKind.touch, const Size(390, 844)),
    (TargetPlatform.macOS, PointerDeviceKind.mouse, const Size(1000, 900)),
  ]) {
    testWidgets(
      'matching accepts real ${pointer.name} drags and locks correct pairs',
      (tester) async {
        await _pumpExercise(
          tester,
          QuestionKind.match,
          platform: platform,
          size: size,
        );
        await _dropMatchingPair(tester, 0, 0, kind: pointer);
        expect(find.text('1/4 matched'), findsOneWidget);
        expect(
          tester
              .widget<Draggable<int>>(
                find.byKey(const ValueKey('match-drag-source-0')),
              )
              .maxSimultaneousDrags,
          0,
        );
        expect(
          tester
              .widget<TextButton>(
                find.byKey(const ValueKey('match-right-0-select')),
              )
              .onPressed,
          isNull,
        );

        await _tap(tester, find.byKey(const ValueKey('match-language-toggle')));
        expect(find.text('1/4 parejas'), findsOneWidget);
        await _dropMatchingPair(tester, 1, 1, kind: pointer);
        expect(find.text('2/4 parejas'), findsOneWidget);
        await _dropMatchingPair(tester, 2, 2, kind: pointer);
        await _dropMatchingPair(tester, 3, 3, kind: pointer);
        expect(find.text('4/4 parejas'), findsOneWidget);
        expect(find.text('+20 points'), findsOneWidget);
        await _tap(tester, find.byKey(const ValueKey('match-language-toggle')));
        await _tap(tester, find.text('Next round'));
        await _top(tester);
        expect(find.text('Round 2 of 10'), findsOneWidget);
        expect(find.text('0/4 matched'), findsOneWidget);
      },
    );
  }

  testWidgets('matching rejects wrong drops and allows a correct retry', (
    tester,
  ) async {
    await _pumpExercise(tester, QuestionKind.match);
    await _dropMatchingPair(tester, 0, 1);
    expect(find.text('Try a different pair.'), findsOneWidget);
    expect(find.text('0/4 matched'), findsOneWidget);
    await _dropMatchingPair(tester, 0, 0);
    expect(find.text('Try a different pair.'), findsNothing);
    expect(find.text('1/4 matched'), findsOneWidget);

    final gesture = await _startMatchingDrag(tester, 1);
    await gesture.moveTo(
      tester.getCenter(find.byKey(const ValueKey('match-drop-target-0'))),
    );
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('1/4 matched'), findsOneWidget);
    expect(
      tester
          .widget<Draggable<int>>(
            find.byKey(const ValueKey('match-drag-source-1')),
          )
          .maxSimultaneousDrags,
      1,
    );
    await _top(tester);
    expect(find.byIcon(Icons.favorite_rounded), findsNWidgets(3));
  });

  testWidgets(
    'matching cancels drags outside targets without selecting a pair',
    (tester) async {
      await _pumpExercise(tester, QuestionKind.match);
      final gesture = await _startMatchingDrag(tester, 0);
      await gesture.moveTo(const Offset(8, 120));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('0/4 matched'), findsOneWidget);
      expect(find.byKey(const ValueKey('match-drag-feedback-0')), findsNothing);
      await _tap(tester, find.byKey(const ValueKey('match-right-0-select')));
      expect(find.text('0/4 matched'), findsOneWidget);

      final cancelled = await _startMatchingDrag(tester, 0);
      await cancelled.cancel();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('match-drag-feedback-0')), findsNothing);
      await _dropMatchingPair(tester, 0, 0);
      expect(find.text('1/4 matched'), findsOneWidget);
    },
  );

  testWidgets('matching words still allow normal vertical touch scrolling', (
    tester,
  ) async {
    await _pumpExercise(tester, QuestionKind.match);
    final scroll = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position;
    final source = find.byKey(const ValueKey('match-left-0'));
    await tester.ensureVisible(source);
    await tester.pumpAndSettle();
    final before = scroll.pixels;
    await tester.dragFrom(tester.getCenter(source), const Offset(0, 100));
    await tester.pumpAndSettle();
    expect(scroll.pixels, lessThan(before));
    expect(find.byType(LongPressDraggable<int>), findsNWidgets(4));
    expect(find.byKey(const ValueKey('match-drag-feedback-0')), findsNothing);
    expect(find.text('0/4 matched'), findsOneWidget);
  });

  testWidgets(
    'matching drags auto-scroll long boards and stop when cancelled',
    (tester) async {
      final pairs = [
        for (var index = 0; index < 4; index++)
          MatchPair(
            left:
                'Term $index with enough readable words to fill several lines '
                'on a narrow phone and make the board scroll vertically.',
            right:
                'Meaning $index with a detailed explanation that stays visible '
                'without truncation while a word is dragged across the board.',
            leftEs:
                'Término $index con una descripción larga para la pantalla.',
            rightEs: 'Significado $index con una explicación larga y legible.',
          ),
      ];
      await _pumpExercise(
        tester,
        QuestionKind.match,
        exerciseQuestions: [
          Question(
            id: 'long-matching',
            kind: QuestionKind.match,
            prompt: 'Match each term to its meaning.',
            promptEs: 'Relaciona cada término con su significado.',
            pairs: pairs,
            explanation: 'Each term has a corresponding meaning.',
            explanationEs: 'Cada término tiene un significado correspondiente.',
          ),
        ],
      );
      final handle = find.descendant(
        of: find.byKey(const ValueKey('match-left-0')),
        matching: find.byIcon(Icons.drag_indicator_rounded),
      );
      await tester.ensureVisible(handle);
      await tester.pumpAndSettle();
      final scroll = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position;
      final before = scroll.pixels;
      final gesture = await tester.startGesture(tester.getCenter(handle));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
      await tester.pump();
      expect(
        find.byKey(const ValueKey('match-drag-feedback-0')),
        findsOneWidget,
      );
      await gesture.moveTo(const Offset(300, 842));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(scroll.pixels, greaterThan(before));
      await gesture.cancel();
      await tester.pumpAndSettle();
      final stopped = scroll.pixels;
      await tester.pump(const Duration(seconds: 1));
      expect(scroll.pixels, stopped);
      expect(find.byKey(const ValueKey('match-drag-feedback-0')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final kind in [QuestionKind.blank]) {
    testWidgets(
      '${kind.title} has bilingual audio and waits for Check answer',
      (tester) async {
        final (question, calls) = await _pumpExercise(tester, kind);
        final prefix = kind.name;
        final english = [
          for (var index = 0; index < question.options.length; index++)
            _cellEnglish(tester, '$prefix-option-$index'),
        ];
        final correctSlot = english.indexOf(question.options[question.answer]);
        await _tap(tester, find.byKey(ValueKey('$prefix-prompt-audio-en')));
        await _tap(tester, find.byKey(ValueKey('$prefix-prompt-audio-es')));
        expect(_spoken(calls), [
          scienceTextNarration(question.prompt, spanish: false),
          scienceTextNarration(question.promptEs, spanish: true),
        ]);

        await _tap(
          tester,
          find.byKey(ValueKey('$prefix-option-$correctSlot-select')),
        );
        expect(find.text('+10 points'), findsNothing);
        if (kind == QuestionKind.blank) {
          expect(
            tester
                .widget<VocabularyText>(find.byKey(ValueKey('$prefix-prompt')))
                .blankFill,
            question.options[question.answer],
          );
        }
        await _tap(tester, find.byKey(ValueKey('$prefix-language-toggle')));
        for (var index = 0; index < english.length; index++) {
          final sourceIndex = question.options.indexOf(english[index]);
          expect(
            find.descendant(
              of: find.byKey(ValueKey('$prefix-option-$index')),
              matching: find.text(question.optionsEs[sourceIndex]),
            ),
            findsOneWidget,
          );
        }
        if (kind == QuestionKind.blank) {
          expect(
            tester
                .widget<VocabularyText>(find.byKey(ValueKey('$prefix-prompt')))
                .blankFill,
            question.optionsEs[question.answer],
          );
        }
        await _tap(tester, find.byKey(ValueKey('$prefix-check-answer')));
        expect(find.text('+10 points'), findsOneWidget);
        expect(find.text(question.explanationEs), findsOneWidget);
        await tester.pump(const Duration(seconds: 61));
        await _top(tester);
        expect(find.text('No timer'), findsOneWidget);
        expect(find.text('1/10'), findsOneWidget);
        expect(find.byIcon(Icons.favorite_rounded), findsNWidgets(3));
        await _tap(tester, find.byKey(ValueKey('$prefix-next-question')));
        await _top(tester);
        expect(find.text('2/10'), findsOneWidget);
      },
    );

    testWidgets(
      '${kind.title} audio menus and vocabulary do not submit answers',
      (tester) async {
        final (question, calls) = await _pumpExercise(tester, kind);
        final prefix = kind.name;
        final english = _cellEnglish(tester, '$prefix-option-0');
        final sourceIndex = question.options.indexOf(english);
        await _tap(tester, find.byKey(ValueKey('$prefix-option-0-audio-menu')));
        await _tap(tester, find.byKey(ValueKey('$prefix-option-0-audio-es')));
        expect(_spoken(calls), [
          scienceTextNarration(question.optionsEs[sourceIndex], spanish: true),
        ]);
        expect(
          tester
              .widget<RadioGroup<int>>(find.byType(RadioGroup<int>))
              .groupValue,
          isNull,
        );
        expect(
          tester
              .widget<FilledButton>(
                find.byKey(ValueKey('$prefix-check-answer')),
              )
              .onPressed,
          isNull,
        );
        final highlighted = find
            .byKey(const ValueKey('vocabulary-speed'))
            .first;
        await _tap(tester, highlighted);
        expect(find.text('Velocidad'), findsOneWidget);
        await _tap(tester, find.byTooltip('Close'));
        expect(find.text('Next question'), findsNothing);
      },
    );
  }

  testWidgets('matching selection and solved pairs survive language changes', (
    tester,
  ) async {
    final (question, _) = await _pumpExercise(tester, QuestionKind.match);
    expect(find.text('0/4 matched'), findsOneWidget);
    final first = question.pairs.first;
    final left = [
      for (var index = 0; index < question.pairs.length; index++)
        _cellEnglish(tester, 'match-left-$index'),
    ].indexOf(first.left);
    final right = [
      for (var index = 0; index < question.pairs.length; index++)
        _cellEnglish(tester, 'match-right-$index'),
    ].indexOf(first.right);

    await _tap(tester, find.byKey(ValueKey('match-left-$left-select')));
    await _tap(tester, find.byKey(const ValueKey('match-language-toggle')));
    await _tap(tester, find.byKey(ValueKey('match-right-$right-select')));
    expect(find.text('1/4 parejas'), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('match-language-toggle')));
    expect(find.text('1/4 matched'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.byKey(ValueKey('match-left-$left-select')))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<TextButton>(find.byKey(ValueKey('match-right-$right-select')))
          .onPressed,
      isNull,
    );
    expect(find.text('+20 points'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'matching audio does not select pairs and completion is self-paced',
    (tester) async {
      final (question, calls) = await _pumpExercise(tester, QuestionKind.match);
      final leftTexts = [
        for (var index = 0; index < question.pairs.length; index++)
          _cellEnglish(tester, 'match-left-$index'),
      ];
      final rightTexts = [
        for (var index = 0; index < question.pairs.length; index++)
          _cellEnglish(tester, 'match-right-$index'),
      ];
      final firstPair = question.pairs.singleWhere(
        (pair) => pair.left == leftTexts.first,
      );
      await _tap(
        tester,
        find.byKey(const ValueKey('match-left-option-0-audio-menu')),
      );
      await _tap(
        tester,
        find.byKey(const ValueKey('match-left-option-0-audio-es')),
      );
      expect(_spoken(calls), [
        scienceTextNarration(firstPair.leftEs, spanish: true),
      ]);
      expect(find.text('0/4 matched'), findsOneWidget);
      for (var index = 0; index < leftTexts.length; index++) {
        final pair = question.pairs.singleWhere(
          (pair) => pair.left == leftTexts[index],
        );
        final right = rightTexts.indexOf(pair.right);
        await _tap(tester, find.byKey(ValueKey('match-left-$index-select')));
        await _tap(tester, find.byKey(ValueKey('match-right-$right-select')));
      }
      expect(find.text('4/4 matched'), findsOneWidget);
      expect(find.text('+20 points'), findsOneWidget);
      await _tap(
        tester,
        find.byKey(const ValueKey('match-explanation-audio-es')),
      );
      expect(
        _spoken(calls).last,
        scienceTextNarration(question.explanationEs, spanish: true),
      );
      await tester.pump(const Duration(seconds: 61));
      await _top(tester);
      expect(find.text('Round 1 of 10'), findsOneWidget);
      expect(find.text('No timer'), findsOneWidget);
      await _tap(tester, find.byKey(const ValueKey('match-next-question')));
      await _top(tester);
      expect(find.text('Round 2 of 10'), findsOneWidget);
    },
  );

  testWidgets('matching vocabulary help does not select a pair', (
    tester,
  ) async {
    final (question, _) = await _pumpExercise(tester, QuestionKind.match);
    final speed = [
      for (var index = 0; index < question.pairs.length; index++)
        _cellEnglish(tester, 'match-left-$index'),
    ].indexOf('Speed');
    final word = find.descendant(
      of: find.byKey(ValueKey('match-left-$speed')),
      matching: find.byKey(const ValueKey('vocabulary-speed')),
    );
    await _tap(tester, word);
    expect(find.text('Velocidad'), findsOneWidget);
    await _tap(tester, find.byTooltip('Close'));
    await _tap(tester, find.byKey(ValueKey('match-right-$speed-select')));
    expect(find.text('0/4 matched'), findsOneWidget);
    expect(find.text('+20 points'), findsNothing);
  });

  testWidgets('matching exposes all ten rounds with four pairs each', (
    tester,
  ) async {
    await _pumpExercise(tester, QuestionKind.match);
    final lesson = await const LocalLessonRepository().fetch('motion');
    final rounds = lesson.questions
        .where((question) => question.kind == QuestionKind.match)
        .toList();
    expect(rounds, hasLength(10));

    for (var round = 0; round < rounds.length; round++) {
      await _top(tester);
      expect(find.text('Round ${round + 1} of 10'), findsOneWidget);
      expect(
        tester
            .widget<VocabularyText>(find.byKey(const ValueKey('match-prompt')))
            .text,
        rounds[round].prompt,
      );
      expect(rounds[round].pairs, hasLength(4));
      expect(
        find.textContaining('Match these 4 pairs to finish this round.'),
        findsOneWidget,
      );
      final leftTexts = [
        for (var index = 0; index < 4; index++)
          _cellEnglish(tester, 'match-left-$index'),
      ];
      final rightTexts = [
        for (var index = 0; index < 4; index++)
          _cellEnglish(tester, 'match-right-$index'),
      ];
      for (var index = 0; index < 4; index++) {
        final pair = rounds[round].pairs.singleWhere(
          (pair) => pair.left == leftTexts[index],
        );
        final right = rightTexts.indexOf(pair.right);
        await _tap(tester, find.byKey(ValueKey('match-left-$index-select')));
        await _tap(tester, find.byKey(ValueKey('match-right-$right-select')));
      }
      expect(find.text('4/4 matched'), findsOneWidget);

      if (round + 1 < rounds.length) {
        await _tap(tester, find.text('Next round'));
      } else {
        final result = find.text('See result');
        await tester.scrollUntilVisible(
          result,
          250,
          scrollable: find.byType(Scrollable).first,
        );
        expect(result, findsOneWidget);
        expect(find.text('Next round'), findsNothing);
      }
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'matching lets students retry an incorrect pair without losing work',
    (tester) async {
      await _pumpExercise(tester, QuestionKind.match);
      await _tap(tester, find.byKey(const ValueKey('match-left-0-select')));
      await _tap(tester, find.byKey(const ValueKey('match-right-1-select')));
      expect(find.text('Try a different pair.'), findsOneWidget);
      expect(find.text('0/4 matched'), findsOneWidget);
      await _tap(tester, find.byKey(const ValueKey('match-right-0-select')));
      expect(find.text('1/4 matched'), findsOneWidget);
      await _top(tester);
      expect(find.byIcon(Icons.favorite_rounded), findsNWidgets(3));
      expect(find.text('Next question'), findsNothing);
    },
  );
}
