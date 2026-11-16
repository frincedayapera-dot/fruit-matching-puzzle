import 'package:flutter/material.dart';
import '../data/game_data.dart';
import '../services/audio_service.dart';
import '../services/fruit_assets.dart';

BoxDecoration goldDecoration({double radius = 28, bool dim = false}) {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: dim
          ? const [Color(0xFF6E5646), Color(0xFF4A382C)]
          : const [kCaramel, kCaramelDark],
    ),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: dim ? const Color(0xFF8A7058) : kGold, width: 3),
    boxShadow: const [
      BoxShadow(color: Colors.black54, offset: Offset(0, 6), blurRadius: 6),
    ],
  );
}

/// Malaking menu button
class MenuTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<MenuTile> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: () {
        AudioService.instance.play('click');
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: goldDecoration(),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration:
                    const BoxDecoration(color: kBrown, shape: BoxShape.circle),
                child: Icon(widget.icon, color: kGold, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                    color: Color(0x33FFFFFF), shape: BoxShape.circle),
                child: const Icon(Icons.chevron_right, color: kGold, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bilog na icon button na may label (may optional na pulang badge)
class RoundIconBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final bool badge;
  const RoundIconBtn({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = true,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AudioService.instance.play('click');
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: active
                        ? const [kCaramel, kCaramelDark]
                        : const [Color(0xFF6E5646), Color(0xFF4A382C)],
                  ),
                  border:
                      Border.all(color: active ? kGold : Colors.grey, width: 3),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              if (badge)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// Header ng bawat screen
class ScreenHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const ScreenHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: goldDecoration(radius: 40),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 28),
              onPressed: () {
                AudioService.instance.play('click');
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
            trailing ?? const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}

Widget starsRow(int stars, {double size = 26}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(
      3,
      (i) => Icon(i < stars ? Icons.star_rounded : Icons.star_border_rounded,
          color: kGold, size: size),
    ),
  );
}

/// Coins display (tulad ng ₱ sa PURCAFÉ)
class CoinPill extends StatelessWidget {
  final int coins;
  const CoinPill({super.key, required this.coins});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: goldDecoration(radius: 40),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on_rounded, color: kGold, size: 28),
          const SizedBox(width: 6),
          Text(
            '$coins',
            style: const TextStyle(
                color: kGold, fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

/// Maliit na gold na button (Buy / Equip / Claim)
Widget pillButton(String text, VoidCallback onTap, {bool enabled = true}) {
  return GestureDetector(
    onTap: enabled
        ? () {
            AudioService.instance.play('click');
            onTap();
          }
        : null,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: enabled ? kGold : const Color(0xFF8A7058),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black38, offset: Offset(0, 3))],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: enabled ? kBrownDark : Colors.white70,
          fontWeight: FontWeight.w900,
          fontSize: 15,
        ),
      ),
    ),
  );
}

/// Mukha ng card: sarili mong PNG kung meron, emoji kung wala
class FruitFace extends StatelessWidget {
  final String fruitKey;
  final double size;
  const FruitFace(this.fruitKey, {super.key, this.size = 60});

  @override
  Widget build(BuildContext context) {
    if (FruitAssets.has(fruitKey)) {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Image.asset(
          'assets/images/fruits/$fruitKey.png',
          fit: BoxFit.contain,
        ),
      );
    }
    return FittedBox(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(emojiFor(fruitKey), style: TextStyle(fontSize: size)),
      ),
    );
  }
}

/// Mascot: assets/images/mascot.png kung meron, strawberry emoji kung wala
class MascotAvatar extends StatelessWidget {
  final double size;
  const MascotAvatar({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    if (FruitAssets.mascotAvailable) {
      return ClipOval(
        child: Image.asset(
          'assets/images/mascot.png',
          width: size * 1.6,
          height: size * 1.6,
          fit: BoxFit.cover,
        ),
      );
    }
    return Text('🍓', style: TextStyle(fontSize: size));
  }
}

Future<T?> showCafeDialog<T>(
  BuildContext context, {
  required String title,
  required Widget content,
  List<Widget> actions = const [],
  bool dismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    builder: (_) => AlertDialog(
      backgroundColor: kCream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: kGold, width: 4),
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: kBrownDark, fontWeight: FontWeight.w900, fontSize: 24),
      ),
      content: DefaultTextStyle(
        style: const TextStyle(color: kBrownDark, fontSize: 16),
        child: content,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: actions,
    ),
  );
}

Widget cafeButton(String text, VoidCallback onPressed, {bool filled = false}) {
  final child = Text(text, style: const TextStyle(fontWeight: FontWeight.bold));
  return filled
      ? FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: kCaramelDark, foregroundColor: Colors.white),
          onPressed: onPressed,
          child: child)
      : TextButton(
          style: TextButton.styleFrom(foregroundColor: kCaramelDark),
          onPressed: onPressed,
          child: child);
}

/// Profile picture na prutas (PNG kung meron, emoji kung wala)
class FruitAvatar extends StatelessWidget {
  final String fruitKey;
  final double size;
  const FruitAvatar(this.fruitKey, {super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    if (FruitAssets.has(fruitKey)) {
      return SizedBox(
        width: size,
        height: size,
        child: Image.asset('assets/images/fruits/$fruitKey.png',
            fit: BoxFit.contain),
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(emojiFor(fruitKey), style: TextStyle(fontSize: size * 0.8)),
      ),
    );
  }
}
