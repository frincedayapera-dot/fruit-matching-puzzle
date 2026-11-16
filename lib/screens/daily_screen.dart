import 'package:flutter/material.dart';
import '../data/game_data.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../widgets/cafe_background.dart';
import '../widgets/cafe_widgets.dart';
import '../widgets/confetti_layer.dart';

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  final GlobalKey<ConfettiLayerState> _confetti = GlobalKey<ConfettiLayerState>();
  String? _msg;

  void _claim() {
    final r = Storage.claimDaily();
    if (r == null) return;
    AudioService.instance.play('win');
    _confetti.currentState?.burst(origin: const Offset(0.5, 0.75), count: 80);
    setState(() {
      _msg = '+${r.coins} coins${r.bonusPack ? ' at libreng power-ups!' : '!'}';
    });
  }

  Widget _dayTile(int day, double width) {
    final reward = kDailyRewards[day - 1];
    final upTo = Storage.dailyClaimedUpTo;
    final claimed = day <= upTo;
    final isNext = !Storage.claimedToday && day == upTo + 1;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: claimed
              ? const [Color(0xFF6FAE4A), Color(0xFF3F7F2E)]
              : const [kCaramel, kCaramelDark],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isNext ? Colors.white : kGold, width: isNext ? 4 : 3),
        boxShadow: const [
          BoxShadow(color: Colors.black54, offset: Offset(0, 5), blurRadius: 5),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('DAY $day',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(day == 7 ? '🎁' : '🪙', style: const TextStyle(fontSize: 26)),
          Text('+${reward.coins}',
              style: const TextStyle(
                  color: kGold, fontSize: 16, fontWeight: FontWeight.w900)),
          SizedBox(
            height: 20,
            child: claimed
                ? const Icon(Icons.check_circle, color: Colors.white, size: 18)
                : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canClaim = Storage.canClaimDaily;
    return CafeBackground(
      full: false,
      child: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const ScreenHeader(title: 'DAILY REWARD'),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: CoinPill(coins: Storage.coins),
                ),
                Text(
                  '🔥 Streak: ${Storage.dailyStreak} araw',
                  style: const TextStyle(
                      color: kGold, fontSize: 17, fontWeight: FontWeight.w900),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: LayoutBuilder(
                      builder: (context, box) {
                        final w = (box.maxWidth - 3 * 10) / 4;
                        return Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 12,
                          children: [
                            for (int d = 1; d <= 7; d++) _dayTile(d, w),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                if (_msg != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(_msg!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900)),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: canClaim
                      ? pillButton('🎁  CLAIM REWARD', _claim)
                      : const Text(
                          'Balik bukas para sa susunod na reward!',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                ),
              ],
            ),
          ),
          Positioned.fill(child: ConfettiLayer(key: _confetti)),
        ],
      ),
    );
  }
}
