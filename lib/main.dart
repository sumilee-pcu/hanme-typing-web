import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const RetroHangulTypingApp());
}

class RetroHangulTypingApp extends StatefulWidget {
  const RetroHangulTypingApp({super.key});

  @override
  State<RetroHangulTypingApp> createState() => _RetroHangulTypingAppState();
}

class _RetroHangulTypingAppState extends State<RetroHangulTypingApp> {
  final Map<PracticeMode, PracticeResult> _bestResults = {};

  void _saveResult(PracticeMode mode, PracticeResult result) {
    final previous = _bestResults[mode];
    if (previous == null || result.score > previous.score) {
      setState(() => _bestResults[mode] = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '레트로 한글 타자',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'NotoSerifKR',
        fontFamilyFallback: const [
          'AppleMyungjo',
          'NanumMyeongjo',
          'Noto Serif CJK KR',
          'Noto Serif KR',
          'serif',
        ],
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.cyan,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.ink,
      ),
      home: Builder(
        builder: (context) {
          return HomeScreen(
            bestResults: _bestResults,
            onStart: (mode) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PracticeScreen(
                    mode: mode,
                    onFinished: (result) => _saveResult(mode, result),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

enum PracticeMode {
  keys,
  words,
  passage,
  defense;

  String get label {
    return switch (this) {
      PracticeMode.keys => '자리 연습',
      PracticeMode.words => '낱말 연습',
      PracticeMode.passage => '긴글 연습',
      PracticeMode.defense => '베네치아',
    };
  }

  String get tag {
    return switch (this) {
      PracticeMode.keys => 'BASIC',
      PracticeMode.words => 'SPEED',
      PracticeMode.passage => 'FLOW',
      PracticeMode.defense => 'ARCADE',
    };
  }

  String get description {
    return switch (this) {
      PracticeMode.keys => '두벌식 기본 리듬을 손끝에 붙입니다.',
      PracticeMode.words => '짧고 선명한 낱말로 속도를 올립니다.',
      PracticeMode.passage => '문장 흐름과 정확도를 함께 다듬습니다.',
      PracticeMode.defense => '떨어지는 단어를 막아 마지막 탑을 지킵니다.',
    };
  }

  IconData get icon {
    return switch (this) {
      PracticeMode.keys => Icons.keyboard_alt_outlined,
      PracticeMode.words => Icons.bolt_outlined,
      PracticeMode.passage => Icons.article_outlined,
      PracticeMode.defense => Icons.shield_outlined,
    };
  }

  Color get accent {
    return switch (this) {
      PracticeMode.keys => AppColors.cyan,
      PracticeMode.words => AppColors.amber,
      PracticeMode.passage => AppColors.green,
      PracticeMode.defense => AppColors.rose,
    };
  }
}

class PracticeResult {
  const PracticeResult({
    required this.score,
    required this.cpm,
    required this.accuracy,
    required this.correct,
    required this.mistakes,
    required this.duration,
  });

  final int score;
  final int cpm;
  final int accuracy;
  final int correct;
  final int mistakes;
  final Duration duration;
}

class AppColors {
  static const ink = Color(0xFF9FDBF2);
  static const panel = Color(0xFFE8FAFF);
  static const panelRaised = Color(0xFFC9EFFC);
  static const line = Color(0xFF177FA4);
  static const text = Color(0xFF102A3A);
  static const muted = Color(0xFF4F6978);
  static const cyan = Color(0xFF007FA3);
  static const amber = Color(0xFF9A6900);
  static const green = Color(0xFF207542);
  static const rose = Color(0xFFB3335D);
  static const blue = Color(0xFF2C60A8);
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.bestResults,
    required this.onStart,
    super.key,
  });

  final Map<PracticeMode, PracticeResult> bestResults;
  final ValueChanged<PracticeMode> onStart;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 760;

    return Scaffold(
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7FCDEA), Color(0xFFAEE6F7), Color(0xFFE8FAFF)],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      isWide ? 28 : 18,
                      18,
                      isWide ? 28 : 18,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _HeroPanel(bestResults: bestResults),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      isWide ? 28 : 18,
                      18,
                      isWide ? 28 : 18,
                      28,
                    ),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final mode = PracticeMode.values[index];
                        return ModeCard(
                          mode: mode,
                          bestResult: bestResults[mode],
                          onTap: () => onStart(mode),
                        );
                      }, childCount: PracticeMode.values.length),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWide ? 2 : 1,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        mainAxisExtent: isWide ? 202 : 186,
                      ),
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
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.bestResults});

  final Map<PracticeMode, PracticeResult> bestResults;

  @override
  Widget build(BuildContext context) {
    final totalPlays = bestResults.length;
    final bestScore = bestResults.values.fold<int>(
      0,
      (score, result) => math.max(score, result.score),
    );

    return RetroFrame(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _WindowDot(color: AppColors.rose),
              const SizedBox(width: 8),
              const _WindowDot(color: AppColors.amber),
              const SizedBox(width: 8),
              const _WindowDot(color: AppColors.green),
              const Spacer(),
              Text(
                'MOBILE BUILD 0.1',
                style: RetroText.mini.copyWith(color: AppColors.cyan),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('레트로 한글 타자', style: RetroText.title),
          const SizedBox(height: 10),
          Text(
            '설치 없이 시작한 감성은 그대로, 모바일 손맛과 기록 설계는 새롭게.',
            style: RetroText.body.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isTight = constraints.maxWidth < 620;
              final cards = [
                HudTile(
                  label: '최고 점수',
                  value: '$bestScore',
                  color: AppColors.amber,
                ),
                HudTile(
                  label: '완료 모드',
                  value: '$totalPlays/4',
                  color: AppColors.cyan,
                ),
                const HudTile(
                  label: '입력 방식',
                  value: '한글 IME',
                  color: AppColors.green,
                ),
              ];

              if (isTight) {
                return Column(
                  children: cards
                      .map(
                        (card) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SizedBox(width: double.infinity, child: card),
                        ),
                      )
                      .toList(),
                );
              }

              return Row(
                children: cards
                    .map(
                      (card) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: card,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ModeCard extends StatelessWidget {
  const ModeCard({
    required this.mode,
    required this.bestResult,
    required this.onTap,
    super.key,
  });

  final PracticeMode mode;
  final PracticeResult? bestResult;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: RetroFrame(
          borderColor: mode.accent,
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -28,
                child: Icon(
                  mode.icon,
                  size: 132,
                  color: mode.accent.withValues(alpha: 0.09),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: mode.accent.withValues(alpha: 0.14),
                            border: Border.all(color: mode.accent),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(9),
                            child: Icon(
                              mode.icon,
                              color: mode.accent,
                              size: 22,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          mode.tag,
                          style: RetroText.mini.copyWith(color: mode.accent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(mode.label, style: RetroText.section),
                    const SizedBox(height: 7),
                    Text(
                      mode.description,
                      style: RetroText.body.copyWith(color: AppColors.muted),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          bestResult == null
                              ? '기록 없음'
                              : 'BEST ${bestResult!.score}',
                          style: RetroText.mini.copyWith(color: AppColors.text),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward, color: mode.accent, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({
    required this.mode,
    required this.onFinished,
    super.key,
  });

  final PracticeMode mode;
  final ValueChanged<PracticeResult> onFinished;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  static const int _maxTowerBlocks = 12;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late List<String> _targets;
  Timer? _ticker;
  DateTime? _startedAt;
  DateTime? _fallStartedAt;
  DateTime? _veniceSweepUntil;
  Duration _elapsed = Duration.zero;
  int _index = 0;
  int _completedChars = 0;
  int _completedStrokes = 0;
  int _mistakeCount = 0;
  int _score = 0;
  int _towerBlocks = _maxTowerBlocks;
  bool _finished = false;
  String _lastCommittedInput = '';

  @override
  void initState() {
    super.initState();
    _targets = PracticeLibrary.targetsFor(widget.mode);
    _controller.addListener(_handleInput);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      if (widget.mode == PracticeMode.defense) {
        _ensureStarted();
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _target => _targets[_index % _targets.length];

  Duration get _limit {
    return switch (widget.mode) {
      PracticeMode.keys => const Duration(seconds: 70),
      PracticeMode.words => const Duration(seconds: 60),
      PracticeMode.passage => const Duration(minutes: 3),
      PracticeMode.defense => const Duration(seconds: 45),
    };
  }

  void _ensureStarted() {
    if (_startedAt != null) {
      return;
    }
    _startedAt = DateTime.now();
    if (widget.mode == PracticeMode.defense) {
      _fallStartedAt = _startedAt;
    }
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted || _startedAt == null || _finished) {
        return;
      }
      final now = DateTime.now();
      var shouldFinish = false;
      setState(() {
        _elapsed = now.difference(_startedAt!);
        if (widget.mode == PracticeMode.defense) {
          if (_elapsed >= _limit) {
            shouldFinish = true;
          } else {
            shouldFinish = _applyVeniceFallDamage(now);
          }
        }
      });
      if (shouldFinish) {
        _finish();
      }
    });
  }

  void _handleInput() {
    if (_finished) {
      return;
    }
    _ensureStarted();
    final input = _committedInput;
    final veniceConfirmed =
        widget.mode == PracticeMode.defense && input.endsWith(' ');
    final judgedInput = widget.mode == PracticeMode.defense
        ? input.trimRight()
        : input;
    _recordNewMistakes(judgedInput);
    final matched = widget.mode == PracticeMode.defense
        ? veniceConfirmed && judgedInput == _target
        : judgedInput == _target;
    if (matched) {
      final earnedScore = _scoreForCurrentTarget();
      _completedChars += _target.length;
      _completedStrokes += _typingStrokeCount(_target);
      _score += earnedScore;
      final veniceSweep =
          widget.mode == PracticeMode.defense && _isVeniceBonusWord;
      final sequenceComplete =
          widget.mode != PracticeMode.defense &&
          (widget.mode == PracticeMode.passage ||
              _index == _targets.length - 1);
      if (sequenceComplete) {
        _clearInputSilently();
        _finish();
      } else {
        setState(() {
          _index += veniceSweep ? 4 : 1;
          if (veniceSweep) {
            _score += 180;
            _veniceSweepUntil = DateTime.now().add(
              const Duration(milliseconds: 900),
            );
          }
          _lastCommittedInput = '';
          _fallStartedAt = DateTime.now();
          _clearInputSilently();
        });
      }
    } else {
      setState(() {});
    }
  }

  int _scoreForCurrentTarget() {
    final paceBonus = math.max(0, 30 - _elapsed.inSeconds);
    final accuracyBonus = _currentAccuracy;
    final base = switch (widget.mode) {
      PracticeMode.keys => 22,
      PracticeMode.words => 38,
      PracticeMode.passage => 160,
      PracticeMode.defense => 48 + paceBonus + (_isVeniceBonusWord ? 120 : 0),
    };
    return base + accuracyBonus;
  }

  void _finish() {
    if (_finished) {
      return;
    }
    _finished = true;
    _ticker?.cancel();
    if (_startedAt != null) {
      _elapsed = DateTime.now().difference(_startedAt!);
    }
    final result = PracticeResult(
      score: _score,
      cpm: _currentCpm,
      accuracy: _currentAccuracy,
      correct: _currentCorrect,
      mistakes: _currentMistakes,
      duration: _elapsed == Duration.zero
          ? const Duration(seconds: 1)
          : _elapsed,
    );
    widget.onFinished(result);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ResultSheet(
        mode: widget.mode,
        result: result,
        onRetry: () {
          Navigator.of(context).pop();
          _reset();
        },
      ),
    );
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _startedAt = null;
      _elapsed = Duration.zero;
      _index = 0;
      _completedChars = 0;
      _completedStrokes = 0;
      _mistakeCount = 0;
      _score = 0;
      _towerBlocks = _maxTowerBlocks;
      _finished = false;
      _lastCommittedInput = '';
      _veniceSweepUntil = null;
      _fallStartedAt = widget.mode == PracticeMode.defense
          ? DateTime.now()
          : null;
      _clearInputSilently();
    });
    if (widget.mode == PracticeMode.defense) {
      _ensureStarted();
    }
    _focusNode.requestFocus();
  }

  bool _applyVeniceFallDamage(DateTime now) {
    final startedAt = _fallStartedAt ?? now;
    if (now.difference(startedAt) < _fallDuration) {
      return false;
    }
    return _dropVeniceWord(now);
  }

  bool _dropVeniceWord(DateTime now) {
    if (!_isVeniceBonusWord) {
      _towerBlocks = math.max(0, _towerBlocks - 1);
      _score = math.max(0, _score - 80);
      _mistakeCount += _target.length;
    }
    _index += 1;
    _lastCommittedInput = '';
    _fallStartedAt = now;
    _clearInputSilently();
    return _towerBlocks <= 0;
  }

  void _recordNewMistakes(String input) {
    if (input.length > _lastCommittedInput.length) {
      for (var i = _lastCommittedInput.length; i < input.length; i += 1) {
        if (i >= _target.length || input[i] != _target[i]) {
          _mistakeCount += 1;
        }
      }
    }
    _lastCommittedInput = input;
  }

  void _clearInputSilently() {
    _controller.removeListener(_handleInput);
    _controller.clear();
    _controller.addListener(_handleInput);
  }

  int get _currentCorrect {
    final input = _committedInput;
    var correct = _completedChars;
    for (var i = 0; i < input.length && i < _target.length; i += 1) {
      if (input[i] == _target[i]) {
        correct += 1;
      }
    }
    return correct;
  }

  int get _currentMistakes {
    return _mistakeCount;
  }

  int get _typedChars => _completedChars + _committedInput.length;

  String get _committedInput {
    final value = _controller.value;
    if (!_hasComposingText(value)) {
      return value.text;
    }
    final start = value.composing.start.clamp(0, value.text.length).toInt();
    final end = value.composing.end.clamp(start, value.text.length).toInt();
    return value.text.replaceRange(start, end, '');
  }

  int get _currentAccuracy {
    final attempts = _currentCorrect + _currentMistakes;
    if (attempts == 0) {
      return 100;
    }
    return ((_currentCorrect / attempts) * 100).clamp(0, 100).round();
  }

  int get _currentCpm {
    final seconds = math.max(1, _effectiveElapsed.inSeconds);
    return ((_currentCorrectStrokes / seconds) * 60).round();
  }

  int get _currentCorrectStrokes {
    final input = _committedInput;
    var strokes = _completedStrokes;
    for (var i = 0; i < input.length && i < _target.length; i += 1) {
      if (input[i] == _target[i]) {
        strokes += _typingStrokeCount(input[i]);
      }
    }
    return strokes;
  }

  Duration get _effectiveElapsed {
    final startedAt = _startedAt;
    if (startedAt == null || _finished) {
      return _elapsed;
    }
    return DateTime.now().difference(startedAt);
  }

  double get _progress {
    if (widget.mode == PracticeMode.defense) {
      return (_elapsed.inMilliseconds / _limit.inMilliseconds).clamp(0, 1);
    }
    final total = _targets.fold<int>(0, (sum, target) => sum + target.length);
    return (_typedChars / total).clamp(0, 1);
  }

  Duration get _fallDuration {
    final speedUp = _elapsed.inSeconds * 70;
    return Duration(milliseconds: math.max(3300, 7200 - speedUp));
  }

  double get _fallProgress {
    if (widget.mode != PracticeMode.defense) {
      return _progress;
    }
    final startedAt = _fallStartedAt;
    if (startedAt == null) {
      return 0;
    }
    return (_effectiveElapsedSince(startedAt).inMilliseconds /
            _fallDuration.inMilliseconds)
        .clamp(0, 1);
  }

  Duration _effectiveElapsedSince(DateTime startedAt) {
    if (_finished) {
      return _elapsed;
    }
    return DateTime.now().difference(startedAt);
  }

  bool get _isVeniceBonusWord =>
      widget.mode == PracticeMode.defense && _index % 6 == 4;

  bool get _veniceSweepActive {
    final until = _veniceSweepUntil;
    return until != null && DateTime.now().isBefore(until);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  PracticeTopBar(
                    mode: widget.mode,
                    onBack: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.only(
                        bottom: math.max(18, bottomInset > 0 ? 18 : 26),
                      ),
                      children: [
                        ProgressHud(
                          mode: widget.mode,
                          elapsed: _elapsed,
                          limit: _limit,
                          cpm: _currentCpm,
                          accuracy: _currentAccuracy,
                          score: _score,
                          progress: _progress,
                          towerBlocks: _towerBlocks,
                        ),
                        const SizedBox(height: 12),
                        if (widget.mode != PracticeMode.defense) ...[
                          TargetPanel(
                            mode: widget.mode,
                            target: _target,
                            editingValue: _controller.value,
                            roundText: '${_index + 1} / ${_targets.length}',
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (widget.mode == PracticeMode.keys)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: HangulKeyboard(target: _target),
                          ),
                        if (widget.mode == PracticeMode.defense)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: WordRainStage(
                              accent: widget.mode.accent,
                              progress: _fallProgress,
                              activeWord: _target,
                              words: _targets,
                              index: _index,
                              towerBlocks: _towerBlocks,
                              maxTowerBlocks: _maxTowerBlocks,
                              bonusWord: _isVeniceBonusWord,
                              sweepActive: _veniceSweepActive,
                            ),
                          ),
                        InputDock(
                          mode: widget.mode,
                          controller: _controller,
                          focusNode: _focusNode,
                          onReset: _reset,
                          onSkip: () {
                            var shouldFinish = false;
                            setState(() {
                              if (widget.mode == PracticeMode.defense) {
                                shouldFinish = _dropVeniceWord(DateTime.now());
                              } else {
                                _index = (_index + 1) % _targets.length;
                                _lastCommittedInput = '';
                                _clearInputSilently();
                              }
                            });
                            if (shouldFinish) {
                              _finish();
                            }
                            _focusNode.requestFocus();
                          },
                        ),
                      ],
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
}

class PracticeTopBar extends StatelessWidget {
  const PracticeTopBar({required this.mode, required this.onBack, super.key});

  final PracticeMode mode;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
          tooltip: '뒤로',
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(mode.label, style: RetroText.section),
              Text(
                mode.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: RetroText.mini.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProgressHud extends StatelessWidget {
  const ProgressHud({
    required this.mode,
    required this.elapsed,
    required this.limit,
    required this.cpm,
    required this.accuracy,
    required this.score,
    required this.progress,
    required this.towerBlocks,
    super.key,
  });

  final PracticeMode mode;
  final Duration elapsed;
  final Duration limit;
  final int cpm;
  final int accuracy;
  final int score;
  final double progress;
  final int towerBlocks;

  @override
  Widget build(BuildContext context) {
    final timeText = mode == PracticeMode.defense
        ? '${math.max(0, limit.inSeconds - elapsed.inSeconds)}s'
        : _formatDuration(elapsed);

    if (mode == PracticeMode.defense) {
      return RetroFrame(
        padding: const EdgeInsets.all(10),
        borderColor: mode.accent,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CompactHudTile(
                    label: '점수',
                    value: '$score',
                    color: AppColors.amber,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: CompactHudTile(
                    label: '타수',
                    value: '$cpm',
                    color: AppColors.cyan,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: CompactHudTile(
                    label: '블록',
                    value: '$towerBlocks/12',
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: CompactHudTile(
                    label: '시간',
                    value: timeText,
                    color: mode.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.ink,
                color: mode.accent,
              ),
            ),
          ],
        ),
      );
    }

    return RetroFrame(
      padding: const EdgeInsets.all(14),
      borderColor: mode.accent,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: HudTile(
                  label: '타수',
                  value: '$cpm',
                  color: AppColors.cyan,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: HudTile(
                  label: '정확도',
                  value: '$accuracy%',
                  color: AppColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: HudTile(
                  label: '점수',
                  value: '$score',
                  color: AppColors.amber,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: HudTile(
                  label: '시간',
                  value: timeText,
                  color: mode.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.ink,
              color: mode.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class TargetPanel extends StatelessWidget {
  const TargetPanel({
    required this.mode,
    required this.target,
    required this.editingValue,
    required this.roundText,
    super.key,
  });

  final PracticeMode mode;
  final String target;
  final TextEditingValue editingValue;
  final String roundText;

  @override
  Widget build(BuildContext context) {
    return RetroFrame(
      borderColor: AppColors.line,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'TARGET',
                style: RetroText.mini.copyWith(color: mode.accent),
              ),
              const Spacer(),
              Text(
                roundText,
                style: RetroText.mini.copyWith(color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              children: _targetSpans(target, editingValue, mode.accent),
            ),
          ),
        ],
      ),
    );
  }
}

List<TextSpan> _targetSpans(
  String target,
  TextEditingValue editingValue,
  Color accent,
) {
  final input = editingValue.text;
  final composingStart = _hasComposingText(editingValue)
      ? editingValue.composing.start.clamp(0, input.length).toInt()
      : -1;
  final composingEnd = _hasComposingText(editingValue)
      ? editingValue.composing.end.clamp(composingStart, input.length).toInt()
      : -1;
  final spans = <TextSpan>[];
  for (var i = 0; i < target.length; i += 1) {
    final char = target[i];
    final typed = i < input.length ? input[i] : null;
    final isComposing = i >= composingStart && i < composingEnd;
    Color color = AppColors.text;
    Color? background;
    if (isComposing) {
      color = accent;
      background = accent.withValues(alpha: 0.12);
    } else if (typed != null && typed == char) {
      color = Colors.white;
      background = AppColors.green;
    } else if (typed != null && typed != char) {
      color = AppColors.text;
      background = AppColors.rose.withValues(alpha: 0.7);
    } else if (i == input.length) {
      color = accent;
      background = accent.withValues(alpha: 0.12);
    }
    spans.add(
      TextSpan(
        text: char,
        style: RetroText.target.copyWith(
          color: color,
          backgroundColor: background,
        ),
      ),
    );
  }
  return spans;
}

bool _hasComposingText(TextEditingValue value) {
  return value.composing.isValid &&
      !value.composing.isCollapsed &&
      value.composing.start >= 0 &&
      value.composing.end <= value.text.length;
}

int _typingStrokeCount(String text) {
  var total = 0;
  for (final codePoint in text.runes) {
    total += _typingStrokeCountForCodePoint(codePoint);
  }
  return total;
}

int _typingStrokeCountForCodePoint(int codePoint) {
  const hangulBase = 0xAC00;
  const hangulEnd = 0xD7A3;
  if (codePoint < hangulBase || codePoint > hangulEnd) {
    return 1;
  }

  const vowelStrokes = [
    1, // ㅏ
    1, // ㅐ
    1, // ㅑ
    1, // ㅒ
    1, // ㅓ
    1, // ㅔ
    1, // ㅕ
    1, // ㅖ
    1, // ㅗ
    2, // ㅘ
    2, // ㅙ
    2, // ㅚ
    1, // ㅛ
    1, // ㅜ
    2, // ㅝ
    2, // ㅞ
    2, // ㅟ
    1, // ㅠ
    1, // ㅡ
    2, // ㅢ
    1, // ㅣ
  ];
  const finalStrokes = [
    0, // none
    1, // ㄱ
    1, // ㄲ
    2, // ㄳ
    1, // ㄴ
    2, // ㄵ
    2, // ㄶ
    1, // ㄷ
    1, // ㄹ
    2, // ㄺ
    2, // ㄻ
    2, // ㄼ
    2, // ㄽ
    2, // ㄾ
    2, // ㄿ
    2, // ㅀ
    1, // ㅁ
    1, // ㅂ
    2, // ㅄ
    1, // ㅅ
    1, // ㅆ
    1, // ㅇ
    1, // ㅈ
    1, // ㅊ
    1, // ㅋ
    1, // ㅌ
    1, // ㅍ
    1, // ㅎ
  ];

  final syllableIndex = codePoint - hangulBase;
  final vowelIndex = (syllableIndex % 588) ~/ 28;
  final finalIndex = syllableIndex % 28;
  return 1 + vowelStrokes[vowelIndex] + finalStrokes[finalIndex];
}

class InputDock extends StatelessWidget {
  const InputDock({
    required this.mode,
    required this.controller,
    required this.focusNode,
    required this.onReset,
    required this.onSkip,
    super.key,
  });

  final PracticeMode mode;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onReset;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return RetroFrame(
      padding: const EdgeInsets.all(14),
      borderColor: mode.accent,
      child: Column(
        children: [
          TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            maxLines: mode == PracticeMode.passage ? 4 : 1,
            minLines: mode == PracticeMode.passage ? 3 : 1,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            enableSuggestions: false,
            cursorColor: mode.accent,
            style: RetroText.input,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.ink,
              hintText: mode == PracticeMode.defense
                  ? '단어 입력 후 스페이스'
                  : '여기에 입력',
              hintStyle: RetroText.input.copyWith(color: AppColors.muted),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.line, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: mode.accent, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: onReset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onSkip,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('넘김'),
                  style: FilledButton.styleFrom(
                    backgroundColor: mode.accent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HangulKeyboard extends StatelessWidget {
  const HangulKeyboard({required this.target, super.key});

  final String target;

  static const rows = [
    ['ㅂ', 'ㅈ', 'ㄷ', 'ㄱ', 'ㅅ', 'ㅛ', 'ㅕ', 'ㅑ', 'ㅐ', 'ㅔ'],
    ['ㅁ', 'ㄴ', 'ㅇ', 'ㄹ', 'ㅎ', 'ㅗ', 'ㅓ', 'ㅏ', 'ㅣ'],
    ['ㅋ', 'ㅌ', 'ㅊ', 'ㅍ', 'ㅠ', 'ㅜ', 'ㅡ'],
  ];

  @override
  Widget build(BuildContext context) {
    final initial = target.isEmpty ? '' : target[0];
    final highlighted = PracticeLibrary.keyHint[initial] ?? initial;

    return RetroFrame(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: rows.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((keyLabel) {
                final active = keyLabel == highlighted;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  width: 34,
                  height: 38,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active ? AppColors.amber : AppColors.panelRaised,
                    border: Border.all(
                      color: active ? AppColors.text : AppColors.line,
                    ),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: AppColors.amber.withValues(alpha: 0.28),
                              blurRadius: 14,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    keyLabel,
                    style: RetroText.key.copyWith(
                      color: active ? Colors.white : AppColors.text,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class DefenseRadar extends StatelessWidget {
  const DefenseRadar({
    required this.accent,
    required this.danger,
    required this.word,
    super.key,
  });

  final Color accent;
  final double danger;
  final String word;

  @override
  Widget build(BuildContext context) {
    return RetroFrame(
      padding: const EdgeInsets.all(14),
      borderColor: accent,
      child: SizedBox(
        height: 130,
        child: CustomPaint(
          painter: DefenseRadarPainter(
            accent: accent,
            danger: danger,
            word: word,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class DefenseRadarPainter extends CustomPainter {
  const DefenseRadarPainter({
    required this.accent,
    required this.danger,
    required this.word,
  });

  final Color accent;
  final double danger;
  final String word;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = AppColors.line.withValues(alpha: 0.45)
      ..strokeWidth = 1;
    for (var x = 0.0; x <= size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y <= size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final dangerY = size.height * danger;
    final wordPaint = Paint()
      ..color = accent.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;
    final wordRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.22,
        dangerY.clamp(6, size.height - 42),
        size.width * 0.56,
        36,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(wordRect, wordPaint);
    canvas.drawRRect(
      wordRect,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: word,
        style: RetroText.radar.copyWith(color: accent),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, wordRect.outerRect.top + 6),
    );

    final base = Paint()
      ..color = AppColors.green
      ..strokeWidth = 4;
    canvas.drawLine(
      Offset(0, size.height - 8),
      Offset(size.width, size.height - 8),
      base,
    );
  }

  @override
  bool shouldRepaint(covariant DefenseRadarPainter oldDelegate) {
    return oldDelegate.danger != danger ||
        oldDelegate.word != word ||
        oldDelegate.accent != accent;
  }
}

class WordRainStage extends StatelessWidget {
  const WordRainStage({
    required this.accent,
    required this.progress,
    required this.activeWord,
    required this.words,
    required this.index,
    required this.towerBlocks,
    required this.maxTowerBlocks,
    required this.bonusWord,
    required this.sweepActive,
    super.key,
  });

  final Color accent;
  final double progress;
  final String activeWord;
  final List<String> words;
  final int index;
  final int towerBlocks;
  final int maxTowerBlocks;
  final bool bonusWord;
  final bool sweepActive;

  @override
  Widget build(BuildContext context) {
    return RetroFrame(
      padding: const EdgeInsets.all(10),
      borderColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('베네치아', style: RetroText.mini.copyWith(color: accent)),
              const Spacer(),
              Text(
                '탑 $towerBlocks/$maxTowerBlocks',
                style: RetroText.mini.copyWith(color: AppColors.green),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final stageHeight = constraints.maxWidth < 520 ? 340.0 : 410.0;
              return SizedBox(
                height: stageHeight,
                child: CustomPaint(
                  painter: WordRainPainter(
                    accent: accent,
                    progress: progress,
                    activeWord: activeWord,
                    words: words,
                    index: index,
                    towerBlocks: towerBlocks,
                    maxTowerBlocks: maxTowerBlocks,
                    bonusWord: bonusWord,
                    sweepActive: sweepActive,
                  ),
                  child: const SizedBox.expand(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class WordRainPainter extends CustomPainter {
  const WordRainPainter({
    required this.accent,
    required this.progress,
    required this.activeWord,
    required this.words,
    required this.index,
    required this.towerBlocks,
    required this.maxTowerBlocks,
    required this.bonusWord,
    required this.sweepActive,
  });

  final Color accent;
  final double progress;
  final String activeWord;
  final List<String> words;
  final int index;
  final int towerBlocks;
  final int maxTowerBlocks;
  final bool bonusWord;
  final bool sweepActive;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1B9A9A), Color(0xFF159191)],
      ).createShader(Offset.zero & size);
    final frame = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(8),
    );
    canvas.drawRRect(frame, background);

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.09)
      ..strokeWidth = 1;
    for (var x = 0.0; x <= size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y <= size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final safeWidth = math.max(1.0, size.width - 132);
    if (!sweepActive) {
      for (var i = 1; i < 6; i += 1) {
        final word = words[(index + i * 3).remainder(words.length)];
        final phase = (progress * 0.7 + index * 0.17 + i * 0.2) % 1.0;
        final left =
            18.0 + ((index * 61 + i * 137) % safeWidth.toInt()).toDouble();
        final y = 44 + phase * (size.height - 134);
        _paintWordChip(
          canvas: canvas,
          word: word,
          offset: Offset(left, y),
          color: AppColors.text.withValues(alpha: 0.78),
          active: false,
          bonus: false,
          maxWidth: size.width - 28,
        );
      }
    }

    final activeLeft = 20.0 + ((index * 89) % safeWidth.toInt()).toDouble();
    final activeWidth = _wordWidth(activeWord, active: true);
    final activeImpactY = _impactYForWord(size, activeLeft, activeWidth);
    final activeY = 44 + progress * (activeImpactY - 44);
    _paintWordChip(
      canvas: canvas,
      word: activeWord,
      offset: Offset(activeLeft, activeY),
      color: bonusWord ? AppColors.amber : AppColors.text,
      active: true,
      bonus: bonusWord,
      maxWidth: size.width - 28,
    );

    _paintTower(canvas, size);
    _paintWater(canvas, size);

    if (sweepActive) {
      _paintSweepBanner(canvas, size);
    }

    final baseText = TextPainter(
      text: TextSpan(
        text: bonusWord ? '노란 단어: 싹쓸이' : '물에 닿기 전에 입력하세요',
        style: RetroText.mini.copyWith(
          color: Colors.white.withValues(alpha: 0.88),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 24);
    baseText.paint(
      canvas,
      Offset(size.width - baseText.width - 16, size.height - 43),
    );
  }

  void _paintWordChip({
    required Canvas canvas,
    required String word,
    required Offset offset,
    required Color color,
    required bool active,
    required bool bonus,
    required double maxWidth,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: word,
        style: (active ? RetroText.section : RetroText.radar).copyWith(
          color: active
              ? (bonus ? const Color(0xFFFFE66D) : Colors.white)
              : color,
          fontSize: active ? 30 : 18,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    final dx = offset.dx
        .clamp(8, math.max(8, maxWidth - textPainter.width))
        .toDouble();
    final shadowPainter = TextPainter(
      text: TextSpan(
        text: word,
        style: (active ? RetroText.section : RetroText.radar).copyWith(
          color: Colors.black.withValues(alpha: active ? 0.55 : 0.18),
          fontSize: active ? 30 : 18,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    shadowPainter.paint(canvas, Offset(dx + 2, offset.dy + 2));
    textPainter.paint(canvas, Offset(dx, offset.dy));
  }

  double _wordWidth(String word, {required bool active}) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: word,
        style: (active ? RetroText.section : RetroText.radar).copyWith(
          fontSize: active ? 30 : 18,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  double _impactYForWord(Size size, double left, double width) {
    const columns = 3;
    const rows = 4;
    final blockSize = math.min(26.0, size.width / 24);
    final towerWidth = columns * blockSize;
    final towerHeight = rows * blockSize;
    final towerLeft = (size.width - towerWidth) / 2;
    final towerRight = towerLeft + towerWidth;
    final towerTop = size.height - towerHeight - 43;
    final wordRight = left + width;
    final hitsTower = wordRight >= towerLeft - 18 && left <= towerRight + 18;
    if (hitsTower && towerBlocks > 0) {
      return towerTop - 44;
    }
    return size.height - 78;
  }

  void _paintTower(Canvas canvas, Size size) {
    const columns = 3;
    const rows = 4;
    final blockSize = math.min(26.0, size.width / 24);
    final towerWidth = columns * blockSize;
    final towerHeight = rows * blockSize;
    final left = (size.width - towerWidth) / 2;
    final top = size.height - towerHeight - 43;

    final roof = RRect.fromRectAndRadius(
      Rect.fromLTWH(left - 16, top - 26, towerWidth + 32, 24),
      const Radius.circular(2),
    );
    canvas.drawRRect(roof, Paint()..color = const Color(0xFFD8D8D8));
    canvas.drawRRect(
      roof,
      Paint()
        ..color = AppColors.text
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    for (var i = 0; i < maxTowerBlocks; i += 1) {
      final alive = i < towerBlocks;
      final col = i % columns;
      final row = rows - 1 - (i ~/ columns);
      final rect = Rect.fromLTWH(
        left + col * blockSize,
        top + row * blockSize,
        blockSize - 2,
        blockSize - 2,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = alive
              ? const Color(0xFFA6A6FF)
              : AppColors.text.withValues(alpha: 0.18),
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = alive ? Colors.white : Colors.white.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  void _paintWater(Canvas canvas, Size size) {
    final waterTop = size.height - 38;
    final water = Paint()..color = const Color(0xFF063C96);
    final wavePath = Path()..moveTo(0, waterTop);
    for (var x = 0.0; x <= size.width + 12; x += 12) {
      wavePath.quadraticBezierTo(x + 6, waterTop - 6, x + 12, waterTop);
    }
    wavePath
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(wavePath, water);

    final foam = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 1;
    for (var x = 0.0; x <= size.width; x += 24) {
      canvas.drawLine(
        Offset(x, waterTop + 5),
        Offset(x + 10, waterTop + 5),
        foam,
      );
    }
  }

  void _paintSweepBanner(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.38),
        width: math.min(260, size.width * 0.72),
        height: 64,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(rect, Paint()..color = const Color(0xFFFFE66D));
    canvas.drawRRect(
      rect,
      Paint()
        ..color = AppColors.text
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final textPainter = TextPainter(
      text: TextSpan(
        text: '싹쓸이!',
        style: RetroText.section.copyWith(color: AppColors.text, fontSize: 30),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        rect.outerRect.top + (rect.outerRect.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant WordRainPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeWord != activeWord ||
        oldDelegate.index != index ||
        oldDelegate.accent != accent ||
        oldDelegate.towerBlocks != towerBlocks ||
        oldDelegate.bonusWord != bonusWord ||
        oldDelegate.sweepActive != sweepActive;
  }
}

class ResultSheet extends StatelessWidget {
  const ResultSheet({
    required this.mode,
    required this.result,
    required this.onRetry,
    super.key,
  });

  final PracticeMode mode;
  final PracticeResult result;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: RetroFrame(
        borderColor: mode.accent,
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified, color: mode.accent),
                const SizedBox(width: 10),
                Text('연습 완료', style: RetroText.section),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: HudTile(
                    label: '점수',
                    value: '${result.score}',
                    color: AppColors.amber,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: HudTile(
                    label: '타수',
                    value: '${result.cpm}',
                    color: AppColors.cyan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: HudTile(
                    label: '정확도',
                    value: '${result.accuracy}%',
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: HudTile(
                    label: '오타',
                    value: '${result.mistakes}',
                    color: AppColors.rose,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('닫기'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.replay),
                    label: const Text('다시 도전'),
                    style: FilledButton.styleFrom(
                      backgroundColor: mode.accent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RetroFrame extends StatelessWidget {
  const RetroFrame({
    required this.child,
    this.padding = EdgeInsets.zero,
    this.borderColor = AppColors.line,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.96),
        border: Border.all(color: borderColor, width: 1.4),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.34),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class HudTile extends StatelessWidget {
  const HudTile({
    required this.label,
    required this.value,
    required this.color,
    super.key,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.ink,
        border: Border.all(color: color.withValues(alpha: 0.62)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: RetroText.mini.copyWith(color: AppColors.muted)),
            const SizedBox(height: 3),
            Text(value, style: RetroText.hud.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class CompactHudTile extends StatelessWidget {
  const CompactHudTile({
    required this.label,
    required this.value,
    required this.color,
    super.key,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.panelRaised,
        border: Border.all(color: color.withValues(alpha: 0.72)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: RetroText.mini.copyWith(
                color: AppColors.muted,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 1),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                style: RetroText.hud.copyWith(color: color, fontSize: 17),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WindowDot extends StatelessWidget {
  const _WindowDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: const SizedBox(width: 12, height: 12),
    );
  }
}

class RetroText {
  static const title = TextStyle(
    fontSize: 34,
    height: 1.08,
    fontWeight: FontWeight.w900,
    color: AppColors.text,
    letterSpacing: 0,
  );

  static const section = TextStyle(
    fontSize: 22,
    height: 1.18,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
    letterSpacing: 0,
  );

  static const body = TextStyle(
    fontSize: 15,
    height: 1.45,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
    letterSpacing: 0,
  );

  static const mini = TextStyle(
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );

  static const hud = TextStyle(
    fontSize: 22,
    height: 1.1,
    fontWeight: FontWeight.w900,
    letterSpacing: 0,
  );

  static const target = TextStyle(
    fontSize: 29,
    height: 1.55,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
    letterSpacing: 0,
  );

  static const input = TextStyle(
    fontSize: 22,
    height: 1.35,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
    letterSpacing: 0,
  );

  static const key = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
  );

  static const radar = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    letterSpacing: 0,
  );
}

class PracticeLibrary {
  static const keyHint = {
    '마': 'ㅁ',
    '나': 'ㄴ',
    '아': 'ㅇ',
    '라': 'ㄹ',
    '하': 'ㅎ',
    '고': 'ㄱ',
    '도': 'ㄷ',
    '사': 'ㅅ',
    '바': 'ㅂ',
    '자': 'ㅈ',
    '카': 'ㅋ',
    '타': 'ㅌ',
    '차': 'ㅊ',
    '파': 'ㅍ',
  };

  static List<String> targetsFor(PracticeMode mode) {
    return switch (mode) {
      PracticeMode.keys => const [
        '마',
        '나',
        '아',
        '라',
        '하',
        '고',
        '도',
        '사',
        '바',
        '자',
        '카',
        '타',
      ],
      PracticeMode.words => const [
        '바람',
        '도서관',
        '새벽길',
        '기록장',
        '연습실',
        '정확도',
        '손끝',
        '속도계',
      ],
      PracticeMode.passage => const [
        '오늘의 연습은 빠르게 치는 것보다 흔들리지 않는 리듬을 찾는 일에서 시작합니다. 손끝은 천천히 길을 기억하고, 문장은 또렷한 호흡으로 이어집니다.',
      ],
      PracticeMode.defense => const [
        '학교',
        '수업',
        '바람',
        '기록',
        '별똥별',
        '소나기',
        '키보드',
        '연습',
        '정확도',
        '집중',
        '완료',
        '도전',
      ],
    };
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
