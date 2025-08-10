// warp_control_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'zero_trust_login_screen.dart';
import 'trusted_networks_dialog.dart';
import 'network_speed_widget.dart';

class WarpControlScreen extends StatefulWidget {
  const WarpControlScreen({super.key});

  @override
  State<WarpControlScreen> createState() => _WarpControlScreenState();
}

class _WarpControlScreenState extends State<WarpControlScreen> {
  Process? _statusListenerProcess;
  
  bool _isConnected = false;
  bool _isWarpCliInstalled = false;
  String _statusText = 'DISCONNECTED';
  String _privateText = 'Your Internet is not private.';
  String _currentIconPath = 'assets/zero-trust-disconnected.svg';
  String _warpCliVersion = 'Loading...';
  String _currentWarpMode = 'warp';
  String _mainTitle = 'WARP';
  final Color _warpColor = const Color(0xFFF65B54);
  final Color _disconnectColor = Colors.grey[400]!;

  @override
  void initState() {
    super.initState();
    _checkWarpCliInstallation();
    _getWarpCliVersion();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isWarpCliInstalled) {
        _getWarpModeFromCli();
        _startStatusListener();
      }
    });
  }

  @override
  void dispose() {
    _statusListenerProcess?.kill();
    super.dispose();
  }

  Future<void> _checkWarpCliInstallation() async {
    try {
      await Process.run('/usr/bin/warp-cli', ['--version']);
      if (mounted) {
        setState(() {
          _isWarpCliInstalled = true;
        });
        _startStatusListener();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isWarpCliInstalled = false;
          _statusText = 'NOT INSTALLED';
          _privateText = 'WARP-CLI not found.';
          _currentIconPath = 'assets/zero-trust-connected-exclamation.svg';
        });
      }
    }
  }

  Future<void> _startStatusListener() async {
    try {
      _statusListenerProcess = await Process.start('/usr/bin/warp-cli', ['--listen', 'status']);
      
      _statusListenerProcess!.stdout.transform(utf8.decoder).listen((output) {
        _updateStatusFromOutput(output);
      });

    } catch (e) {
      if (mounted) {
        setState(() {
          _isWarpCliInstalled = false;
          _statusText = 'NOT INSTALLED';
          _privateText = 'WARP-CLI not found.';
          _currentIconPath = 'assets/zero-trust-connected-exclamation.svg';
        });
      }
    }
  }

  void _updateStatusFromOutput(String output) {
    if (mounted) {
      setState(() {
        final cleanedOutput = output.trim();
        if (cleanedOutput.contains('Connected')) {
          _isConnected = true;
          _statusText = 'CONNECTED';
          _privateText = 'Your Internet is private.';
          _currentIconPath = 'assets/zero-trust-connected.svg';
          _getWarpModeFromCli();
        } else if (cleanedOutput.contains('Disconnected')) {
          _isConnected = false;
          _statusText = 'DISCONNECTED';
          _privateText = 'Your Internet is not private.';
          _currentIconPath = 'assets/zero-trust-disconnected.svg';
          _getWarpModeFromCli();
        } else if (cleanedOutput.contains('Connecting')) {
          _isConnected = false;
          _statusText = 'CONNECTING...';
          _privateText = 'Attempting to connect.';
          _currentIconPath = 'assets/zero-trust-connecting.svg';
        } else {
          _isConnected = false;
          _statusText = 'STATUS UNKNOWN';
          _privateText = 'Could not get a valid status.';
          _currentIconPath = 'assets/zero-trust-error.svg';
        }
      });
    }
  }

  Future<String> _executeWarpCommand(String command, [List<String> arguments = const []]) async {
    if (!_isWarpCliInstalled && command != '--version') {
      return 'Error: warp-cli is not installed.';
    }
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
  
  Future<void> _getWarpModeFromCli() async {
    try {
      final modeOutput = await _executeWarpCommand('settings', ['list']);
      if (mounted) {
        setState(() {
          if (modeOutput.contains('Mode: DnsOverHttps')) {
            _currentWarpMode = 'doh';
            _mainTitle = 'DoH';
          } else if (modeOutput.contains('Mode: WarpWithDnsOverHttps')) {
            _currentWarpMode = 'warp+doh';
            _mainTitle = 'WARP + DoH';
          } else if (modeOutput.contains('Mode: DnsOverTls')) {
            _currentWarpMode = 'dot';
            _mainTitle = 'DoT';
          } else if (modeOutput.contains('Mode: WarpWithDnsOverTls')) {
            _currentWarpMode = 'warp+dot';
            _mainTitle = 'WARP + DoT';
          } else if (modeOutput.contains('Mode: Proxy') || modeOutput.contains('Mode: WarpProxy')) {
            _currentWarpMode = 'proxy';
            _mainTitle = 'Proxy';
          } else if (modeOutput.contains('Mode: TunnelOnly')) {
            _currentWarpMode = 'tunnel_only';
            _mainTitle = 'Tunnel Only';
          } else {
            _currentWarpMode = 'warp';
            _mainTitle = 'WARP';
          }
        });
      }
    } catch (e) {
    }
  }

  Future<void> _checkWarpStatus() async {
    final statusOutput = await _executeWarpCommand('status');
    _updateStatusFromOutput(statusOutput);
  }

  Future<void> _toggleWarp() async {
    if (!_isWarpCliInstalled) {
      return;
    }
    final command = _isConnected ? 'disconnect' : 'connect';
    await _executeWarpCommand(command);
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
                _checkWarpStatus();
                if (mounted) Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Register new client'),
              onTap: () async {
                await _executeWarpCommand('registration', ['delete']);
                await _executeWarpCommand('registration', ['new']);
                _checkWarpStatus();
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
        backgroundColor: Colors.white,
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
        backgroundColor: Colors.white,
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
        backgroundColor: Colors.white,
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
      return TrustedNetworksDialog(
        executeWarpCommand: _executeWarpCommand,
        showTrustedSsidsDialog: _showTrustedSsidsDialog,
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
        backgroundColor: Colors.white,
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
        backgroundColor: Colors.white,
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
        backgroundColor: Colors.white,
        title: const Text('Virtual Network (VNet)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Vnet: $currentVnet'),
            TextField(
              decoration: const InputDecoration(labelText: 'Set New Vnet'),
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
  
void _showLogoutConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Are you sure you want to logout from Cloudflare Zero Trust?'),
        content: const Text(
          'After the logout, you will be disassociated from Cloudflare Zero Trust.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _executeWarpCommand('disconnect');
              _checkWarpStatus();
              if (mounted) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Confirm logout'),
          ),
        ],
      );
    },
  );
}

