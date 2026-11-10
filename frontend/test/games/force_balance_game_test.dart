import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:physics_quest/games/force_balance_arena.dart';
import 'package:physics_quest/games/force_balance_game.dart';
import 'package:physics_quest/games/force_balance_model.dart';
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
      home: const ForceBalanceGame(),
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

ForceBalanceRound _round(WidgetTester tester) =>
    tester.widget<ForceBalanceArena>(find.byType(ForceBalanceArena)).round;

String _text(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(ValueKey(key))).data!;

List<String> _spoken(List<MethodCall> calls) => [
  for (final call in calls)
    if (call.method == 'speak') call.arguments as String,
];

Future<void> _strength(WidgetTester tester, double value) async {
  final semantics = tester.ensureSemantics();
  try {
    await tester.pump();
    while (_round(tester).strength != value) {
      final node = tester.getSemantics(
        find.byKey(const ValueKey('balance-strength')),
      );
      node.owner!.performAction(
        node.id,
        _round(tester).strength < value
            ? SemanticsAction.increase
            : SemanticsAction.decrease,
      );
      await tester.pump();
    }
  } finally {
    semantics.dispose();
  }
}

Future<void> _steps(WidgetTester tester, int count) async {
  for (var step = 0; step < count; step++) {
    await _tap(tester, 'balance-play');
  }
}

Future<void> _firstTwo(WidgetTester tester) async {
  await _tap(tester, 'balance-left');
  await _steps(tester, 3);
  await _tap(tester, 'balance-next');
  await _strength(tester, 15);
  await _tap(tester, 'balance-right');
  await _steps(tester, 3);
  await _tap(tester, 'balance-next');
}

