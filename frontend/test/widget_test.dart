import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:physics_quest/main.dart';
import 'package:physics_quest/views/lesson_screen.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  // Real phone size, so any layout overflow fails the test.
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const PhysicsQuestApp());
  await tester.pump(const Duration(milliseconds: 900));
}

/// The backdrop animation loops forever, so pumpAndSettle would never return.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('home shows the three choice cards', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Physics Quest'), findsOneWidget);
    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
  });

  testWidgets('tapping Learn opens the lessons screen', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Learn'));
    await _settle(tester);

    expect(find.text('Your lessons'), findsOneWidget);
    expect(find.text('Forces'), findsOneWidget);
  });

  testWidgets('lesson cards flip between English and Spanish', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Learn'));
    await _settle(tester);
    await tester.tap(find.text('Motion & Speed'));
    await _settle(tester);

    expect(find.bySemanticsLabel('Listen in English'), findsWidgets);
    expect(
      find.bySemanticsLabel('Escuchar traducción en español'),
      findsWidgets,
    );

    final flipButton = find.byKey(const ValueKey('section-1-flip-top'));
    await tester.tap(flipButton);
    await _settle(tester);

    expect(find.text('¿Qué es el movimiento?'), findsOneWidget);
    expect(find.textContaining('Algo está en movimiento'), findsOneWidget);
    expect(find.text('Volver al inglés'), findsOneWidget);
    expect(find.text('What is motion?'), findsNothing);

    await tester.tap(flipButton);
    await _settle(tester);

    expect(find.text('What is motion?'), findsOneWidget);
    expect(find.text('Ver en español'), findsWidgets);
  });

  testWidgets('highlighted vocabulary opens bilingual audio card', (
    tester,
  ) async {
    const ttsChannel = MethodChannel('flutter_tts');
    final ttsCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, (call) async {
          ttsCalls.add(call);
          return 1;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(ttsChannel, null),
    );

    await _pumpApp(tester);
    await tester.tap(find.text('Learn'));
    await _settle(tester);
    await tester.tap(find.text('Motion & Speed'));
    await _settle(tester);

    final motionWord = find.byKey(const ValueKey('vocabulary-motion'));
    expect(motionWord, findsOneWidget);
    await tester.tap(motionWord);
    await _settle(tester);

    expect(find.text('Motion'), findsOneWidget);
    expect(find.text('Movimiento'), findsOneWidget);
    expect(
      find.text('A change of position compared to a reference point.'),
      findsOneWidget,
    );
    expect(
      find.text('Un cambio de posición respecto a un punto de referencia.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('vocabulary-audio-en')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('vocabulary-audio-es')));
    await tester.pump();

    expect(
      ttsCalls
          .where((call) => call.method == 'speak')
          .map((call) => call.arguments),
      ['Motion', 'Movimiento'],
    );
  });

  testWidgets('Forces around you cards include bilingual detail and audio', (
    tester,
  ) async {
    const ttsChannel = MethodChannel('flutter_tts');
    final ttsCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, (call) async {
          ttsCalls.add(call);
          return 1;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(ttsChannel, null),
    );

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(18),
            child: ForceTypesDemo(),
          ),
        ),
      ),
    );

    expect(find.text('Gravity'), findsOneWidget);
    expect(find.text('Gravedad'), findsOneWidget);
    expect(find.text('Applied force'), findsOneWidget);
    expect(find.text('Fuerza aplicada'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('force-type-gravity')));
    await _settle(tester);

    const detailEn =
        'Gravity is a non-contact force that pulls objects with mass '
        'toward one another. Near Earth, it pulls objects toward the ground.';
    const detailEs =
        'La gravedad es una fuerza sin contacto que atrae entre sí a los '
        'objetos con masa. Cerca de la Tierra, atrae los objetos hacia el suelo.';
    const exampleEn =
        'Example: An apple falls because Earth’s gravity pulls it downward.';
    const exampleEs =
        'Ejemplo: Una manzana cae porque la gravedad de la Tierra la atrae hacia abajo.';

    expect(find.text(detailEn), findsOneWidget);
    expect(find.text(detailEs), findsOneWidget);
    expect(find.text(exampleEn), findsOneWidget);
    expect(find.text(exampleEs), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('force-type-audio-en-gravity')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('force-type-audio-es-gravity')));
    await tester.pump();

    expect(
      ttsCalls
          .where((call) => call.method == 'speak')
          .map((call) => call.arguments),
      ['Gravity. $detailEn $exampleEn', 'Gravedad. $detailEs $exampleEs'],
    );
  });

  testWidgets('speed formula reads the equation in English', (tester) async {
    const ttsChannel = MethodChannel('flutter_tts');
    final ttsCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, (call) async {
          ttsCalls.add(call);
          return 1;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(ttsChannel, null),
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SpeedFormulaDemo())),
    );
    final audioButton = find.byKey(const ValueKey('speed-equation-audio'));
    expect(audioButton, findsOneWidget);
    expect(
      find.bySemanticsLabel('Listen to the equation in English'),
      findsOneWidget,
    );
    await tester.tap(audioButton);
    await tester.pump();

    final spanishAudioButton = find.byKey(
      const ValueKey('speed-equation-audio-es'),
    );
    expect(spanishAudioButton, findsOneWidget);
    expect(
      find.bySemanticsLabel('Escuchar la ecuación en español'),
      findsOneWidget,
    );
    await tester.tap(spanishAudioButton);
    await tester.pump();

    expect(
      ttsCalls
          .where((call) => call.method == 'speak')
          .map((call) => call.arguments),
      [
        '100 metres divided by 20 seconds equals 5 metres per second.',
        '100 metros divididos entre 20 segundos es igual a 5 metros por segundo.',
      ],
    );
  });

  testWidgets('Remember this card flips and reads both languages', (
    tester,
  ) async {
    const ttsChannel = MethodChannel('flutter_tts');
    final ttsCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ttsChannel, (call) async {
          ttsCalls.add(call);
          return 1;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(ttsChannel, null),
    );

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(18),
            child: KeyPointsCard(
              points: [
                'Motion is a change of position.',
                'Speed = distance divided by time.',
              ],
              pointsEs: [
                'El movimiento es un cambio de posición.',
                'Velocidad = distancia dividida entre tiempo.',
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('key-points-en')), findsOneWidget);
    expect(find.text('Remember this'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('key-points-audio-en')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('key-points-audio-es')));
    await tester.pump();

    expect(
      ttsCalls
          .where((call) => call.method == 'speak')
          .map((call) => call.arguments),
      [
        'Remember this. Motion is a change of position. '
            'Speed equals distance divided by time.',
        'Recuerda esto. El movimiento es un cambio de posición. '
            'Velocidad es igual a distancia dividida entre tiempo.',
      ],
    );

    await tester.tap(find.byKey(const ValueKey('key-points-flip-top')));
    await _settle(tester);

    expect(find.byKey(const ValueKey('key-points-es')), findsOneWidget);
    expect(find.text('Recuerda esto'), findsOneWidget);
    expect(
      find.text('El movimiento es un cambio de posición.'),
      findsOneWidget,
    );
    expect(find.text('Back to English'), findsOneWidget);
  });

  testWidgets('acceleration graph is slow and has playback controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(18),
            child: SpeedChangeDemo(),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('speed-change-graph')), findsOneWidget);
    expect(find.text('Pause animation'), findsOneWidget);
    expect(find.textContaining('time moves left to right'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Halfway'), findsOneWidget);
    expect(find.text('Pause animation'), findsOneWidget);

    final playback = find.byKey(const ValueKey('speed-change-playback'));
    await tester.tap(playback);
    await tester.pump();
    expect(find.text('Continue animation'), findsOneWidget);

    await tester.tap(playback);
    await tester.pump();
    expect(find.text('Pause animation'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Finished'), findsOneWidget);
    expect(find.text('Replay animation'), findsOneWidget);

    await tester.tap(playback);
    await tester.pump();
    expect(find.text('Starting'), findsOneWidget);
    expect(find.text('Pause animation'), findsOneWidget);
  });

  testWidgets('tapping Practice opens the quiz list', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Practice'));
    await _settle(tester);

    expect(find.text('Daily Challenge'), findsOneWidget);
    expect(find.text('Practice a lesson'), findsOneWidget);
    // Quizzes are built from lesson data, so a lesson title proves the
    // repository was read rather than a placeholder rendered.
    expect(find.text('Motion & Speed'), findsOneWidget);
  });

  testWidgets('tapping Play opens the games screen and can go back', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Play'));
    await _settle(tester);
    expect(find.text('Speed Run'), findsOneWidget);
    expect(find.text('Soft Landing'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await _settle(tester);
    expect(find.text('Physics Quest'), findsOneWidget);
  });
}
