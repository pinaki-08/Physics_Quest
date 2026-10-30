import 'dart:async';

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

  test('a newer pronunciation cancels an earlier pending request', () async {
    final stopStarted = Completer<void>();
    final releaseStop = Completer<void>();
    var blockFirstStop = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'stop' && blockFirstStop) {
            blockFirstStop = false;
            stopStarted.complete();
            await releaseStop.future;
          }
          return 1;
        });

    final earlier = TermSpeaker.instance.speak('Velocidad', spanish: true);
    await stopStarted.future;
    final latest = TermSpeaker.instance.speak('Speed', spanish: false);
    releaseStop.complete();
    await Future.wait([earlier, latest]);

    expect(
      calls
          .where((call) => call.method == 'speak')
          .map((call) => call.arguments),
      ['Speed'],
    );
    expect(
      calls.lastWhere((call) => call.method == 'setLanguage').arguments,
      'en-US',
    );
  });

  test('stop cancels speech that is still being configured', () async {
    final stopStarted = Completer<void>();
    final releaseStop = Completer<void>();
    var blockFirstStop = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'stop' && blockFirstStop) {
            blockFirstStop = false;
            stopStarted.complete();
            await releaseStop.future;
          }
          return 1;
        });

    final speech = TermSpeaker.instance.speak('Speed', spanish: false);
    await stopStarted.future;
    final stop = TermSpeaker.instance.stop();
    releaseStop.complete();
    await Future.wait([speech, stop]);

    expect(calls.where((call) => call.method == 'speak'), isEmpty);
    expect(calls.last.method, 'stop');
  });
}
