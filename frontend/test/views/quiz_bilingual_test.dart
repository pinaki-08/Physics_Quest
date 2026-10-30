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

Future<(Lesson, List<MethodCall>)> _pumpQuiz(
  WidgetTester tester, {
  List<Question>? questions,
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

  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await TermSpeaker.instance.stop();
    messenger.setMockMethodCallHandler(channel, null);
  });

  final lesson = await const LocalLessonRepository().fetch('motion');
  final mcqs = lesson.questions
      .where((question) => question.kind == QuestionKind.mcq)
      .toList();
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      home: QuizScreen(
        quizId: 'mcq-motion',
        title: lesson.title,
        color: AppColors.learn,
        questions: questions ?? mcqs,
        glossary: lesson.glossary,
      ),
    ),
  );
  await tester.pump();
  return (lesson, calls);
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) await _scrollToTop(tester);
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      300,
      scrollable: find
          .descendant(
            of: find.byType(ListView).first,
            matching: find.byType(Scrollable),
          )
          .first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await _reveal(tester, finder);
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
}

Future<void> _submitOption(WidgetTester tester, int index) async {
  await _tap(tester, find.byKey(ValueKey('mcq-option-$index-select')));
  await _tap(tester, find.byKey(const ValueKey('mcq-check-answer')));
}

Future<void> _playChoiceAudio(
  WidgetTester tester,
  int index, {
  required bool spanish,
}) async {
  await _tap(tester, find.byKey(ValueKey('mcq-option-$index-audio-menu')));
  await _tap(
    tester,
    find.byKey(ValueKey('mcq-option-$index-audio-${spanish ? 'es' : 'en'}')),
  );
}

Future<void> _scrollToTop(WidgetTester tester) async {
  final scrollable = find
      .descendant(
        of: find.byType(ListView).first,
        matching: find.byType(Scrollable),
      )
      .first;
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pump();
}

String _englishOption(WidgetTester tester, int index) {
  final content = find.descendant(
    of: find.byKey(ValueKey('mcq-option-$index')),
    matching: find.byType(VocabularyText),
  );
  return tester.widget<VocabularyText>(content).text;
}

List<Object?> _spoken(List<MethodCall> calls) => [
  for (final call in calls)
    if (call.method == 'speak') call.arguments,
];

