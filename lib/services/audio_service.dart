import 'package:audioplayers/audioplayers.dart';
import '../data/game_data.dart';
import 'storage_service.dart';

/// SFX: click, flip, match, wrong, win, coin, tick, shuffle
/// Music: kMusicTracks (puwedeng palitan sa Settings)
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  static const List<String> _sfxNames = [
    'click', 'flip', 'match', 'wrong', 'win', 'coin', 'tick', 'shuffle',
  ];

  final AudioPlayer _bgm = AudioPlayer();
  final Map<String, AudioPlayer> _sfx = {};
  int? _playingTrack;

  Future<void> init() async {
    try {
      await _bgm.setReleaseMode(ReleaseMode.loop);
      await _bgm.setVolume(Storage.musicVolume);
      for (final name in _sfxNames) {
        final p = AudioPlayer();
        await p.setPlayerMode(PlayerMode.lowLatency);
        await p.setReleaseMode(ReleaseMode.stop);
        await p.setVolume(Storage.sfxVolume);
        _sfx[name] = p;
      }
    } catch (_) {}
  }

  Future<void> play(String name) async {
    if (!Storage.soundOn) return;
    final p = _sfx[name];
    if (p == null) return;
    try {
      await p.stop();
      await p.play(AssetSource('sounds/$name.wav'));
    } catch (_) {}
  }

  // ---------- Music ----------
  bool _playing = false;
  bool _starting = false;

  /// Tinatawag sa bawat tap. Sa web, hinaharang ng browser ang autoplay,
  /// kaya magsisimula ang music sa unang tap ng player.
  Future<void> ensureMusic() async {
    if (_playing || _starting || !Storage.musicOn) return;
    _starting = true;
    try {
      await startMusic();
    } finally {
      _starting = false;
    }
  }

  Future<void> startMusic() async {
    if (!Storage.musicOn) return;
    try {
      final t = Storage.musicTrack;
      await _bgm.setVolume(Storage.musicVolume);
      if (_playingTrack == t) {
        await _bgm.resume();
      } else {
        await _bgm.stop();
        await _bgm.play(AssetSource('sounds/${kMusicTracks[t].file}'));
        _playingTrack = t;
      }
      _playing = true;
    } catch (_) {
      _playing = false;
    }
  }

  Future<void> pauseMusic() async {
    _playing = false;
    try {
      await _bgm.pause();
    } catch (_) {}
  }

  void setMusic(bool on) {
    if (on) {
      startMusic();
    } else {
      pauseMusic();
    }
  }

  /// Tawagin pagkatapos palitan ang Storage.musicTrack
  Future<void> changeTrack() async {
    _playingTrack = null;
    await startMusic();
  }

  void setMusicVolume(double v) {
    try {
      _bgm.setVolume(v);
    } catch (_) {}
  }

  void setSfxVolume(double v) {
    for (final p in _sfx.values) {
      try {
        p.setVolume(v);
      } catch (_) {}
    }
  }
}
