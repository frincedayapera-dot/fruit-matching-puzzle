import 'package:flutter/material.dart';
import '../data/game_data.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../widgets/cafe_background.dart';
import '../widgets/cafe_widgets.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  void _buyPower(PowerUp p) {
    if (Storage.spendCoins(p.price)) {
      Storage.addPowerUp(p.id);
      AudioService.instance.play('coin');
    } else {
      AudioService.instance.play('wrong');
      _toast('Kulang ang coins mo! Maglaro pa para kumita.');
    }
    setState(() {});
  }

  void _themeTap(int i) {
    final t = kBackThemes[i];
    if (Storage.ownsTheme(i)) {
      Storage.selectTheme(i);
    } else if (Storage.spendCoins(t.price)) {
      Storage.unlockTheme(i);
      Storage.selectTheme(i);
      AudioService.instance.play('coin');
    } else {
      AudioService.instance.play('wrong');
      _toast('Kulang ang coins mo! Maglaro pa para kumita.');
    }
    setState(() {});
  }

  Widget _section(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
        child: Text(
          text,
          style: const TextStyle(
              color: kGold,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 2),
        ),
      );

  Widget _powerTile(PowerUp p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: goldDecoration(radius: 24),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration:
                const BoxDecoration(color: kBrown, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(p.emoji, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                Text(p.desc,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                Text('Owned: ${Storage.powerUps(p.id)}',
                    style: const TextStyle(
                        color: kGold, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          pillButton('🪙 ${p.price}', () => _buyPower(p)),
        ],
      ),
    );
  }

  Widget _themeTile(int i) {
    final t = kBackThemes[i];
    final owned = Storage.ownsTheme(i);
    final equipped = Storage.selectedTheme == i;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: goldDecoration(radius: 24),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [t.c1, t.c2],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kGold, width: 2),
            ),
            child: const Icon(Icons.question_mark_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(t.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900)),
          ),
          if (equipped)
            const Text('✔ Equipped',
                style: TextStyle(
                    color: kGold, fontSize: 15, fontWeight: FontWeight.w900))
          else if (owned)
            pillButton('Equip', () => _themeTap(i))
          else
            pillButton('🪙 ${t.price}', () => _themeTap(i)),
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
            const ScreenHeader(title: 'SHOP'),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: CoinPill(coins: Storage.coins),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  _section('POWER-UPS'),
                  for (final p in kPowerUps) _powerTile(p),
                  const SizedBox(height: 8),
                  _section('CARD THEMES'),
                  for (int i = 0; i < kBackThemes.length; i++) _themeTile(i),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
