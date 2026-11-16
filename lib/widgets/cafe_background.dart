import 'package:flutter/material.dart';

/// Background ng buong app: assets/images/bg_cafe.jpg
/// full = true  -> mas malinaw ang larawan (Splash, Home)
/// full = false -> mas madilim para mabasa ang laro/menus (Levels, Game, Shop...)
/// Palitan lang ang bg_cafe.jpg para magpalit ng background.
class CafeBackground extends StatelessWidget {
  final Widget child;
  final bool full;
  const CafeBackground({super.key, required this.child, this.full = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A1810),
      body: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/bg_cafe.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: const Color(0xFF2A1810)),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: full
                          ? const [
                              Color(0x00000000),
                              Color(0x33000000),
                              Color(0x99000000),
                            ]
                          : const [
                              Color(0x66000000),
                              Color(0x80000000),
                              Color(0xA6000000),
                            ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}
