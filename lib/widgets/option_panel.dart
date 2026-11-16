import 'package:flutter/material.dart';
import '../services/audio_service.dart';

const Color _kWoodDark = Color(0xFF5D3A12);
const Color _kInk = Color(0xFF4E2E14);
const Color _kGoldLight = Color(0xFFFFE082);
const Color _kGoldMid = Color(0xFFFFB300);

/// Pindutan sa panel (gintong button)
class OptionBtn {
  final String label;
  final VoidCallback onTap;
  const OptionBtn(this.label, this.onTap);
}

/// Pormal na game panel: kahoy na panel, gintong frame, gintong title plate,
/// gintong buttons at bilog na X sa ilalim. Kusang sasara ang panel bago tawagin ang onTap.
/// onClose = aksyon ng X button (kapag null, walang X).
Future<T?> showOptionPanel<T>(
  BuildContext context, {
  required String title,
  Widget? content,
  required List<OptionBtn> buttons,
  List<Widget> iconRow = const [],
  VoidCallback? onClose,
  bool dismissible = false,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: 'option',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (ctx, _, __) => PopScope(
      canPop: dismissible,
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: _OptionPanel(
                title: title,
                content: content,
                buttons: buttons,
                iconRow: iconRow,
                onClose: onClose,
              ),
            ),
          ),
        ),
      ),
    ),
    transitionBuilder: (ctx, anim, _, child) => FadeTransition(
      opacity: anim,
      child: ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: child,
      ),
    ),
  );
}

/// Cream na kahon sa loob ng panel (para sa score, stars, atbp.)
Widget optionInset(Widget child) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF3D6),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFF8A5A10), width: 3),
    ),
    child: DefaultTextStyle(
      style: const TextStyle(
          color: _kInk, fontSize: 16, fontWeight: FontWeight.w700),
      textAlign: TextAlign.center,
      child: child,
    ),
  );
}

class _OptionPanel extends StatelessWidget {
  final String title;
  final Widget? content;
  final List<OptionBtn> buttons;
  final List<Widget> iconRow;
  final VoidCallback? onClose;
  const _OptionPanel({
    required this.title,
    required this.content,
    required this.buttons,
    required this.iconRow,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: EdgeInsets.only(top: 26, bottom: onClose != null ? 28 : 0),
              child: _WoodFrame(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (content != null) ...[
                      content!,
                      const SizedBox(height: 16),
                    ],
                    for (final b in buttons)
                      _GoldButton(
                        label: b.label,
                        onTap: () {
                          Navigator.pop(context);
                          b.onTap();
                        },
                      ),
                    if (iconRow.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2, bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int i = 0; i < iconRow.length; i++) ...[
                              if (i > 0) const SizedBox(width: 22),
                              iconRow[i],
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            _TitlePlate(title),
            if (onClose != null)
              Positioned(
                bottom: 0,
                child: _CloseBtn(
                  onTap: () {
                    Navigator.pop(context);
                    onClose!();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Gintong frame + kahoy sa loob
class _WoodFrame extends StatelessWidget {
  final Widget child;
  const _WoodFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kGoldLight, Color(0xFFF9A825), Color(0xFFFFD54F)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _kWoodDark, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: CustomPaint(
          painter: _WoodPainter(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 48, 18, 22),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _WoodPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF8A5A33));
    const plank = 44.0;
    int i = 0;
    for (double y = 0; y < size.height; y += plank, i++) {
      if (i.isOdd) {
        canvas.drawRect(Rect.fromLTWH(0, y, size.width, plank),
            Paint()..color = const Color(0x1A000000));
      }
      canvas.drawLine(Offset(0, y), Offset(size.width, y),
          Paint()
            ..color = const Color(0x55000000)
            ..strokeWidth = 2);
    }
    final grain = Paint()
      ..color = const Color(0x22000000)
      ..strokeWidth = 1.5;
    for (double y = 12; y < size.height; y += 22) {
      canvas.drawLine(Offset(size.width * 0.1 + (y % 40), y),
          Offset(size.width * 0.55 + (y % 60), y), grain);
    }
    final gold = Paint()..color = const Color(0xFFFFC107);
    final rim = Paint()
      ..color = _kWoodDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final o in [
      const Offset(12, 12),
      Offset(size.width - 12, 12),
      Offset(12, size.height - 12),
      Offset(size.width - 12, size.height - 12),
    ]) {
      canvas.drawCircle(o, 5, gold);
      canvas.drawCircle(o, 5, rim);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TitlePlate extends StatelessWidget {
  final String title;
  const _TitlePlate(this.title);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 290, minWidth: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_kGoldLight, _kGoldMid],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kWoodDark, width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black45, offset: Offset(0, 4)),
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            style: const TextStyle(
              color: _kInk,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              shadows: [Shadow(color: Color(0x88FFFFFF), offset: Offset(0, 1.5))],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GoldButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          AudioService.instance.play('click');
          onTap();
        },
        child: Container(
          height: 54,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_kGoldLight, _kGoldMid],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF8A5A10), width: 3),
            boxShadow: const [
              BoxShadow(color: Colors.black38, offset: Offset(0, 3)),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: _kInk,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _CloseBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AudioService.instance.play('click');
        onTap();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_kGoldLight, _kGoldMid],
          ),
          border: Border.all(color: _kWoodDark, width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black45, offset: Offset(0, 4)),
          ],
        ),
        child: const Icon(Icons.close_rounded, color: _kInk, size: 32),
      ),
    );
  }
}

/// Bilog na gintong on/off button (sound, music)
class OptionToggle extends StatefulWidget {
  final IconData on;
  final IconData off;
  final bool value;
  final ValueChanged<bool> onChanged;
  const OptionToggle({
    super.key,
    required this.on,
    required this.off,
    required this.value,
    required this.onChanged,
  });

  @override
  State<OptionToggle> createState() => _OptionToggleState();
}

class _OptionToggleState extends State<OptionToggle> {
  late bool _v = widget.value;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _v = !_v);
        widget.onChanged(_v);
        if (_v) AudioService.instance.play('click');
      },
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_kGoldLight, _kGoldMid],
          ),
          border: Border.all(color: const Color(0xFF8A5A10), width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black38, offset: Offset(0, 3)),
          ],
        ),
        child: Icon(_v ? widget.on : widget.off, color: _kInk, size: 28),
      ),
    );
  }
}
