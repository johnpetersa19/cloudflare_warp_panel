// zero_trust_login_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ZeroTrustLoginScreen extends StatefulWidget {
  const ZeroTrustLoginScreen({super.key});

  @override
  State<ZeroTrustLoginScreen> createState() => _ZeroTrustLoginScreenState();
}

class _ZeroTrustLoginScreenState extends State<ZeroTrustLoginScreen> {
  final TextEditingController _teamNameController = TextEditingController();

  Future<void> _launchLoginUrl() async {
    final teamName = _teamNameController.text;
    if (teamName.isNotEmpty) {
      final urlString = 'https://$teamName.cloudflareaccess.com';
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not open URL: $url';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zero Trust Login'),
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
                  color: Color(0xFF1976D2), // Cor similar à da imagem
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
              ElevatedButton(
                onPressed: _launchLoginUrl,
                child: const Text('Login via browser'),
              ),
              const SizedBox(height: 48),
              // Adicionando a parte inferior da imagem
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'WARP',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'by Cloudflare',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.settings), // Ícone de engrenagem
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
