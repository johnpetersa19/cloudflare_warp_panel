// zero_trust_login_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class ZeroTrustLoginScreen extends StatefulWidget {
  const ZeroTrustLoginScreen({super.key});

  @override
  State<ZeroTrustLoginScreen> createState() => _ZeroTrustLoginScreenState();
}

class _ZeroTrustLoginScreenState extends State<ZeroTrustLoginScreen> {
  final TextEditingController _teamNameController = TextEditingController();
  final ValueNotifier<bool> _isProcessing = ValueNotifier<bool>(false);

  Future<void> _launchLoginUrl() async {
    final teamName = _teamNameController.text.trim();
    if (teamName.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your team name.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    _isProcessing.value = true;
    
    try {
      // Delete current registration (if any)
      await Process.run('/usr/bin/warp-cli', ['registration', 'delete']);

      // Register using your team's direct link
      final registerResult = await Process.run(
        '/usr/bin/warp-cli',
        ['--accept-tos', 'registration', 'new', teamName]
      );

      if (registerResult.exitCode != 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error registering team: ${registerResult.stderr}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        // Return a false value to the parent screen in case of failure.
        Navigator.of(context).pop(false);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful. Please check your browser to continue.'),
              backgroundColor: Colors.green,
            ),
          );
          // Return a true value to the parent screen in case of success.
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('FATAL ERROR: Failed to execute warp-cli command: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      Navigator.of(context).pop(false);
    } finally {
      _isProcessing.value = false;
    }
  }

  // Function to revert to free WARP mode
  Future<void> _revertToFreeMode() async {
    if (mounted) {
      _isProcessing.value = true;
      try {
        // Delete current Zero Trust registration
        await Process.run('/usr/bin/warp-cli', ['registration', 'delete']);
        // Register again in Free WARP mode
        await Process.run('/usr/bin/warp-cli', ['--accept-tos', 'register']);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reverted to free WARP mode. Please check the main dashboard.'),
              backgroundColor: Colors.blue,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error reverting to free mode: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        _isProcessing.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zero Trust Login'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Zero Trust',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _teamNameController,
                decoration: InputDecoration(
                  labelText: 'Your team name',
                  border: const OutlineInputBorder(),
                  suffix: const Text('.cloudflareaccess.com'),
                ),
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<bool>(
                valueListenable: _isProcessing,
                builder: (context, value, child) {
                  return ElevatedButton(
                    onPressed: value ? null : _launchLoginUrl,
                    child: value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Login via browser'),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _revertToFreeMode,
                child: const Text('Revert to Free WARP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
