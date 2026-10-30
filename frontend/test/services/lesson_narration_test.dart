import 'package:flutter_test/flutter_test.dart';
import 'package:physics_quest/services/lesson_narration.dart';

void main() {
  test('reads exercise gaps and matching formulas in both languages', () {
    expect(
      scienceTextNarration(
        'Speed = distance ÷ ___; speed × time.',
        spanish: false,
      ),
      'Speed equals distance divided by blank; speed times time.',
    );
    expect(
      scienceTextNarration(
        'Velocidad = distancia ÷ ___; 10 N per kg.',
        spanish: true,
      ),
      'Velocidad es igual a distancia dividido entre espacio en blanco; '
      '10 newtons por kilogramo.',
    );
  });
  test('reads MCQ force units and decimals naturally in English', () {
    expect(
      scienceTextNarration('3 kg at 10 N/kg = 30 N; 1.5 m/s.', spanish: false),
      '3 kilograms at 10 newtons per kilogram equals 30 newtons; '
      '1 point 5 metres per second.',
    );
  });

  test('reads MCQ force units and decimals naturally in Spanish', () {
    expect(
      scienceTextNarration('3 kg a 10 N/kg = 30 N; 0,6 m/s.', spanish: true),
      '3 kilogramos a 10 newtons por kilogramo es igual a 30 newtons; '
      '0 punto 6 metros por segundo.',
    );
  });

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
