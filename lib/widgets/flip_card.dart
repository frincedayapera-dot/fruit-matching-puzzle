import 'dart:math';
import 'package:flutter/material.dart';
import '../data/game_data.dart';
import '../services/storage_service.dart';
import 'cafe_widgets.dart';

class FlipCard extends StatelessWidget {
  final CardModel card;
  const FlipCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final showFront = card.faceUp || card.matched;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: showFront ? 1 : 0),
      duration: const Duration(milliseconds: 350),
      builder: (context, value, _) {
        final angle = value * pi;
        final isFront = value > 0.5;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: isFront
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: _front(),
                )
              : _back(),
        );
      },
    );
  }

  Widget _front() {
    return Container(
      decoration: BoxDecoration(
        color: card.matched ? const Color(0xFFE3F4C0) : kCream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kGold, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black54, offset: Offset(0, 4))],
      ),
      child: Center(child: FruitFace(card.fruit)),
    );
  }

  Widget _back() {
    final th = kBackThemes[Storage.selectedTheme];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [th.c1, th.c2],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kGold, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black54, offset: Offset(0, 4))],
      ),
      child: const Center(
        child: Icon(Icons.question_mark_rounded, color: Colors.white, size: 40),
      ),
    );
  }
}
