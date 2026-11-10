import 'dart:math' as math;

enum BalanceMode { practice, challenge }

enum BoxPush { none, left, right }

enum BalanceCue {
  windRight(
    'Wind pushes right. Tap Push left to oppose it.',
    'El viento empuja a la derecha. Toca Empujar a la izquierda.',
  ),
  windLeft(
    'Wind pushes left. Tap Push right to oppose it.',
    'El viento empuja a la izquierda. Toca Empujar a la derecha.',
  ),
  withWind(
    'Your push goes with the wind. Try the other side.',
    'Tu fuerza va con el viento. Prueba el otro lado.',
  ),
  weaker(
    'Your push is weaker. Increase its strength to balance.',
    'Tu fuerza es menor. Auméntala para equilibrar.',
  ),
  stronger(
    'Your push is stronger. Reduce it to balance.',
    'Tu fuerza es mayor. Redúcela para equilibrar.',
  ),
  readyToBalance(
    'The box is stopped. Match the arrows before playing again.',
    'La caja se detuvo. Iguala las flechas antes de continuar.',
  ),
  slowing(
    'The opposite force slows the box. Balance again when it is steady.',
    'La fuerza contraria frena la caja. Equilibra cuando esté estable.',
  ),
  balancedStill(
    'Equal pushes keep a resting box still.',
    'Las fuerzas iguales mantienen quieta una caja que estaba en reposo.',
  ),
  balancedMovingRight(
    'Balanced forces, but the box still moves right. Push left more strongly to slow it.',
    'Las fuerzas están equilibradas, pero la caja sigue a la derecha. Empuja más a la izquierda para frenarla.',
  ),
  balancedMovingLeft(
    'Balanced forces, but the box still moves left. Push right more strongly to slow it.',
    'Las fuerzas están equilibradas, pero la caja sigue a la izquierda. Empuja más a la derecha para frenarla.',
  ),
  outside(
    'Balanced, but outside the green zone. Move the box back.',
    'Hay equilibrio, pero la caja está fuera de la zona verde. Hazla volver.',
  ),
  calm(
    'The wind is calm. Release your push and watch the box.',
    'El viento está en calma. Suelta tu fuerza y observa la caja.',
  ),
  edge(
    'The box reached the edge. Reset and try again.',
    'La caja llegó al borde. Reinicia e inténtalo de nuevo.',
  ),
  complete(
    'Balanced and steady in the green zone!',
    '¡Fuerzas equilibradas y caja estable en la zona verde!',
  );

  const BalanceCue(this.english, this.spanish);
  final String english;
  final String spanish;
}

class BalanceLesson {
  const BalanceLesson({
    required this.id,
    required this.instruction,
    required this.instructionEs,
    required this.wind,
    this.position = 0,
    this.velocity = 0,
    this.strength = 10,
    this.success = 'Balanced and steady in the green zone!',
    this.successEs = '¡Fuerzas equilibradas y caja estable en la zona verde!',
  });

  final String id;
  final String instruction;
  final String instructionEs;
  final double wind;
  final double position;
  final double velocity;
  final double strength;
  final String success;
  final String successEs;
}

const balanceLessons = [
  BalanceLesson(
    id: 'oppose-right-wind',
    instruction: 'Balance the pushes in the green zone.',
    instructionEs: 'Equilibra las fuerzas en la zona verde.',
    wind: 10,
  ),
  BalanceLesson(
    id: 'oppose-left-wind',
    instruction: 'Balance the wind from the other side.',
    instructionEs: 'Equilibra el viento desde el otro lado.',
    wind: -15,
  ),
  BalanceLesson(
    id: 'slow-then-balance',
    instruction: 'Slow the moving box, then balance.',
    instructionEs:
        'Reduce la velocidad de la caja y luego equilibra las fuerzas.',
    wind: 10,
    position: -0.75,
    velocity: 0.5,
    strength: 20,
  ),
];

class ForceBalanceRound {
  ForceBalanceRound.practice(BalanceLesson this.lesson)
    : mode = BalanceMode.practice,
      _random = math.Random(0),
      _position = lesson.position,
      _velocity = lesson.velocity,
      _wind = lesson.wind,
      _strength = lesson.strength;

  ForceBalanceRound.challenge({math.Random? random})
    : mode = BalanceMode.challenge,
      lesson = null,
      _random = random ?? math.Random(),
      _position = 0,
      _velocity = 0,
      _wind = 0,
      _strength = 45;

  static const maxStrength = 60.0;
  static const steadySeconds = 3.0;
  static const _epsilon = 0.000000001;
  final BalanceMode mode;
  final BalanceLesson? lesson;
  final math.Random _random;
  double _position;
  double _velocity;
  double _wind;
  double _strength;
  BoxPush _push = BoxPush.none;
  double _elapsed = 0;
  double _held = 0;
  double _gustIn = 1.5;
  int _gustChanges = 0;
  bool _won = false;
  bool _edgeReached = false;
  bool _balancePause = false;

  double get position => _position;
  double get velocity => _velocity;
  double get wind => _wind;
  double get strength => _strength;
  BoxPush get push => _push;
  double get elapsed => _elapsed;
  double get held => _held;
  int get gustChanges => _gustChanges;
  bool get won => _won;
  bool get edgeReached => _edgeReached;
  bool get balancePause => _balancePause;
  bool get ended => _won || _edgeReached;
  double get mass => mode == BalanceMode.practice ? 40 : 20;
  double get railLimit => mode == BalanceMode.practice ? 6 : 50;
  double get greenLimit => mode == BalanceMode.practice ? 1.25 : 36;
  double get playerForce => switch (_push) {
    BoxPush.none => 0,
    BoxPush.left => -_strength,
    BoxPush.right => _strength,
  };
  double get netForce {
    final total = _wind + playerForce;
    return total.abs() <= _epsilon ? 0 : total;
  }

