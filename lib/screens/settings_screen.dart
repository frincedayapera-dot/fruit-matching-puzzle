import 'package:flutter/material.dart';
import '../data/game_data.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../widgets/cafe_background.dart';
import '../widgets/cafe_widgets.dart';
import 'feedback_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Widget _section(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
        child: Text(
          text,
          style: const TextStyle(
              color: kGold,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 2),
        ),
      );

  Widget _switchTile(
      IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: goldDecoration(radius: 24),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration:
                const BoxDecoration(color: kBrown, shape: BoxShape.circle),
            child: Icon(icon, color: kGold, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: kGold,
          ),
        ],
      ),
    );
  }

  Widget _sliderTile(String title, double value, ValueChanged<double> onChanged,
      {VoidCallback? onEnd}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      decoration: goldDecoration(radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title  ${(value * 100).round()}%',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900)),
          Slider(
            value: value,
            onChanged: onChanged,
            onChangeEnd: onEnd == null ? null : (_) => onEnd(),
            activeColor: kGold,
            inactiveColor: const Color(0x55FFFFFF),
          ),
        ],
      ),
    );
  }

  Widget _trackTile(int i) {
    final selected = Storage.musicTrack == i;
    return GestureDetector(
      onTap: () {
        Storage.setMusicTrack(i);
        Storage.setMusic(true);
        AudioService.instance.changeTrack();
        setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: goldDecoration(radius: 24, dim: !selected),
        child: Row(
          children: [
            Icon(selected ? Icons.graphic_eq_rounded : Icons.music_note_rounded,
                color: selected ? kGold : Colors.white70, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Text(kMusicTracks[i].name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900)),
            ),
            if (selected)
              const Text('✔ Playing',
                  style: TextStyle(
                      color: kGold, fontWeight: FontWeight.w900, fontSize: 14)),
          ],
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
            const ScreenHeader(title: 'SETTINGS'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  _section('BACKGROUND MUSIC'),
                  _switchTile(Icons.music_note_rounded, 'Play Music',
                      Storage.musicOn, (v) {
                    Storage.setMusic(v);
                    AudioService.instance.setMusic(v);
                    setState(() {});
                  }),
                  _sliderTile('Music Volume', Storage.musicVolume, (v) {
                    Storage.setMusicVolume(v);
                    AudioService.instance.setMusicVolume(v);
                    setState(() {});
                  }),
                  for (int i = 0; i < kMusicTracks.length; i++) _trackTile(i),
                  _section('SOUND EFFECTS'),
                  _switchTile(Icons.volume_up_rounded, 'Sound Effects',
                      Storage.soundOn, (v) {
                    Storage.setSound(v);
                    if (v) AudioService.instance.play('click');
                    setState(() {});
                  }),
                  _sliderTile('Effects Volume', Storage.sfxVolume, (v) {
                    Storage.setSfxVolume(v);
                    AudioService.instance.setSfxVolume(v);
                    setState(() {});
                  }, onEnd: () => AudioService.instance.play('click')),
                  _section('HELP'),
                  MenuTile(
                    icon: Icons.feedback_rounded,
                    title: 'FEEDBACK',
                    subtitle: 'Send suggestions to the developer',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const FeedbackScreen()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Fruit Matching Puzzle v$kAppVersion\nPuzzle Kids World • Frinova',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
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