void _showEnvironmentDialog() {
  String? newEnvironment;
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Environment Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Set new environment'),
              onChanged: (value) => newEnvironment = value,
            ),
            ElevatedButton(
              onPressed: () async {
                if (newEnvironment != null && newEnvironment!.isNotEmpty) {
                  final result = await _executeWarpCommand('environment', ['set', newEnvironment!]);
                  if (mounted) Navigator.of(context).pop();
                  _showResultDialog('Environment Status', result);
                }
              },
              child: const Text('Set'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await _executeWarpCommand('environment', ['reset']);
                if (mounted) Navigator.of(context).pop();
                _showResultDialog('Environment Status', result);
              },
              child: const Text('Reset'),
            ),
          ],
        ),
      );
    },
  );
}

void _showMdmDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('MDM Configurations'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Get MDM configs'),
              onTap: () async {
                final result = await _executeWarpCommand('mdm', ['get-configs']);
                if (mounted) Navigator.of(context).pop();
                _showResultDialog('MDM Configs', result);
              },
            ),
          ],
        ),
      );
    },
  );
}

void _showOverrideDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Override Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Show overrides'),
              onTap: () async {
                final result = await _executeWarpCommand('override', ['show']);
                if (mounted) Navigator.of(context).pop();
                _showResultDialog('Override Status', result);
              },
            ),
            ListTile(
              title: const Text('Unlock policies'),
              onTap: () async {
                final result = await _executeWarpCommand('override', ['unlock']);
                if (mounted) Navigator.of(context).pop();
                _showResultDialog('Override Status', result);
              },
            ),
            ListTile(
              title: const Text('Local Network Override'),
              onTap: () {
                Navigator.of(context).pop();
                _showLocalNetworkOverrideDialog();
              },
            ),
          ],
        ),
      );
    },
  );
}

