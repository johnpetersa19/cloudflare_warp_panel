// zero_trust_login_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'l10n/app_localizations.dart';

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
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseEnterTeamName),
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
              content: Text(AppLocalizations.of(context)!.errorRegisteringTeam(registerResult.stderr.toString())),
              backgroundColor: Colors.red,
            ),
          );
        }
        // Return a false value to the parent screen in case of failure.
        if (mounted) Navigator.of(context).pop(false);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.registrationSuccessful),
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
            content: Text(AppLocalizations.of(context)!.fatalErrorWarpCli(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (mounted) Navigator.of(context).pop(false);
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
            SnackBar(
              content: Text(AppLocalizations.of(context)!.revertedToFreeMode),
              backgroundColor: Colors.blue,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.errorReverting(e.toString())),
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
        title: Text(AppLocalizations.of(context)!.zeroTrustLogin),
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
              Text(
                AppLocalizations.of(context)!.zeroTrust,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _teamNameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.yourTeamName,
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
                        : Text(AppLocalizations.of(context)!.loginViaBrowser),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _revertToFreeMode,
                child: Text(AppLocalizations.of(context)!.revertToFreeWarp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

