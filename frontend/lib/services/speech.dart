import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Speaks lesson text using the clearest matching voice installed on the
/// learner's device.
class TermSpeaker {
  TermSpeaker._();

  static final TermSpeaker instance = TermSpeaker._();

  static const _englishLocale = 'en-US';
  static const _spanishLocale = 'es-MX';
  static const _webEnglishRate = 0.88;
  static const _webSpanishRate = 0.82;
  static const _nativeRate = 0.45;

  final _tts = FlutterTts();
  List<Map<String, String>>? _voices;

  Future<void> speak(String text, {required bool spanish}) async {
    try {
      await _tts.stop();
      if (spanish) {
        await _configureSpanishVoice();
      } else {
        await _tts.setLanguage(_englishLocale);
      }
      await _tts.setVolume(1.0);
      await _tts.setSpeechRate(
        kIsWeb ? (spanish ? _webSpanishRate : _webEnglishRate) : _nativeRate,
      );
      await _tts.setPitch(1.0);
      await _tts.speak(text);
    } on PlatformException catch (error, stackTrace) {
      _reportFailure(error, stackTrace);
    } on MissingPluginException catch (error, stackTrace) {
      _reportFailure(error, stackTrace);
    }
  }

  Future<void> _configureSpanishVoice() async {
    final voice = _bestSpanishVoice(await _availableVoices());
    final locale = voice?['locale'] ?? _spanishLocale;

    await _tts.setLanguage(locale);
    if (voice != null) {
      await _tts.setVoice(voice);
    }

    if (kDebugMode) {
      final Object description = voice ?? 'system default ($_spanishLocale)';
      debugPrint('Spanish TTS voice: $description');
    }
  }

  Future<List<Map<String, String>>> _availableVoices() async {
    final cached = _voices;
    if (cached != null) return cached;

    for (var attempt = 0; attempt < (kIsWeb ? 2 : 1); attempt++) {
      final rawVoices = await _tts.getVoices;
      final voices = _parseVoices(rawVoices);
      if (voices.isNotEmpty) {
        _voices = List.unmodifiable(voices);
        return _voices!;
      }
      if (kIsWeb) {
        await Future<void>.delayed(const Duration(milliseconds: 150));
      }
    }

    return const [];
  }

  List<Map<String, String>> _parseVoices(Object? rawVoices) {
    if (rawVoices is! Iterable) return const [];

    final voices = <Map<String, String>>[];
    for (final rawVoice in rawVoices) {
      if (rawVoice is! Map) continue;
      final name = rawVoice['name'];
      final locale = rawVoice['locale'];
      if (name is String && locale is String) {
        voices.add({'name': name, 'locale': locale});
      }
    }
    return voices;
  }

  Map<String, String>? _bestSpanishVoice(List<Map<String, String>> voices) {
    Map<String, String>? best;
    var bestScore = -1;

    for (final voice in voices) {
      final locale = _normalizeLocale(voice['locale']!);
      if (!locale.startsWith('es')) continue;

      final score = _spanishVoiceScore(
        name: voice['name']!.toLowerCase(),
        locale: locale,
      );
      if (score > bestScore) {
        best = voice;
        bestScore = score;
      }
    }
    return best;
  }

  int _spanishVoiceScore({required String name, required String locale}) {
    var score = switch (locale) {
      'es-mx' => 100,
      'es-us' => 70,
      'es-es' => 40,
      _ => 55,
    };

    if (name == 'paulina') score += 80;
    if (name.contains('natural') ||
        name.contains('neural') ||
        name.contains('enhanced') ||
        name.contains('premium')) {
      score += 50;
    }
    if (name.contains('google') || name.contains('microsoft')) {
      score += 30;
    }
    if (name.contains('eddy') ||
        name.contains('flo') ||
        name.contains('grandma') ||
        name.contains('grandpa') ||
        name.contains('rocko') ||
        name.contains('sandy') ||
        name.contains('shelley')) {
      score -= 40;
    }
    return score;
  }

  String _normalizeLocale(String locale) =>
      locale.replaceAll('_', '-').toLowerCase();

  void _reportFailure(Object error, StackTrace stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'Physics Quest speech service',
        context: ErrorDescription('while reading lesson text aloud'),
      ),
    );
  }
}
