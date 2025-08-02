import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'warp_control_screen.dart';

void main() {
  runApp(const MyApp());
  doWhenWindowReady(() {
    const fixedSize = Size(400, 540);
    appWindow.minSize = fixedSize;
    appWindow.size = fixedSize;
    appWindow.maxSize = fixedSize;
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
