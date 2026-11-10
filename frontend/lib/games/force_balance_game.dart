import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../services/speech.dart';
import '../theme.dart';
import '../widgets/back_bar.dart';
import '../widgets/game_icon_button.dart';
import 'force_balance_arena.dart';
import 'force_balance_model.dart';

class ForceBalanceGame extends StatefulWidget {
  const ForceBalanceGame({super.key});

  @override
  State<ForceBalanceGame> createState() => _ForceBalanceGameState();
}

class _ForceBalanceGameState extends State<ForceBalanceGame>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const _accent = Color(0xFF426D73);
  static const _helpEnglish =
      'Look at the blue wind arrow. Tap Push left or Push right to keep pushing. '
      'Tap again or Release to turn your push off. '
      'Match the two arrow lengths to balance the forces. '
      'If the box is moving, use a stronger opposite push to slow it, then balance again. '
      'N means newtons, the unit of force.';
  static const _helpSpanish =
      'Mira la flecha azul del viento. Toca Empujar a la izquierda o Empujar a la derecha. '
      'La fuerza queda activada. Toca otra vez o Soltar para quitar tu fuerza. '
      'Iguala el largo de las flechas para equilibrar las fuerzas. '
      'Si la caja se mueve, usa una fuerza contraria mayor para frenarla y luego vuelve a equilibrar. '
      'N significa newtons, la unidad de fuerza.';

  late final Ticker _ticker;
  late ForceBalanceRound _practice;
  late ForceBalanceRound _challenge;
  BalanceMode _mode = BalanceMode.practice;
  int _lessonIndex = 0;
  double _best = 0;
  Duration _lastTick = Duration.zero;
  bool _playing = false;
  bool _spanish = false;
  bool _reduced = false;
  bool _helpOpen = false;
  bool _speechUsed = false;

  ForceBalanceRound get _round =>
      _mode == BalanceMode.practice ? _practice : _challenge;
  String get _goal => _mode == BalanceMode.practice
      ? balanceLessons[_lessonIndex].instruction
      : 'Challenge: keep the box in the green zone.';
  String get _goalEs => _mode == BalanceMode.practice
      ? balanceLessons[_lessonIndex].instructionEs
      : 'Reto: mantén la caja en la zona verde.';

  @override
  void initState() {
    super.initState();
    _practice = ForceBalanceRound.practice(balanceLessons.first);
    _challenge = ForceBalanceRound.challenge();
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
    final dt = (elapsed - _lastTick).inMicroseconds /
        Duration.microsecondsPerSecond;
    _lastTick = elapsed;
    setState(() {
      _round.advance(dt);
      if (_round.ended || _round.balancePause) {
        _ticker.stop();
        _playing = false;
        if (_mode == BalanceMode.challenge) {
          _best = math.max(_best, _challenge.elapsed);
        }
      }
    });
  }

  void _pause() {
    if (!_playing) return;
    _ticker.stop();
    setState(() => _playing = false);
  }

  void _stopSpeech() {
    if (!_speechUsed) return;
    _speechUsed = false;
    unawaited(TermSpeaker.instance.stop());
  }

  void _play() {
    if (_round.ended) return;
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
    if (_round.ended || _playing) return;
    _stopSpeech();
    setState(() {
      _round.advance(1);
      if (_mode == BalanceMode.challenge && _round.ended) {
        _best = math.max(_best, _round.elapsed);
      }
    });
  }

  void _push(BoxPush direction) {
    setState(() {
      _round.setPush(_round.push == direction ? BoxPush.none : direction);
    });
  }

  void _strength(double value) {
    setState(() => _round.setStrength(value));
  }

  void _reset() {
    _pause();
    _stopSpeech();
    setState(() {
      if (_mode == BalanceMode.challenge) {
        _best = math.max(_best, _challenge.elapsed);
      }
      _round.reset();
    });
  }

  void _modeChanged(BalanceMode mode) {
    _pause();
    _stopSpeech();
    setState(() => _mode = mode);
  }

  void _next() {
    if (_mode != BalanceMode.practice ||
        !_practice.won ||
        _lessonIndex + 1 >= balanceLessons.length) {
      return;
    }
    _stopSpeech();
    setState(() {
      _lessonIndex++;
      _practice = ForceBalanceRound.practice(balanceLessons[_lessonIndex]);
    });
  }

  void _practiceAgain() {
    _pause();
    _stopSpeech();
    setState(() {
      _mode = BalanceMode.practice;
      _lessonIndex = 0;
      _practice = ForceBalanceRound.practice(balanceLessons.first);
    });
  }

  void _speak({required bool spanish}) {
    _pause();
    _speechUsed = true;
    final text = spanish
        ? '$_goalEs ${_round.cue.spanish} $_helpSpanish'
        : '$_goal ${_round.cue.english} $_helpEnglish';
    unawaited(TermSpeaker.instance.speak(text, spanish: spanish));
  }

  GameIconButton _icon({
    required String key,
    required String label,
    required String labelEs,
    required IconData icon,
    required VoidCallback? onPressed,
    bool tonal = false,
  }) => GameIconButton(
    key: ValueKey(key),
    label: _spanish ? '$label / $labelEs' : label,
    icon: icon,
    onPressed: onPressed,
    tonal: tonal,
    color: _accent,
  );

  Widget _goalCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _goal,
                  key: const ValueKey('balance-goal'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.2),
                ),
              ),
              _icon(
                key: 'balance-audio-en',
                label: 'Listen to instructions in English',
                labelEs: 'Escuchar instrucciones en inglés',
                icon: Icons.volume_up_outlined,
                onPressed: () => _speak(spanish: false),
              ),
              MergeSemantics(
                key: const ValueKey('balance-language'),
                child: Semantics(
                  label: 'Spanish help / Ayuda en español',
                  toggled: _spanish,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: _accent,
                      minimumSize: const Size(40, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: () {
                      _pause();
                      setState(() => _spanish = !_spanish);
                    },
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
                    _goalEs,
                    key: const ValueKey('balance-spanish-goal'),
                    style: const TextStyle(fontSize: 16, height: 1.3),
                  ),
                ),
                _icon(
                  key: 'balance-audio-es',
                  label: 'Listen to instructions in Spanish',
                  labelEs: 'Escuchar instrucciones en español',
                  icon: Icons.volume_up_outlined,
                  onPressed: () => _speak(spanish: true),
                ),
              ],
            ),
          if (_mode == BalanceMode.challenge)
            Text(
              '${_spanish ? 'Mejor tiempo' : 'Best'}: ${_best.toStringAsFixed(1)} s',
              style: const TextStyle(fontSize: 12, color: AppColors.ink),
            ),
        ],
      ),
    );
  }

  Widget _cueCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _round.won ? const Color(0xFFDFEBDD) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _round.cue.english,
                  key: const ValueKey('balance-cue'),
                  style: const TextStyle(fontSize: 14, height: 1.25),
                ),
                if (_spanish)
                  Text(
                    _round.cue.spanish,
                    key: const ValueKey('balance-spanish-cue'),
                    style: const TextStyle(fontSize: 13, height: 1.25),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${balanceNumber(_round.netForce.abs())} N total',
            key: const ValueKey('balance-result-label'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _round.balanced ? const Color(0xFF496650) : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _strengthControl() {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _spanish ? 'Tu fuerza' : 'Push strength',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                '${balanceNumber(_round.strength)} N',
                style: const TextStyle(fontSize: 18, color: balancePushColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Expanded(
          child: MergeSemantics(
            key: const ValueKey('balance-strength'),
            child: Semantics(
              label: _spanish ? 'Push strength / Intensidad de tu fuerza' : 'Push strength',
              child: Slider(
                value: _round.strength,
                min: 0,
                max: ForceBalanceRound.maxStrength,
                divisions: 12,
                activeColor: balancePushColor,
                label: '${balanceNumber(_round.strength)} N',
                semanticFormatterCallback: (value) => '${balanceNumber(value)} newtons',
                onChanged: _round.ended ? null : _strength,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pushButton(BoxPush push, String key, String english, String spanish, IconData icon) {
    final selected = _round.push == push;
    return Expanded(
      child: MergeSemantics(
        child: Semantics(
          selected: selected,
          child: OutlinedButton.icon(
            key: ValueKey(key),
            onPressed: _round.ended
                ? null
                : push == BoxPush.none
                ? () => setState(() => _round.setPush(BoxPush.none))
                : () => _push(push),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.ink,
              backgroundColor: selected ? const Color(0xFFE8DFD5) : AppColors.surface,
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              side: BorderSide(color: selected ? balancePushColor : AppColors.line),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: Icon(icon, size: 18),
            label: Text(
              _spanish ? '$english\n$spanish' : english,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pushControls() => Row(
    children: [
      _pushButton(BoxPush.left, 'balance-left', 'Push left', 'Empujar a la izquierda', Icons.arrow_back_rounded),
      const SizedBox(width: 6),
      _pushButton(BoxPush.none, 'balance-release', 'Release', 'Soltar', Icons.pan_tool_outlined),
      const SizedBox(width: 6),
      _pushButton(BoxPush.right, 'balance-right', 'Push right', 'Empujar a la derecha', Icons.arrow_forward_rounded),
    ],
  );

  Widget _primary(String key, String english, String spanish, IconData icon, VoidCallback onPressed) {
    return Expanded(
      child: FilledButton.icon(
        key: ValueKey(key),
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: _accent,
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          _spanish ? '$english / $spanish' : english,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }

  Widget _playControls() {
    return Row(
      children: [
        if (_mode == BalanceMode.practice && _round.won)
          if (_lessonIndex + 1 < balanceLessons.length)
            _primary('balance-next', 'Next practice', 'Siguiente práctica', Icons.arrow_forward_rounded, _next)
          else
            _primary('balance-try-challenge', 'Try challenge', 'Probar reto', Icons.sports_esports_outlined, () => _modeChanged(BalanceMode.challenge))
        else if (_round.edgeReached)
          _primary('balance-play', 'Try again', 'Intentar otra vez', Icons.replay_rounded, _reset)
        else
          _primary(
            'balance-play',
            _reduced ? 'Move 1 second' : _playing ? 'Pause' : 'Play',
            _reduced ? 'Avanzar 1 segundo' : _playing ? 'Pausar' : 'Jugar',
            _reduced ? Icons.skip_next_rounded : _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
            _play,
          ),
        if (!_playing && !_round.ended && !_reduced) ...[
          const SizedBox(width: 4),
          _icon(
            key: 'balance-step',
            label: 'Move one second',
            labelEs: 'Avanzar un segundo',
            icon: Icons.skip_next_rounded,
            onPressed: _step,
            tonal: true,
          ),
        ],
        const SizedBox(width: 4),
        PopupMenuButton<BalanceMode>(
          key: const ValueKey('balance-mode'),
          tooltip: 'Choose guided practice or survival challenge',
          initialValue: _mode,
          onOpened: _pause,
          onSelected: _modeChanged,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: BalanceMode.practice,
              child: Text(_spanish ? 'Práctica guiada' : 'Guided practice'),
            ),
            PopupMenuItem(
              value: BalanceMode.challenge,
              child: Text(_spanish ? 'Reto de supervivencia' : 'Survival challenge'),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _mode == BalanceMode.practice
                      ? (_spanish ? 'Práctica' : 'Practice')
                      : (_spanish ? 'Reto' : 'Challenge'),
                  style: const TextStyle(fontSize: 12, color: _accent),
                ),
                const Icon(Icons.expand_more_rounded, size: 16, color: _accent),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lessonBackground,
      appBar: BackBar(
        title: const Text(
          'Hold the Line',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        actions: [
          Text(
            _mode == BalanceMode.practice
                ? '${_lessonIndex + 1} / ${balanceLessons.length}'
                : '${_challenge.elapsed.toStringAsFixed(1)} s',
            key: const ValueKey('balance-count'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          _icon(
            key: 'balance-reset',
            label: 'Reset box',
            labelEs: 'Reiniciar caja',
            icon: Icons.restart_alt_rounded,
            onPressed: _reset,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final large = MediaQuery.textScalerOf(context).scale(14) > 19;
            final height = large ? 220.0 : constraints.maxHeight < 650 ? 140.0 : 210.0;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _goalCard(),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: height,
                        child: ForceBalanceArena(
                          round: _round,
                          playing: _playing,
                          spanish: _spanish,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _cueCard(),
                      if (!_round.ended) ...[
                        const SizedBox(height: 4),
                        _strengthControl(),
                        _pushControls(),
                      ],
                      const SizedBox(height: 6),
                      _playControls(),
                      TextButton.icon(
                        key: const ValueKey('balance-help'),
                        onPressed: () {
                          _pause();
                          setState(() => _helpOpen = !_helpOpen);
                        },
                        icon: const Icon(Icons.help_outline_rounded, size: 18),
                        label: Text(_spanish ? 'Cómo jugar' : 'How to play'),
                      ),
                      if (_helpOpen)
                        Text(
                          _spanish ? '$_helpEnglish\n\n$_helpSpanish' : _helpEnglish,
                          key: const ValueKey('balance-help-text'),
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                      if (_mode == BalanceMode.practice && _round.won && _lessonIndex + 1 == balanceLessons.length)
                        TextButton(
                          key: const ValueKey('balance-replay'),
                          onPressed: _practiceAgain,
                          child: Text(_spanish ? 'Repetir práctica' : 'Practice again'),
                        ),
                      if (_reduced)
                        Text(
                          _spanish ? 'Modo por pasos: un segundo cada vez.' : 'Step mode: one second at a time.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: AppColors.ink),
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
