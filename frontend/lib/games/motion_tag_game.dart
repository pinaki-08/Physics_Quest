import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../services/speech.dart';
import '../theme.dart';
import '../widgets/back_bar.dart';
import '../widgets/game_icon_button.dart';
import 'motion_tag_arena.dart';
import 'motion_tag_model.dart';

class MotionTagGame extends StatefulWidget {
  const MotionTagGame({super.key});

  @override
  State<MotionTagGame> createState() => _MotionTagGameState();
}

class _MotionTagGameState extends State<MotionTagGame>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const _accent = Color(0xFF426D73);
  late final Ticker _ticker;
  late MotionTagRound _round;
  int _missionIndex = 0;
  Duration _lastTick = Duration.zero;
  bool _playing = false;
  bool _spanish = false;
  bool _reduced = false;
  bool _speechUsed = false;

  @override
  void initState() {
    super.initState();
    _round = MotionTagRound(tagMissions.first);
    _ticker = createTicker(_tick);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.disableAnimationsOf(context);
    if (_reduced && _playing) {
      _ticker.stop();
      _playing = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _pause();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_speechUsed) unawaited(TermSpeaker.instance.stop());
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    final delta =
        (elapsed - _lastTick).inMicroseconds / Duration.microsecondsPerSecond;
    _lastTick = elapsed;
    setState(() {
      _round.advance(delta);
      if (_round.won) {
        _ticker.stop();
        _playing = false;
      }
    });
  }

  void _stopSpeech() {
    if (!_speechUsed) return;
    _speechUsed = false;
    unawaited(TermSpeaker.instance.stop());
  }

  void _pause() {
    if (!_playing) return;
    _ticker.stop();
    setState(() => _playing = false);
  }

  void _togglePlay() {
    if (_round.won) return;
    _stopSpeech();
    if (_reduced) {
      _step();
    } else if (_playing) {
      _pause();
    } else {
      final lifecycle = WidgetsBinding.instance.lifecycleState;
      if (lifecycle != null && lifecycle != AppLifecycleState.resumed) return;
      _lastTick = Duration.zero;
      setState(() => _playing = true);
      _ticker.start();
    }
  }

  void _step() {
    if (_round.won || _playing) return;
    _stopSpeech();
    setState(() => _round.advance(1));
  }

  void _changeSpeed(double value) {
    setState(() => _round.setSpeed(value));
  }

  void _reset() {
    _pause();
    _stopSpeech();
    setState(_round.reset);
  }

  void _next() {
    if (!_round.won || _missionIndex + 1 >= tagMissions.length) return;
    _stopSpeech();
    setState(() {
      _missionIndex++;
      _round = MotionTagRound(tagMissions[_missionIndex]);
    });
  }

  void _replay() {
    _pause();
    _stopSpeech();
    setState(() {
      _missionIndex = 0;
      _round = MotionTagRound(tagMissions.first);
    });
  }

  void _speak({required bool spanish}) {
    _pause();
    _speechUsed = true;
    unawaited(
      TermSpeaker.instance.speak(
        spanish ? _round.mission.instructionEs : _round.mission.instruction,
        spanish: spanish,
      ),
    );
  }

  void _toggleSpanish() {
    _pause();
    setState(() => _spanish = !_spanish);
  }

  Widget _iconControl({
    required String key,
    required String english,
    required String spanish,
    required IconData icon,
    required VoidCallback? onPressed,
    bool tonal = true,
    bool? selected,
  }) {
    final label = _spanish ? '$english / $spanish' : english;
    return GameIconButton(
      key: ValueKey(key),
      label: label,
      icon: icon,
      onPressed: onPressed,
      selected: selected,
      tonal: tonal,
      color: _accent,
    );
  }

  Widget _goal() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _round.mission.instruction,
                  key: const ValueKey('tag-goal'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
              _iconControl(
                key: 'tag-audio-en',
                english: 'Listen to the goal in English',
                spanish: 'Escuchar la meta en inglés',
                tonal: false,
                onPressed: () => _speak(spanish: false),
                icon: Icons.volume_up_outlined,
              ),
              MergeSemantics(
                key: const ValueKey('tag-language'),
                child: Semantics(
                  label: 'Spanish help / Ayuda en español',
                  toggled: _spanish,
                  child: TextButton(
                    onPressed: _toggleSpanish,
                    style: TextButton.styleFrom(
                      foregroundColor: _accent,
                      minimumSize: const Size(40, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const ExcludeSemantics(child: Text('ES')),
                  ),
                ),
              ),
            ],
          ),
          if (_spanish)
            Row(
              children: [
                Expanded(
                  child: Text(
                    _round.mission.instructionEs,
                    key: const ValueKey('tag-spanish-goal'),
                    style: const TextStyle(fontSize: 16, height: 1.3),
                  ),
                ),
                _iconControl(
                  key: 'tag-audio-es',
                  english: 'Listen to the goal in Spanish',
                  spanish: 'Escuchar la meta en español',
                  tonal: false,
                  onPressed: () => _speak(spanish: true),
                  icon: Icons.volume_up_outlined,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _cue() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _round.won ? const Color(0xFFDFEBDD) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _round.won ? _round.mission.success : _round.cue.english,
            key: const ValueKey('tag-cue'),
            style: const TextStyle(
              fontSize: 14,
              height: 1.25,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_spanish)
            Text(
              _round.won ? _round.mission.successEs : _round.cue.spanish,
              key: const ValueKey('tag-spanish-cue'),
              style: const TextStyle(fontSize: 13, height: 1.25),
            ),
        ],
      ),
    );
  }

  Widget _speedControl() {
    return Row(
      children: [
        SizedBox(
          width: 78,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _spanish ? 'Tu velocidad' : 'Your speed',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                '${tagNumber(_round.speed)} m/s',
                style: const TextStyle(
                  fontSize: 18,
                  color: tagPlayerColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: MergeSemantics(
            key: const ValueKey('tag-speed'),
            child: Semantics(
              label: _spanish
                  ? 'Your robot speed / Tu velocidad'
                  : 'Your robot speed',
              child: Slider(
                value: _round.speed,
                min: 0,
                max: MotionTagRound.maxSpeed,
                divisions: 4,
                activeColor: tagPlayerColor,
                label: '${tagNumber(_round.speed)} m/s',
                semanticFormatterCallback: (value) =>
                    '${tagNumber(value)} ${value == 1 ? 'meter' : 'meters'} per second',
                onChanged: _round.won ? null : _changeSpeed,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            '${_spanish ? 'Azul' : 'Blue'}\n${tagNumber(_round.mission.blueSpeed)} m/s',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: tagBlueColor),
          ),
        ),
      ],
    );
  }

  Widget _controls() {
    final enabled = !_round.won;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _iconControl(
          key: 'tag-left',
          english: 'Move left',
          spanish: 'Mover a la izquierda',
          selected: _round.direction == TagDirection.left,
          onPressed: enabled
              ? () => setState(() => _round.setDirection(TagDirection.left))
              : null,
          icon: Icons.arrow_back_rounded,
        ),
        _iconControl(
          key: 'tag-right',
          english: 'Move right',
          spanish: 'Mover a la derecha',
          selected: _round.direction == TagDirection.right,
          onPressed: enabled
              ? () => setState(() => _round.setDirection(TagDirection.right))
              : null,
          icon: Icons.arrow_forward_rounded,
        ),
        const SizedBox(height: 28, child: VerticalDivider(width: 8)),
        _iconControl(
          key: 'tag-slower',
          english: 'Slower',
          spanish: 'Más despacio',
          onPressed: enabled && _round.speed > 0
              ? () => _changeSpeed(
                  math.max(0.0, _round.speed - MotionTagRound.speedStep),
                )
              : null,
          icon: Icons.remove_rounded,
        ),
        _iconControl(
          key: 'tag-stop',
          english: 'Stop your robot',
          spanish: 'Detener tu robot',
          onPressed: enabled ? () => _changeSpeed(0) : null,
          icon: Icons.stop_rounded,
        ),
        _iconControl(
          key: 'tag-faster',
          english: 'Faster',
          spanish: 'Más rápido',
          onPressed: enabled && _round.speed < MotionTagRound.maxSpeed
              ? () => _changeSpeed(
                  math.min(
                    MotionTagRound.maxSpeed,
                    _round.speed + MotionTagRound.speedStep,
                  ),
                )
              : null,
          icon: Icons.add_rounded,
        ),
      ],
    );
  }

  Widget _primary({
    required String key,
    required String english,
    required String spanish,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return FilledButton.icon(
      key: ValueKey(key),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(
        _spanish ? '$english / $spanish' : english,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: _accent,
        minimumSize: const Size(0, 46),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _playControls() {
    if (_round.won) {
      return _missionIndex + 1 == tagMissions.length
          ? _primary(
              key: 'tag-replay',
              english: 'Play again',
              spanish: 'Volver a jugar',
              icon: Icons.replay_rounded,
              onPressed: _replay,
            )
          : _primary(
              key: 'tag-next',
              english: 'Next goal',
              spanish: 'Siguiente reto',
              icon: Icons.arrow_forward_rounded,
              onPressed: _next,
            );
    }
    return Row(
      children: [
        Expanded(
          child: _primary(
            key: 'tag-play',
            english: _reduced
                ? 'Move 1 second'
                : _playing
                ? 'Pause'
                : 'Play',
            spanish: _reduced
                ? 'Avanzar 1 segundo'
                : _playing
                ? 'Pausar'
                : 'Jugar',
            icon: _reduced
                ? Icons.skip_next_rounded
                : _playing
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            onPressed: _togglePlay,
          ),
        ),
        if (!_playing && !_reduced) ...[
          const SizedBox(width: 8),
          _iconControl(
            key: 'tag-step',
            english: 'Move one second',
            spanish: 'Avanzar un segundo',
            onPressed: _step,
            icon: Icons.skip_next_rounded,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lessonBackground,
      appBar: BackBar(
        title: const Text(
          'Motion Tag',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        actions: [
          Text(
            '${_missionIndex + 1} / ${tagMissions.length}',
            key: const ValueKey('tag-count'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          _iconControl(
            key: 'tag-reset',
            english: 'Reset positions',
            spanish: 'Reiniciar posiciones',
            tonal: false,
            onPressed: _reset,
            icon: Icons.restart_alt_rounded,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final largeText = MediaQuery.textScalerOf(context).scale(14) > 19;
            final height = largeText
                ? 220.0
                : constraints.maxHeight < 600
                ? 150.0
                : 230.0;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _goal(),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: height,
                        child: MotionTagArena(
                          round: _round,
                          playing: _playing,
                          spanish: _spanish,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _cue(),
                      const SizedBox(height: 4),
                      if (!_round.won) ...[
                        _speedControl(),
                        _controls(),
                        const SizedBox(height: 4),
                      ],
                      _playControls(),
                      const SizedBox(height: 4),
                      Text(
                        _reduced
                            ? (_spanish
                                  ? 'Modo por pasos: avanza un segundo cada vez.'
                                  : 'Step mode: move one second at a time.')
                            : (_spanish
                                  ? 'Cambia la velocidad al moverte. Puedes pausar cuando quieras.'
                                  : 'Change speed as you move. Pause any time.'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.3,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
