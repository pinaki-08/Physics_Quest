import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:physics_quest/games/force_balance_model.dart';

void main() {
  test('Hold the Line practice has short original bilingual force goals', () {
    expect(balanceLessons, hasLength(3));
    for (final lesson in balanceLessons) {
      expect(lesson.instruction, isNotEmpty);
      expect(lesson.instructionEs, isNotEmpty);
      expect(lesson.success, isNotEmpty);
      expect(lesson.successEs, isNotEmpty);
    }
    for (final cue in BalanceCue.values) {
      expect(cue.english, isNotEmpty);
      expect(cue.spanish, isNotEmpty);
    }
  });

  test(
    'Hold the Line opposing push magnitudes determine the actual net force',
    () {
      final round = ForceBalanceRound.practice(balanceLessons[0]);
      expect(round.wind, 10);
      expect(round.netForce, 10);
      round.setPush(BoxPush.left);
      expect(round.playerForce, -10);
      expect(round.netForce, 0);
      expect(round.balanced, isTrue);
      round.setStrength(20);
      expect(round.netForce, -10);
      expect(round.acceleration, -0.25);
      round.setPush(BoxPush.right);
      expect(round.netForce, 30);
      round.setPush(BoxPush.none);
      expect(round.netForce, 10);
    },
  );

  test('Hold the Line matched slider values do not display a phantom force direction', () {
    final round = ForceBalanceRound.practice(balanceLessons.first)
      ..setPush(BoxPush.left)
      ..setStrength(10.000000000000002);
    expect(round.netForce, 0);
    expect(round.acceleration, 0);
    round.advance(3);
    expect(round.position, 0);
    expect(round.velocity, 0);
    expect(round.won, isTrue);
  });

  test(
    'Hold the Line forces accelerate the box with exact position integration',
    () {
      final round = ForceBalanceRound.practice(balanceLessons[0]);
      round.advance(2);
      expect(round.velocity, closeTo(0.5, 0.000001));
      expect(round.position, closeTo(0.5, 0.000001));
      expect(round.held, 0);
      expect(round.won, isFalse);
    },
  );

  test('Hold the Line balanced forces do not stop an already moving box', () {
    final round = ForceBalanceRound.practice(balanceLessons[2])
      ..setStrength(10)
      ..setPush(BoxPush.left);
    expect(round.netForce, 0);
    round.advance(2);
    expect(round.velocity, 0.5);
    expect(round.position, closeTo(0.25, 0.000001));
    expect(round.cue, BalanceCue.balancedMovingRight);
    expect(round.held, 0);
    expect(round.won, isFalse);
  });

  test('Hold the Line first two goals require equal opposite pushes', () {
    for (var index = 0; index < 2; index++) {
      final round = ForceBalanceRound.practice(balanceLessons[index]);
      round.setStrength(round.wind.abs());
      round.setPush(round.wind > 0 ? BoxPush.left : BoxPush.right);
      round.advance(2.999);
      expect(round.won, isFalse);
      round.advance(0.001);
      expect(round.won, isTrue);
      expect(round.held, 3);
      expect(round.position, 0);
      expect(round.velocity, 0);
    }
  });

  test(
    'Hold the Line slows drift with an unbalanced force before balancing',
    () {
      final round = ForceBalanceRound.practice(balanceLessons[2])
        ..setStrength(20)
        ..setPush(BoxPush.left);
      expect(round.cue, BalanceCue.slowing);
      round.advance(2);
      expect(round.velocity, closeTo(0, 0.000001));
      expect(round.position, closeTo(-0.25, 0.000001));
      expect(round.won, isFalse);
      round.setStrength(10);
      round.advance(3);
      expect(round.won, isTrue);
      expect(round.velocity, closeTo(0, 0.000001));
      expect(round.position, closeTo(-0.25, 0.000001));
    },
  );

  test('Hold the Line guided practice pauses at the real stop so matching is not a reflex test', () {
    final round = ForceBalanceRound.practice(balanceLessons[2])
      ..setStrength(20)
      ..setPush(BoxPush.left);
    round.advance(10);
    expect(round.balancePause, isTrue);
    expect(round.elapsed, closeTo(2, 0.000001));
    expect(round.velocity, 0);
    expect(round.position, closeTo(-0.25, 0.000001));
    expect(round.netForce, -10);
    expect(round.won, isFalse);
    round.setStrength(10);
    expect(round.balancePause, isFalse);
    round.advance(3);
    expect(round.won, isTrue);
  });

  test(
    'Hold the Line steady progress resets when the applied forces change',
    () {
      final round = ForceBalanceRound.practice(balanceLessons[0])
        ..setPush(BoxPush.left);
      round.advance(2);
      expect(round.held, 2);
      round.setPush(BoxPush.none);
      round.advance(0.01);
      expect(round.held, 0);
      expect(round.won, isFalse);
    },
  );

  test(
    'Hold the Line stops at the actual edge crossing rather than skipping it',
    () {
      final round = ForceBalanceRound.practice(balanceLessons[0]);
      round.advance(20);
      expect(round.edgeReached, isTrue);
      expect(round.position, round.railLimit);
      expect(round.elapsed, closeTo(math.sqrt(48), 0.000001));
      final elapsed = round.elapsed;
      round.advance(10);
      expect(round.elapsed, elapsed);
    },
  );

  test('Hold the Line survival retains increasing gusts and a time score', () {
    final round = ForceBalanceRound.challenge(random: math.Random(8));
    expect(round.mode, BalanceMode.challenge);
    expect(round.wind, 0);
    expect(round.strength, 45);
    round.advance(1.49);
    expect(round.gustChanges, 0);
    round.advance(0.02);
    expect(round.gustChanges, 1);
    expect(round.wind.abs(), inInclusiveRange(5, 60));
    expect(round.wind / 5, (round.wind / 5).roundToDouble());
    expect(round.elapsed, closeTo(1.51, 0.000001));
    expect(round.won, isFalse);
  });

  test(
    'Hold the Line large frames agree with small frames across gust changes',
    () {
      final one = ForceBalanceRound.challenge(random: math.Random(4));
      final many = ForceBalanceRound.challenge(random: math.Random(4));
      one.advance(8);
      for (var frame = 0; frame < 480; frame++) {
        many.advance(1 / 60);
      }
      expect(many.position, closeTo(one.position, 0.000001));
      expect(many.velocity, closeTo(one.velocity, 0.000001));
      expect(many.elapsed, closeTo(one.elapsed, 0.000001));
      expect(many.gustChanges, one.gustChanges);
      expect(many.wind, one.wind);
    },
  );

  test(
    'Hold the Line reset restores the box without losing chosen push controls',
    () {
      final round = ForceBalanceRound.practice(balanceLessons[2])
        ..setStrength(20)
        ..setPush(BoxPush.left);
      round.advance(1);
      round.reset();
      expect(round.position, -0.75);
      expect(round.velocity, 0.5);
      expect(round.strength, 20);
      expect(round.push, BoxPush.left);
      expect(round.elapsed, 0);
      expect(round.held, 0);
    },
  );

  test('Hold the Line invalid strength and time values fail explicitly', () {
    final round = ForceBalanceRound.practice(balanceLessons.first);
    for (final value in [-1.0, 61.0, double.nan, double.infinity]) {
      expect(() => round.setStrength(value), throwsArgumentError);
    }
    for (final time in [-1.0, double.nan, double.infinity]) {
      expect(() => round.advance(time), throwsArgumentError);
    }
    round.advance(0);
    expect(round.elapsed, 0);
  });
}
