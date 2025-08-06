// main.dart
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importe shared_preferences
import 'warp_control_screen.dart';
import 'legal_notice_screen.dart'; // Importe a tela de aviso legal

void main() async { // Torne o main assíncrono

  WidgetsFlutterBinding.ensureInitialized();


  final prefs = await SharedPreferences.getInstance();
  final hasSeenLegalNotice = prefs.getBool('hasSeenLegalNotice') ?? false;

  runApp(MyApp(hasSeenLegalNotice: hasSeenLegalNotice));

  doWhenWindowReady(() {
    const fixedSize = Size(500, 640);
    appWindow.minSize = fixedSize;
    appWindow.size = fixedSize;
    appWindow.maxSize = fixedSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "Cloudflare WARP Panel";
    appWindow.show();

  });
}

class MyApp extends StatelessWidget {
  final bool hasSeenLegalNotice;

  const MyApp({super.key, required this.hasSeenLegalNotice});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloudflare WARP Panel',
      debugShowCheckedModeBanner: false,

      home: hasSeenLegalNotice ? const WarpControlScreen() : const LegalNoticeScreen(),
    );
  }
}
