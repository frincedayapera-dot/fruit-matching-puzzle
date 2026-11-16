import 'package:flutter/material.dart';
import '../data/game_data.dart';
import '../services/fruit_assets.dart';
import '../services/storage_service.dart';
import '../widgets/cafe_background.dart';
import '../widgets/cafe_widgets.dart';
import 'daily_screen.dart';
import 'feedback_screen.dart';
import 'game_screen.dart';
import 'high_scores_screen.dart';
import 'levels_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    // Kapag may daily reward na puwedeng kunin, bubukas agad ang Daily screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Storage.canClaimDaily) _open(const DailyScreen());
    });
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  Future<void> _open(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) setState(() {});
  }

  void _howToPlay() {
    showCafeDialog(
      context,
      title: 'Paano Maglaro',
      content: const SingleChildScrollView(
        child: Text(
          '1. Walang preview! Ititiklop at ima-shuffle ang mga cards sa loob ng 3 segundo.\n\n'
          '2. Pumili ng dalawang cards. Kapag magkapareho, may points ka!\n\n'
          '3. 🔥 Combo: magkakasunod na tama = dagdag na points.\n\n'
          '4. ⏱ Bilisan! May time limit ang bawat level. Ang matitirang oras ay dagdag score.\n\n'
          '5. ⭐ Stars: mas kaunti ang moves, mas maraming stars. Tapusin ang level para mabuksan ang susunod.\n\n'
          '6. 🪙 Kumita ng coins at bumili ng Power-ups (Peek, Extra Time, Hint) at card themes sa Shop.\n\n'
          '7. ⭐ Gamitin ang stars para bumili ng profile picture (strawberry, watermelon at iba pa) sa Profile.\n\n'
          '8. 👥 Endless Rush: 2 minuto ang simula. Kada natapos na round, +50 segundo at may coin reward! Hanggang kailan mo kayang tumagal?',
        ),
      ),
      actions: [
        Builder(
          builder: (ctx) =>
              cafeButton('OK!', () => Navigator.pop(ctx), filled: true),
        ),
      ],
    );
  }

  Widget _avatar(double size) {
    if (FruitAssets.mascotAvailable) return MascotAvatar(size: size);
    return FruitAvatar(Storage.avatar, size: size * 1.4);
  }

  // ---------- Parts ----------
  Widget _profilePill() {
    final stars = Storage.totalStars;
    return GestureDetector(
      onTap: () => _open(const ProfileScreen()),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
        decoration: goldDecoration(radius: 40),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: kCream,
                shape: BoxShape.circle,
                border: Border.all(color: kGold, width: 3),
              ),
              alignment: Alignment.center,
              child: _avatar(24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Storage.playerName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900),
                  ),
                  Text(
                    '${rankFor(stars)} • ⭐$stars',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: kGold,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleSign() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          decoration: BoxDecoration(
            color: kCaramelDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kGold, width: 2),
          ),
          child: const Text(
            '★ PUZZLE KIDS WORLD ★',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 13),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: goldDecoration(radius: 32),
          child: FittedBox(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🍎', style: TextStyle(fontSize: 38)),
                const SizedBox(width: 10),
                Text.rich(
                  const TextSpan(children: [
                    TextSpan(text: 'FRUIT', style: TextStyle(color: kGold)),
                    TextSpan(text: 'MATCH', style: TextStyle(color: Colors.white)),
                  ]),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    shadows: [Shadow(color: kBrownDark, offset: Offset(3, 3))],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _mascot() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _bounce,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, -8 * _bounce.value),
            child: child,
          ),
          child: GestureDetector(
            onTap: () => _open(const ProfileScreen()),
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [kBrown, kCaramel],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: kGold, width: 6),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 12)
                ],
              ),
              alignment: Alignment.center,
              child: Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                    color: Color(0xFFFFE9D6), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: _avatar(56),
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              color: kCaramelDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kGold, width: 2),
            ),
            child: Text(
              rankFor(Storage.totalStars).toUpperCase(),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB9763E), kCaramelDark],
        ),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: kGold, width: 3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          RoundIconBtn(
            icon: Icons.card_giftcard_rounded,
            label: 'Daily',
            badge: Storage.canClaimDaily,
            onTap: () => _open(const DailyScreen()),
          ),
          RoundIconBtn(
            icon: Icons.menu_book_rounded,
            label: 'Book',
            onTap: _howToPlay,
          ),
          RoundIconBtn(
            icon: Icons.person_rounded,
            label: 'Profile',
            onTap: () => _open(const ProfileScreen()),
          ),
          RoundIconBtn(
            icon: Icons.settings_rounded,
            label: 'Settings',
            onTap: () => _open(const SettingsScreen()),
          ),
          RoundIconBtn(
            icon: Icons.feedback_rounded,
            label: 'Feedback',
            onTap: () => _open(const FeedbackScreen()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CafeBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _profilePill()),
                  const SizedBox(width: 12),
                  CoinPill(coins: Storage.coins),
                ],
              ),
              const SizedBox(height: 18),
              _titleSign(),
              const SizedBox(height: 16),
              _mascot(),
              MenuTile(
                icon: Icons.favorite_rounded,
                title: 'ENDLESS RUSH',
                subtitle: 'Unlimited Customers Challenge',
                onTap: () => _open(const GameScreen(endless: true)),
              ),
              MenuTile(
                icon: Icons.map_rounded,
                title: 'LEVELS',
                subtitle: 'Campaign Mode (Levels 1 - ${kLevels.length})',
                onTap: () => _open(const LevelsScreen()),
              ),
              MenuTile(
                icon: Icons.storefront_rounded,
                title: 'SHOP',
                subtitle: 'Power-ups & Card Themes',
                onTap: () => _open(const ShopScreen()),
              ),
              MenuTile(
                icon: Icons.bar_chart_rounded,
                title: 'HIGH SCORES',
                subtitle: 'View Records & Stars',
                onTap: () => _open(const HighScoresScreen()),
              ),
              const SizedBox(height: 4),
              _bottomBar(),
            ],
          ),
        ),
      ),
    );
  }
}
