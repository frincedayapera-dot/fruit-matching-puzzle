import 'dart:math';
import 'package:flutter/material.dart';
import '../data/game_data.dart';
import '../services/audio_service.dart';
import '../widgets/cafe_background.dart';
import '../widgets/cafe_widgets.dart';
import 'home_screen.dart';

/// Unang lalabas kapag binuksan ang game (Loading / "Open for business")
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _load;
  late final AnimationController _float;

  // emoji, x (0-1), y (0-1), phase
  static const List<List<Object>> _bubbles = [
    ['🍓', 0.05, 0.20, 0.0],
    ['🍌', 0.78, 0.16, 1.1],
    ['🍊', 0.80, 0.50, 2.2],
    ['🍇', 0.04, 0.52, 3.3],
    ['🍉', 0.58, 0.80, 4.4],
    ['🍍', 0.16, 0.80, 5.5],
  ];

  @override
  void initState() {
    super.initState();
    _float = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
    _load = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3600))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _goHome();
      })
      ..forward();
    AudioService.instance.startMusic();
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _load.dispose();
    _float.dispose();
    super.dispose();
  }

  String _loadingText(double v) {
    if (v < 0.35) return 'Preparing Fresh Fruits & Cards...';
    if (v < 0.7) return 'Shuffling the Cards...';
    return 'Almost Ready...';
  }

  @override
  Widget build(BuildContext context) {
    return CafeBackground(
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth, h = box.maxHeight;
          return Stack(
            children: [
              // Floating fruit bubbles
              AnimatedBuilder(
                animation: _float,
                builder: (_, __) {
                  final t = _float.value * 2 * pi;
                  return Stack(
                    children: [
                      for (final b in _bubbles)
                        Positioned(
                          left: (b[1] as double) * w +
                              14 * sin(t + (b[3] as double)),
                          top: (b[2] as double) * h +
                              18 * cos(t + (b[3] as double)),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0x33FFFFFF),
                              border: Border.all(color: kGold, width: 3),
                            ),
                            alignment: Alignment.center,
                            child: Text(b[0] as String,
                                style: const TextStyle(fontSize: 32)),
                          ),
                        ),
                    ],
                  );
                },
              ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Card na may mascot
                        Container(
                          width: w * 0.72,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: kCream,
                            borderRadius: BorderRadius.circular(36),
                            border: Border.all(color: kCaramel, width: 5),
                            boxShadow: const [
                              BoxShadow(color: Colors.black54, blurRadius: 18),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [kBrown, kCaramel],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(color: kGold, width: 7),
                                ),
                                alignment: Alignment.center,
                                child: Container(
                                  width: 110,
                                  height: 110,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFFFE9D6),
                                      shape: BoxShape.circle),
                                  alignment: Alignment.center,
                                  child: const MascotAvatar(size: 64),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: kGold,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const FittedBox(
                                  child: Text(
                                    "✨ LET'S PLAY ✨",
                                    style: TextStyle(
                                      color: kBrownDark,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 3,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),
                        const Text(
                          'FRUIT MATCH',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            shadows: [Shadow(color: kGold, blurRadius: 18)],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Matching your sweet fruit adventure...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: kGold,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        AnimatedBuilder(
                          animation: _load,
                          builder: (_, __) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: _load.value,
                                    minHeight: 14,
                                    color: kGold,
                                    backgroundColor: const Color(0x33FFFFFF),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  _loadingText(_load.value),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
