import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:physics_quest/games/motion_tag_arena.dart';
import 'package:physics_quest/games/motion_tag_game.dart';
import 'package:physics_quest/games/motion_tag_model.dart';
import 'package:physics_quest/services/speech.dart';
import 'package:physics_quest/theme.dart';

Future<List<MethodCall>> _pumpGame(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double textScale = 1,
  bool reduced = false,
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
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(const SizedBox.shrink());
    await TermSpeaker.instance.stop();
    messenger.setMockMethodCallHandler(channel, null);
  });
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: reduced,
        ),
        child: child!,
      ),
      home: const MotionTagGame(),
    ),
  );
  await tester.pump();
  return calls;
}

Future<void> _tap(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}

MotionTagRound _round(WidgetTester tester) =>
    tester.widget<MotionTagArena>(find.byType(MotionTagArena)).round;

String _text(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(ValueKey(key))).data!;

List<Object?> _spoken(List<MethodCall> calls) => [
  for (final call in calls)
    if (call.method == 'speak') call.arguments,
];

Future<void> _speed(WidgetTester tester, double desired) async {
  while (_round(tester).speed < desired) {
    await _tap(tester, 'tag-faster');
  }
  while (_round(tester).speed > desired) {
    await _tap(tester, 'tag-slower');
  }
}

Future<void> _steps(WidgetTester tester, int count) async {
  for (var index = 0; index < count; index++) {
    await _tap(tester, 'tag-play');
  }
}

Future<void> _catch(WidgetTester tester) async {
  await _speed(tester, 2);
  await _steps(tester, 4);
  expect(_round(tester).won, isTrue);
}

Future<void> _beside(WidgetTester tester) async {
  await _speed(tester, 2);
  await _steps(tester, 2);
  expect(_round(tester).inPosition, isTrue);
  expect(_round(tester).won, isFalse);
  await _speed(tester, 1);
  await _steps(tester, 3);
  expect(_round(tester).won, isTrue);
}

Future<void> _follow(WidgetTester tester) async {
  await _speed(tester, 1.5);
  await _steps(tester, 4);
  expect(_round(tester).gap, closeTo(2.5, 0.000001));
  await _speed(tester, 1);
  await _steps(tester, 3);
  expect(_round(tester).won, isTrue);
}

