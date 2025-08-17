// legal_notice_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'warp_control_screen.dart';
import 'l10n/app_localizations.dart';

class LegalNoticeScreen extends StatelessWidget {
  const LegalNoticeScreen({super.key});

  Future<void> _saveConfirmationAndNavigate(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    print(localizations.savingConfirmation);
    try {
      final appSupportDir = await getApplicationSupportDirectory();
      print(localizations.appSupportDirFound(appSupportDir.path));

      final prefsDir = Directory('${appSupportDir.path}/cloudflare_warp_panel');
      print(localizations.checkingPrefsDir(prefsDir.path));

      if (!await prefsDir.exists()) {
        print(localizations.dirDoesNotExist);
        await prefsDir.create(recursive: true);
        print(localizations.prefsDirCreated);
      } else {
        print(localizations.prefsDirExists);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenLegalNotice', true);
      print(localizations.hasSeenLegalNoticeSaved);
      
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const WarpControlScreen()),
        );
        print(localizations.navigationInitiated);
      }
    } catch (e) {
      print(localizations.fatalErrorSavePref(e.toString()));
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const WarpControlScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          localizations.legalNoticeConfirmation,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFF65B54),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.importantInfoPanel,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                children: [
                  TextSpan(
                    text: localizations.appDescription1.split('graphical control panel (GUI)')[0],
                  ),
                  TextSpan(
                    text: 'graphical control panel (GUI)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: localizations.appDescription1.split('graphical control panel (GUI)')[1].split('official Cloudflare WARP program')[0],
                  ),
                  TextSpan(
                    text: 'official Cloudflare WARP program',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: localizations.appDescription1.split('official Cloudflare WARP program')[1].split('NOT the official Cloudflare application')[0],
                  ),
                  TextSpan(
                    text: 'NOT the official Cloudflare application',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: localizations.appDescription1.split('NOT the official Cloudflare application')[1],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                children: [
                  TextSpan(
                    text: localizations.appDescription2.split('ESSENTIAL')[0],
                  ),
                  TextSpan(
                    text: 'ESSENTIAL',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: localizations.appDescription2.split('ESSENTIAL')[1].split('official Cloudflare WARP for Linux installed')[0],
                  ),
                  TextSpan(
                    text: 'official Cloudflare WARP for Linux installed',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: localizations.appDescription2.split('official Cloudflare WARP for Linux installed')[1].split('DOES NOT collect ANY user data')[0],
                  ),
                  TextSpan(
                    text: 'DOES NOT collect ANY user data',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: localizations.appDescription2.split('DOES NOT collect ANY user data')[1].split('entirely with Cloudflare')[0],
                  ),
                  TextSpan(
                    text: 'entirely with Cloudflare',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: localizations.appDescription2.split('entirely with Cloudflare')[1],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                children: [
                  TextSpan(
                    text: localizations.confirmationText,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () => _saveConfirmationAndNavigate(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF65B54),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  localizations.iUnderstand,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

