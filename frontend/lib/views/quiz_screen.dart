import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/progress_repository.dart';
import '../models/lesson.dart';
import '../theme.dart';
import '../widgets/back_bar.dart';
import '../widgets/bouncy.dart';

/// Options are shuffled per run. Without this the seeded answer index of 0
/// would make the first option correct every single time.
class _Shuffled {
  final String prompt;
  final List<String> options;
  final int answer;
  final int points;
  final QuestionKind kind;
  final List<MatchPair> pairs;
  final List<String> rights;
  final String explanation;

  const _Shuffled({
    required this.prompt,
    required this.options,
    required this.answer,
    required this.points,
    required this.kind,
    required this.pairs,
    required this.rights,
    required this.explanation,
  });

  factory _Shuffled.from(Question q, math.Random rng) {
    if (q.kind == QuestionKind.match) {
      final pairs = [...q.pairs]..shuffle(rng);
      final rights = [for (final p in q.pairs) p.right]..shuffle(rng);
      return _Shuffled(
        prompt: q.prompt,
        options: const [],
        answer: 0,
        points: q.points,
        kind: q.kind,
        pairs: pairs,
        rights: rights,
        explanation: q.explanation,
      );
    }
    final order = List<int>.generate(q.options.length, (i) => i)..shuffle(rng);
    return _Shuffled(
      prompt: q.prompt,
      options: [for (final i in order) q.options[i]],
      answer: order.indexOf(q.answer),
      points: q.points,
      kind: q.kind,
      pairs: const [],
      rights: const [],
      explanation: q.explanation,
    );
  }

  /// Matching needs longer than a single tap-to-answer question.
  int get seconds => kind == QuestionKind.match ? 45 : 20;
}

class QuizScreen extends StatefulWidget {
  final String quizId;
  final String title;
  final Color color;
  final List<Question> questions;