void main() {
  testWidgets(
    'Motion Tag opens directly into play without the rejected quiz workflow',
    (tester) async {
      final calls = await _pumpGame(tester);
      expect(find.text('Motion Tag'), findsOneWidget);
      expect(_text(tester, 'tag-goal'), tagMissions.first.instruction);
      expect(_text(tester, 'tag-count'), '1 / 3');
      expect(find.byKey(const ValueKey('tag-play')), findsOneWidget);
      expect(find.byKey(const ValueKey('tag-speed')), findsOneWidget);
      expect(find.textContaining('Predict'), findsNothing);
      expect(find.textContaining('Check explanation'), findsNothing);
      expect(_spoken(calls), isEmpty);
      await tester.pump(const Duration(seconds: 20));
      expect(_round(tester).playerPosition, 0);
      expect(_round(tester).bluePosition, 4);
    },
  );

  testWidgets(
    'Motion Tag normal desktop viewport keeps the goal and play controls on one screen',
    (tester) async {
      const size = Size(732, 607);
      await _pumpGame(tester, size: size);
      for (final key in ['tag-goal', 'tag-speed', 'tag-play', 'tag-reset']) {
        final rect = tester.getRect(find.byKey(ValueKey(key)));
        expect(rect.top, greaterThanOrEqualTo(0), reason: key);
        expect(rect.bottom, lessThanOrEqualTo(size.height), reason: key);
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Motion Tag renders actual robot movement and a closing relative gap',
    (tester) async {
      await _pumpGame(tester);
      await _speed(tester, 2);
      final playerBefore = tester
          .getCenter(find.byKey(const ValueKey('tag-player')))
          .dx;
      final blueBefore = tester
          .getCenter(find.byKey(const ValueKey('tag-blue')))
          .dx;
      await _tap(tester, 'tag-step');
      final playerAfter = tester
          .getCenter(find.byKey(const ValueKey('tag-player')))
          .dx;
      final blueAfter = tester
          .getCenter(find.byKey(const ValueKey('tag-blue')))
          .dx;
      expect(playerAfter, greaterThan(playerBefore));
      expect(blueAfter, greaterThan(blueBefore));
      expect(blueAfter - playerAfter, lessThan(blueBefore - playerBefore));
      expect(_round(tester).playerPosition, 2);
      expect(_round(tester).bluePosition, 5);
      expect(_round(tester).gap, 3);
      expect(_text(tester, 'tag-cue'), TagCue.closing.english);
    },
  );

  testWidgets(
    'Motion Tag speed and stop controls work while robots are moving',
    (tester) async {
      await _pumpGame(tester);
      await _tap(tester, 'tag-play');
      await tester.pump(const Duration(seconds: 1));
      expect(_round(tester).gap, closeTo(4, 0.000001));
      await _speed(tester, 2);
      await tester.pump(const Duration(seconds: 1));
      expect(_round(tester).gap, lessThan(4));
      await _tap(tester, 'tag-stop');
      final player = _round(tester).playerPosition;
      final blue = _round(tester).bluePosition;
      await tester.pump(const Duration(seconds: 1));
      expect(_round(tester).playerPosition, player);
      expect(_round(tester).bluePosition, greaterThan(blue));
      expect(_text(tester, 'tag-cue'), TagCue.stopped.english);
    },
  );

  testWidgets(
    'Motion Tag pause freezes both robots and reset keeps chosen speed',
    (tester) async {
      await _pumpGame(tester);
      await _speed(tester, 1.5);
      await _tap(tester, 'tag-play');
      await tester.pump(const Duration(seconds: 1));
      await _tap(tester, 'tag-play');
      final player = _round(tester).playerPosition;
      final blue = _round(tester).bluePosition;
      await tester.pump(const Duration(seconds: 10));
      expect(_round(tester).playerPosition, player);
      expect(_round(tester).bluePosition, blue);
      await _tap(tester, 'tag-reset');
      expect(_round(tester).playerPosition, 0);
      expect(_round(tester).bluePosition, 4);
      expect(_round(tester).speed, 1.5);
      expect(find.byKey(const ValueKey('tag-step')), findsOneWidget);
    },
  );

  testWidgets(
    'Motion Tag completes all three goals through controls rather than answers',
    (tester) async {
      await _pumpGame(tester, reduced: true);
      await _catch(tester);
      expect(_text(tester, 'tag-cue'), tagMissions[0].success);
      await _tap(tester, 'tag-next');
      expect(_text(tester, 'tag-goal'), tagMissions[1].instruction);
      await _beside(tester);
      expect(_text(tester, 'tag-cue'), tagMissions[1].success);
      await _tap(tester, 'tag-next');
      await _follow(tester);
      expect(_text(tester, 'tag-cue'), tagMissions[2].success);
      expect(_text(tester, 'tag-count'), '3 / 3');
      await _tap(tester, 'tag-replay');
      expect(_text(tester, 'tag-count'), '1 / 3');
      expect(_round(tester).won, isFalse);
      expect(_round(tester).playerPosition, 0);
    },
  );

  testWidgets(
    'Motion Tag reversed direction is visible and makes the gap larger',
    (tester) async {
      await _pumpGame(tester, reduced: true);
      await _tap(tester, 'tag-left');
      await _tap(tester, 'tag-play');
      expect(_round(tester).playerPosition, -1);
      expect(_round(tester).gap, 6);
      expect(_text(tester, 'tag-cue'), TagCue.wrongWay.english);
      await _tap(tester, 'tag-right');
      expect(_round(tester).speed, 1);
    },
  );

  testWidgets('Motion Tag the slider supports real pointer input', (
    tester,
  ) async {
    await _pumpGame(tester);
    final slider = find.byKey(const ValueKey('tag-speed'));
    final rect = tester.getRect(slider);
    await tester.tapAt(Offset(rect.right - 20, rect.center.dy));
    await tester.pump();
    expect(_round(tester).speed, 2);
  });

  testWidgets(
    'Motion Tag language help and narration pause without resetting positions',
    (tester) async {
      final calls = await _pumpGame(tester);
      await _tap(tester, 'tag-play');
      await tester.pump(const Duration(seconds: 1));
      await _tap(tester, 'tag-audio-en');
      expect(_spoken(calls).last, tagMissions.first.instruction);
      final position = _round(tester).playerPosition;
      await tester.pump(const Duration(seconds: 4));
      expect(_round(tester).playerPosition, position);
      await _tap(tester, 'tag-language');
      expect(
        _text(tester, 'tag-spanish-goal'),
        tagMissions.first.instructionEs,
      );
      expect(_text(tester, 'tag-spanish-cue'), _round(tester).cue.spanish);
      await _tap(tester, 'tag-audio-es');
      expect(_spoken(calls).last, tagMissions.first.instructionEs);
      expect(_round(tester).playerPosition, position);
    },
  );

  testWidgets('Motion Tag reduced motion is playable one second at a time', (
    tester,
  ) async {
    await _pumpGame(tester, reduced: true);
    await _speed(tester, 2);
    await tester.pump(const Duration(seconds: 20));
    expect(_round(tester).elapsed, 0);
    await _tap(tester, 'tag-play');
    expect(_round(tester).elapsed, 1);
    expect(_round(tester).gap, 3);
    await tester.pump(const Duration(seconds: 20));
    expect(_round(tester).elapsed, 1);
    await _steps(tester, 3);
    expect(_round(tester).won, isTrue);
  });

  testWidgets(
    'Motion Tag backgrounding pauses and never fast-forwards robots',
    (tester) async {
      await _pumpGame(tester);
      await _tap(tester, 'tag-play');
      await tester.pump(const Duration(seconds: 1));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      final position = _round(tester).playerPosition;
      await tester.pump(const Duration(seconds: 20));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(_round(tester).playerPosition, position);
      expect(find.byKey(const ValueKey('tag-step')), findsOneWidget);
    },
  );

  testWidgets('Motion Tag can recover when blue leaves the visible track', (
    tester,
  ) async {
    await _pumpGame(tester);
    await _tap(tester, 'tag-stop');
    await _tap(tester, 'tag-play');
    await tester.pump(const Duration(seconds: 30));
    expect(find.byKey(const ValueKey('tag-blue-offscreen')), findsOneWidget);
    expect(_round(tester).won, isFalse);
    await _speed(tester, 2);
    await tester.pump(const Duration(seconds: 40));
    expect(_round(tester).won, isTrue);
    expect(_round(tester).gap, closeTo(0.5, 0.000001));
  });

  testWidgets(
    'Motion Tag arena and controls have meaningful accessible labels',
    (tester) async {
      await _pumpGame(tester);
      final semantics = tester.ensureSemantics();
      try {
        await tester.pump();
        final arena = tester
            .getSemantics(find.byKey(const ValueKey('tag-arena')))
            .getSemanticsData();
        expect(arena.label, contains('Your robot'));
        expect(arena.label, contains('4 meters ahead'));
        final slider = tester
            .getSemantics(find.byKey(const ValueKey('tag-speed')))
            .getSemanticsData();
        expect(slider.label, 'Your robot speed\n1 m/s');
        expect(slider.hasAction(SemanticsAction.increase), isTrue);
        expect(slider.hasAction(SemanticsAction.decrease), isTrue);
        expect(
          tester
              .getSemantics(find.byKey(const ValueKey('tag-faster')))
              .getSemanticsData()
              .label,
          contains('Faster'),
        );
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets('Motion Tag duplicate next callbacks do not skip a goal', (
    tester,
  ) async {
    await _pumpGame(tester, reduced: true);
    await _catch(tester);
    final next = tester
        .widget<FilledButton>(find.byKey(const ValueKey('tag-next')))
        .onPressed!;
    next();
    next();
    await tester.pump();
    expect(_text(tester, 'tag-count'), '2 / 3');
  });

  testWidgets('Motion Tag leaving running play disposes animation and speech', (
    tester,
  ) async {
    final calls = await _pumpGame(tester);
    await _tap(tester, 'tag-audio-en');
    await _tap(tester, 'tag-play');
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
    expect(calls.where((call) => call.method == 'stop'), isNotEmpty);
    expect(tester.takeException(), isNull);
  });

  for (final (width, scale) in [(320.0, 1.0), (390.0, 1.6), (1280.0, 1.0)]) {
    testWidgets(
      'Motion Tag fits width $width and text scale $scale with Spanish help',
      (tester) async {
        await _pumpGame(
          tester,
          size: Size(width, 844),
          textScale: scale,
          reduced: true,
        );
        await _tap(tester, 'tag-language');
        await _catch(tester);
        await _tap(tester, 'tag-next');
        await _beside(tester);
        await _tap(tester, 'tag-next');
        await _follow(tester);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
