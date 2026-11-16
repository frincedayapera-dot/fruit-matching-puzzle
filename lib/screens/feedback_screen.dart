import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../data/game_data.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../widgets/cafe_background.dart';
import '../widgets/cafe_widgets.dart';

/// Feedback / Suggestion / Bug report -> bubukas ang email app
/// na naka-address sa developer account (kFeedbackEmail).
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  static const List<List<String>> _types = [
    ['💬', 'Feedback'],
    ['💡', 'Suggestion'],
  ];

  int _type = 0;
  bool _sending = false;
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _copyEmail() async {
    await Clipboard.setData(const ClipboardData(text: kFeedbackEmail));
    _toast('Na-copy ang email: $kFeedbackEmail');
  }

  /// Direktang padala sa email ng developer (walang email app na kailangan)
  Future<bool> _sendDirect(String subject, String message) async {
    try {
      final res = await http
          .post(
            Uri.parse(kFeedbackEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'name': Storage.playerName,
              'message': message,
              '_subject': subject,
              '_captcha': 'false',
              '_template': 'table',
            }),
          )
          .timeout(const Duration(seconds: 20));
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body);
        return j is Map && (j['success'] == true || j['success'] == 'true');
      }
    } catch (_) {}
    return false;
  }

  Future<void> _send() async {
    if (_sending) return;
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      AudioService.instance.play('wrong');
      _toast('Isulat muna ang mensahe mo.');
      return;
    }
    final subject = '[Fruit Match] ${_types[_type][1]}';
    final body = '$text\n\n---\n'
        'Player: ${Storage.playerName}\n'
        'App: Fruit Matching Puzzle v$kAppVersion';

    // 1) Direktang padala sa Gmail (FormSubmit)
    setState(() => _sending = true);
    final sent = await _sendDirect(subject, body);
    if (!mounted) return;
    setState(() => _sending = false);
    if (sent) {
      _ctrl.clear();
      AudioService.instance.play('win');
      _toast('✅ Naipadala na! Salamat sa feedback mo.');
      return;
    }

    // 2) Backup: buksan ang email app
    final uri = Uri.parse(
      'mailto:$kFeedbackEmail'
      '?subject=${Uri.encodeComponent(subject)}'
      '&body=${Uri.encodeComponent(body)}',
    );
    bool ok = false;
    try {
      ok = await launchUrl(uri);
    } catch (_) {
      ok = false;
    }
    if (!mounted) return;
    if (ok) {
      _toast('Pindutin ang SEND sa email app para maipadala.');
    } else {
      await Clipboard.setData(const ClipboardData(text: kFeedbackEmail));
      if (!mounted) return;
      _toast('Hindi naipadala. Na-copy ang email: $kFeedbackEmail');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CafeBackground(
      full: false,
      child: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'FEEDBACK'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Ipadala ang feedback o suggestion mo sa developer account namin:',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: goldDecoration(radius: 20),
                    child: Row(
                      children: [
                        const Icon(Icons.email_rounded, color: kGold),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            kFeedbackEmail,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 15),
                          ),
                        ),
                        pillButton('Copy', _copyEmail),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (int i = 0; i < _types.length; i++)
                        GestureDetector(
                          onTap: () => setState(() => _type = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: _type == i
                                  ? kGold
                                  : const Color(0xFF6E5646),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Text(
                              '${_types[i][0]} ${_types[i][1]}',
                              style: TextStyle(
                                color: _type == i ? kBrownDark : Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _ctrl,
                    maxLines: 6,
                    maxLength: 500,
                    style: const TextStyle(color: kBrownDark, fontSize: 16),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: kCream,
                      hintText: 'Isulat dito ang mensahe mo...',
                      hintStyle: const TextStyle(color: Colors.black45),
                      counterStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: kGold, width: 3),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: kGold, width: 3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: _sending
                        ? const CircularProgressIndicator(color: kGold)
                        : pillButton('📨  SEND', _send),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Direktang ipapadala ang mensahe mo sa developer. Kailangan ng internet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
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
