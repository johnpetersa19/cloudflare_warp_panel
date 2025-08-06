// legal_notice_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'warp_control_screen.dart';

class LegalNoticeScreen extends StatelessWidget {
  const LegalNoticeScreen({super.key});


  Future<void> _saveConfirmationAndNavigate(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenLegalNotice', true);
    

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WarpControlScreen()),
      );
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
              'Important Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This application is a graphical control panel (GUI) and not the official Cloudflare WARP program. It was created by a user to facilitate the manipulation of the `warp-cli` program on Linux. For this panel to work, you MUST have the official Cloudflare WARP for Linux installed on your system.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'This project DOES NOT collect data. The responsibility for the functioning and security of Cloudflare WARP lies entirely with Cloudflare, as this application only sends commands to the official WARP program installed on the system.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'By clicking "I understand", you confirm that you have read, understood, and accept the terms above. Your confirmation will be recorded locally and this notice will not be displayed again.',
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

