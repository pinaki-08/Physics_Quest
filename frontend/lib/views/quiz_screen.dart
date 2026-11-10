import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/progress_repository.dart';
import '../models/lesson.dart';
import '../services/lesson_narration.dart';
import '../services/speech.dart';
import '../theme.dart';
import '../widgets/back_bar.dart';
import '../widgets/bouncy.dart';
import '../widgets/practice_drag_card.dart';
import '../widgets/vocabulary_text.dart';

/// Options are shuffled per run. Without this the seeded answer index of 0
/// would make the first option correct every single time.
class _Shuffled {
  final String prompt;
  final String promptEs;
  final List<String> options;
  final List<String> optionsEs;
  final int answer;
  final int points;
  final QuestionKind kind;
  final List<MatchPair> pairs;
  final List<int> rightOrder;
  final String explanation;
  final String explanationEs;

  const _Shuffled({
    required this.prompt,
    this.promptEs = '',
    required this.options,
    this.optionsEs = const [],
    required this.answer,
    required this.points,
    required this.kind,
    required this.pairs,
    required this.rightOrder,
    required this.explanation,
    this.explanationEs = '',
  });

  factory _Shuffled.from(Question q, math.Random rng) {
    if (q.kind == QuestionKind.match) {
      final pairs = [...q.pairs]..shuffle(rng);
      final rightOrder = List<int>.generate(pairs.length, (index) => index)
        ..shuffle(rng);
      return _Shuffled(
        prompt: q.prompt,
        promptEs: q.hasSpanishTranslation ? q.promptEs : '',
        options: const [],
        answer: 0,
        points: q.points,
        kind: q.kind,
        pairs: pairs,
        rightOrder: rightOrder,
        explanation: q.explanation,
        explanationEs: q.hasSpanishTranslation ? q.explanationEs : '',
      );
    }
    final order = List<int>.generate(q.options.length, (i) => i)..shuffle(rng);
    return _Shuffled(
      prompt: q.prompt,
      promptEs: q.hasSpanishTranslation ? q.promptEs : '',
      options: [for (final i in order) q.options[i]],
      optionsEs: q.hasSpanishTranslation
          ? [for (final i in order) q.optionsEs[i]]
          : const [],
      answer: order.indexOf(q.answer),
      points: q.points,
      kind: q.kind,
      pairs: const [],
      rightOrder: const [],
      explanation: q.explanation,
      explanationEs: q.hasSpanishTranslation ? q.explanationEs : '',
    );
  }

  bool get hasSpanishTranslation => promptEs.isNotEmpty;
}

class QuizScreen extends StatefulWidget {
  final String quizId;
  final String title;
  final Color color;
  final List<Question> questions;
  final List<GlossaryTerm> glossary;