Future<void> _mode(WidgetTester tester, String label) async {
  await _tap(tester, 'balance-mode');
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(find.text(label).last);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets(
    'Hold the Line starts with clear guided practice instead of unexplained survival',
    (tester) async {
      final calls = await _pumpGame(tester);
      expect(_round(tester).mode, BalanceMode.practice);
      expect(_text(tester, 'balance-goal'), balanceLessons.first.instruction);
      expect(_text(tester, 'balance-count'), '1 / 3');
      expect(find.text('Push left'), findsOneWidget);
      expect(find.text('Push right'), findsOneWidget);
      expect(find.text('Release'), findsOneWidget);
      expect(find.textContaining('Thrust'), findsNothing);
      expect(find.textContaining('Pod'), findsNothing);
      expect(_spoken(calls), isEmpty);
      await tester.pump(const Duration(seconds: 20));
      expect(_round(tester).elapsed, 0);
    },
  );

  testWidgets(
    'Hold the Line normal viewport keeps the main goal and force controls visible',
    (tester) async {
      const size = Size(732, 607);
      await _pumpGame(tester, size: size);
      for (final key in [
        'balance-goal',
        'balance-strength',
        'balance-left',
        'balance-right',
        'balance-play',
        'balance-mode',
      ]) {
        final rect = tester.getRect(find.byKey(ValueKey(key)));
        expect(rect.top, greaterThanOrEqualTo(0), reason: key);
        expect(rect.bottom, lessThanOrEqualTo(size.height), reason: key);
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Hold the Line tap-to-push persists until release or another tap',
    (tester) async {
      await _pumpGame(tester);
      await _tap(tester, 'balance-left');
      expect(_round(tester).playerForce, -10);
      await tester.pump(const Duration(seconds: 10));
      expect(_round(tester).playerForce, -10);
      await _tap(tester, 'balance-left');
      expect(_round(tester).playerForce, 0);
      await _tap(tester, 'balance-right');
      expect(_round(tester).playerForce, 10);
      await _tap(tester, 'balance-release');
      expect(_round(tester).playerForce, 0);
    },
  );

  testWidgets(
    'Hold the Line visible arrow lengths match actual force magnitudes',
    (tester) async {
      await _pumpGame(tester);
      await _tap(tester, 'balance-left');
      final wind = tester
          .getSize(find.byKey(const ValueKey('balance-wind-arrow')))
          .width;
      final push = tester
          .getSize(find.byKey(const ValueKey('balance-push-arrow')))
          .width;
      expect(push, closeTo(wind, 0.001));
      expect(_round(tester).netForce, 0);
      expect(_text(tester, 'balance-result-label'), '0 N total');
      await _strength(tester, 20);
      expect(
        tester.getSize(find.byKey(const ValueKey('balance-push-arrow'))).width,
        closeTo(wind * 2, 0.001),
      );
      expect(_round(tester).netForce, -10);
    },
  );

  testWidgets(
    'Hold the Line all guided goals teach opposing forces and slowing drift',
    (tester) async {
      await _pumpGame(tester, reduced: true);
      await _firstTwo(tester);
      expect(_round(tester).velocity, 0.5);
      await _tap(tester, 'balance-left');
      await _steps(tester, 2);
      expect(_round(tester).velocity, closeTo(0, 0.000001));
      expect(_round(tester).position, closeTo(-0.25, 0.000001));
      await _strength(tester, 10);
      await _steps(tester, 3);
      expect(_round(tester).won, isTrue);
      expect(_text(tester, 'balance-count'), '3 / 3');
      expect(
        find.byKey(const ValueKey('balance-try-challenge')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Hold the Line zero net force is never falsely labelled as stopping drift',
    (tester) async {
      await _pumpGame(tester, reduced: true);
      await _firstTwo(tester);
      await _strength(tester, 10);
      await _tap(tester, 'balance-left');
      final before = tester
          .getCenter(find.byKey(const ValueKey('balance-box')))
          .dx;
      await _steps(tester, 2);
      expect(_round(tester).netForce, 0);
      expect(_round(tester).velocity, 0.5);
      expect(_round(tester).won, isFalse);
      expect(
        _text(tester, 'balance-cue'),
        BalanceCue.balancedMovingRight.english,
      );
      expect(
        tester.getCenter(find.byKey(const ValueKey('balance-box'))).dx,
        greaterThan(before),
      );
    },
  );

  testWidgets(
    'Hold the Line release removes the push without instantly stopping the box',
    (tester) async {
      await _pumpGame(tester, reduced: true);
      await _tap(tester, 'balance-play');
      final velocity = _round(tester).velocity;
      await _tap(tester, 'balance-left');
      await _tap(tester, 'balance-release');
      expect(_round(tester).velocity, velocity);
      expect(_round(tester).netForce, 10);
    },
  );

  testWidgets(
    'Hold the Line practice gives time to balance after a stronger push stops drift',
    (tester) async {
      await _pumpGame(tester);
      await _tap(tester, 'balance-play');
      await tester.pump(const Duration(seconds: 1));
      await _tap(tester, 'balance-play');
      await _strength(tester, 20);
      await _tap(tester, 'balance-left');
      await _tap(tester, 'balance-play');
      await tester.pump(const Duration(seconds: 10));
      expect(_round(tester).balancePause, isTrue);
      expect(_round(tester).velocity, 0);
      expect(_round(tester).won, isFalse);
      expect(_text(tester, 'balance-cue'), BalanceCue.readyToBalance.english);
      expect(find.byKey(const ValueKey('balance-step')), findsOneWidget);
    },
  );

  testWidgets(
    'Hold the Line optional challenge retains survival and preserves practice when switching',
    (tester) async {
      await _pumpGame(tester, reduced: true);
      await _tap(tester, 'balance-left');
      await _steps(tester, 1);
      expect(_round(tester).held, 1);
      await _mode(tester, 'Survival challenge');
      expect(_round(tester).mode, BalanceMode.challenge);
      await _steps(tester, 2);
      expect(_round(tester).elapsed, closeTo(2, 0.000001));
      expect(_round(tester).gustChanges, 1);
      expect(_round(tester).won, isFalse);
      await _mode(tester, 'Guided practice');
      expect(_round(tester).held, 1);
      expect(_round(tester).push, BoxPush.left);
      await _steps(tester, 2);
      expect(_round(tester).won, isTrue);
    },
  );

  testWidgets(
    'Hold the Line language help and bilingual audio pause without losing force settings',
    (tester) async {
      final calls = await _pumpGame(tester);
      await _tap(tester, 'balance-left');
      await _tap(tester, 'balance-play');
      await tester.pump(const Duration(seconds: 1));
      await _tap(tester, 'balance-audio-en');
      expect(_spoken(calls).last, contains(balanceLessons.first.instruction));
      expect(_spoken(calls).last, contains('Release'));
      final held = _round(tester).held;
      await tester.pump(const Duration(seconds: 8));
      expect(_round(tester).held, held);
      expect(_round(tester).push, BoxPush.left);
      await _tap(tester, 'balance-language');
      expect(
        _text(tester, 'balance-spanish-goal'),
        balanceLessons.first.instructionEs,
      );
      expect(_text(tester, 'balance-spanish-cue'), _round(tester).cue.spanish);
      await _tap(tester, 'balance-audio-es');
      expect(_spoken(calls).last, contains(balanceLessons.first.instructionEs));
      expect(_spoken(calls).last, contains('Soltar'));
      expect(_round(tester).held, held);
    },
  );

  testWidgets(
    'Hold the Line has short in-game control help without extra quiz screens',
    (tester) async {
      await _pumpGame(tester);
      await _tap(tester, 'balance-help');
      expect(_text(tester, 'balance-help-text'), contains('Tap'));
      expect(_text(tester, 'balance-help-text'), contains('Release'));
      expect(_text(tester, 'balance-help-text'), contains('newtons'));
      expect(find.textContaining('Check answer'), findsNothing);
    },
  );

  testWidgets(
    'Hold the Line pause and reset keep settings and stop active game time',
    (tester) async {
      await _pumpGame(tester);
      await _tap(tester, 'balance-play');
      await tester.pump(const Duration(seconds: 1));
      await _tap(tester, 'balance-play');
      final position = _round(tester).position;
      await tester.pump(const Duration(seconds: 10));
      expect(_round(tester).position, position);
      await _tap(tester, 'balance-left');
      await _tap(tester, 'balance-reset');
      expect(_round(tester).position, 0);
      expect(_round(tester).velocity, 0);
      expect(_round(tester).push, BoxPush.left);
      expect(_round(tester).elapsed, 0);
    },
  );

  testWidgets(
    'Hold the Line backgrounding pauses instead of skipping force motion',
    (tester) async {
      await _pumpGame(tester);
      await _tap(tester, 'balance-play');
      await tester.pump(const Duration(seconds: 1));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      final elapsed = _round(tester).elapsed;
      await tester.pump(const Duration(seconds: 10));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(_round(tester).elapsed, elapsed);
      expect(find.byKey(const ValueKey('balance-step')), findsOneWidget);
    },
  );

  testWidgets(
    'Hold the Line reduced motion remains playable through exact one-second steps',
    (tester) async {
      await _pumpGame(tester, reduced: true);
      await _tap(tester, 'balance-left');
      await tester.pump(const Duration(seconds: 20));
      expect(_round(tester).held, 0);
      await _steps(tester, 3);
      expect(_round(tester).won, isTrue);
      expect(_round(tester).held, 3);
    },
  );

  testWidgets(
    'Hold the Line an edge ends the attempt honestly and allows reset',
    (tester) async {
      await _pumpGame(tester);
      await _tap(tester, 'balance-play');
      await tester.pump(const Duration(seconds: 10));
      expect(_round(tester).edgeReached, isTrue);
      expect(_round(tester).won, isFalse);
      expect(_text(tester, 'balance-cue'), BalanceCue.edge.english);
      await _tap(tester, 'balance-reset');
      expect(_round(tester).edgeReached, isFalse);
      expect(_round(tester).position, 0);
    },
  );

  testWidgets(
    'Hold the Line force inputs and diagram have clear accessible names',
    (tester) async {
      await _pumpGame(tester);
      final semantics = tester.ensureSemantics();
      try {
        await tester.pump();
        final slider = tester
            .getSemantics(find.byKey(const ValueKey('balance-strength')))
            .getSemanticsData();
        expect(slider.label, contains('Push strength'));
        expect(slider.hasAction(SemanticsAction.increase), isTrue);
        expect(slider.hasAction(SemanticsAction.decrease), isTrue);
        await _tap(tester, 'balance-left');
        final arena = tester
            .getSemantics(find.byKey(const ValueKey('balance-arena')))
            .getSemanticsData();
        expect(arena.label, contains('10 newtons right'));
        expect(arena.label, contains('10 newtons left'));
        expect(arena.label, contains('0 newtons'));
        expect(
          tester
              .getSemantics(find.byKey(const ValueKey('balance-audio-en')))
              .getSemanticsData()
              .label,
          contains('English'),
        );
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets('Hold the Line leaving play disposes animation and narration', (
    tester,
  ) async {
    final calls = await _pumpGame(tester);
    await _tap(tester, 'balance-audio-en');
    await _tap(tester, 'balance-play');
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
    expect(calls.where((call) => call.method == 'stop'), isNotEmpty);
    expect(tester.takeException(), isNull);
  });

  for (final (width, scale) in [(320.0, 1.0), (390.0, 1.6), (1280.0, 1.0)]) {
    testWidgets(
      'Hold the Line fits width $width and text scale $scale with Spanish support',
      (tester) async {
        await _pumpGame(
          tester,
          size: Size(width, 844),
          textScale: scale,
          reduced: true,
        );
        await _tap(tester, 'balance-language');
        await _firstTwo(tester);
        await _tap(tester, 'balance-left');
        await _steps(tester, 2);
        await _strength(tester, 10);
        await _steps(tester, 3);
        expect(_round(tester).won, isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
