import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/game_data.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../widgets/cafe_background.dart';
import '../widgets/cafe_widgets.dart';
import '../widgets/confetti_layer.dart';
import '../widgets/flip_card.dart';
import '../widgets/option_panel.dart';
import 'settings_screen.dart';

/// Level mode:   GameScreen(levelIndex: 0)
/// Endless mode: GameScreen(endless: true)   -> Unlimited Customers Challenge
class GameScreen extends StatefulWidget {
  final int levelIndex;
  final bool endless;
  const GameScreen({super.key, this.levelIndex = 0, this.endless = false});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const List<int> _endlessPairs = [4, 5, 6, 8, 10, 12];
  static const int _shuffleMs = 3000; // 3 segundo na shuffle
  static const int _endlessStartTime = 120; // Endless: 2 minuto
  static const int _endlessBonusTime = 50; // +50 segundo kada natapos na round

  List<CardModel> cards = [];
  CardModel? first;
  bool busy = true; // naka-lock ang pag-tap
  bool shuffling = true; // nagsa-shuffle pa ang cards
  bool ended = false;
  bool paused = false; // naka-pause (OPTION panel)
  int shuffleLeft = 3;
  int timeLeft = 0;
  int timeTotal = 1;
  int score = 0;
  int moves = 0;
  int combo = 0;
  int maxCombo = 0;
  int served = 0; // endless: ilang customer na ang napagsilbihan
  int customerNo = 1;
  int runCoins = 0; // coins na nakuha sa Endless run na ito
  int _gen = 0;
  String? comboLabel;
  Timer? _shuffleTimer;
  Timer? _gameTimer;
  final GlobalKey<ConfettiLayerState> _confetti =
      GlobalKey<ConfettiLayerState>();

  // ---------------- Config ----------------
  int get pairs => widget.endless
      ? _endlessPairs[min(served ~/ 2, _endlessPairs.length - 1)]
      : kLevels[widget.levelIndex].pairs;

  int get columns {
    final n = pairs * 2;
    if (n <= 4) return 2;
    if (n % 5 == 0) return 5;
    return 4;
  }

  // ---------------- Lifecycle ----------------
  @override
  void initState() {
    super.initState();
    _resetState();
    _startShuffle();
  }

  @override
  void dispose() {
    _shuffleTimer?.cancel();
    _gameTimer?.cancel();
    super.dispose();
  }

  void _resetState() {
    score = 0;
    moves = 0;
    combo = 0;
    maxCombo = 0;
    served = 0;
    customerNo = 1;
    runCoins = 0;
    paused = false;
    ended = false;
    comboLabel = null;
    timeTotal = widget.endless
        ? _endlessStartTime
        : kLevels[widget.levelIndex].timeLimit;
    timeLeft = timeTotal;
    _setupCards();
  }

  void _restart() {
    _shuffleTimer?.cancel();
    _gameTimer?.cancel();
    setState(_resetState);
    _startShuffle();
  }

  void _nextCustomer() {
    _shuffleTimer?.cancel();
    _gameTimer?.cancel();
    setState(() {
      customerNo++;
      combo = 0;
      _setupCards();
    });
    _startShuffle();
  }

  void _setupCards() {
    _gen++;
    final keys = kFruitDefs.map((f) => f.key).toList()..shuffle(Random());
    final chosen = keys.take(pairs).toList();
    final list = <CardModel>[];
    int id = 0;
    for (final k in chosen) {
      list.add(CardModel(id++, k)); // WALANG preview: nakatago agad
      list.add(CardModel(id++, k));
    }
    list.shuffle(Random());
    for (int i = 0; i < list.length; i++) {
      list[i].slot = i;
    }
    cards = list;
    first = null;
    busy = true;
    shuffling = true;
    shuffleLeft = _shuffleMs ~/ 1000;
  }

  // ---------------- 3-second shuffle ----------------
  void _shuffleSlots() {
    final slots = List<int>.generate(cards.length, (i) => i)
      ..shuffle(Random());
    for (int i = 0; i < cards.length; i++) {
      cards[i].slot = slots[i];
    }
  }