  const QuizScreen({
    super.key,
    required this.quizId,
    required this.title,
    required this.color,
    required this.questions,
    this.glossary = const [],
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const _maxLives = 3;
  static const _maxTries = 3;

  late List<_Shuffled> _deck;
  final _scroll = ScrollController();

  int _index = 0;
  int _score = 0;
  int _points = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _lives = _maxLives;
  int _lastAward = 0;
  bool _finished = false;

  /// Per question state.
  final _wrong = <int>{};
  bool _settled = false;
  bool _gotIt = false;
  bool _showSpanish = false;
  bool _hasSpoken = false;
  bool _advancing = false;
  int? _selectedOption;

  late final List<GlossaryTerm> _glossary = {
    for (final term in widget.glossary) term.en.toLowerCase(): term,
  }.values.toList();

  _Shuffled get _question => _deck[_index];
  String get _prefix => _question.kind.name;
  int get _triesLeft => _maxTries - _wrong.length;

  /// Consecutive correct answers increase the points multiplier.
  int get _multiplier => _streak >= 4
      ? 3
      : _streak >= 2
      ? 2
      : 1;

  @override
  void initState() {
    super.initState();
    _deal();
  }

  void _deal() {
    final rng = math.Random();
    _deck = [for (final q in widget.questions) _Shuffled.from(q, rng)];
  }

  @override
  void dispose() {
    if (_hasSpoken) unawaited(TermSpeaker.instance.stop());
    _scroll.dispose();
    super.dispose();
  }

  /// A wrong answer costs a try; only exhausting the tries costs a heart.
  void _choose(int option) {
    if (_settled || _wrong.contains(option)) return;
    if (option == _question.answer) {
      final attempt = _wrong.length;
      final share = attempt == 0
          ? 1.0
          : attempt == 1
          ? 0.5
          : 0.25;
      setState(() {
        _settled = true;
        _gotIt = true;
        _score++;
        _streak++;
        _bestStreak = math.max(_bestStreak, _streak);
        _lastAward = (_question.points * _multiplier * share).round();
        _points += _lastAward;
      });
      return;
    }

    setState(() {
      _wrong.add(option);
      _selectedOption = null;
    });
    if (_wrong.length >= _maxTries) {
      setState(() {
        _settled = true;
        _gotIt = false;
        _streak = 0;
        _lives--;
        _lastAward = 0;
      });
    }
  }

  Future<void> _next() async {
    if (_advancing || !mounted || !_settled || _finished) return;
    _advancing = true;
    try {
      await _stopAudio();
      if (!mounted) return;
      final lastQuestion = _index + 1 >= _deck.length;
      if (_lives <= 0 || lastQuestion) {
        setState(() => _finished = true);
        await progressRepository.recordAttempt(
          quizId: widget.quizId,
          score: _score,
          total: _deck.length,
          points: _points,
        );
        return;
      }
      setState(() {
        _index++;
        _wrong.clear();
        _settled = false;
        _gotIt = false;
        _showSpanish = false;
        _selectedOption = null;
      });
      if (_scroll.hasClients) _scroll.jumpTo(0);
    } finally {
      _advancing = false;
    }
  }

  Future<void> _restart() async {
    await _stopAudio();
    if (!mounted) return;
    setState(() {
      _deal();
      _index = 0;
      _score = 0;
      _points = 0;
      _streak = 0;
      _bestStreak = 0;
      _lives = _maxLives;
      _wrong.clear();
      _settled = false;
      _gotIt = false;
      _finished = false;
      _showSpanish = false;
      _selectedOption = null;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Future<void> _speak(String text, {required bool spanish}) async {
    _hasSpoken = true;
    await TermSpeaker.instance.speak(
      scienceTextNarration(text, spanish: spanish),
      spanish: spanish,
    );
  }

  Future<void> _stopAudio() async {
    if (!_hasSpoken) return;
    _hasSpoken = false;
    await TermSpeaker.instance.stop();
  }

  void _selectOption(int option) {
    if (_settled || _wrong.contains(option)) return;
    setState(() => _selectedOption = option);
  }

  void _checkAnswer() {
    final selected = _selectedOption;
    if (selected != null) _choose(selected);
  }

  Widget _languageButton(String key) {
    return TextButton.icon(
      key: ValueKey(key),
      onPressed: () => setState(() => _showSpanish = !_showSpanish),
      icon: const Icon(Icons.translate_rounded, size: 16),
      label: Text(_showSpanish ? 'English' : 'Español'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.learnDeep,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
    );
  }

  String? _filledWord({required bool spanish}) {
    if (_question.kind != QuestionKind.blank) return null;
    final index = _settled ? _question.answer : _selectedOption;
    if (index == null) return null;
    return spanish ? _question.optionsEs[index] : _question.options[index];
  }

  String _spokenPrompt({required bool spanish}) {
    final prompt = spanish ? _question.promptEs : _question.prompt;
    final filled = _filledWord(spanish: spanish);
    return filled == null ? prompt : prompt.replaceAll('___', filled);
  }

  String _explanationBody({required bool spanish}) {
    final q = _question;
    final explanation = spanish ? q.explanationEs : q.explanation;
    if (q.kind != QuestionKind.oddOneOut) return explanation;
    final answer = spanish ? q.optionsEs[q.answer] : q.options[q.answer];
    return '${spanish ? 'La tarjeta' : 'The card'} "$answer" '
        '${spanish ? 'no pertenece a este grupo.' : 'does not belong in this group.'} '
        '$explanation';
  }

  String _spokenExplanation({required bool spanish}) {
    final q = _question;
    final explanation = _explanationBody(spanish: spanish);
    if (q.kind == QuestionKind.match || q.kind == QuestionKind.oddOneOut) {
      return explanation;
    }
    final answer = spanish ? q.optionsEs[q.answer] : q.options[q.answer];
    return '${spanish ? 'La respuesta es' : 'The answer is'} $answer. '
        '$explanation';
  }

  Widget _prompt() {
    final q = _question;
    return Container(
      key: ValueKey('$_prefix-question-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VocabularyText(
            key: ValueKey('$_prefix-prompt'),
            text: _showSpanish ? q.promptEs : q.prompt,
            terms: _showSpanish ? const [] : _glossary,
            blankFill: _filledWord(spanish: _showSpanish),
            blankLabel: _showSpanish ? 'espacio en blanco' : 'blank',
            onSpeak: _speak,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _PracticeAudioControls(
                  keyPrefix: '$_prefix-prompt-audio',
                  english: _spokenPrompt(spanish: false),
                  spanishText: q.hasSpanishTranslation
                      ? _spokenPrompt(spanish: true)
                      : null,
                  onSpeak: _speak,
                  onStop: _stopAudio,
                ),
              ),
              if (q.hasSpanishTranslation)
                _languageButton('$_prefix-language-toggle'),
            ],
          ),
          if (!q.hasSpanishTranslation)
            const Text(
              'Spanish translation is not available for this question yet.',
              style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
            ),
          if (!_showSpanish && _glossary.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Tap a highlighted word for help.',
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: AppColors.inkSoft,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _answerArea() {
    final q = _question;
    if (q.kind == QuestionKind.match) {
      return _MatchBoard(
        key: ValueKey(_index),
        pairs: q.pairs,
        rightOrder: q.rightOrder,
        showSpanish: _showSpanish,
        glossary: _glossary,
        onSpeak: _speak,
        locked: _settled,
        onSolved: () => _choose(q.answer),
      );
    }
    if (q.kind == QuestionKind.oddOneOut) {
      return _OddOneOutBoard(
        key: ValueKey(_index),
        options: q.options,
        optionsEs: q.hasSpanishTranslation ? q.optionsEs : const [],
        answer: q.answer,
        wrong: _wrong,
        settled: _settled,
        gotIt: _gotIt,
        selected: _selectedOption,
        showSpanish: _showSpanish,
        glossary: _glossary,
        onSpeak: _speak,
        onSelect: _selectOption,
        onChoose: _choose,
      );
    }
    return RadioGroup<int>(
      groupValue: _selectedOption,
      onChanged: (option) {
        if (option != null) _selectOption(option);
      },
      child: Column(
        children: [
          for (var i = 0; i < q.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _Option(
                key: ValueKey('$_prefix-option-$i'),
                prefix: _prefix,
                index: i,
                selected: _selectedOption == i,
                text: _showSpanish ? q.optionsEs[i] : q.options[i],
                content: _showSpanish
                    ? null
                    : VocabularyText(
                        text: q.options[i],
                        terms: _glossary,
                        onSpeak: _speak,
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                audioMenu: _OptionAudioMenu(
                  prefix: _prefix,
                  index: i,
                  english: q.options[i],
                  spanishText: q.hasSpanishTranslation ? q.optionsEs[i] : null,
                  onSpeak: _speak,
                ),
                wrong: _wrong.contains(i),
                correct: i == q.answer,
                settled: _settled,
                onTap: () => _selectOption(i),
              ),
            ),
          if (!_settled) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: ValueKey('$_prefix-check-answer'),
                onPressed: _selectedOption == null ? null : _checkAnswer,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: Text(
                  _showSpanish ? 'Comprobar respuesta' : 'Check answer',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.learnDeep,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final needsReview = _settled;
    return Scaffold(
      backgroundColor: AppColors.lessonBackground,
      appBar: const BackBar(),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          key: const ValueKey('quiz-content'),
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
            children: [
              if (_finished)
                _Result(
                  score: _score,
                  total: _deck.length,
                  points: _points,
                  bestStreak: _bestStreak,
                  survived: _lives > 0,
                  color: widget.color,
                  onRetry: _restart,
                  onDone: () => Navigator.of(context).pop(),
                )
              else ...[
                _StatusBar(
                  title: widget.title,
                  kind: _question.kind,
                  spanish: _showSpanish,
                  lives: _lives,
                  maxLives: _maxLives,
                  multiplier: _multiplier,
                  index: _index,
                  total: _deck.length,
                ),
                const SizedBox(height: 16),
                _prompt(),
                const SizedBox(height: 16),
                _answerArea(),
                if (_settled || _wrong.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _Feedback(
                    settled: _settled,
                    gotIt: _gotIt,
                    award: _lastAward,
                    multiplier: _multiplier,
                    triesLeft: _triesLeft,
                    attempts: _wrong.length,
                  ),
                ],
                if (needsReview) ...[
                  const SizedBox(height: 12),
                  _Explanation(
                    heading: _showSpanish ? 'Explicación' : 'Explanation',
                    plain: true,
                    answer: _question.kind == QuestionKind.match
                        ? null
                        : (_showSpanish
                              ? _question.optionsEs[_question.answer]
                              : _question.options[_question.answer]),
                    why: _explanationBody(spanish: _showSpanish),
                    spanish: _showSpanish,
                    content: !_showSpanish
                        ? VocabularyText(
                            text: _explanationBody(spanish: false),
                            terms: _glossary,
                            onSpeak: _speak,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppColors.ink,
                            ),
                          )
                        : null,
                    audioControls: Row(
                      children: [
                        Expanded(
                          child: _PracticeAudioControls(
                            keyPrefix: '$_prefix-explanation-audio',
                            english: _spokenExplanation(spanish: false),
                            spanishText: _question.hasSpanishTranslation
                                ? _spokenExplanation(spanish: true)
                                : null,
                            onSpeak: _speak,
                            onStop: _stopAudio,
                          ),
                        ),
                        if (_question.hasSpanishTranslation)
                          _languageButton(
                            '$_prefix-explanation-language-toggle',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    key: ValueKey('$_prefix-next-question'),
                    onPressed: _next,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: Text(
                      _index + 1 < _deck.length && _lives > 0
                          ? (_question.kind == QuestionKind.match
                                ? (_showSpanish
                                      ? 'Siguiente ronda'
                                      : 'Next round')
                                : 'Next question')
                          : 'See result',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.learnDeep,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PracticeAudioControls extends StatelessWidget {
  final String keyPrefix;
  final String english;
  final String? spanishText;
  final Future<void> Function(String text, {required bool spanish}) onSpeak;
  final VoidCallback? onStop;

  const _PracticeAudioControls({
    required this.keyPrefix,
    required this.english,
    required this.spanishText,
    required this.onSpeak,
    this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final translation = spanishText;
    return Wrap(
      spacing: 2,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Tooltip(
          message: 'Listen in English',
          child: TextButton.icon(
            key: ValueKey('$keyPrefix-en'),
            onPressed: () => onSpeak(english, spanish: false),
            icon: const Icon(Icons.volume_up_outlined, size: 16),
            label: const Text('EN'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.inkSoft,
              minimumSize: const Size(0, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            ),
          ),
        ),
        Tooltip(
          message: 'Escuchar en español',
          child: TextButton.icon(
            key: ValueKey('$keyPrefix-es'),
            onPressed: translation == null
                ? null
                : () => onSpeak(translation, spanish: true),
            icon: const Icon(Icons.volume_up_outlined, size: 16),
            label: const Text('ES'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.inkSoft,
              minimumSize: const Size(0, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            ),
          ),
        ),
        if (onStop != null)
          IconButton(
            key: ValueKey('$keyPrefix-stop'),
            tooltip: 'Stop audio',
            onPressed: onStop,
            icon: const Icon(Icons.stop_rounded, size: 18),
            color: AppColors.inkSoft,
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
      ],
    );
  }
}

class _OptionAudioMenu extends StatelessWidget {
  final String prefix;
  final int index;
  final String english;
  final String? spanishText;
  final Future<void> Function(String text, {required bool spanish}) onSpeak;

  const _OptionAudioMenu({
    required this.prefix,
    required this.index,
    required this.english,
    required this.spanishText,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<bool>(
      key: ValueKey('$prefix-option-$index-audio-menu'),
      tooltip: 'Listen to this answer',
      icon: const Icon(
        Icons.volume_up_outlined,
        size: 20,
        color: AppColors.inkSoft,
      ),
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (spanish) {
        final text = spanish ? spanishText : english;
        if (text != null) onSpeak(text, spanish: spanish);
      },
      itemBuilder: (_) => [
        PopupMenuItem<bool>(
          key: ValueKey('$prefix-option-$index-audio-en'),
          value: false,
          child: const Text('Listen in English'),
        ),
        PopupMenuItem<bool>(
          key: ValueKey('$prefix-option-$index-audio-es'),
          value: true,
          enabled: spanishText != null,
          child: const Text('Escuchar en español'),
        ),
      ],
    );
  }
}

/// Names the right answer and the reasoning behind it.
class _Explanation extends StatelessWidget {
  final String? answer;
  final String why;
  final bool spanish;
  final Widget? content;
  final Widget? audioControls;
  final String? heading;
  final bool plain;

  const _Explanation({
    required this.answer,
    required this.why,
    this.spanish = false,
    this.content,
    this.audioControls,
    this.heading,
    this.plain = false,
  });

  @override
  Widget build(BuildContext context) {
    if (answer == null && why.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: plain ? AppColors.surface : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: plain
              ? AppColors.line
              : AppColors.learn.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_rounded,
                size: 18,
                color: AppColors.learn,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  heading ??
                      (answer == null
                          ? (spanish ? 'Por qué' : 'Why')
                          : (spanish
                                ? 'La respuesta es $answer'
                                : 'The answer is $answer')),
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.learnDeep,
                  ),
                ),
              ),
            ],
          ),
          if (why.isNotEmpty) ...[
            const SizedBox(height: 8),
            content ??
                Text(
                  why,
                  style: TextStyle(
                    fontSize: plain ? 14 : 13.5,
                    height: plain ? 1.5 : 1.45,
                    color: AppColors.ink,
                  ),
                ),
          ],
          if (audioControls != null) ...[
            const SizedBox(height: 12),
            audioControls!,
          ],
        ],
      ),
    );
  }
}

class _OddOneOutBoard extends StatefulWidget {
  final List<String> options;
  final List<String> optionsEs;
  final int answer;
  final Set<int> wrong;
  final bool settled;
  final bool gotIt;
  final int? selected;
  final bool showSpanish;
  final List<GlossaryTerm> glossary;
  final Future<void> Function(String text, {required bool spanish}) onSpeak;
  final ValueChanged<int> onSelect;
  final ValueChanged<int> onChoose;

  const _OddOneOutBoard({
    super.key,
    required this.options,
    required this.optionsEs,
    required this.answer,
    required this.wrong,
    required this.settled,
    required this.gotIt,
    required this.selected,
    required this.showSpanish,
    required this.glossary,
    required this.onSpeak,
    required this.onSelect,
    required this.onChoose,
  });

  @override
  State<_OddOneOutBoard> createState() => _OddOneOutBoardState();
}

class _OddOneOutBoardState extends State<_OddOneOutBoard> {
  static const _prefix = 'oddOneOut';
  int? _dragging;

  bool _available(int index) =>
      !widget.settled && !widget.wrong.contains(index);

  String _text(int index) =>
      widget.showSpanish ? widget.optionsEs[index] : widget.options[index];

  Widget _audio(int index) => _OptionAudioMenu(
    prefix: _prefix,
    index: index,
    english: widget.options[index],
    spanishText: widget.optionsEs.isEmpty ? null : widget.optionsEs[index],
    onSpeak: widget.onSpeak,
  );

  Widget _word(int index) {
    final wrong = !widget.settled && widget.wrong.contains(index);
    final selected = widget.selected == index && !widget.settled;
    final tone = widget.settled
        ? AppColors.playDeep
        : wrong
        ? const Color(0xFFAD533B)
        : AppColors.learnDeep;
    final active = selected || wrong || widget.settled;
    final enabled =
        _available(index) && (_dragging == null || _dragging == index);

    return PracticeDragCard(
      prefix: _prefix,
      index: index,
      text: _text(index),
      enabled: enabled,
      onDragStarted: () => setState(() => _dragging = index),
      onDragEnded: () {
        if (mounted) setState(() => _dragging = null);
      },
      child: Material(
        key: ValueKey('$_prefix-option-$index'),
        color: active ? tone.withValues(alpha: 0.05) : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: active ? tone : AppColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _available(index) ? () => widget.onSelect(index) : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 116),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.settled
                            ? Icons.check_rounded
                            : wrong
                            ? Icons.close_rounded
                            : Icons.drag_indicator_rounded,
                        size: 16,
                        color: active ? tone : AppColors.inkSoft,
                      ),
                      Semantics(
                        label: _text(index),
                        selected: selected,
                        child: TextButton(
                          key: ValueKey('$_prefix-option-$index-select'),
                          onPressed: _available(index)
                              ? () => widget.onSelect(index)
                              : null,
                          style: TextButton.styleFrom(
                            foregroundColor: tone,
                            minimumSize: const Size(32, 32),
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(String.fromCharCode(65 + index)),
                        ),
                      ),
                      const Spacer(),
                      _audio(index),
                    ],
                  ),
                  const SizedBox(height: 8),
                  VocabularyText(
                    text: _text(index),
                    terms: widget.showSpanish ? const [] : widget.glossary,
                    onSpeak: widget.onSpeak,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tray(bool hovering) {
    final selected = widget.selected;
    final tone = hovering
        ? AppColors.learnDeep
        : widget.settled && widget.gotIt
        ? AppColors.playDeep
        : widget.wrong.isNotEmpty
        ? const Color(0xFFAD533B)
        : AppColors.inkSoft;
    final title = widget.settled
        ? widget.gotIt
              ? (widget.showSpanish
                    ? 'Encontraste la palabra diferente'
                    : 'Odd card found')
              : (widget.showSpanish
                    ? 'Palabra diferente revelada'
                    : 'Odd card revealed')
        : (widget.showSpanish ? 'No pertenece' : "Doesn't belong");

    return Semantics(
      container: true,
      liveRegion: true,
      child: Material(
        key: const ValueKey('oddOneOut-tray-surface'),
        color: hovering
            ? AppColors.learnDeep.withValues(alpha: 0.06)
            : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: tone.withValues(alpha: 0.6), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    widget.settled
                        ? (widget.gotIt
                              ? Icons.check_circle_outline_rounded
                              : Icons.info_outline)
                        : Icons.move_to_inbox_outlined,
                    color: tone,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: tone,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (widget.settled) _audio(widget.answer),
                ],
              ),
              const SizedBox(height: 12),
              if (widget.settled) ...[
                Text(
                  _text(widget.answer),
                  key: const ValueKey('oddOneOut-tray-word'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                    height: 1.4,
                  ),
                ),
                if (widget.optionsEs.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.showSpanish
                        ? widget.options[widget.answer]
                        : widget.optionsEs[widget.answer],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.inkSoft,
                    ),
                  ),
                ],
              ] else ...[
                Text(
                  hovering
                      ? (widget.showSpanish ? 'Suelta aquí' : 'Drop here')
                      : (widget.showSpanish
                            ? 'Arrastra aquí la tarjeta diferente.'
                            : 'Drag the odd card here.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.inkSoft,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                TextButton.icon(
                  key: const ValueKey('oddOneOut-move-to-tray'),
                  onPressed: selected == null || !_available(selected)
                      ? null
                      : () => widget.onChoose(selected),
                  icon: const Icon(Icons.arrow_downward_rounded, size: 17),
                  label: Text(
                    widget.showSpanish
                        ? 'Mover la tarjeta seleccionada'
                        : 'Move selected card',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final indices = [
      for (var index = 0; index < widget.options.length; index++)
        if (!widget.settled || index != widget.answer) index,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.settled
              ? (widget.showSpanish
                    ? 'Estas ${indices.length} tarjetas pertenecen al mismo grupo.'
                    : 'These ${indices.length} cards belong together.')
              : (widget.showSpanish
                    ? '${practiceDragRequiresHold(context) ? 'Mantén presionada y arrastra' : 'Arrastra'} '
                          'la tarjeta diferente a la bandeja.'
                    : '${practiceDragRequiresHold(context) ? 'Touch and hold, then drag' : 'Drag'} '
                          'the odd card into the tray.'),
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.inkSoft,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns =
                constraints.maxWidth < 300 ||
                    MediaQuery.textScalerOf(context).scale(16) > 24
                ? 1
                : 2;
            final width = (constraints.maxWidth - 12 * (columns - 1)) / columns;
            return Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final index in indices)
                  SizedBox(width: width, child: _word(index)),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        DragTarget<int>(
          key: const ValueKey('oddOneOut-tray'),
          onWillAcceptWithDetails: (details) =>
              _dragging == details.data && _available(details.data),
          onAcceptWithDetails: (details) => widget.onChoose(details.data),
          builder: (context, candidates, rejected) =>
              _tray(candidates.isNotEmpty),
        ),
      ],
    );
  }
}

/// Canonical pair indices keep dragging and the tap alternative independent
/// of shuffled display order and the selected language.
class _MatchBoard extends StatefulWidget {
  final List<MatchPair> pairs;
  final List<int> rightOrder;
  final bool showSpanish;
  final List<GlossaryTerm> glossary;
  final Future<void> Function(String text, {required bool spanish}) onSpeak;
  final bool locked;
  final VoidCallback onSolved;

  const _MatchBoard({
    super.key,
    required this.pairs,
    required this.rightOrder,
    required this.showSpanish,
    required this.glossary,
    required this.onSpeak,
    required this.locked,
    required this.onSolved,
  });

  @override
  State<_MatchBoard> createState() => _MatchBoardState();
}

class _MatchBoardState extends State<_MatchBoard> {
  int? _selectedLeft;
  int? _wrongRight;
  int? _draggingLeft;
  final _solved = <int>{};

  void _tapLeft(int left) {
    if (widget.locked || _solved.contains(left)) return;
    setState(() {
      _selectedLeft = _selectedLeft == left ? null : left;
      _wrongRight = null;
    });
  }

  void _tapRight(int right) {
    final left = _selectedLeft;
    if (left != null) _match(left, right);
  }

  void _match(int left, int right) {
    if (widget.locked || _solved.contains(left) || _solved.contains(right)) {
      return;
    }
    if (right == left) {
      setState(() {
        _solved.add(left);
        _selectedLeft = null;
        _wrongRight = null;
      });
      if (_solved.length == widget.pairs.length) widget.onSolved();
    } else {
      setState(() => _wrongRight = right);
    }
  }

  void _startDrag(int index) {
    setState(() {
      _draggingLeft = index;
      _selectedLeft = null;
      _wrongRight = null;
    });
  }

  void _endDrag() {
    if (!mounted) return;
    setState(() => _draggingLeft = null);
  }

  bool get _holdToDrag => practiceDragRequiresHold(context);

  Widget _tile(
    int index, {
    required bool left,
    required String badge,
    bool hovering = false,
  }) {
    final pair = widget.pairs[index];
    final prefix = left ? 'match-left' : 'match-right';
    final english = left ? pair.left : pair.right;
    final spanish = left ? pair.leftEs : pair.rightEs;
    final text = widget.showSpanish ? spanish : english;
    return _MatchTile(
      key: ValueKey('$prefix-$index'),
      selectionKey: ValueKey('$prefix-$index-select'),
      badge: badge,
      text: text,
      solved: _solved.contains(index),
      selected: left && _selectedLeft == index,
      hovering: hovering,
      wrong: !left && _wrongRight == index,
      locked: widget.locked,
      draggable: left && !_solved.contains(index) && !widget.locked,
      content: widget.showSpanish
          ? null
          : VocabularyText(
              text: english,
              terms: widget.glossary,
              onSpeak: widget.onSpeak,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
      audioMenu: _OptionAudioMenu(
        prefix: prefix,
        index: index,
        english: english,
        spanishText: spanish.isEmpty ? null : spanish,
        onSpeak: widget.onSpeak,
      ),
      onTap: left ? () => _tapLeft(index) : () => _tapRight(index),
    );
  }

  Widget _word(int index, {required String badge}) {
    final pair = widget.pairs[index];
    return PracticeDragCard(
      prefix: 'match',
      index: index,
      text: widget.showSpanish ? pair.leftEs : pair.left,
      enabled:
          !widget.locked &&
          !_solved.contains(index) &&
          (_draggingLeft == null || _draggingLeft == index),
      onDragStarted: () => _startDrag(index),
      onDragEnded: _endDrag,
      child: _tile(index, left: true, badge: badge),
    );
  }

  Widget _meaning(int index, {required String badge}) {
    return DragTarget<int>(
      key: ValueKey('match-drop-target-$index'),
      onWillAcceptWithDetails: (details) =>
          !widget.locked &&
          _draggingLeft == details.data &&
          !_solved.contains(details.data) &&
          !_solved.contains(index),
      onAcceptWithDetails: (details) => _match(details.data, index),
      builder: (context, candidates, rejected) => _tile(
        index,
        left: false,
        badge: badge,
        hovering: candidates.isNotEmpty,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.showSpanish
              ? 'Completa estas ${widget.pairs.length} parejas para terminar la ronda.\n'
                    '${_holdToDrag ? 'Mantén presionada una palabra y arrástrala' : 'Arrastra una palabra'} '
                    'hasta su significado a la derecha.'
              : 'Match these ${widget.pairs.length} pairs to finish this round.\n'
                    '${_holdToDrag ? 'Touch and hold a word, then drag it' : 'Drag a word'} '
                    'onto its meaning on the right.',
          style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
        ),
        const SizedBox(height: 4),
        Text(
          widget.showSpanish
              ? 'También puedes elegir una letra y luego su número.'
              : 'Or select a letter, then its matching number.',
          style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
        ),
        const SizedBox(height: 10),
        for (var position = 0; position < widget.pairs.length; position++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _word(
                    position,
                    badge: String.fromCharCode(65 + position),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _meaning(
                    widget.rightOrder[position],
                    badge: '${position + 1}',
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        Text(
          widget.showSpanish
              ? '${_solved.length}/${widget.pairs.length} parejas'
              : '${_solved.length}/${widget.pairs.length} matched',
          key: const ValueKey('match-progress'),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.inkSoft,
          ),
        ),
        if (_wrongRight != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.showSpanish
                ? 'Prueba otra pareja.'
                : 'Try a different pair.',
            style: const TextStyle(fontSize: 12, color: Color(0xFFAD533B)),
          ),
        ],
      ],
    );
  }
}

class _MatchTile extends StatelessWidget {
  final Key selectionKey;
  final String badge;
  final String text;
  final bool solved;
  final bool selected;
  final bool hovering;
  final bool draggable;
  final bool wrong;
  final bool locked;
  final Widget? content;
  final Widget audioMenu;
  final VoidCallback onTap;

  const _MatchTile({
    super.key,
    required this.selectionKey,
    required this.badge,
    required this.text,
    required this.solved,
    required this.selected,
    required this.hovering,
    required this.draggable,
    required this.wrong,
    required this.locked,
    required this.audioMenu,
    this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tone = solved
        ? AppColors.playDeep
        : wrong
        ? const Color(0xFFB65D43)
        : AppColors.learnDeep;
    final active = solved || selected || wrong || hovering;
    return Material(
      color: active ? tone.withValues(alpha: 0.05) : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: active ? tone : AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: solved || locked ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (draggable)
                    const Tooltip(
                      message: 'Drag to the matching meaning',
                      triggerMode: TooltipTriggerMode.manual,
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        size: 16,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  TextButton(
                    key: selectionKey,
                    onPressed: solved || locked ? null : onTap,
                    style: TextButton.styleFrom(
                      foregroundColor: tone,
                      minimumSize: const Size(32, 32),
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: solved
                        ? Icon(
                            Icons.check_circle_outline_rounded,
                            size: 19,
                            color: tone,
                          )
                        : Text(
                            badge,
                            style: TextStyle(
                              color: tone,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                  const Spacer(),
                  audioMenu,
                ],
              ),
              DefaultTextStyle.merge(
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                  height: 1.4,
                ),
                child: content ?? Text(text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final String title;
  final QuestionKind kind;
  final bool spanish;
  final int lives;
  final int maxLives;
  final int multiplier;
  final int index;
  final int total;

  const _StatusBar({
    required this.title,
    required this.kind,
    required this.spanish,
    required this.lives,
    required this.maxLives,
    required this.multiplier,
    required this.index,
    required this.total,
  });

  Widget _hearts({double size = 20, Color color = AppColors.practice}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < maxLives; i++)
          Padding(
            padding: const EdgeInsets.only(right: 3),
            child: Icon(
              i < lives
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              size: size,
              color: i < lives
                  ? color
                  : AppColors.inkSoft.withValues(alpha: 0.4),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 7,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        kind.title,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.inkSoft,
                        ),
                      ),
                      const SizedBox(
                        width: 2,
                        height: 2,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.inkSoft,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const Text(
                        'No timer',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (multiplier > 1) ...[
              Text(
                '${multiplier}x',
                style: const TextStyle(
                  color: AppColors.playDeep,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  kind == QuestionKind.match
                      ? (spanish
                            ? 'Ronda ${index + 1} de $total'
                            : 'Round ${index + 1} of $total')
                      : '${index + 1}/$total',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                _hearts(size: 14, color: const Color(0xFFB86B53)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: (index + 1) / total,
            minHeight: 4,
            backgroundColor: AppColors.line,
            valueColor: const AlwaysStoppedAnimation(AppColors.learnDeep),
          ),
        ),
      ],
    );
  }
}

class _Feedback extends StatelessWidget {
  final bool settled;
  final bool gotIt;
  final int award;
  final int multiplier;
  final int triesLeft;
  final int attempts;

  const _Feedback({
    required this.settled,
    required this.gotIt,
    required this.award,
    required this.multiplier,
    required this.triesLeft,
    required this.attempts,
  });

  @override
  Widget build(BuildContext context) {
    if (!settled && attempts == 0) {
      return const SizedBox(
        height: 44,
        child: Center(
          child: Text(
            'You get three tries.',
            style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
          ),
        ),
      );
    }

    final good = settled && gotIt;
    final retrying = !settled;
    final label = good
        ? '+$award points${multiplier > 1 ? '  ($multiplier x streak)' : ''}'
        : retrying
        ? 'Not that one — $triesLeft ${triesLeft == 1 ? 'try' : 'tries'} left'
        : 'Out of tries — one heart lost';

    final feedbackColor = good ? AppColors.playDeep : const Color(0xFFAD533B);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            good ? Icons.check_circle_outline_rounded : Icons.info_outline,
            size: 18,
            color: feedbackColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: feedbackColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final String prefix;
  final int index;
  final bool selected;
  final String text;
  final bool wrong;
  final bool correct;
  final bool settled;
  final VoidCallback onTap;
  final Widget? content;
  final Widget audioMenu;

  const _Option({
    super.key,
    required this.prefix,
    required this.index,
    required this.selected,
    required this.text,
    required this.wrong,
    required this.correct,
    required this.settled,
    required this.onTap,
    this.content,
    required this.audioMenu,
  });

  @override
  Widget build(BuildContext context) {
    // A wrong pick stays marked while the student keeps trying; the right one
    // only lights up once the question is settled.
    final showRight = settled && correct;
    final highlight = showRight || wrong;
    final tone = showRight
        ? AppColors.playDeep
        : wrong
        ? const Color(0xFFB65D43)
        : AppColors.learnDeep;

    return Bouncy(
      onTap: settled || wrong ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: highlight || selected
              ? tone.withValues(alpha: 0.05)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: highlight || selected ? tone : AppColors.line,
            width: highlight || selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Semantics(
              label: text,
              child: Radio<int>(
                key: ValueKey('$prefix-option-$index-select'),
                value: index,
                enabled: !settled && !wrong,
                visualDensity: VisualDensity.compact,
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (highlight) return tone;
                  return states.contains(WidgetState.selected)
                      ? AppColors.learnDeep
                      : AppColors.inkSoft;
                }),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: highlight || selected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: AppColors.ink,
                ),
                child: content ?? Text(text),
              ),
            ),
            if (highlight)
              Icon(
                showRight ? Icons.check_circle_rounded : Icons.cancel_rounded,
                size: 18,
                color: tone,
              ),
            const SizedBox(width: 4),
            audioMenu,
          ],
        ),
      ),
    );
  }
}

class _Result extends StatelessWidget {
  final int score;
  final int total;
  final int points;
  final int bestStreak;
  final bool survived;
  final Color color;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  const _Result({
    required this.score,
    required this.total,
    required this.points,
    required this.bestStreak,
    required this.survived,
    required this.color,
    required this.onRetry,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final perfect = score == total;
    final headline = !survived
        ? 'Out of hearts'
        : perfect
        ? 'Every one right'
        : 'Round complete';
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: perfect
                  ? [AppColors.play, AppColors.playDeep]
                  : [color, color.withValues(alpha: 0.75)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: glow(perfect ? AppColors.play : color, opacity: 0.36),
          ),
          child: Column(
            children: [
              Icon(
                perfect
                    ? Icons.emoji_events_rounded
                    : survived
                    ? Icons.flag_rounded
                    : Icons.heart_broken_rounded,
                size: 44,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                headline,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: points.toDouble()),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => Text(
                  '${value.round()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
              const Text(
                'points',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Tally(
                    icon: Icons.check_circle_rounded,
                    label: 'Correct',
                    value: '$score/$total',
                  ),
                  _Tally(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Best streak',
                    value: '$bestStreak',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _WideButton(label: 'Play again', color: color, onTap: onRetry),
        const SizedBox(height: 10),
        _WideButton(
          label: 'Back to practice',
          color: AppColors.grape,
          filled: false,
          onTap: onDone,
        ),
      ],
    );
  }
}

class _Tally extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Tally({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11.5),
        ),
      ],
    );
  }
}

class _WideButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _WideButton({
    required this.label,
    required this.color,
    this.filled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Bouncy(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: filled ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
