import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:physics_quest/theme.dart';
import 'package:physics_quest/views/practice_view.dart';

const _activities = {
  'mcq': 'Multiple Choice',
  'blank': 'Fill the Blank',
  'oddOneOut': 'Odd One Out',
  'match': 'Match Up',
};

Future<void> _pumpPractice(
  WidgetTester tester, {
  required Size size,
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: const PracticeView(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final width in [390.0, 1280.0]) {
    testWidgets(
      'Practice cards have centered large titles and subtle colors at $width',
      (tester) async {
        await _pumpPractice(tester, size: Size(width, 900));
        final fills = <Color>{};
        for (final entry in _activities.entries) {
          final card = find.byKey(ValueKey('practice-mode-${entry.key}'));
          await tester.ensureVisible(card);
          await tester.pumpAndSettle();
          final titleFinder = find.descendant(
            of: card,
            matching: find.text(entry.value),
          );
          final title = tester.widget<Text>(titleFinder);
          expect(title.textAlign, TextAlign.center);
          expect(title.style!.fontSize, 24);
          expect(title.style!.fontWeight, FontWeight.w700);
          expect(title.overflow, isNot(TextOverflow.ellipsis));

          final cardBounds = tester.getRect(card);
          final titleBounds = tester.getRect(titleFinder);
          expect(titleBounds.center.dx, closeTo(cardBounds.center.dx, 1));
          expect(titleBounds.center.dy, closeTo(cardBounds.center.dy, 1));
          final subtitle = find
              .descendant(of: card, matching: find.byType(Text))
              .at(1);
          expect(titleBounds.bottom, lessThan(tester.getRect(subtitle).top));
          expect(cardBounds.width, lessThanOrEqualTo(453));

          final surface = tester
              .widgetList<Container>(
                find.descendant(of: card, matching: find.byType(Container)),
              )
              .map((container) => container.decoration)
              .whereType<BoxDecoration>()
              .first;
          expect(surface.gradient, isNull);
          final fill = surface.color!;
          fills.add(fill);
          expect(HSVColor.fromColor(fill).saturation, lessThan(0.10));
          final foregroundLuminance = title.style!.color!.computeLuminance();
          final contrast =
              (fill.computeLuminance() + 0.05) / (foregroundLuminance + 0.05);
          expect(contrast, greaterThanOrEqualTo(4.5));
        }
        expect(fills, hasLength(4));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Practice cards use one column on narrow screens', (
    tester,
  ) async {
    await _pumpPractice(tester, size: const Size(320, 844));
    final first = find.byKey(const ValueKey('practice-mode-mcq'));
    final second = find.byKey(const ValueKey('practice-mode-blank'));
    expect(tester.getRect(first).width, closeTo(284, 1));
    expect(tester.getRect(first).left, tester.getRect(second).left);
    expect(
      tester.getRect(second).top,
      greaterThan(tester.getRect(first).bottom),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Practice cards accommodate larger accessibility text', (
    tester,
  ) async {
    await _pumpPractice(tester, size: const Size(390, 844), textScale: 1.6);
    for (final entry in _activities.entries) {
      final card = find.byKey(ValueKey('practice-mode-${entry.key}'));
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      expect(tester.getSize(card).width, closeTo(354, 1));
      expect(
        find.descendant(of: card, matching: find.text(entry.value)),
        findsOneWidget,
      );
    }
    expect(tester.takeException(), isNull);
  });
}
