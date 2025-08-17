// main.dart

import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'warp_control_screen.dart';
import 'legal_notice_screen.dart';

// Definir a classe MyApp como StatefulWidget
class MyApp extends StatefulWidget {
  final bool hasSeenLegalNotice;

  const MyApp({super.key, required this.hasSeenLegalNotice});

  // Adicionar um GlobalKey para o Navigator, para que possamos navegar
  // e reconstruir a árvore de widgets quando o idioma mudar.
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // A função para mudar o locale do aplicativo
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }
  
  @override
  void initState() {
    super.initState();
    // Inicializa o locale com o do sistema, ou com 'pt' como padrão.
    _locale = const Locale('pt');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: MyApp.navigatorKey,
      
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,

      home: Builder(
        builder: (context) {
          final localizations = AppLocalizations.of(context);
          final title = localizations?.appTitle ?? 'Cloudflare WARP Panel';
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            appWindow.title = title;
          });
          
          return widget.hasSeenLegalNotice
              ? const WarpControlScreen()
              : const LegalNoticeScreen();
        },
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final hasSeenLegalNotice = prefs.getBool('hasSeenLegalNotice') ?? false;

  runApp(MyApp(hasSeenLegalNotice: hasSeenLegalNotice));

  doWhenWindowReady(() {
    const fixedSize = Size(500, 640);
    appWindow.minSize = fixedSize;
    appWindow.size = fixedSize;
    appWindow.maxSize = fixedSize;
    appWindow.show();
  });
}

