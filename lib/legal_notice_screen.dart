// legal_notice_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart'; // Import this package
import 'dart:io';
import 'warp_control_screen.dart';

class LegalNoticeScreen extends StatelessWidget {
  const LegalNoticeScreen({super.key});

  Future<void> _saveConfirmationAndNavigate(BuildContext context) async {
    print('Starting the process of saving confirmation...');
    try {
      final appSupportDir = await getApplicationSupportDirectory();
      print('Application support directory found: ${appSupportDir.path}');

      final prefsDir = Directory('${appSupportDir.path}/cloudflare_warp_panel');
      print('Attempting to check if the preferences directory exists: ${prefsDir.path}');

      if (!await prefsDir.exists()) {
        print('Directory does not exist. Attempting to create...');
        await prefsDir.create(recursive: true);
        print('Preferences directory created successfully.');
      } else {
        print('Preferences directory already exists.');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenLegalNotice', true);
      print('The hasSeenLegalNotice preference has been saved successfully.');
      
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const WarpControlScreen()),
        );
        print('Navigation to the main screen initiated.');
      }
    } catch (e) {
      print('FATAL ERROR: Failed to save preference or create directory. Details: $e');
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const WarpControlScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Legal Notice and Confirmation'),
        backgroundColor: const Color(0xFFF65B54),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Important Information About the Panel',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This app is a **graphical control panel (GUI)** developed by a user to make it easier to interact with the **official Cloudflare WARP program** on Linux. It is **NOT the official Cloudflare application**.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'For this panel to work properly, it is **ESSENTIAL** that you have the **official Cloudflare WARP for Linux installed** on your system. This project **DOES NOT collect ANY user data**. Responsibility for the operation, privacy, and security of your internet traffic lies **entirely with Cloudflare**, as this panel only sends commands to the already installed official WARP program.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'By clicking "I understand", you confirm that you have read, understood, and accepted the above terms. Your confirmation will be saved locally on your device, and this notice will not be shown again on future launches of the panel.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
                ),
                child: const Text(
                  'I understand',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
