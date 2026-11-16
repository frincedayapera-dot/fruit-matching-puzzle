import 'package:flutter/material.dart';
import '../data/game_data.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../widgets/cafe_background.dart';
import '../widgets/cafe_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _name =
      TextEditingController(text: Storage.playerName);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  void _saveName() {
    final n = _name.text.trim();
    if (n.isEmpty) return;
    Storage.setPlayerName(n);
    FocusScope.of(context).unfocus();
    _toast('Na-save ang pangalan!');
    setState(() {});
  }

  void _avatarTap(AvatarDef a) {
    if (Storage.ownsAvatar(a.key)) {
      Storage.setAvatar(a.key);
      AudioService.instance.play('click');
    } else if (Storage.buyAvatar(a)) {
      Storage.setAvatar(a.key);
      AudioService.instance.play('coin');
      _toast('Nabili mo ang ${fruitName(a.key)}! 🎉');
    } else {
      AudioService.instance.play('wrong');
      _toast('Kulang ang stars mo. Tapusin pa ang mga level para kumita!');
    }
    setState(() {});
  }

  Widget _avatarTile(AvatarDef a) {
    final owned = Storage.ownsAvatar(a.key);
    final selected = Storage.avatar == a.key;
    return GestureDetector(
      onTap: () => _avatarTap(a),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: owned
                ? const [kCaramel, kCaramelDark]
                : const [Color(0xFF6E5646), Color(0xFF4A382C)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? Colors.white : (owned ? kGold : Colors.grey),
              width: selected ? 4 : 3),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FruitAvatar(a.key, size: 52),
              Text(fruitName(a.key),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900)),
              Text(
                selected
                    ? '✔ Using'
                    : owned
                        ? 'Use'
                        : '⭐ ${a.price}',
                style: TextStyle(
                    color: owned ? kGold : Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
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
            const ScreenHeader(title: 'PROFILE'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Center(
                    child: Container(
                      width: 124,
                      height: 124,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [kBrown, kCaramel],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: kGold, width: 6),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 92,
                        height: 92,
                        decoration: const BoxDecoration(
                            color: Color(0xFFFFE9D6), shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: FruitAvatar(Storage.avatar, size: 64),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _name,
                          maxLength: 14,
                          onSubmitted: (_) => _saveName(),
                          style: const TextStyle(
                              color: kBrownDark, fontWeight: FontWeight.w900),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: kCream,
                            counterText: '',
                            hintText: 'Pangalan ng player',
                            hintStyle: const TextStyle(color: Colors.black45),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide:
                                  const BorderSide(color: kGold, width: 3),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide:
                                  const BorderSide(color: kGold, width: 3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      pillButton('Save', _saveName),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: goldDecoration(radius: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded, color: kGold, size: 30),
                        const SizedBox(width: 8),
                        Text(
                          '${Storage.availableStars} stars available  (${Storage.totalStars} earned)',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(4, 18, 4, 10),
                    child: Text('PROFILE PICTURES',
                        style: TextStyle(
                            color: kGold,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2)),
                  ),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                    children: [for (final a in kAvatars) _avatarTile(a)],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