void main() {
  testWidgets(
    'MCQ layout keeps short questions and answers compact on phones',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await _pumpQuiz(tester);
        expect(find.text('Choose'), findsNothing);
        expect(find.text('Elegir'), findsNothing);
        expect(find.byType(Radio<int>), findsNWidgets(4));
        expect(find.byType(PopupMenuButton<bool>), findsNWidgets(4));
        for (var index = 0; index < 4; index++) {
          expect(
            find.byKey(ValueKey('mcq-option-$index-audio-en')),
            findsNothing,
          );
          expect(
            tester.getSize(find.byKey(ValueKey('mcq-option-$index'))).height,
            lessThanOrEqualTo(80),
          );
          expect(
            tester
                .getSemantics(find.byKey(ValueKey('mcq-option-$index-select')))
                .getSemanticsData()
                .label,
            _englishOption(tester, index),
          );
        }
        final check = find.byKey(const ValueKey('mcq-check-answer'));
        expect(tester.widget<FilledButton>(check).onPressed, isNull);
        expect(tester.getRect(check).bottom, lessThanOrEqualTo(844));

        await _tap(tester, find.byKey(const ValueKey('mcq-language-toggle')));
        expect(tester.getRect(check).bottom, lessThanOrEqualTo(844));
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets('MCQ desktop layout is centered and capped at 720 pixels', (
    tester,
  ) async {
    await _pumpQuiz(tester);
    tester.view.physicalSize = const Size(1280, 900);
    await tester.pumpAndSettle();

    final content = find.byKey(const ValueKey('quiz-content'));
    expect(tester.getSize(content).width, 720);
    expect(tester.getRect(content).center.dx, closeTo(640, 1));
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      AppColors.lessonBackground,
    );
  });

  testWidgets('MCQ answer selection waits for Check answer', (tester) async {
    final (lesson, _) = await _pumpQuiz(tester);
    final question = lesson.questions.first;
    final slot = [
      for (var index = 0; index < question.options.length; index++)
        _englishOption(tester, index),
    ].indexOf(question.options[question.answer]);
    final check = find.byKey(const ValueKey('mcq-check-answer'));

    await _tap(tester, find.byKey(ValueKey('mcq-option-$slot-select')));
    expect(
      tester.widget<RadioGroup<int>>(find.byType(RadioGroup<int>)).groupValue,
      slot,
    );
    expect(tester.widget<FilledButton>(check).onPressed, isNotNull);
    expect(find.text('+10 points'), findsNothing);
    expect(
      find.byKey(const ValueKey('mcq-explanation-audio-en')),
      findsNothing,
    );
    await _tap(tester, find.byKey(const ValueKey('mcq-language-toggle')));
    expect(
      tester.widget<RadioGroup<int>>(find.byType(RadioGroup<int>)).groupValue,
      slot,
    );
    await _playChoiceAudio(tester, slot, spanish: true);
    expect(
      tester.widget<RadioGroup<int>>(find.byType(RadioGroup<int>)).groupValue,
      slot,
    );
    await _tap(tester, check);
    expect(find.text('+10 points'), findsOneWidget);
  });

  testWidgets('MCQ audio reads both languages without choosing an answer', (
    tester,
  ) async {
    final (lesson, calls) = await _pumpQuiz(tester);
    final question = lesson.questions.first;
    expect(find.text('No timer'), findsOneWidget);

    await _tap(tester, find.byKey(const ValueKey('mcq-prompt-audio-en')));
    await _tap(tester, find.byKey(const ValueKey('mcq-prompt-audio-es')));
    expect(_spoken(calls), [question.prompt, question.promptEs]);

    final expectedChoices = <String>[];
    for (var index = 0; index < question.options.length; index++) {
      final english = _englishOption(tester, index);
      final sourceIndex = question.options.indexOf(english);
      expectedChoices.add(
        scienceTextNarration(question.optionsEs[sourceIndex], spanish: true),
      );
      await _playChoiceAudio(tester, index, spanish: true);
    }
    expect(_spoken(calls).skip(2), expectedChoices);
    expect(
      tester.widget<RadioGroup<int>>(find.byType(RadioGroup<int>)).groupValue,
      isNull,
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('mcq-check-answer')))
          .onPressed,
      isNull,
    );
    await _scrollToTop(tester);
    expect(find.text('1/10'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsNWidgets(3));
    expect(
      find.byKey(const ValueKey('mcq-explanation-audio-en')),
      findsNothing,
    );
    expect(find.text('Next question'), findsNothing);
  });

  testWidgets('MCQ translation keeps shuffled answers and scoring aligned', (
    tester,
  ) async {
    final (lesson, calls) = await _pumpQuiz(tester);
    final question = lesson.questions.first;
    final englishChoices = [
      for (var index = 0; index < question.options.length; index++)
        _englishOption(tester, index),
    ];
    final correctIndex = englishChoices.indexOf(
      question.options[question.answer],
    );

    await _tap(tester, find.byKey(const ValueKey('mcq-language-toggle')));
    expect(find.text(question.promptEs), findsOneWidget);
    for (var index = 0; index < englishChoices.length; index++) {
      final originalIndex = question.options.indexOf(englishChoices[index]);
      expect(
        find.descendant(
          of: find.byKey(ValueKey('mcq-option-$index')),
          matching: find.text(question.optionsEs[originalIndex]),
        ),
        findsOneWidget,
      );
    }

    await _submitOption(tester, correctIndex);
    expect(find.text('+10 points'), findsOneWidget);
    expect(find.text(question.explanationEs), findsOneWidget);
    expect(find.text('Explicación'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await _scrollToTop(tester);
    expect(find.text('1/10'), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('mcq-explanation-audio-en')));
    await _tap(tester, find.byKey(const ValueKey('mcq-explanation-audio-es')));
    expect(_spoken(calls), [
      'The answer is ${question.options[question.answer]}. '
          '${question.explanation}',
      'La respuesta es ${question.optionsEs[question.answer]}. '
          '${question.explanationEs}',
    ]);

    final stopsBeforeNext = calls.where((call) => call.method == 'stop').length;
    await _tap(tester, find.text('Next question'));
    await tester.pumpAndSettle();
    await _scrollToTop(tester);
    expect(find.text('2/10'), findsOneWidget);
    expect(
      tester
          .widget<VocabularyText>(find.byKey(const ValueKey('mcq-prompt')))
          .text,
      lesson.questions[1].prompt,
    );
    expect(
      calls.where((call) => call.method == 'stop').length,
      greaterThan(stopsBeforeNext),
    );
  });

  testWidgets('MCQ physics vocabulary has bilingual audio and no time limit', (
    tester,
  ) async {
    final (_, calls) = await _pumpQuiz(tester);
    await tester.pump(const Duration(seconds: 61));
    expect(find.text('No timer'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsNWidgets(3));
    expect(find.textContaining('Out of time'), findsNothing);

    await _tap(tester, find.byKey(const ValueKey('vocabulary-speed')));
    expect(find.text('Speed'), findsOneWidget);
    expect(find.text('Velocidad'), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('vocabulary-audio-en')));
    await _tap(tester, find.byKey(const ValueKey('vocabulary-audio-es')));
    expect(_spoken(calls), ['Speed', 'Velocidad']);

    await _tap(tester, find.byTooltip('Close'));
    await _scrollToTop(tester);
    expect(find.text('1/10'), findsOneWidget);
    expect(find.text('Next question'), findsNothing);
  });

  testWidgets('MCQ option vocabulary does not submit the answer', (
    tester,
  ) async {
    final lesson = await const LocalLessonRepository().fetch('motion');
    final question = lesson.questions.firstWhere(
      (question) => question.id == 'q3',
    );
    final (_, calls) = await _pumpQuiz(
      tester,
      questions: [question, lesson.questions.first],
    );
    final slot = [
      for (var index = 0; index < question.options.length; index++)
        _englishOption(tester, index),
    ].indexOf('Acceleration');
    final vocabulary = find.descendant(
      of: find.byKey(ValueKey('mcq-option-$slot')),
      matching: find.byKey(const ValueKey('vocabulary-acceleration')),
    );

    await _tap(tester, vocabulary);
    expect(find.text('Aceleración'), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('vocabulary-audio-es')));
    expect(_spoken(calls), ['Aceleración']);
    await _tap(tester, find.byTooltip('Close'));
    expect(
      tester
          .widget<Radio<int>>(find.byKey(ValueKey('mcq-option-$slot-select')))
          .enabled,
      isTrue,
    );

    expect(
      tester.widget<RadioGroup<int>>(find.byType(RadioGroup<int>)).groupValue,
      isNull,
    );
    await _submitOption(tester, slot);
    await _reveal(tester, find.text('+10 points'));
    expect(find.text('+10 points'), findsOneWidget);
  });

  testWidgets('MCQ language changes preserve attempts and partial credit', (
    tester,
  ) async {
    final (lesson, _) = await _pumpQuiz(tester);
    final question = lesson.questions.first;
    final choices = [
      for (var index = 0; index < question.options.length; index++)
        _englishOption(tester, index),
    ];
    final correct = choices.indexOf(question.options[question.answer]);
    final wrong = (correct + 1) % choices.length;

    await _submitOption(tester, wrong);
    await _reveal(tester, find.textContaining('2 tries left'));
    expect(find.textContaining('2 tries left'), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('mcq-language-toggle')));
    expect(
      tester
          .widget<Radio<int>>(find.byKey(ValueKey('mcq-option-$wrong-select')))
          .enabled,
      isFalse,
    );
    await _submitOption(tester, correct);
    await _reveal(tester, find.text('+5 points'));
    expect(find.text('+5 points'), findsOneWidget);
    await _scrollToTop(tester);
    expect(find.byIcon(Icons.favorite_rounded), findsNWidgets(3));
  });

  testWidgets('rapid Next taps cannot skip an unanswered MCQ', (tester) async {
    final (lesson, _) = await _pumpQuiz(tester);
    final question = lesson.questions.first;
    final slot = [
      for (var index = 0; index < question.options.length; index++)
        _englishOption(tester, index),
    ].indexOf(question.options[question.answer]);
    await _submitOption(tester, slot);
    final next = find.text('Next question');
    if (next.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        next,
        300,
        scrollable: find.byType(Scrollable).first,
      );
    }
    await tester.ensureVisible(next);
    await tester.pump();
    await tester.tap(next);
    await tester.tap(next);
    await tester.pumpAndSettle();
    await _scrollToTop(tester);
    expect(find.text('2/10'), findsOneWidget);
  });

  testWidgets('untranslated MCQs explicitly disable Spanish support', (
    tester,
  ) async {
    await _pumpQuiz(
      tester,
      questions: const [
        Question(
          id: 'legacy',
          prompt: 'Choose a quantity.',
          options: ['Speed', 'Force', 'Mass', 'Time'],
        ),
      ],
    );
    expect(
      find.text('Spanish translation is not available for this question yet.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('mcq-language-toggle')), findsNothing);
    expect(
      tester
          .widget<TextButton>(find.byKey(const ValueKey('mcq-prompt-audio-es')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('other Practice activities are now bilingual and self-paced', (
    tester,
  ) async {
    final lesson = await const LocalLessonRepository().fetch('motion');
    final blank = lesson.questions.firstWhere(
      (question) => question.kind == QuestionKind.blank,
    );
    await _pumpQuiz(tester, questions: [blank]);
    expect(find.text('No timer'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byKey(const ValueKey('blank-language-toggle')), findsOneWidget);

    await tester.pump(const Duration(seconds: 61));
    expect(find.textContaining('Out of time'), findsNothing);
    expect(find.byIcon(Icons.favorite_rounded), findsNWidgets(3));
  });
}
