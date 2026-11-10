import 'package:flutter_test/flutter_test.dart';
import 'package:physics_quest/games/motion_tag_model.dart';

void main() {
  test('Motion Tag has three original bilingual movement goals', () {
    expect(tagMissions.map((mission) => mission.goal), [
      TagGoal.catchUp,
      TagGoal.beside,
      TagGoal.follow,
    ]);
    expect(tagMissions.map((mission) => mission.id).toSet(), hasLength(3));
    for (final mission in tagMissions) {
      expect(mission.instruction, isNotEmpty);
      expect(mission.instructionEs, isNotEmpty);
      expect(mission.success, isNotEmpty);
      expect(mission.successEs, isNotEmpty);
      expect(mission.blueSpeed, 1);
    }
    for (final cue in TagCue.values) {
      expect(cue.english, isNotEmpty);
      expect(cue.spanish, isNotEmpty);
    }
  });

  test(
    'Motion Tag same speeds preserve the gap and a faster robot closes it',
    () {
      final round = MotionTagRound(tagMissions[0]);
      round.advance(2);
      expect(round.playerPosition, 2);
      expect(round.bluePosition, 6);
      expect(round.gap, 4);
      expect(round.won, isFalse);
      expect(round.cue, TagCue.sameBehind);
      round.setSpeed(1.5);
      round.advance(2);
      expect(round.playerPosition, 5);
      expect(round.bluePosition, 8);
      expect(round.gap, 3);
      expect(round.cue, TagCue.closing);
    },
  );

  test(
    'Motion Tag catches swept contact even when a frame would skip past blue',
    () {
      final round = MotionTagRound(tagMissions[0])..setSpeed(2);
      round.advance(20);
      expect(round.won, isTrue);
      expect(round.elapsed, closeTo(3.5, 0.000001));
      expect(round.playerPosition, closeTo(7, 0.000001));
      expect(round.bluePosition, closeTo(7.5, 0.000001));
      expect(round.gap, closeTo(0.5, 0.000001));
      round.advance(10);
      expect(round.elapsed, closeTo(3.5, 0.000001));
    },
  );

  test('Motion Tag changing direction never creates a negative speed', () {
    final round = MotionTagRound(tagMissions[0])
      ..setSpeed(1.5)
      ..setDirection(TagDirection.left);
    round.advance(2);
    expect(round.speed, 1.5);
    expect(round.playerVelocity, -1.5);
    expect(round.playerPosition, -3);
    expect(round.bluePosition, 6);
    expect(round.gap, 9);
    expect(round.cue, TagCue.wrongWay);
    round.setSpeed(0);
    round.advance(2);
    expect(round.playerPosition, -3);
    expect(round.bluePosition, 8);
    expect(round.cue, TagCue.stopped);
  });

  test(
    'Motion Tag being briefly beside blue is not the same as matching speed',
    () {
      final round = MotionTagRound(tagMissions[1])..setSpeed(2);
      round.advance(2);
      expect(round.gap, closeTo(0, 0.000001));
      expect(round.inPosition, isTrue);
      expect(round.held, 0);
      expect(round.won, isFalse);
      expect(round.cue, TagCue.matchNow);
      round.setSpeed(1);
      round.advance(2.999);
      expect(round.won, isFalse);
      round.advance(0.001);
      expect(round.won, isTrue);
      expect(round.held, closeTo(3, 0.000001));
    },
  );

  test(
    'Motion Tag follow requires a real gap behind blue, not just equal speeds',
    () {
      final round = MotionTagRound(tagMissions[2]);
      round.advance(4);
      expect(round.gap, 4.5);
      expect(round.held, 0);
      round.setSpeed(1.5);
      round.advance(4);
      expect(round.gap, closeTo(2.5, 0.000001));
      expect(round.inPosition, isTrue);
      expect(round.held, 0);
      round.setSpeed(1);
      round.advance(3);
      expect(round.won, isTrue);
      expect(round.gap, closeTo(2.5, 0.000001));
    },
  );

  test(
    'Motion Tag leaving the required motion resets continuous hold progress',
    () {
      final round = MotionTagRound(tagMissions[1])..setSpeed(2);
      round.advance(2);
      round.setSpeed(1);
      round.advance(2);
      expect(round.held, 2);
      round.setSpeed(1.5);
      round.advance(0.1);
      expect(round.held, 0);
      round.setSpeed(1);
      round.advance(2);
      expect(round.won, isFalse);
      round.advance(1);
      expect(round.won, isTrue);
    },
  );

  test('Motion Tag one large time step agrees with many small steps', () {
    final one = MotionTagRound(tagMissions[0])..setSpeed(2);
    final many = MotionTagRound(tagMissions[0])..setSpeed(2);
    one.advance(4);
    for (var frame = 0; frame < 240; frame++) {
      many.advance(1 / 60);
    }
    expect(many.won, one.won);
    expect(many.playerPosition, closeTo(one.playerPosition, 0.000001));
    expect(many.bluePosition, closeTo(one.bluePosition, 0.000001));
    expect(many.elapsed, closeTo(one.elapsed, 0.000001));
  });

  test('Motion Tag completed hold progress fills all three stars at frame intervals', () {
    final round = MotionTagRound(tagMissions[1])..setSpeed(2);
    round.advance(2);
    round.setSpeed(1);
    for (var frame = 0; frame < 180; frame++) {
      round.advance(1 / 60);
    }
    expect(round.won, isTrue);
    expect(round.held, 3);
    expect(round.progress, 1);
  });

  test(
    'Motion Tag reset restores positions without discarding chosen controls',
    () {
      final round = MotionTagRound(tagMissions[0])..setSpeed(2);
      round.advance(4);
      round.reset();
      expect(round.playerPosition, 0);
      expect(round.bluePosition, 4);
      expect(round.speed, 2);
      expect(round.held, 0);
      expect(round.elapsed, 0);
      expect(round.won, isFalse);
    },
  );

  test('Motion Tag invalid speed and time values fail explicitly', () {
    final round = MotionTagRound(tagMissions.first);
    for (final speed in [-1.0, 2.5, double.nan, double.infinity]) {
      expect(() => round.setSpeed(speed), throwsArgumentError);
    }
    for (final time in [-1.0, double.nan, double.infinity]) {
      expect(() => round.advance(time), throwsArgumentError);
    }
    round.advance(0);
    expect(round.elapsed, 0);
    expect(round.playerPosition, 0);
  });
}