void _showTargetDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Targets'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('List all targets'),
                onTap: () async {
                  final result = await _executeWarpCommand('target', ['list']);
                  if (mounted) Navigator.of(context).pop();
                  _showResultDialog('Targets', result);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showCertsDialog() async {
  final result = await _executeWarpCommand('certs');
  if (mounted) {
    _showResultDialog('Account Certificates', result);
  }
}

void _showLocalNetworkOverrideDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Local Network Override'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Allow access'),
              onTap: () async {
                final result = await _executeWarpCommand('override', ['local-network', 'allow']);
                if (mounted) Navigator.of(context).pop();
                _showResultDialog('Local Network Status', result);
              },
            ),
            ListTile(
              title: const Text('Show access'),
              onTap: () async {
                final result = await _executeWarpCommand('override', ['local-network', 'show']);
                if (mounted) Navigator.of(context).pop();
                _showResultDialog('Local Network Status', result);
              },
            ),
            ListTile(
              title: const Text('Stop access'),
              onTap: () async {
                final result = await _executeWarpCommand('override', ['local-network', 'stop']);
                if (mounted) Navigator.of(context).pop();
                _showResultDialog('Local Network Status', result);
              },
            ),
          ],
        ),
      );
    },
  );
}


void _showTrustedSsidsDialog() {
  String? ssidName;
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Trusted SSIDs'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('List SSIDs'),
              onTap: () async {
                final result = await _executeWarpCommand('trusted', ['ssid', 'list']);
                if (mounted) Navigator.of(context).pop();
                _showResultDialog('Trusted SSIDs', result);
              },
            ),
            ListTile(
              title: const Text('Add SSID'),
              onTap: () {
                Navigator.of(context).pop();
                _showAddSsidsDialog();
              },
            ),
            ListTile(
              title: const Text('Remove SSID'),
              onTap: () {
                Navigator.of(context).pop();
                _showRemoveSsidsDialog();
              },
            ),
            ListTile(
              title: const Text('Reset SSIDs'),
              onTap: () async {
                final result = await _executeWarpCommand('trusted', ['ssid', 'reset']);
                if (mounted) Navigator.of(context).pop();
                _showResultDialog('Reset SSIDs', result);
              },
            ),
          ],
        ),
      );
    },
  );
}

void _showAddSsidsDialog() {
  String? ssidName;
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Add SSID'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Enter SSID Name'),
              onChanged: (value) => ssidName = value,
            ),
            ElevatedButton(
              onPressed: () async {
                if (ssidName != null && ssidName!.isNotEmpty) {
                  await _executeWarpCommand('trusted', ['ssid', 'add', ssidName!]);
                  if (mounted) Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );
    },
  );
}

