String speedEquationNarration({
  required int distanceMetres,
  required int timeSeconds,
}) {
  if (distanceMetres <= 0) {
    throw ArgumentError.value(
      distanceMetres,
      'distanceMetres',
      'Distance must be greater than zero.',
    );
  }
  if (timeSeconds <= 0) {
    throw ArgumentError.value(
      timeSeconds,
      'timeSeconds',
      'Time must be greater than zero.',
    );
  }

  final speed = distanceMetres / timeSeconds;
  final speedText = speed == speed.roundToDouble()
      ? '${speed.round()}'
      : speed.toStringAsFixed(1);
  final distanceUnit = distanceMetres == 1 ? 'metre' : 'metres';
  final timeUnit = timeSeconds == 1 ? 'second' : 'seconds';
  final speedUnit = speed == 1 ? 'metre per second' : 'metres per second';

  return '$distanceMetres $distanceUnit divided by '
      '$timeSeconds $timeUnit equals $speedText $speedUnit.';
}

String speedEquationNarrationEs({
  required int distanceMetres,
  required int timeSeconds,
}) {
  if (distanceMetres <= 0) {
    throw ArgumentError.value(
      distanceMetres,
      'distanceMetres',
      'La distancia debe ser mayor que cero.',
    );
  }
  if (timeSeconds <= 0) {
    throw ArgumentError.value(
      timeSeconds,
      'timeSeconds',
      'El tiempo debe ser mayor que cero.',
    );
  }

  final speed = distanceMetres / timeSeconds;
  final speedText =
      (speed == speed.roundToDouble()
              ? '${speed.round()}'
              : speed.toStringAsFixed(1))
          .replaceAll('.', ',');
  final distanceUnit = distanceMetres == 1 ? 'metro' : 'metros';
  final division = distanceMetres == 1 ? 'dividido' : 'divididos';
  final timeUnit = timeSeconds == 1 ? 'segundo' : 'segundos';
  final speedUnit = speed == 1 ? 'metro por segundo' : 'metros por segundo';

  return '$distanceMetres $distanceUnit $division entre '
      '$timeSeconds $timeUnit es igual a $speedText $speedUnit.';
}

String keyPointsNarration(List<String> points, {required bool spanish}) {
  if (points.isEmpty) {
    throw ArgumentError.value(
      points,
      'points',
      'At least one key point is required.',
    );
  }

  final heading = spanish ? 'Recuerda esto.' : 'Remember this.';
  final equals = spanish ? 'es igual a' : 'equals';
  final narration = points
      .map((point) => point.replaceAll('=', equals))
      .join(' ');
  return '$heading $narration';
}

String scienceTextNarration(String text, {required bool spanish}) {
  return text
      .replaceAll('___', spanish ? 'espacio en blanco' : 'blank')
      .replaceAll('÷', spanish ? 'dividido entre' : 'divided by')
      .replaceAll('×', spanish ? 'por' : 'times')
      .replaceAll(
        RegExp(r'\bN\s*(?:/|per|por)\s*kg\b'),
        spanish ? 'newtons por kilogramo' : 'newtons per kilogram',
      )
      .replaceAll(
        RegExp(r'\bm/s\b'),
        spanish ? 'metros por segundo' : 'metres per second',
      )
      .replaceAll(RegExp(r'\bkg\b'), spanish ? 'kilogramos' : 'kilograms')
      .replaceAll(RegExp(r'\bN\b'), 'newtons')
      .replaceAll('=', spanish ? 'es igual a' : 'equals')
      .replaceAllMapped(
        RegExp(r'(\d)[.,](\d+)'),
        (match) => '${match[1]} ${spanish ? 'punto' : 'point'} ${match[2]}',
      );
}