  const QuizScreen({
    super.key,
    required this.quizId,
    required this.title,
    required this.color,
    required this.questions,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  static const _maxLives = 3;
  static const _maxTries = 3;

  late List<_Shuffled> _deck;
  late final AnimationController _clock;

  int _index = 0;
  int _score = 0;
  int _points = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _lives = _maxLives;
  int _lastAward = 0;
  bool _finished = false;
  Timer? _advance;

  /// Per question state.
  final _wrong = <int>{};
  bool _settled = false;
  bool _gotIt = false;
  bool _timedOut = false;

  _Shuffled get _question => _deck[_index];
  int get _triesLeft => _maxTries - _wrong.length;

  /// Answering several in a row is worth more than answering many slowly.
  int get _multiplier => _streak >= 4
      ? 3
      : _streak >= 2
          ? 2
          : 1;

  @override
  void initState() {
    super.initState();
    _deal();
    _clock = AnimationController(vsync: this, duration: Duration.zero)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_settled) _timeUp();
      });
    _startClock();
  }

  void _startClock() {
    _clock
      ..duration = Duration(seconds: _question.seconds)
      ..forward(from: 0);
  }

  void _deal() {
    final rng = math.Random();
    _deck = [for (final q in widget.questions) _Shuffled.from(q, rng)];
  }

  @override
  void dispose() {
    _advance?.cancel();
    _clock.dispose();
    super.dispose();
  }

  void _timeUp() {
    setState(() {
      _settled = true;
      _gotIt = false;
      _timedOut = true;
      _streak = 0;
      _lives--;
      _lastAward = 0;
    });
  }

  /// A wrong tap costs a try, not the question. Only running out of tries
  /// settles it and costs a heart.
  void _choose(int option) {
    if (_settled) return;
    if (option == _question.answer) {
      _clock.stop();
      final attempt = _wrong.length;
      final speedBonus = attempt == 0 ? ((1 - _clock.value) * 10).round() : 0;
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
        _lastAward =
            (_question.points * _multiplier * share).round() + speedBonus;
        _points += _lastAward;
      });
      // A clean first-time answer needs no explanation, so it flows on.
      if (attempt == 0) {
        _advance = Timer(const Duration(milliseconds: 1200), _next);
      }
      return;
    }

    setState(() => _wrong.add(option));
    if (_wrong.length >= _maxTries) {
      _clock.stop();
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
      _timedOut = false;
    });
    _startClock();
  }

  void _restart() {
    _advance?.cancel();
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
      _timedOut = false;
      _finished = false;
    });
    _startClock();
  }

  Widget _prompt() {
    final q = _question;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
        boxShadow: glow(widget.color, opacity: 0.14, blur: 18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _KindTag(kind: q.kind),
          const SizedBox(height: 10),
          if (q.kind == QuestionKind.blank)
            _BlankSentence(
              sentence: q.prompt,
              filled: _settled ? q.options[q.answer] : null,
              color: widget.color,
            )
          else
            Text(
              q.prompt,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
        ],
      ),
    );
  }

  Widget _answerArea() {
    final q = _question;
    switch (q.kind) {
      case QuestionKind.match:
        return _MatchBoard(
          key: ValueKey(_index),
          pairs: q.pairs,
          rights: q.rights,
          color: widget.color,
          locked: _settled,
          onSolved: () => _choose(q.answer),
        );
      case QuestionKind.oddOneOut:
        return _OddGrid(
          options: q.options,
          answer: q.answer,
          wrong: _wrong,
          settled: _settled,
          onTap: _choose,
        );
      case QuestionKind.blank:
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var i = 0; i < q.options.length; i++)
              _WordChip(
                text: q.options[i],
                wrong: _wrong.contains(i),
                correct: i == q.answer,
                settled: _settled,
                onTap: () => _choose(i),
              ),
          ],
        );
      case QuestionKind.mcq:
        return Column(
          children: [
            for (var i = 0; i < q.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _Option(
                  text: q.options[i],
                  wrong: _wrong.contains(i),
                  correct: i == q.answer,
                  settled: _settled,
                  onTap: () => _choose(i),
                ),
              ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final needsReview = _settled && (!_gotIt || _wrong.isNotEmpty);
    return Scaffold(
      appBar: const BackBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
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
              lives: _lives,
              maxLives: _maxLives,
              streak: _streak,
              multiplier: _multiplier,
              index: _index,
              total: _deck.length,
              clock: _clock,
              seconds: _question.seconds,
              color: widget.color,
            ),
            const SizedBox(height: 16),
            _prompt(),
            const SizedBox(height: 16),
            _answerArea(),
            const SizedBox(height: 12),
            _Feedback(
              settled: _settled,
              gotIt: _gotIt,
              award: _lastAward,
              multiplier: _multiplier,
              triesLeft: _triesLeft,
              attempts: _wrong.length,
              timedOut: _timedOut,
            ),
            if (needsReview) ...[
              const SizedBox(height: 12),
              _Explanation(
                answer: _question.kind == QuestionKind.match
                    ? null
                    : _question.options[_question.answer],
                why: _question.explanation,
              ),
              const SizedBox(height: 12),
              _WideButton(
                label: _index + 1 < _deck.length && _lives > 0
                    ? 'Next question'
                    : 'See result',
                color: widget.color,
                onTap: _next,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// Names the right answer and the reasoning behind it.
class _Explanation extends StatelessWidget {
  final String? answer;
  final String why;

  const _Explanation({required this.answer, required this.why});

  @override
  Widget build(BuildContext context) {
    if (answer == null && why.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.learn.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded,
                  size: 18, color: AppColors.learn),
              const SizedBox(width: 8),
              Text(
                answer == null ? 'Why' : 'The answer is $answer',
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.learnDeep,
                ),
              ),
            ],
          ),
          if (why.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              why,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: AppColors.ink,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _KindTag extends StatelessWidget {
  final QuestionKind kind;
  const _KindTag({required this.kind});

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = switch (kind) {
      QuestionKind.mcq => ('Multiple choice', Icons.checklist_rounded, AppColors.learn),
      QuestionKind.blank => ('Fill the blank', Icons.edit_note_rounded, AppColors.play),
      QuestionKind.oddOneOut => ('Odd one out', Icons.search_off_rounded, AppColors.grape),
      QuestionKind.match => ('Match up', Icons.compare_arrows_rounded, AppColors.sunshine),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders the sentence with the gap shown as an underline, and drops the
/// right word in once the answer is revealed.
class _BlankSentence extends StatelessWidget {
  final String sentence;
  final String? filled;
  final Color color;

  const _BlankSentence({
    required this.sentence,
    required this.filled,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final parts = sentence.split('___');
    const base = TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.5);
    return RichText(
      text: TextSpan(
        style: base.copyWith(color: AppColors.ink),
        children: [
          TextSpan(text: parts.first),
          if (parts.length > 1) ...[
            TextSpan(
              text: filled ?? '            ',
              style: base.copyWith(
                color: filled == null ? Colors.transparent : AppColors.play,
                decoration: TextDecoration.underline,
                decorationColor: filled == null ? AppColors.inkSoft : AppColors.play,
                decorationThickness: 2,
              ),
            ),
            TextSpan(text: parts.last),
          ],
        ],
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  final String text;
  final bool wrong;
  final bool correct;
  final bool settled;
  final VoidCallback onTap;

  const _WordChip({
    required this.text,
    required this.wrong,
    required this.correct,
    required this.settled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final showRight = settled && correct;
    final highlight = showRight || wrong;
    final tone = showRight ? AppColors.play : AppColors.practice;
    return Bouncy(
      onTap: settled || wrong ? () {} : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        decoration: BoxDecoration(
          color: highlight ? tone.withValues(alpha: 0.16) : AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: highlight ? tone : AppColors.line,
            width: highlight ? 2 : 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: highlight ? tone : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _OddGrid extends StatelessWidget {
  final List<String> options;
  final int answer;
  final Set<int> wrong;
  final bool settled;
  final ValueChanged<int> onTap;

  const _OddGrid({
    required this.options,
    required this.answer,
    required this.wrong,
    required this.settled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.7,
      children: [
        for (var i = 0; i < options.length; i++)
          Builder(
            builder: (context) {
              final showRight = settled && i == answer;
              final isWrong = wrong.contains(i);
              final highlight = showRight || isWrong;
              final tone = showRight ? AppColors.play : AppColors.practice;
              return Bouncy(
                onTap: settled || isWrong ? () {} : () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        highlight ? tone.withValues(alpha: 0.16) : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: highlight ? tone : AppColors.line,
                      width: highlight ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    options[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: highlight ? tone : AppColors.ink,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Tap a term, then tap its meaning. Correct pairs lock in place, so the
/// board gets easier as it empties.
class _MatchBoard extends StatefulWidget {
  final List<MatchPair> pairs;
  final List<String> rights;
  final Color color;
  final bool locked;
  final VoidCallback onSolved;

  const _MatchBoard({
    super.key,
    required this.pairs,
    required this.rights,
    required this.color,
    required this.locked,
    required this.onSolved,
  });

  @override
  State<_MatchBoard> createState() => _MatchBoardState();
}

class _MatchBoardState extends State<_MatchBoard> {
  String? _selectedLeft;
  String? _wrongRight;
  final _solved = <String>{};

  void _tapLeft(String left) {
    if (widget.locked || _solved.contains(left)) return;
    setState(() {
      _selectedLeft = _selectedLeft == left ? null : left;
      _wrongRight = null;
    });
  }

  void _tapRight(String right) {
    if (widget.locked || _selectedLeft == null) return;
    final expected =
        widget.pairs.firstWhere((p) => p.left == _selectedLeft!).right;
    if (right == expected) {
      setState(() {
        _solved.add(_selectedLeft!);
        _selectedLeft = null;
        _wrongRight = null;
      });
      if (_solved.length == widget.pairs.length) widget.onSolved();
    } else {
      setState(() => _wrongRight = right);
    }
  }

  bool _rightSolved(String right) =>
      widget.pairs.any((p) => p.right == right && _solved.contains(p.left));

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              for (final pair in widget.pairs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _MatchTile(
                    text: pair.left,
                    solved: _solved.contains(pair.left),
                    selected: _selectedLeft == pair.left,
                    wrong: false,
                    color: widget.color,
                    onTap: () => _tapLeft(pair.left),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              for (final right in widget.rights)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _MatchTile(
                    text: right,
                    solved: _rightSolved(right),
                    selected: false,
                    wrong: _wrongRight == right,
                    color: widget.color,
                    onTap: () => _tapRight(right),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MatchTile extends StatelessWidget {
  final String text;
  final bool solved;
  final bool selected;
  final bool wrong;
  final Color color;
  final VoidCallback onTap;

  const _MatchTile({
    required this.text,
    required this.solved,
    required this.selected,
    required this.wrong,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tone = solved
        ? AppColors.play
        : wrong
            ? AppColors.practice
            : color;
    final active = solved || selected || wrong;
    return Bouncy(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 58,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: active ? tone.withValues(alpha: 0.16) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? tone : AppColors.line,
            width: active ? 2 : 1,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? tone : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final int lives;
  final int maxLives;
  final int streak;
  final int multiplier;
  final int index;
  final int total;
  final Animation<double> clock;
  final int seconds;
  final Color color;

  const _StatusBar({
    required this.lives,
    required this.maxLives,
    required this.streak,
    required this.multiplier,
    required this.index,
    required this.total,
    required this.clock,
    required this.seconds,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            for (var i = 0; i < maxLives; i++)
              Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Icon(
                  i < lives
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 20,
                  color: i < lives
                      ? AppColors.practice
                      : AppColors.inkSoft.withValues(alpha: 0.4),
                ),
              ),
          ],
        ),
        const Spacer(),
        if (multiplier > 1)
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.sunshine.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department_rounded,
                    size: 15, color: Color(0xFFE07C00)),
                const SizedBox(width: 3),
                Text(
                  '${multiplier}x',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE07C00),
                  ),
                ),
              ],
            ),
          ),
        Text(
          '${index + 1}/$total',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(width: 10),
        AnimatedBuilder(
          animation: clock,
          builder: (context, _) {
            final left = ((1 - clock.value) * seconds).ceil();
            // Turns red in the last few seconds to create urgency.
            final urgent = left <= 5;
            return SizedBox(
              width: 38,
              height: 38,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 38,
                    height: 38,
                    child: CircularProgressIndicator(
                      value: 1 - clock.value,
                      strokeWidth: 4,
                      backgroundColor: AppColors.line,
                      valueColor: AlwaysStoppedAnimation(
                        urgent ? AppColors.practice : color,
                      ),
                    ),
                  ),
                  Text(
                    '$left',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: urgent ? AppColors.practice : AppColors.ink,
                    ),
                  ),
                ],
              ),
            );
          },
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
  final bool timedOut;

  const _Feedback({
    required this.settled,
    required this.gotIt,
    required this.award,
    required this.multiplier,
    required this.triesLeft,
    required this.attempts,
    required this.timedOut,
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
    final tone = good
        ? AppColors.play
        : retrying
            ? AppColors.sunshine
            : AppColors.practice;
    final label = good
        ? '+$award points${multiplier > 1 ? '  ($multiplier x streak)' : ''}'
        : retrying
            ? 'Not that one — $triesLeft ${triesLeft == 1 ? 'try' : 'tries'} left'
            : timedOut
                ? 'Out of time — one heart lost'
                : 'Out of tries — one heart lost';

    return Container(
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: good ? AppColors.playDeep : tone,
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final String text;
  final bool wrong;
  final bool correct;
  final bool settled;
  final VoidCallback onTap;

  const _Option({
    required this.text,
    required this.wrong,
    required this.correct,
    required this.settled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // A wrong pick stays marked while the student keeps trying; the right one
    // only lights up once the question is settled.
    final showRight = settled && correct;
    final highlight = showRight || wrong;
    final tone = showRight ? AppColors.play : AppColors.practice;

    return Bouncy(
      onTap: settled || wrong ? () {} : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: highlight ? tone.withValues(alpha: 0.14) : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: highlight ? tone : AppColors.line,
            width: highlight ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                  color: highlight ? tone : AppColors.ink,
                ),
              ),
            ),
            if (highlight)
              Icon(
                showRight
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                size: 20,
                color: tone,
              ),
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

  const _Tally({
    required this.icon,
    required this.label,
    required this.value,
  });

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
