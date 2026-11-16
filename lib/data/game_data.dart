import 'package:flutter/material.dart';

// ---------------- Cafe palette ----------------
const Color kGold = Color(0xFFFFC62B);
const Color kCaramel = Color(0xFFD98E4F);
const Color kCaramelDark = Color(0xFF9C5A2E);
const Color kBrown = Color(0xFF6B3B1E);
const Color kBrownDark = Color(0xFF3B2314);
const Color kCream = Color(0xFFFDF8EA);

// ---------------- Fruits (15) ----------------
// key = pangalan ng PNG sa assets/images/fruits/<key>.png (kung meron)
class FruitDef {
  final String key;
  final String emoji;
  const FruitDef(this.key, this.emoji);
}

const List<FruitDef> kFruitDefs = [
  FruitDef('apple', '🍎'),
  FruitDef('banana', '🍌'),
  FruitDef('strawberry', '🍓'),
  FruitDef('orange', '🍊'),
  FruitDef('grapes', '🍇'),
  FruitDef('watermelon', '🍉'),
  FruitDef('pineapple', '🍍'),
  FruitDef('kiwi', '🥝'),
  FruitDef('cherry', '🍒'),
  FruitDef('pear', '🍐'),
  FruitDef('peach', '🍑'),
  FruitDef('lemon', '🍋'),
  FruitDef('mango', '🥭'),
  FruitDef('blueberry', '🫐'),
  FruitDef('coconut', '🥥'),
];

String emojiFor(String key) =>
    kFruitDefs.firstWhere((f) => f.key == key).emoji;

// ---------------- Levels (20) ----------------
class LevelInfo {
  final int cards;
  final String difficulty;
  final int timeLimit; // segundo
  final int preview; // segundo ng preview
  const LevelInfo(this.cards, this.difficulty, this.timeLimit, this.preview);
  int get pairs => cards ~/ 2;
}

const List<int> _kLevelPairs = [
  2, 4, 6, 8, 10, //  Level 1-5
  10, 12, 12, 12, 12, //  Level 6-10
  15, 15, 15, 15, 15, //  Level 11-15
  15, 15, 15, 15, 15, //  Level 16-20
];

List<LevelInfo> _buildLevels() {
  const perPair = [10, 9, 8, 7]; // mas mabilis habang tumataas ang level
  return List.generate(_kLevelPairs.length, (i) {
    final pairs = _kLevelPairs[i];
    final tier = i ~/ 5;
    final diff = i < 3
        ? 'Easy'
        : i < 10
            ? 'Medium'
            : i < 16
                ? 'Hard'
                : 'Expert';
    return LevelInfo(pairs * 2, diff, 15 + pairs * perPair[tier], 3 + pairs ~/ 5);
  });
}

final List<LevelInfo> kLevels = _buildLevels();

class CardModel {
  final int id;
  final String fruit; // fruit key
  bool faceUp;
  bool matched;
  int slot; // posisyon sa grid (nagbabago habang nag-shuffle)
  CardModel(this.id, this.fruit,
      {this.faceUp = false, this.matched = false, this.slot = 0});
}

String rankFor(int totalStars) {
  final maxStars = kLevels.length * 3;
  final pct = totalStars * 100 ~/ maxStars;
  if (pct >= 70) return 'Memory Master';
  if (pct >= 35) return 'Fruit Expert';
  if (pct >= 10) return 'Fruit Fan';
  return 'Little Learner';
}

// ---------------- Shop ----------------
class PowerUp {
  final String id;
  final String name;
  final String emoji;
  final String desc;
  final int price;
  const PowerUp(this.id, this.name, this.emoji, this.desc, this.price);
}

const List<PowerUp> kPowerUps = [
  PowerUp('peek', 'Peek', '👀', 'Ipakita sandali ang lahat ng cards', 25),
  PowerUp('time', 'Extra Time', '⏱️', 'Dagdag na 15 segundo', 20),
  PowerUp('hint', 'Hint', '💡', 'Ipakita ang isang pares', 35),
];

class BackTheme {
  final String name;
  final int price;
  final Color c1;
  final Color c2;
  const BackTheme(this.name, this.price, this.c1, this.c2);
}

const List<BackTheme> kBackThemes = [
  BackTheme('Caramel', 0, kCaramel, kCaramelDark),
  BackTheme('Berry', 150, Color(0xFFB65CC9), Color(0xFF6E2B86)),
  BackTheme('Mint', 150, Color(0xFF59C9A5), Color(0xFF2B8668)),
  BackTheme('Ocean', 200, Color(0xFF4AA3E0), Color(0xFF1F5E9E)),
  BackTheme('Sunset', 100, Color(0xFFFF8A65), Color(0xFFE64A19)),
  BackTheme('Rose', 120, Color(0xFFF48FB1), Color(0xFFAD1457)),
  BackTheme('Lemon', 120, Color(0xFFFFF176), Color(0xFFF9A825)),
  BackTheme('Lava', 150, Color(0xFFEF5350), Color(0xFFB71C1C)),
  BackTheme('Midnight', 180, Color(0xFF5C6BC0), Color(0xFF1A237E)),
  BackTheme('Candy', 200, Color(0xFFF06292), Color(0xFF7B1FA2)),
  BackTheme('Gold', 250, Color(0xFFFFD54F), Color(0xFFFF8F00)),
  BackTheme('Galaxy', 300, Color(0xFF7E57C2), Color(0xFF311B92)),
];

// ---------------- Daily rewards (7-day cycle) ----------------
class DailyReward {
  final int coins;
  final bool bonusPack; // +1 bawat power-up
  const DailyReward(this.coins, {this.bonusPack = false});
}

const List<DailyReward> kDailyRewards = [
  DailyReward(20),
  DailyReward(30),
  DailyReward(40),
  DailyReward(50),
  DailyReward(60),
  DailyReward(80),
  DailyReward(150, bonusPack: true),
];

// ---------------- Profile avatars (binibili gamit ang STARS) ----------------
class AvatarDef {
  final String key; // fruit key
  final int price; // stars
  const AvatarDef(this.key, this.price);
}

const List<AvatarDef> kAvatars = [
  AvatarDef('strawberry', 0),
  AvatarDef('watermelon', 1),
  AvatarDef('banana', 2),
  AvatarDef('orange', 2),
  AvatarDef('apple', 3),
  AvatarDef('cherry', 3),
  AvatarDef('grapes', 3),
  AvatarDef('peach', 4),
  AvatarDef('pineapple', 4),
  AvatarDef('kiwi', 4),
  AvatarDef('lemon', 5),
  AvatarDef('mango', 5),
  AvatarDef('pear', 5),
  AvatarDef('blueberry', 6),
  AvatarDef('coconut', 7),
];

String fruitName(String key) => key[0].toUpperCase() + key.substring(1);

// ---------------- Background music tracks ----------------
class MusicTrack {
  final String name;
  final String file;
  const MusicTrack(this.name, this.file);
}

const List<MusicTrack> kMusicTracks = [
  MusicTrack('Sunny Morning', 'bgm.wav'),
  MusicTrack('Cozy Cafe', 'bgm2.wav'),
  MusicTrack('Fruit Party', 'bgm3.wav'),
];

// ---------------- App info ----------------
const String kFeedbackEmail = 'frincedayapera@gmail.com';
const String kAppVersion = '1.2.0';

/// Direktang padala ng feedback papunta sa kFeedbackEmail (FormSubmit.co, walang signup).
/// Sa unang padala, magpapadala sila ng activation email sa developer. I-click lang ang Activate.
const String kFeedbackEndpoint = 'https://formsubmit.co/ajax/$kFeedbackEmail';
