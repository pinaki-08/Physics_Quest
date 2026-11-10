import 'dart:math' as math;

enum TagGoal { catchUp, beside, follow }
enum TagDirection { left, right }

enum TagCue {
  closing(
    'Faster than blue: the gap gets smaller.',
    'Más rápido que Azul: la distancia disminuye.',
  ),
  growing(
    'Slower than blue: the gap gets bigger.',
    'Más lento que Azul: la distancia aumenta.',
  ),
  sameBehind(
    'Same speed keeps this gap. Try going faster.',
    'La misma velocidad mantiene esta distancia. Prueba ir más rápido.',
  ),
  sameAhead(
    'Same speed keeps you ahead. Try slowing down.',
    'La misma velocidad te mantiene adelante. Prueba ir más despacio.',
  ),
  matchNow(
    "Good position! Match blue's speed to stay here.",
    '¡Buena posición! Iguala la velocidad de Azul para mantenerla.',
  ),
  holding(
    'Nice! Keep this speed and position.',
    '¡Bien! Mantén esta velocidad y posición.',
  ),
  ahead(
    'You are ahead. Slow down to come alongside.',
    'Estás adelante. Reduce la velocidad para quedar al lado.',
  ),
  blueClosing(
    'Blue is catching up. Watch the gap.',
    'Azul se está acercando. Mira la distancia.',
  ),
  wrongWay(
    'Blue moves right. Try moving right too.',
    'Azul va a la derecha. Prueba ir a la derecha también.',
  ),
  stopped(
    'Your speed is zero. Blue keeps moving.',
    'Tu velocidad es cero. Azul sigue avanzando.',
  ),
  won('Goal complete!', '¡Reto completado!');

  const TagCue(this.english, this.spanish);
  final String english;
  final String spanish;
}

class TagMission {
  const TagMission({
    required this.id,
    required this.goal,
    required this.instruction,
    required this.instructionEs,
    required this.success,
    required this.successEs,
    required this.initialGap,
    required this.minGap,
    required this.maxGap,
    this.blueSpeed = 1,
    this.holdSeconds = 3,
  });

  final String id;
  final TagGoal goal;
  final String instruction;
  final String instructionEs;
  final String success;
  final String successEs;
  final double initialGap;
  final double minGap;
  final double maxGap;
  final double blueSpeed;
  final double holdSeconds;
}

const tagMissions = [
  TagMission(
    id: 'catch-blue',
    goal: TagGoal.catchUp,
    instruction: 'Catch the blue robot.',
    instructionEs: 'Alcanza al robot azul.',
    success: 'Tag! You closed the gap by moving faster.',
    successEs: '¡Lo alcanzaste! Te acercaste al moverte más rápido.',
    initialGap: 4,
    minGap: -0.5,
    maxGap: 0.5,
    holdSeconds: 0,
  ),
  TagMission(
    id: 'stay-beside',
    goal: TagGoal.beside,
    instruction: 'Stay beside the blue robot.',
    instructionEs: 'Mantente al lado del robot azul.',
    success: 'Same speed, side by side!',
    successEs: '¡A la misma velocidad, lado a lado!',
    initialGap: 2,
    minGap: -0.6,
    maxGap: 0.6,
  ),
  TagMission(
    id: 'follow-blue',
    goal: TagGoal.follow,
    instruction: 'Follow blue and keep a steady gap.',
    instructionEs: 'Sigue a Azul y mantén la misma distancia.',
    success: 'Great following! The gap stayed steady.',
    successEs: '¡Lo seguiste bien! La distancia se mantuvo constante.',
    initialGap: 4.5,
    minGap: 2,
    maxGap: 3.2,
  ),
];

class MotionTagRound {
  MotionTagRound(this.mission) : _bluePosition = mission.initialGap;

  static const maxSpeed = 2.0;
  static const speedStep = 0.5;
  static const _epsilon = 0.000000001;

  final TagMission mission;
  double _playerPosition = 0;
  double _bluePosition;
  double _speed = 1;
  TagDirection _direction = TagDirection.right;
  double _held = 0;
  double _elapsed = 0;
  bool _won = false;

  double get playerPosition => _playerPosition;
  double get bluePosition => _bluePosition;
  double get speed => _speed;
  TagDirection get direction => _direction;
  double get playerVelocity => _direction == TagDirection.right ? _speed : -_speed;
  double get gap => _bluePosition - _playerPosition;
  double get held => _held;
  double get elapsed => _elapsed;
  bool get won => _won;
  bool get matchingSpeed =>
      (playerVelocity - mission.blueSpeed).abs() <= _epsilon;
  bool get inPosition =>
      gap >= mission.minGap - _epsilon && gap <= mission.maxGap + _epsilon;
  bool get canHold =>
      mission.goal != TagGoal.catchUp && inPosition && matchingSpeed;
  double get progress => mission.goal == TagGoal.catchUp
      ? (_won ? 1 : 0)
      : _held / mission.holdSeconds;

  TagCue get cue {
    if (_won) return TagCue.won;
    if (_speed == 0) return TagCue.stopped;
    if (_direction == TagDirection.left) return TagCue.wrongWay;
    if (mission.goal != TagGoal.catchUp && inPosition) {
      return matchingSpeed ? TagCue.holding : TagCue.matchNow;
    }
    if (matchingSpeed) return gap >= 0 ? TagCue.sameBehind : TagCue.sameAhead;
    if (gap >= 0) {
      return playerVelocity > mission.blueSpeed ? TagCue.closing : TagCue.growing;
    }
    return playerVelocity > mission.blueSpeed ? TagCue.ahead : TagCue.blueClosing;
  }

  void setSpeed(double value) {
    if (!value.isFinite || value < 0 || value > maxSpeed) {
      throw ArgumentError.value(value, 'speed', 'Use a speed from 0 to 2 m/s.');
    }
    if (!_won) _speed = value;
  }

  void setDirection(TagDirection value) {
    if (!_won) _direction = value;
  }

  void reset() {
    _playerPosition = 0;
    _bluePosition = mission.initialGap;
    _held = 0;
    _elapsed = 0;
    _won = false;
  }

  void advance(double seconds) {
    if (!seconds.isFinite || seconds < 0) {
      throw ArgumentError.value(seconds, 'seconds', 'Use a finite, nonnegative time.');
    }
    if (_won || seconds == 0) return;
    var duration = seconds;
    if (mission.goal == TagGoal.catchUp) {
      final contact = _contactWithin(seconds);
      if (contact != null) {
        duration = contact;
        _won = true;
      }
    } else if (canHold) {
      duration = math.min(seconds, mission.holdSeconds - _held);
      _held = math.min(mission.holdSeconds, _held + duration);
      if (_held >= mission.holdSeconds - _epsilon) {
        _held = mission.holdSeconds;
        _won = true;
      }
    } else {
      _held = 0;
    }
    _playerPosition += playerVelocity * duration;
    _bluePosition += mission.blueSpeed * duration;
    _elapsed += duration;
  }

  double? _contactWithin(double seconds) {
    if (inPosition) return 0;
    final rate = mission.blueSpeed - playerVelocity;
    if (rate.abs() <= _epsilon) return null;
    final first = (mission.minGap - gap) / rate;
    final last = (mission.maxGap - gap) / rate;
    final enter = math.max(0.0, math.min(first, last));
    final exit = math.min(seconds, math.max(first, last));
    // Test the whole swept interval, so a dropped frame cannot skip a tag.
    return enter <= exit + _epsilon && exit >= 0
        ? math.min(enter, seconds)
        : null;
  }
}
