import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'zero_trust_login_screen.dart';

class WarpControlScreen extends StatefulWidget {
  const WarpControlScreen({super.key});

  @override
  State<WarpControlScreen> createState() => _WarpControlScreenState();
}

class _WarpControlScreenState extends State<WarpControlScreen> {
  bool _isConnected = false;
  String _statusText = 'DISCONNECTED';
  String _privateText = 'Your Internet is not private.';
  String _currentIconPath = 'assets/zero-trust-disconnected.svg';
  String _warpCliVersion = 'Loading...';
  final Color _warpColor = const Color(0xFFF65B54);
  final Color _disconnectColor = Colors.grey[400]!;

  @override
  void initState() {
    super.initState();
    _checkWarpStatus();
    _getWarpCliVersion();

    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  Future<String> _executeWarpCommand(String command, [List<String> arguments = const []]) async {
    try {
      final List<String> cmdArgs = [command, ...arguments];
      final result = await Process.run('/usr/bin/warp-cli', cmdArgs);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      } else {
        return 'Error: ${result.stderr}';
      }
    } catch (e) {
      return 'Error: The warp-cli command failed.';
    }
  }

  Future<void> _getWarpCliVersion() async {
    final versionOutput = await _executeWarpCommand('--version');
    if (mounted) {
      setState(() {
        _warpCliVersion = versionOutput;
      });
    }
  }

  Future<void> _checkWarpStatus() async {
    final statusOutput = await _executeWarpCommand('status');
    if (statusOutput.contains('Connected')) {
      setState(() {
        _isConnected = true;
        _statusText = 'CONNECTED';
        _privateText = 'Your Internet is private.';
        _currentIconPath = 'assets/zero-trust-connected.svg';
      });
    } else if (statusOutput.contains('Disconnected')) {
      setState(() {
        _isConnected = false;
        _statusText = 'DISCONNECTED';
        _privateText = 'Your Internet is not private.';
        _currentIconPath = 'assets/zero-trust-disconnected.svg';
      });
    } else {
      setState(() {
        _isConnected = false;
        _statusText = 'ERROR';
        _privateText = 'Could not read status.';
        _currentIconPath = 'assets/zero-trust-error.svg';
      });
    }
  }

  Future<void> _toggleWarp() async {
    final command = _isConnected ? 'disconnect' : 'connect';
    await _executeWarpCommand(command);
    await Future.delayed(const Duration(seconds: 2));
    await _checkWarpStatus();
  }
  
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not open URL: $url';
    }
  }

  void _showAboutZeroTrustDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'About Cloudflare',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/cloudflare-logo.svg',
                  width: 100,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _launchUrl('https://www.cloudflare.com/pt-br/application/privacypolicy/'),
                  child: const Text(
                    'Privacy policy',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _launchUrl('https://www.cloudflare.com/pt-br/application/terms/'),
                  child: const Text(
                    'Terms of service',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _launchUrl('https://developers.cloudflare.com/warp-client/legal/3rdparty/'),
                  child: const Text(
                    'Third party licenses',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Version $_warpCliVersion'),
                const SizedBox(height: 8),
                const Text('Copyright © 2023 Cloudflare, Inc.'),
              ],
            ),
          ),
        );
      },
    );
  }

