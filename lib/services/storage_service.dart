import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/game_data.dart';

/// Permanenteng save: stars, scores, coins, power-ups, themes, daily, settings.
class Storage {
  static late SharedPreferences _p;

  static Future<void> init() async {
    _p = await SharedPreferences.getInstance();
  }

  // ---------------- Levels ----------------
  static int stars(int level) => _p.getInt('stars_$level') ?? 0;
  static int bestScore(int level) => _p.getInt('best_$level') ?? 0;
  static int bestMoves(int level) => _p.getInt('moves_$level') ?? 0;

  static int get totalStars {
    int t = 0;
    for (int i = 0; i < kLevels.length; i++) {
      t += stars(i);
    }
    return t;
  }

  static bool isUnlocked(int level) => level == 0 || stars(level - 1) > 0;

  static void saveResult(int level, int earnedStars, int score, int moves) {
    if (earnedStars > stars(level)) _p.setInt('stars_$level', earnedStars);
    if (score > bestScore(level)) _p.setInt('best_$level', score);
    final m = bestMoves(level);
    if (m == 0 || moves < m) _p.setInt('moves_$level', moves);
  }

  // ---------------- Endless ----------------
  static int get endlessBest => _p.getInt('endless_best') ?? 0;
  static int get endlessRound => _p.getInt('endless_round') ?? 0;

  static void saveEndless(int score, int round) {
    if (score > endlessBest) _p.setInt('endless_best', score);
    if (round > endlessRound) _p.setInt('endless_round', round);
  }

  // ---------------- Coins ----------------
  static int get coins => _p.getInt('coins') ?? 50; // starter coins

  static void addCoins(int n) => _p.setInt('coins', coins + n);

  static bool spendCoins(int n) {
    if (coins < n) return false;
    _p.setInt('coins', coins - n);
    return true;
  }

  // ---------------- Power-ups ----------------
  static int powerUps(String id) => _p.getInt('pu_$id') ?? 1; // 1 libre

  static void addPowerUp(String id, [int n = 1]) =>
      _p.setInt('pu_$id', powerUps(id) + n);

  static bool usePowerUp(String id) {
    final n = powerUps(id);
    if (n <= 0) return false;
    _p.setInt('pu_$id', n - 1);
    return true;
  }

  // ---------------- Card back themes ----------------
  static List<int> get ownedThemes =>
      (_p.getStringList('themes') ?? ['0']).map(int.parse).toList();
  static bool ownsTheme(int i) => ownedThemes.contains(i);

  static void unlockTheme(int i) => _p.setStringList(
      'themes', [...ownedThemes, i].map((e) => e.toString()).toList());

  static int get selectedTheme {
    final i = _p.getInt('theme_sel') ?? 0;
    return (i >= 0 && i < kBackThemes.length) ? i : 0;
  }

  static void selectTheme(int i) => _p.setInt('theme_sel', i);

  // ---------------- Daily reward ----------------
  static int _today() {
    final n = DateTime.now();
    return DateTime.utc(n.year, n.month, n.day).millisecondsSinceEpoch ~/ 86400000;
  }

  static int get _lastClaim => _p.getInt('daily_last') ?? -1;
  static int get _streak => _p.getInt('daily_streak') ?? 0;

  static bool get claimedToday => _lastClaim == _today();
  static bool get canClaimDaily => !claimedToday;

  /// Ilang araw na ang na-claim sa kasalukuyang 7-day cycle (0-7)
  static int get dailyClaimedUpTo {
    final today = _today();
    if (_lastClaim == today) return ((_streak - 1) % 7) + 1;
    if (_lastClaim == today - 1) return _streak % 7;
    return 0;
  }

  static int get dailyStreak {
    final today = _today();
    return (_lastClaim != -1 && _lastClaim >= today - 1) ? _streak : 0;
  }

  static DailyReward? claimDaily() {
    if (claimedToday) return null;
    final today = _today();
    final newStreak = (_lastClaim == today - 1) ? _streak + 1 : 1;
    final reward = kDailyRewards[(newStreak - 1) % 7];
    _p.setInt('daily_last', today);
    _p.setInt('daily_streak', newStreak);
    addCoins(reward.coins);
    if (reward.bonusPack) {
      for (final pu in kPowerUps) {
        addPowerUp(pu.id);
      }
    }
    return reward;
  }

  // ---------------- Avatars (binibili gamit ang stars) ----------------
  static String get avatar => _p.getString('avatar') ?? 'strawberry';
  static void setAvatar(String key) => _p.setString('avatar', key);

  static List<String> get ownedAvatars =>
      _p.getStringList('avatars') ?? ['strawberry'];
  static bool ownsAvatar(String key) => ownedAvatars.contains(key);

  static int get starsSpent => _p.getInt('stars_spent') ?? 0;

  /// Stars na puwede pang gastusin (hindi nababawasan ang level stars mo)
  static int get availableStars => max(0, totalStars - starsSpent);

  static bool buyAvatar(AvatarDef a) {
    if (ownsAvatar(a.key)) return true;
    if (availableStars < a.price) return false;
    _p.setInt('stars_spent', starsSpent + a.price);
    _p.setStringList('avatars', [...ownedAvatars, a.key]);
    return true;
  }

  // ---------------- Top 10 Endless runs (sa phone lang) ----------------
  static List<List<int>> get endlessRuns {
    final out = <List<int>>[];
    for (final s in _p.getStringList('endless_runs') ?? <String>[]) {
      final p = s.split('|');
      if (p.length == 2) {
        final a = int.tryParse(p[0]);
        final b = int.tryParse(p[1]);
        if (a != null && b != null) out.add([a, b]); // [score, rounds]
      }
    }
    return out;
  }

  static void addEndlessRun(int score, int rounds) {
    if (score <= 0) return;
    final runs = endlessRuns..add([score, rounds]);
    runs.sort((a, b) => b[0].compareTo(a[0]));
    _p.setStringList(
        'endless_runs', runs.take(10).map((r) => '${r[0]}|${r[1]}').toList());
  }

  // ---------------- Settings ----------------
  static bool get soundOn => _p.getBool('sound') ?? true;
  static bool get musicOn => _p.getBool('music') ?? true;
  static String get playerName => _p.getString('name') ?? 'Player';

  static double get musicVolume => _p.getDouble('music_vol') ?? 0.35;
  static double get sfxVolume => _p.getDouble('sfx_vol') ?? 1.0;
  static int get musicTrack {
    final i = _p.getInt('music_track') ?? 0;
    return (i >= 0 && i < kMusicTracks.length) ? i : 0;
  }

  static void setSound(bool v) => _p.setBool('sound', v);
  static void setMusic(bool v) => _p.setBool('music', v);
  static void setPlayerName(String v) => _p.setString('name', v);
  static void setMusicVolume(double v) => _p.setDouble('music_vol', v);
  static void setSfxVolume(double v) => _p.setDouble('sfx_vol', v);
  static void setMusicTrack(int i) => _p.setInt('music_track', i);
}
