import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:physics_quest/data/lesson_repository.dart';
import 'package:physics_quest/models/lesson.dart';
import 'package:physics_quest/services/lesson_narration.dart';
import 'package:physics_quest/services/speech.dart';
import 'package:physics_quest/theme.dart';
import 'package:physics_quest/views/quiz_screen.dart';
import 'package:physics_quest/widgets/vocabulary_text.dart';

Future<(Question, List<MethodCall>)> _pumpExercise(
  WidgetTester tester,
  QuestionKind kind,
) async {
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
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await TermSpeaker.instance.stop();
    messenger.setMockMethodCallHandler(channel, null);
  });
  final lesson = await const LocalLessonRepository().fetch('motion');
  final questions = lesson.questions
      .where((question) => question.kind == kind)
      .toList();
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
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

void main() {
  for (final kind in [QuestionKind.blank, QuestionKind.oddOneOut]) {
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
      expect(find.text('1/10'), findsOneWidget);
      expect(find.text('No timer'), findsOneWidget);
      await _tap(tester, find.byKey(const ValueKey('match-next-question')));
      await _top(tester);
      expect(find.text('2/10'), findsOneWidget);
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
