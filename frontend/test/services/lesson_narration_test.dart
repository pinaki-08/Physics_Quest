import 'package:flutter_test/flutter_test.dart';
import 'package:physics_quest/services/lesson_narration.dart';

void main() {
  test('reads a whole-number speed equation naturally', () {
    expect(
      speedEquationNarration(distanceMetres: 100, timeSeconds: 20),
      '100 metres divided by 20 seconds equals 5 metres per second.',
    );
  });

  test('reads a decimal speed equation naturally', () {
    expect(
      speedEquationNarration(distanceMetres: 30, timeSeconds: 20),
      '30 metres divided by 20 seconds equals 1.5 metres per second.',
    );
  });

  test('reads a whole-number speed equation naturally in Spanish', () {
    expect(
      speedEquationNarrationEs(distanceMetres: 100, timeSeconds: 20),
      '100 metros divididos entre 20 segundos es igual a 5 metros por segundo.',
    );
  });

  test('uses a decimal comma in Spanish narration', () {
    expect(
      speedEquationNarrationEs(distanceMetres: 30, timeSeconds: 20),
      '30 metros divididos entre 20 segundos es igual a 1,5 metros por segundo.',
    );
  });

  test('reads English key points and verbalizes the equals sign', () {
    expect(
      keyPointsNarration(const [
        'Speed = distance divided by time.',
      ], spanish: false),
      'Remember this. Speed equals distance divided by time.',
    );
  });

  test('reads Spanish key points and verbalizes the equals sign', () {
    expect(
      keyPointsNarration(const [
        'Velocidad = distancia dividida entre tiempo.',
      ], spanish: true),
      'Recuerda esto. Velocidad es igual a distancia dividida entre tiempo.',
    );
  });
}
