import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:physics_quest/services/speech.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter_tts');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'getVoices') {
            return [
              {'name': 'Eddy (Spanish (Mexico))', 'locale': 'es-MX'},
              {'name': 'Paulina', 'locale': 'es-MX'},
              {'name': 'Google español de Estados Unidos', 'locale': 'es-US'},
            ];
          }
          return 1;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('Spanish playback selects a clear Mexican voice', () async {
    await TermSpeaker.instance.speak('La pelota se mueve.', spanish: true);

    expect(
      calls.singleWhere((call) => call.method == 'setLanguage').arguments,
      'es-MX',
    );
    expect(calls.singleWhere((call) => call.method == 'setVoice').arguments, {
      'name': 'Paulina',
      'locale': 'es-MX',
    });
    expect(
      calls.singleWhere((call) => call.method == 'setSpeechRate').arguments,
      0.45,
    );
    expect(
      calls.singleWhere((call) => call.method == 'setVolume').arguments,
      1.0,
    );
  });
}
