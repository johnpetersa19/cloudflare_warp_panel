import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'warp_control_screen.dart';

void main() {
  runApp(const MyApp());
  doWhenWindowReady(() {
    final initialSize = const Size(400, 550); // ajuste o tamanho conforme seu painel
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "Cloudflare WARP Panel";
    appWindow.show();
    // appWindow.setEffect(WindowEffect.transparent); // REMOVA OU COMENTE ESTA LINHA!
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Cloudflare WARP Panel',
      debugShowCheckedModeBanner: false,
      home: WarpControlScreen(),
    );
  }
}
