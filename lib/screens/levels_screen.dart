import 'package:flutter/material.dart';
import '../data/game_data.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../widgets/cafe_background.dart';
import '../widgets/cafe_widgets.dart';
import 'game_screen.dart';

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key});

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  Future<void> _play(int i) async {
    if (!Storage.isUnlocked(i)) {
      AudioService.instance.play('wrong');
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('Tapusin muna ang Level $i para mabuksan ito!'),
        ));
      return;
    }
    AudioService.instance.play('click');
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(levelIndex: i)),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CafeBackground(
      full: false,
      child: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'LEVELS'),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '⭐ ${Storage.totalStars} / ${kLevels.length * 3}',
                style: const TextStyle(
                    color: kGold, fontSize: 17, fontWeight: FontWeight.w900),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemCount: kLevels.length,
                itemBuilder: (context, i) {
                  final lv = kLevels[i];
                  final unlocked = Storage.isUnlocked(i);
                  return GestureDetector(
                    onTap: () => _play(i),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: goldDecoration(radius: 20, dim: !unlocked),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            unlocked
                                ? Text('${i + 1}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w900))
                                : const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4),
                                    child: Icon(Icons.lock_rounded,
                                        color: Colors.white70, size: 28),
                                  ),
                            starsRow(Storage.stars(i), size: 16),
                            Text('${lv.cards} cards',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