  void _startShuffle() {
    _shuffleTimer?.cancel();
    _gameTimer?.cancel();
    AudioService.instance.play('shuffle');
    int elapsed = 0;
    _shuffleTimer = Timer.periodic(const Duration(milliseconds: 300), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (paused) return;
      elapsed += 300;
      if (elapsed >= _shuffleMs) {
        t.cancel();
        setState(() {
          shuffling = false;
          busy = false;
          shuffleLeft = 0;
        });
        _startGameTimer();
      } else {
        setState(() {
          _shuffleSlots();
          shuffleLeft = ((_shuffleMs - elapsed) / 1000).ceil();
        });
      }
    });
  }

  // ---------------- Game timer ----------------
  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || ended || shuffling || paused) return;
      setState(() => timeLeft--);
      if (timeLeft > 0 && timeLeft <= 5) AudioService.instance.play('tick');
      if (timeLeft <= 0) _timeUp();
    });
  }

  void _timeUp() {
    if (ended) return;
    _gameTimer?.cancel();
    AudioService.instance.play('wrong');

    if (widget.endless) {
      setState(() {
        ended = true;
        busy = true;
        timeLeft = 0;
      });
      _endlessOver();
      return;
    }

    setState(() {
      ended = true;
      busy = true;
      timeLeft = 0;
    });
    showOptionPanel(
      context,
      title: "TIME'S UP",
      onClose: () => Navigator.pop(context),
      content: optionInset(const Text(
        'Subukan ulit, kaya mo yan!',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      )),
      buttons: [
        OptionBtn('RESTART', _restart),
        OptionBtn('MENU', () => Navigator.pop(context)),
      ],
    );
  }

  // ---------------- Gameplay ----------------
  void _flash(String text) {
    setState(() => comboLabel = text);
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted && comboLabel == text) setState(() => comboLabel = null);
    });
  }

  void _onTap(CardModel card) {
    if (busy || ended || shuffling || card.faceUp || card.matched) return;

    AudioService.instance.play('flip');
    setState(() => card.faceUp = true);

    if (first == null) {
      first = card;
      return;
    }

    final a = first!;
    final b = card;
    first = null;
    moves++;
    busy = true;

    if (a.fruit == b.fruit) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted || ended) return;
        AudioService.instance.play('match');
        combo++;
        if (combo > maxCombo) maxCombo = combo;
        final points = 100 + min(combo - 1, 5) * 50; // combo bonus
        setState(() {
          a.matched = true;
          b.matched = true;
          score += points;
          busy = false;
        });
        if (combo >= 2) _flash('COMBO x$combo!  +$points');
        if (combo >= 3) {
          _confetti.currentState?.burst(
              origin: const Offset(0.5, 0.45), count: 30, power: 0.8);
        }
        if (cards.every((c) => c.matched)) {
          if (widget.endless) {
            _customerServed();
          } else {
            _levelCleared();
          }
        }
      });
    } else {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted || ended) return;
        AudioService.instance.play('wrong');
        setState(() {
          a.faceUp = false;
          b.faceUp = false;
          combo = 0;
          score = max(0, score - 10);
          busy = false;
        });
      });
    }
  }

  int _calcStars() {
    if (moves <= pairs + (pairs / 2).ceil()) return 3;
    if (moves <= pairs * 2 + 2) return 2;
    return 1;
  }

  // ---------------- Level cleared ----------------
  void _levelCleared() {
    _gameTimer?.cancel();
    final timeBonus = timeLeft * 5;
    setState(() {
      ended = true;
      busy = true;
      score += timeBonus;
    });
    final stars = _calcStars();
    final coinsEarned = max(5, score ~/ 10);
    Storage.saveResult(widget.levelIndex, stars, score, moves);
    Storage.addCoins(coinsEarned);

    _confetti.currentState
        ?.burst(origin: const Offset(0.15, 0.95), count: 70, spread: 0.7);
    _confetti.currentState
        ?.burst(origin: const Offset(0.85, 0.95), count: 70, spread: 0.7);

    final isLast = widget.levelIndex == kLevels.length - 1;
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      AudioService.instance.play('win');
      showOptionPanel(
        context,
        title: 'LEVEL ${widget.levelIndex + 1} CLEAR',
        onClose: () => Navigator.pop(context),
        content: optionInset(Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            starsRow(stars, size: 46),
            const SizedBox(height: 8),
            Text('Score: $score',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w900)),
            Text('Moves: $moves  •  Best combo: x$maxCombo',
                style: const TextStyle(fontSize: 14)),
            if (timeBonus > 0)
              Text('⏱ Time bonus: +$timeBonus',
                  style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Text('🪙 +$coinsEarned coins',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w900)),
          ],
        )),
        buttons: [
          if (!isLast)
            OptionBtn('NEXT', () => _goLevel(widget.levelIndex + 1)),
          OptionBtn('RESTART', _restart),
          OptionBtn('MENU', () => Navigator.pop(context)),
        ],
      );
    });
  }

  // ---------------- Endless: Unlimited Customers ----------------
  void _customerServed() {
    _gameTimer?.cancel();
    final bonus = 150 + served * 20 + timeLeft * 3;
    final coinReward = 10 + served * 3; // coin reward kada natapos na round
    Storage.addCoins(coinReward);
    setState(() {
      busy = true;
      score += bonus;
      served++;
      runCoins += coinReward;
      timeLeft += _endlessBonusTime; // +50 segundo
    });
    AudioService.instance.play('win');
    _confetti.currentState?.burst(
        origin: const Offset(0.5, 0.5), count: 50, power: 0.9, spread: 2.0);
    _flash('✅ ROUND CLEAR!\n⏱ +${_endlessBonusTime}s   🪙 +$coinReward');
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted && !ended) _nextCustomer();
    });
  }

  void _endlessOver() {
    final finalBonus = max(5, score ~/ 30);
    final newBest = score > Storage.endlessBest;
    Storage.saveEndless(score, served);
    Storage.addCoins(finalBonus);
    runCoins += finalBonus;
    Storage.addEndlessRun(score, served); // top 10 runs sa phone

    showOptionPanel(
      context,
      title: 'GAME OVER',
      onClose: () => Navigator.pop(context),
      content: optionInset(Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Rounds cleared: $served',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          Text('Score: $score',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          if (newBest)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('🏆 Bagong High Score!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 6),
          Text('🪙 +$runCoins coins',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        ],
      )),
      buttons: [
        OptionBtn('RESTART', _restart),
        OptionBtn('MENU', () => Navigator.pop(context)),
      ],
    );
  }

  // ---------------- Pause (OPTION) ----------------
  void _pause() {
    if (ended) return;
    AudioService.instance.play('click');
    setState(() => paused = true);
    void resume() {
      if (mounted) setState(() => paused = false);
    }

    showOptionPanel(
      context,
      title: 'PAUSED',
      onClose: resume,
      iconRow: [
        OptionToggle(
          on: Icons.volume_up_rounded,
          off: Icons.volume_off_rounded,
          value: Storage.soundOn,
          onChanged: (v) => Storage.setSound(v),
        ),
        OptionToggle(
          on: Icons.music_note_rounded,
          off: Icons.music_off_rounded,
          value: Storage.musicOn,
          onChanged: (v) {
            Storage.setMusic(v);
            AudioService.instance.setMusic(v);
          },
        ),
      ],
      buttons: [
        OptionBtn('PLAY', resume),
        OptionBtn('RESTART', _restart),
        OptionBtn('OPTIONS', () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
          if (mounted && !ended) _pause();
        }),
        OptionBtn('QUIT', () => Navigator.pop(context)),
      ],
    );
  }

  // ---------------- Next / Back ----------------
  void _goLevel(int idx) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(levelIndex: idx)),
    );
  }

  // ---------------- Power-ups ----------------
  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  void _usePower(PowerUp p) {
    if (ended || shuffling) return;
    if (Storage.powerUps(p.id) <= 0) {
      AudioService.instance.play('wrong');
      _toast('Wala ka nang ${p.name}. Bumili sa Shop!');
      return;
    }

    switch (p.id) {
      case 'time':
        Storage.usePowerUp(p.id);
        AudioService.instance.play('coin');
        setState(() => timeLeft += 15);
        _flash('⏱ +15s');
        break;

      case 'peek':
        if (busy) return;
        final reveal = cards.where((c) => !c.matched && !c.faceUp).toList();
        if (reveal.isEmpty) return;
        Storage.usePowerUp(p.id);
        AudioService.instance.play('flip');
        setState(() {
          busy = true;
          for (final c in reveal) {
            c.faceUp = true;
          }
        });
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (!mounted) return;
          setState(() {
            for (final c in reveal) {
              c.faceUp = false;
            }
            busy = false;
          });
        });
        break;

      case 'hint':
        if (busy) return;
        final CardModel a;
        final CardModel b;
        final f = first;
        if (f != null) {
          a = f;
          b = cards.firstWhere(
              (c) => !c.matched && c != f && c.fruit == f.fruit);
        } else {
          final un = cards.where((c) => !c.matched).toList()..shuffle();
          final x = un.first;
          a = x;
          b = un.firstWhere((c) => c != x && c.fruit == x.fruit);
        }
        Storage.usePowerUp(p.id);
        AudioService.instance.play('flip');
        final reveal = [a, b].where((c) => !c.faceUp).toList();
        setState(() {
          busy = true;
          for (final c in reveal) {
            c.faceUp = true;
          }
        });
        Future.delayed(const Duration(milliseconds: 1300), () {
          if (!mounted) return;
          setState(() {
            for (final c in reveal) {
              c.faceUp = false;
            }
            busy = false;
          });
        });
        break;
    }
  }

  // ---------------- UI ----------------
  String _fmt(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kCaramel, kCaramelDark],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kGold, width: 2),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900)),
      );

  Widget _timerBar() {
    final v = (timeLeft / timeTotal).clamp(0.0, 1.0);
    final low = timeLeft <= 10;
    final face = timeLeft > 60 ? '😊' : (timeLeft > 20 ? '😐' : '😠');
    final label = widget.endless
        ? '$face Round $customerNo  ⏱ ${_fmt(max(0, timeLeft))}'
        : '⏱ ${_fmt(max(0, timeLeft))}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0x99000000),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: low ? Colors.redAccent : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: v,
                  minHeight: 12,
                  color: low ? Colors.redAccent : kGold,
                  backgroundColor: const Color(0x33FFFFFF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _grid() {
    return LayoutBuilder(
      builder: (context, box) {
        final cols = columns;
        const gap = 12.0;
        final avail = min(box.maxWidth - 32, 420.0);
        final cell = (avail - gap * (cols - 1)) / cols;
        final rows = (cards.length / cols).ceil();
        final w = cell * cols + gap * (cols - 1);
        final h = cell * rows + gap * (rows - 1);
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              width: w,
              height: h,
              child: Stack(
                children: [
                  for (final c in cards)
                    AnimatedPositioned(
                      key: ValueKey('$_gen-${c.id}'),
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOut,
                      left: (c.slot % cols) * (cell + gap),
                      top: (c.slot ~/ cols) * (cell + gap),
                      width: cell,
                      height: cell,
                      child: GestureDetector(
                        onTap: () => _onTap(c),
                        child: FlipCard(card: c),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _powerBtn(PowerUp p) {
    final n = Storage.powerUps(p.id);
    return GestureDetector(
      onTap: () => _usePower(p),
      child: Opacity(
        opacity: n > 0 ? 1 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: goldDecoration(radius: 22),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(p.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 6),
              Text('x$n',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _powerBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [for (final p in kPowerUps) _powerBtn(p)],
      ),
    );
  }

  /// BACK at NEXT buttons (level mode lang)
  Widget _navRow() {
    final i = widget.levelIndex;
    final hasPrev = i > 0;
    final hasNext = i < kLevels.length - 1 && Storage.isUnlocked(i + 1);
    final nextExists = i < kLevels.length - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          pillButton('◀ BACK', () {
            if (hasPrev) {
              _goLevel(i - 1);
            } else {
              Navigator.pop(context);
            }
          }),
          if (nextExists)
            pillButton(hasNext ? 'NEXT ▶' : 'NEXT 🔒', () => _goLevel(i + 1),
                enabled: hasNext),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CafeBackground(
      full: false,
      child: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                ScreenHeader(
                  title: widget.endless
                      ? 'ENDLESS RUSH'
                      : 'LEVEL ${widget.levelIndex + 1}',
                  trailing: IconButton(
                    icon: const Icon(Icons.pause_circle_filled_rounded,
                        color: Colors.white, size: 32),
                    onPressed: _pause,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: widget.endless
                        ? [
                            _chip('⭐ $score'),
                            _chip('👥 Served $served'),
                            _chip('🔥 x$combo'),
                          ]
                        : [
                            _chip('⭐ $score'),
                            _chip('👆 $moves'),
                            _chip('🔥 x$combo'),
                          ],
                  ),
                ),
                _timerBar(),
                SizedBox(
                  height: 28,
                  child: Center(
                    child: shuffling
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0x99000000),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '🔀 Nagsa-shuffle ang cards... $shuffleLeft',
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: kGold),
                            ),
                          )
                        : null,
                  ),
                ),
                Expanded(child: _grid()),
                _powerBar(),
                if (!widget.endless) _navRow(),
              ],
            ),
          ),
          Positioned.fill(child: ConfettiLayer(key: _confetti)),
          if (comboLabel != null)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      comboLabel!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: kGold,
                        shadows: [
                          Shadow(
                              color: Colors.black,
                              blurRadius: 8,
                              offset: Offset(2, 2)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