void _showRegistrationSettingsDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: const Text(
          'Registration Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Show registration info'),
              onTap: () async {
                final result = await _executeWarpCommand('registration', ['show']);
                if (mounted) Navigator.of(context).pop();
                _showResultDialog('Registration Info', result);
              },
            ),
            ListTile(
              title: const Text('Delete current registration'),
              onTap: () async {
                await _executeWarpCommand('registration', ['delete']);
                await _checkWarpStatus();
                if (mounted) Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Register new client'),
              onTap: () async {
                await _executeWarpCommand('registration', ['delete']);
                await _executeWarpCommand('registration', ['new']);
                await _checkWarpStatus();
                if (mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}

  void _showResultDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: Text(content)),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDnsSettingsDialog() {
    String? fallbackDomain;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('DNS Settings'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Show DNS stats'),
                  onTap: () async {
                    final result = await _executeWarpCommand('dns', ['stats']);
                    if (mounted) Navigator.of(context).pop();
                    _showResultDialog('DNS Stats', result);
                  },
                ),
                ListTile(
                  title: const Text('Show default fallbacks'),
                  onTap: () async {
                    final result = await _executeWarpCommand('dns', ['default-fallbacks']);
                    if (mounted) Navigator.of(context).pop();
                    _showResultDialog('Default DNS Fallbacks', result);
                  },
                ),
                ListTile(
                  title: const Text('Toggle DNS logging'),
                  onTap: () async {
                    await _executeWarpCommand('dns', ['log', 'toggle']);
                    if (mounted) Navigator.of(context).pop();
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Set Fallback Domain'),
                  onChanged: (value) => fallbackDomain = value,
                  onSubmitted: (value) async {
                    await _executeWarpCommand('dns', ['fallback', value]);
                    if (mounted) Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProxySettingsDialog() {
    String? port;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Proxy Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Set Proxy Port'),
                keyboardType: TextInputType.number,
                onChanged: (value) => port = value,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (port != null && port!.isNotEmpty) {
                    await _executeWarpCommand('proxy', ['port', port!]);
                    if (mounted) Navigator.of(context).pop();
                  }
                },
                child: const Text('Set Port'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTrustedNetworksDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Trusted Networks'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Manage trusted SSIDs'),
                onTap: () async {
                  final result = await _executeWarpCommand('trusted', ['ssid']);
                  if (mounted) Navigator.of(context).pop();
                  _showResultDialog('Trusted SSIDs', result);
                },
              ),
              ListTile(
                title: const Text('Toggle trusted Ethernet'),
                onTap: () async {
                  await _executeWarpCommand('trusted', ['ethernet']);
                  if (mounted) Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Toggle trusted Wi-Fi'),
                onTap: () async {
                  await _executeWarpCommand('trusted', ['wifi']);
                  if (mounted) Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStatsDialog() async {
    final result = await _executeWarpCommand('stats');
    if (mounted) {
      _showResultDialog('WARP Stats', result);
    }
  }

  void _showDebugMenuDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Debug Menu'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Show Network Info'),
                  onTap: () async {
                    final result = await _executeWarpCommand('debug', ['network']);
                    if (mounted) Navigator.of(context).pop();
                    _showResultDialog('Network Info', result);
                  },
                ),
                ListTile(
                  title: const Text('Show Posture Info'),
                  onTap: () async {
                    final result = await _executeWarpCommand('debug', ['posture']);
                    if (mounted) Navigator.of(context).pop();
                    _showResultDialog('Posture Info', result);
                  },
                ),
                ListTile(
                  title: const Text('Show DEX data'),
                  onTap: () async {
                    final result = await _executeWarpCommand('debug', ['dex']);
                    if (mounted) Navigator.of(context).pop();
                    _showResultDialog('DEX Data', result);
                  },
                ),
                ListTile(
                  title: const Text('Toggle connectivity check'),
                  onTap: () async {
                    final result = await _executeWarpCommand('debug', ['connectivity-check', 'toggle']);
                    if (mounted) Navigator.of(context).pop();
                    _showResultDialog('Connectivity Check', result);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTunnelSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tunnel Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Show Tunnel Stats'),
                onTap: () async {
                  final result = await _executeWarpCommand('tunnel', ['stats']);
                  if (mounted) Navigator.of(context).pop();
                  _showResultDialog('Tunnel Stats', result);
                },
              ),
              ListTile(
                title: const Text('Rotate Tunnel Keys'),
                onTap: () async {
                  await _executeWarpCommand('tunnel', ['rotate-keys']);
                  if (mounted) Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVnetDialog() async {
    final currentVnet = await _executeWarpCommand('vnet');
    String? newVnet;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Virtual Network (VNet)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current VNet: $currentVnet'),
              TextField(
                decoration: const InputDecoration(labelText: 'Set New VNet'),
                onChanged: (value) => newVnet = value,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (newVnet != null && newVnet!.isNotEmpty) {
                    await _executeWarpCommand('vnet', [newVnet!]);
                    if (mounted) Navigator.of(context).pop();
                    _showResultDialog('VNet Set', 'New VNet has been set to $newVnet');
                  }
                },
                child: const Text('Set VNet'),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Função para o diálogo de confirmação de logout
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure you want to logout from Cloudflare Zero Trust?'),
          content: const Text(
            'After the logout, you will be disassociated from Cloudflare Zero Trust.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Executa o comando de logout e fecha todos os diálogos
                await _executeWarpCommand('disconnect');
                await _checkWarpStatus();
                if (mounted) {
                  Navigator.of(context).pop(); // Fecha o diálogo de confirmação
                  Navigator.of(context).pop(); // Fecha o menu de configurações
                }
              },
              child: const Text('Confirm logout'),
            ),
          ],
        );
      },
    );
  }

void _showSettingsMenu() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Gateway with DoH'),
                onTap: () async {
                  await _executeWarpCommand('mode', ['doh']);
                  await _checkWarpStatus();
                  if (mounted) Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Gateway with WARP'),
                onTap: () async {
                  await _executeWarpCommand('mode', ['warp']);
                  await _checkWarpStatus();
                  if (mounted) Navigator.of(context).pop();
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('DNS Settings'),
                onTap: () {
                  if (mounted) Navigator.of(context).pop();
                  _showDnsSettingsDialog();
                },
              ),
              ListTile(
                title: const Text('Proxy Settings'),
                onTap: () {
                  if (mounted) Navigator.of(context).pop();
                  _showProxySettingsDialog();
                },
              ),
              ListTile(
                title: const Text('Trusted Networks'),
                onTap: () {
                  if (mounted) Navigator.of(context).pop();
                  _showTrustedNetworksDialog();
                },
              ),
              ListTile(
                title: const Text('Show Statistics'),
                onTap: () {
                  if (mounted) Navigator.of(context).pop();
                  _showStatsDialog();
                },
              ),
              ListTile(
                title: const Text('Tunnel Settings'),
                onTap: () {
                  if (mounted) Navigator.of(context).pop();
                  _showTunnelSettingsDialog();
                },
              ),
              ListTile(
                title: const Text('VNet Settings'),
                onTap: () {
                  if (mounted) Navigator.of(context).pop();
                  _showVnetDialog();
                },
              ),
              ListTile(
                title: const Text('Debug Menu'),
                onTap: () {
                  if (mounted) Navigator.of(context).pop();
                  _showDebugMenuDialog();
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('Logout from Zero Trust'),
                onTap: () {
                  _showLogoutConfirmationDialog(context);
                },
              ),
              ListTile(
                title: const Text('Re-authenticate session'),
                onTap: () async {
                  await _executeWarpCommand('debug', ['access-reauth']);
                  await _checkWarpStatus();
                  if (mounted) Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Registration Settings'),
                onTap: () {
                  if (mounted) Navigator.of(context).pop();
                  _showRegistrationSettingsDialog();
                },
              ),
              ListTile(
                title: const Text('Zero Trust Login'),
                onTap: () {
                  Navigator.of(context).pop(); // Fecha o menu de configurações
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ZeroTrustLoginScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('About Zero Trust'),
                onTap: () {
                  if (mounted) Navigator.of(context).pop();
                  _showAboutZeroTrustDialog();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Center(
        child: SizedBox(
          width: 350,
          height: 450,
          child: Column(
            children: [
              const SizedBox(height: 24),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(top: 0.0),
                      child: Text(
                        'WARP',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF65B54),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: SvgPicture.asset(
                        _currentIconPath,
                        width: 100,
                      ),
                    ),
                    GestureDetector(
                      onTap: _toggleWarp,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                        width: 120,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _isConnected ? _warpColor : _disconnectColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 300),
                          alignment: _isConnected ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          _statusText,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _isConnected ? _warpColor : _disconnectColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _privateText,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/zero-trust-orange.svg',
                                width: 22,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'CLOUDFLARE\nWARP',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.network_wifi, color: Colors.grey),
                                iconSize: 22,
                                onPressed: () {
                                  // Adicione a lógica para o ícone de rede aqui
                                },
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                icon: const Icon(Icons.settings, color: Colors.grey),
                                iconSize: 22,
                                onPressed: _showSettingsMenu,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
