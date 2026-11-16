import 'package:flutter/material.dart';
import '../data/game_data.dart';
import '../services/storage_service.dart';
import '../widgets/cafe_background.dart';
import '../widgets/cafe_widgets.dart';

class HighScoresScreen extends StatelessWidget {
  const HighScoresScreen({super.key});

  String _medal(int i) =>
      i == 0 ? '🥇' : (i == 1 ? '🥈' : (i == 2 ? '🥉' : '${i + 1}.'));

  Widget _endlessCard() {
    final played = Storage.endlessBest > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: goldDecoration(dim: !played),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: kGold, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ENDLESS RUSH',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(
                  played
                      ? 'Best score: ${Storage.endlessBest}  •  Best rounds: ${Storage.endlessRound}'
                      : 'Hindi pa nalalaro',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Top 10 pinakamagandang Endless runs mo (naka-save sa phone)
  Widget _runsCard() {
    final runs = Storage.endlessRuns;
    if (runs.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: goldDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏆 TOP ENDLESS RUNS',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          for (int i = 0; i < runs.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(_medal(i),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900)),
                  ),
                  Expanded(
                    child: Text('Rounds cleared: ${runs[i][1]}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  Text('${runs[i][0]}',
                      style: const TextStyle(
                          color: kGold,
                          fontSize: 17,
                          fontWeight: FontWeight.w900)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _levelRow(int i) {
    final played = Storage.stars(i) > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: goldDecoration(radius: 22, dim: !played),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LEVEL ${i + 1}  •  ${kLevels[i].cards} cards',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(
                  played
                      ? 'Best score: ${Storage.bestScore(i)}  •  Best moves: ${Storage.bestMoves(i)}'
                      : 'Hindi pa nalalaro',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          starsRow(Storage.stars(i), size: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CafeBackground(
      full: false,
      child: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'HIGH SCORES'),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '⭐ ${Storage.totalStars} / ${kLevels.length * 3}  •  ${rankFor(Storage.totalStars)}',
                style: const TextStyle(
                    color: kGold, fontSize: 17, fontWeight: FontWeight.w900),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  _endlessCard(),
                  _runsCard(),
                  for (int i = 0; i < kLevels.length; i++) _levelRow(i),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
