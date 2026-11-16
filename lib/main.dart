import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/game_data.dart';
import 'screens/splash_screen.dart';
import 'services/audio_service.dart';
import 'services/fruit_assets.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Storage.init();
  await FruitAssets.init();
  await AudioService.instance.init();
  runApp(const FruitMatchingApp());
}

class FruitMatchingApp extends StatefulWidget {
  const FruitMatchingApp({super.key});

  @override
  State<FruitMatchingApp> createState() => _FruitMatchingAppState();
}

class _FruitMatchingAppState extends State<FruitMatchingApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      AudioService.instance.pauseMusic();
    } else if (state == AppLifecycleState.resumed) {
      AudioService.instance.startMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruit Matching Puzzle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kCaramel,
          brightness: Brightness.dark,
        ),
      ),
      // Web: nakasentro ang laro (max 480px). Music: magsisimula sa unang tap kung hinarang ng browser.
      builder: (context, child) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => AudioService.instance.ensureMusic(),
        child: Container(
          color: const Color(0xFF120A06),
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: child,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