void _showRemoveSsidsDialog() {
  String? ssidName;
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Remove SSID'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Enter SSID Name'),
              onChanged: (value) => ssidName = value,
            ),
            ElevatedButton(
              onPressed: () async {
                if (ssidName != null && ssidName!.isNotEmpty) {
                  await _executeWarpCommand('trusted', ['ssid', 'remove', ssidName!]);
                  if (mounted) Navigator.of(context).pop();
                }
              },
              child: const Text('Remove'),
            ),
          ],
        ),
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
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Gateway with DoH'),
                    value: 'doh',
                    groupValue: _currentWarpMode,
                    onChanged: (value) async {
                      if (value != null) {
                        await _executeWarpCommand('mode', ['doh']);
                        setState(() {
                          _currentWarpMode = value;
                          _getWarpModeFromCli();
                        });
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Gateway with WARP'),
                    value: 'warp',
                    groupValue: _currentWarpMode,
                    onChanged: (value) async {
                      if (value != null) {
                        await _executeWarpCommand('mode', ['warp']);
                        setState(() {
                          _currentWarpMode = value;
                          _getWarpModeFromCli();
                        });
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Gateway with WARP + DoH'),
                    value: 'warp+doh',
                    groupValue: _currentWarpMode,
                    onChanged: (value) async {
                      if (value != null) {
                        await _executeWarpCommand('mode', ['warp+doh']);
                        setState(() {
                          _currentWarpMode = value;
                          _getWarpModeFromCli();
                        });
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Gateway with DoT'),
                    value: 'dot',
                    groupValue: _currentWarpMode,
                    onChanged: (value) async {
                      if (value != null) {
                        await _executeWarpCommand('mode', ['dot']);
                        setState(() {
                          _currentWarpMode = value;
                          _getWarpModeFromCli();
                        });
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Gateway with WARP + DoT'),
                    value: 'warp+dot',
                    groupValue: _currentWarpMode,
                    onChanged: (value) async {
                      if (value != null) {
                        await _executeWarpCommand('mode', ['warp+dot']);
                        setState(() {
                          _currentWarpMode = value;
                          _getWarpModeFromCli();
                        });
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Proxy Mode'),
                    value: 'proxy',
                    groupValue: _currentWarpMode,
                    onChanged: (value) async {
                      if (value != null) {
                        await _executeWarpCommand('mode', ['proxy']);
                        
                        setState(() {
                          _currentWarpMode = value;
                        });
                        
                        if (mounted) {
                          await _getWarpModeFromCli();
                          Navigator.of(context).pop();
                        }
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Tunnel Only'),
                    value: 'tunnel_only',
                    groupValue: _currentWarpMode,
                    onChanged: (value) async {
                      if (value != null) {
                        await _executeWarpCommand('mode', ['tunnel_only']);
                        setState(() {
                          _currentWarpMode = value;
                          _getWarpModeFromCli();
                        });
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      }
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
                    title: const Text('Environment Settings'),
                    onTap: () {
                      if (mounted) Navigator.of(context).pop();
                      _showEnvironmentDialog();
                    },
                  ),
                  ListTile(
                    title: const Text('MDM Settings'),
                    onTap: () {
                      if (mounted) Navigator.of(context).pop();
                      _showMdmDialog();
                    },
                  ),
                  ListTile(
                    title: const Text('Override Settings'),
                    onTap: () {
                      if (mounted) Navigator.of(context).pop();
                      _showOverrideDialog();
                    },
                  ),
                  ListTile(
                    title: const Text('Target List'),
                    onTap: () {
                      if (mounted) Navigator.of(context).pop();
                      _showTargetDialog();
                    },
                  ),
                  ListTile(
                    title: const Text('Show Certificates'),
                    onTap: () {
                      if (mounted) Navigator.of(context).pop();
                      _showCertsDialog();
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
                      _checkWarpStatus();
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
                      Navigator.of(context).pop();
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
            );
          },
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Text(
              _mainTitle,
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF65B54),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: SvgPicture.asset(
                _currentIconPath,
                width: 100,
              ),
            ),
            Column(
              children: [
                Text(
                  _statusText,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _isWarpCliInstalled && _isConnected ? _warpColor : _disconnectColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _privateText,
                  style: TextStyle(
                    fontSize: 15,
                    color: _isWarpCliInstalled ? Colors.grey[600] : Colors.red,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
              child: GestureDetector(
                onTap: _isWarpCliInstalled ? _toggleWarp : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  width: 120,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _isWarpCliInstalled && _isConnected ? _warpColor : _disconnectColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    alignment: _isConnected && _isWarpCliInstalled ? Alignment.centerRight : Alignment.centerLeft,
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
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!, width: 1.0),
                ),
              ),
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
                      NetworkSpeedWidget(isConnected: _isConnected),
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
    );
  }
}