  double get acceleration => netForce / mass;
  bool get balanced => netForce.abs() <= _epsilon;
  bool get inGreen => _position.abs() <= greenLimit + _epsilon;
  bool get nearStill => _velocity.abs() <= 0.025;
  bool get steady => balanced && inGreen && nearStill;

  BalanceCue get cue {
    if (_edgeReached) return BalanceCue.edge;
    if (_won) return BalanceCue.complete;
    if (_balancePause) return BalanceCue.readyToBalance;
    if (balanced) {
      if (_velocity > 0.000001) return BalanceCue.balancedMovingRight;
      if (_velocity < -0.000001) return BalanceCue.balancedMovingLeft;
      return inGreen ? BalanceCue.balancedStill : BalanceCue.outside;
    }
    if (_wind == 0) return BalanceCue.calm;
    if (playerForce == 0) {
      return _wind > 0 ? BalanceCue.windRight : BalanceCue.windLeft;
    }
    if (playerForce.sign == _wind.sign) return BalanceCue.withWind;
    if (netForce * _velocity < -_epsilon) return BalanceCue.slowing;
    return playerForce.abs() < _wind.abs()
        ? BalanceCue.weaker
        : BalanceCue.stronger;
  }

  void setStrength(double value) {
    if (!value.isFinite || value < 0 || value > maxStrength) {
      throw ArgumentError.value(
        value,
        'strength',
        'Use a push from 0 to 60 N.',
      );
    }
    if (!ended) {
      _strength = value;
      _balancePause = false;
    }
  }

  void setPush(BoxPush value) {
    if (!ended) {
      _push = value;
      _balancePause = false;
    }
  }

  void reset() {
    _position = lesson?.position ?? 0;
    _velocity = lesson?.velocity ?? 0;
    _wind = lesson?.wind ?? 0;
    _elapsed = 0;
    _held = 0;
    _gustIn = 1.5;
    _gustChanges = 0;
    _won = false;
    _edgeReached = false;
    _balancePause = false;
  }

  void advance(double seconds) {
    if (!seconds.isFinite || seconds < 0) {
      throw ArgumentError.value(
        seconds,
        'seconds',
        'Use a finite, nonnegative time.',
      );
    }
    if (seconds == 0 || ended) return;
    _balancePause = false;
    var remaining = seconds;
    while (remaining > _epsilon && !ended && !_balancePause) {
      if (mode == BalanceMode.challenge && _gustIn <= _epsilon) _changeGust();
      var duration = mode == BalanceMode.challenge
          ? math.min(remaining, _gustIn)
          : remaining;
      final edgeTime = _edgeTime(duration);
      if (edgeTime != null) duration = math.min(duration, edgeTime);
      if (mode == BalanceMode.practice &&
          acceleration * _velocity < -_epsilon) {
        final stoppedAt = -_velocity / acceleration;
        if (stoppedAt > 0 && stoppedAt <= duration + _epsilon) {
          duration = math.min(duration, stoppedAt);
          _balancePause = true;
        }
      }
      if (mode == BalanceMode.practice) {
        if (steady) {
          final greenTime = _timeToGreenEdge();
          final required = steadySeconds - _held;
          if (required <= math.min(duration, greenTime) + _epsilon) {
            duration = math.min(duration, required);
            _held = steadySeconds;
            _won = true;
          } else {
            _held += math.min(duration, greenTime);
            if (greenTime < duration) _held = 0;
          }
        } else {
          _held = 0;
        }
      }
      final a = acceleration;
      _position += _velocity * duration + 0.5 * a * duration * duration;
      _velocity += a * duration;
      if (_balancePause) _velocity = 0;
      _elapsed += duration;
      _gustIn -= duration;
      remaining -= duration;
      if (!_won && edgeTime != null && edgeTime <= duration + _epsilon) {
        _position = _position < 0 ? -railLimit : railLimit;
        _edgeReached = true;
      }
    }
  }

  double _timeToGreenEdge() {
    if (_velocity.abs() <= _epsilon) return double.infinity;
    return math.max(
      0.0,
      ((_velocity > 0 ? greenLimit : -greenLimit) - _position) / _velocity,
    );
  }

  double? _edgeTime(double duration) {
    double? first;
    final a = acceleration;
    for (final edge in [-railLimit, railLimit]) {
      if (a.abs() <= _epsilon) {
        if (_velocity.abs() <= _epsilon) continue;
        final time = (edge - _position) / _velocity;
        if (time >= -_epsilon && time <= duration + _epsilon) {
          final candidate = math.max(0.0, time);
          if (first == null || candidate < first) first = candidate;
        }
      } else {
        final discriminant = _velocity * _velocity - 2 * a * (_position - edge);
        if (discriminant < 0) continue;
        for (final sign in [-1, 1]) {
          final time = (-_velocity + sign * math.sqrt(discriminant)) / a;
          if (time >= -_epsilon && time <= duration + _epsilon) {
            final candidate = math.max(0.0, time);
            if (first == null || candidate < first) first = candidate;
          }
        }
      }
    }
    return first;
  }

  void _changeGust() {
    final ramp = 1 + _elapsed / 18;
    final raw = (_random.nextDouble() * 60 - 30) * ramp;
    var force = (raw / 5).round() * 5.0;
    if (force == 0) force = raw < 0 ? -5 : 5;
    _wind = force.clamp(-maxStrength, maxStrength);
    _gustIn = math.max(0.7, 2.2 - _elapsed / 20);
    _gustChanges++;
  }
}
