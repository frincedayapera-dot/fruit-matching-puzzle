import 'package:flutter/services.dart';
import '../data/game_data.dart';

/// Chine-check kung may sarili kang PNG sa assets/images/fruits/ at mascot.png.
/// Kapag wala, emoji ang gagamitin.
class FruitAssets {
  static final Set<String> _available = {};
  static bool mascotAvailable = false;

  static Future<void> init() async {
    for (final f in kFruitDefs) {
      try {
        await rootBundle.load('assets/images/fruits/${f.key}.png');
        _available.add(f.key);
      } catch (_) {}
    }
    try {
      await rootBundle.load('assets/images/mascot.png');
      mascotAvailable = true;
    } catch (_) {}
  }

  static bool has(String key) => _available.contains(key);
}
