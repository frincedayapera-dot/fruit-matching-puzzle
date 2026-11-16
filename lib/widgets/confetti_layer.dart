import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class _Particle {
  double x, y, vx, vy, rot, vr, size, life;
  final Color color;
  final bool round;
  _Particle(this.x, this.y, this.vx, this.vy, this.rot, this.vr, this.size,
      this.life, this.color, this.round);
}

/// Ilagay sa ibabaw ng Stack, tapos tawagin:
///   key.currentState?.burst(origin: Offset(0.5, 0.5), count: 60);
class ConfettiLayer extends StatefulWidget {
  const ConfettiLayer({super.key});

  @override
  State<ConfettiLayer> createState() => ConfettiLayerState();
}

class ConfettiLayerState extends State<ConfettiLayer>
    with SingleTickerProviderStateMixin {
  static const List<Color> _colors = [
    Color(0xFFFFC62B),
    Color(0xFFFF5A5F),
    Color(0xFF4CAF50),
    Color(0xFF42A5F5),
    Color(0xFFFF8AD8),
    Color(0xFFFF9800),
  ];

  final Random _rnd = Random();
  final List<_Particle> _ps = [];
  late final Ticker _ticker = createTicker(_onTick);
  Duration _last = Duration.zero;

  /// origin = posisyon (0-1) ng screen; spread = lawak ng sabog
  void burst({
    Offset origin = const Offset(0.5, 0.6),
    int count = 60,
    double power = 1.0,
    double spread = 1.0,
  }) {
    final box = context.size;
    if (box == null) return;
    for (int i = 0; i < count; i++) {
      final angle = -pi / 2 + (_rnd.nextDouble() - 0.5) * pi * spread;
      final speed = (250 + _rnd.nextDouble() * 500) * power;
      _ps.add(_Particle(
        origin.dx * box.width,
        origin.dy * box.height,
        cos(angle) * speed,
        sin(angle) * speed,
        _rnd.nextDouble() * pi * 2,
        (_rnd.nextDouble() - 0.5) * 12,
        6 + _rnd.nextDouble() * 8,
        2.0 + _rnd.nextDouble() * 0.8,
        _colors[_rnd.nextInt(_colors.length)],
        _rnd.nextBool(),
      ));
    }
    if (!_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1000000.0;
    _last = elapsed;
    for (final p in _ps) {
      p.vy += 900 * dt;
      p.vx *= (1 - 0.8 * dt);
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.rot += p.vr * dt;
      p.life -= dt;
    }
    _ps.removeWhere((p) => p.life <= 0);
    if (_ps.isEmpty) _ticker.stop();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ConfettiPainter(_ps),
        size: Size.infinite,
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> ps;
  _ConfettiPainter(this.ps);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in ps) {
      final alpha = (p.life / 0.5).clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withAlpha((alpha * 255).round());
      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rot);
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.size * 0.5, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => true;
}
