// warp_control_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'zero_trust_login_screen.dart';
import 'trusted_networks_dialog.dart';
import 'network_speed_widget.dart';
import 'l10n/app_localizations.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'language_selector.dart';
import 'main.dart'; // Importa o main.dart para acessar o setLocale da MyApp

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isWarpCliInstalled) {
      _getWarpModeFromCli();
      _startStatusListener();
    }
    _checkWarpCliInstallation();
    _getWarpCliVersion();
  }

  @override
  void dispose() {
    _statusListenerProcess?.kill();
    super.dispose();
  }

  Future<void> _checkWarpCliInstallation() async {
    final localizations = AppLocalizations.of(context);
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
          _statusText = localizations?.notInstalled ?? 'NOT INSTALLED';
          _privateText = localizations?.warpCliNotFound ?? 'WARP-CLI not found.';
          _currentIconPath = 'assets/zero-trust-connected-exclamation.svg';
        });
      }
    }
  }

  Future<void> _startStatusListener() async {
    final localizations = AppLocalizations.of(context);
    try {
      _statusListenerProcess = await Process.start('/usr/bin/warp-cli', ['--listen', 'status']);
      
      _statusListenerProcess!.stdout.transform(utf8.decoder).listen((output) {
        _updateStatusFromOutput(output);
      });

    } catch (e) {
      if (mounted) {
        setState(() {
          _isWarpCliInstalled = false;
          _statusText = localizations?.notInstalled ?? 'NOT INSTALLED';
          _privateText = localizations?.warpCliNotFound ?? 'WARP-CLI not found.';
          _currentIconPath = 'assets/zero-trust-connected-exclamation.svg';
        });
      }
    }
  }

  void _updateStatusFromOutput(String output) {
    if (mounted) {
      setState(() {
        final cleanedOutput = output.trim();
        final localizations = AppLocalizations.of(context);
        if (cleanedOutput.contains('Connected')) {
          _isConnected = true;
          _statusText = localizations?.connectedStatus ?? 'CONNECTED';
          _privateText = localizations?.privateInternet ?? 'Your Internet is private.';
          _currentIconPath = 'assets/zero-trust-connected.svg';
          _getWarpModeFromCli();
        } else if (cleanedOutput.contains('Disconnected')) {
          _isConnected = false;
          _statusText = localizations?.disconnectedStatus ?? 'DISCONNECTED';
          _privateText = localizations?.notPrivateInternet ?? 'Your Internet is not private.';
          _currentIconPath = 'assets/zero-trust-disconnected.svg';
          _getWarpModeFromCli();
        } else if (cleanedOutput.contains('Connecting')) {
          _isConnected = false;
          _statusText = localizations?.connectingStatus ?? 'CONNECTING...';
          _privateText = localizations?.attemptingToConnect ?? 'Attempting to connect.';
          _currentIconPath = 'assets/zero-trust-connecting.svg';
        } else {
          _isConnected = false;
          _statusText = localizations?.statusUnknown ?? 'STATUS UNKNOWN';
          _privateText = localizations?.couldNotGetStatus ?? 'Could not get a valid status.';
          _currentIconPath = 'assets/zero-trust-error.svg';
        }
      });
    }
  }

  Future<String> _executeWarpCommand(String command, [List<String> arguments = const []]) async {
    final localizations = AppLocalizations.of(context);
    if (!_isWarpCliInstalled && command != '--version') {
      return localizations?.errorWarpCliNotInstalled ?? 'Error: warp-cli is not installed.';
    }
    try {
      final List<String> cmdArgs = [command, ...arguments];
      final result = await Process.run('/usr/bin/warp-cli', cmdArgs);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      } else {
        return localizations?.errorResultStderr(result.stderr.toString()) ?? 'Error: ${result.stderr}';
      }
    } catch (e) {
      return localizations?.errorWarpCliFailed ?? 'Error: The warp-cli command failed.';
    }
  }

  Future<void> _getWarpCliVersion() async {
    final localizations = AppLocalizations.of(context);
    final versionOutput = await _executeWarpCommand('--version');
    if (mounted) {
      setState(() {
        _warpCliVersion = versionOutput;
      });
    }
  }
  
  Future<void> _getWarpModeFromCli() async {
    final localizations = AppLocalizations.of(context);
    try {
      final modeOutput = await _executeWarpCommand('settings', ['list']);
      if (mounted) {
        setState(() {
          if (modeOutput.contains('Mode: DnsOverHttps')) {
            _currentWarpMode = 'doh';
            _mainTitle = localizations?.doh ?? 'DoH';
          } else if (modeOutput.contains('Mode: WarpWithDnsOverHttps')) {
            _currentWarpMode = 'warp+doh';
            _mainTitle = localizations?.warpDoh ?? 'WARP + DoH';
          } else if (modeOutput.contains('Mode: DnsOverTls')) {
            _currentWarpMode = 'dot';
            _mainTitle = localizations?.dot ?? 'DoT';
          } else if (modeOutput.contains('Mode: WarpWithDnsOverTls')) {
            _currentWarpMode = 'warp+dot';
            _mainTitle = localizations?.warpDot ?? 'WARP + DoT';
          } else if (modeOutput.contains('Mode: Proxy') || modeOutput.contains('Mode: WarpProxy')) {
            _currentWarpMode = 'proxy';
            _mainTitle = localizations?.proxy ?? 'Proxy';
          } else if (modeOutput.contains('Mode: TunnelOnly')) {
            _currentWarpMode = 'tunnel_only';
            _mainTitle = localizations?.tunnelOnly ?? 'Tunnel Only';
          } else {
            _currentWarpMode = 'warp';
            _mainTitle = localizations?.warp ?? 'WARP';
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
    final localizations = AppLocalizations.of(context);
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
              Expanded(
                child: Text(
                  localizations?.aboutCloudflare ?? 'About Cloudflare',
                  style: const TextStyle(
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
                  child: Text(
                    localizations?.privacyPolicy ?? 'Privacy policy',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _launchUrl('https://www.cloudflare.com/pt-br/application/terms/'),
                  child: Text(
                    localizations?.termsOfService ?? 'Terms of service',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _launchUrl('https://developers.cloudflare.com/warp-client/legal/3rdparty/'),
                  child: Text(
                    localizations?.thirdPartyLicenses ?? 'Third party licenses',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(localizations?.version(_warpCliVersion) ?? 'Version $_warpCliVersion'),
                const SizedBox(height: 8),
                Text(localizations?.copyright ?? 'Copyright © 2023 Cloudflare, Inc.'),
              ],
            ),
          ),
        );
      },
    );
  }

void _showRegistrationSettingsDialog() {
  final localizations = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(
          localizations?.registrationSettings ?? 'Registration Settings',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(localizations?.showRegistrationInfo ?? 'Show registration info'),
              onTap: () async {
                final result = await _executeWarpCommand('registration', ['show']);
                if (mounted) Navigator.of(context).pop();
                _showResultDialog(localizations?.registrationInfo ?? 'Registration Info', result);
              },
            ),
            ListTile(
              title: Text(localizations?.deleteCurrentRegistration ?? 'Delete current registration'),
              onTap: () async {
                await _executeWarpCommand('registration', ['delete']);
                _checkWarpStatus();
                if (mounted) Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(localizations?.registerNewClient ?? 'Register new client'),
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
  final localizations = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: <Widget>[
          TextButton(
            child: Text(localizations?.ok ?? 'OK'),
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
  final localizations = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(localizations?.dnsSettings ?? 'DNS Settings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(localizations?.showDnsStats ?? 'Show DNS stats'),
                onTap: () async {
                  final result = await _executeWarpCommand('dns', ['stats']);
                  if (mounted) Navigator.of(context).pop();
                  _showResultDialog(localizations?.dnsStats ?? 'DNS Stats', result);
                },
              ),
              ListTile(
                title: Text(localizations?.showDefaultFallbacks ?? 'Show default fallbacks'),
                onTap: () async {
                  final result = await _executeWarpCommand('dns', ['default-fallbacks']);
                  if (mounted) Navigator.of(context).pop();
                  _showResultDialog(localizations?.defaultDnsFallbacks ?? 'Default DNS Fallbacks', result);
                },
              ),
              ListTile(
                title: Text(localizations?.toggleDnsLogging ?? 'Toggle DNS logging'),
                onTap: () async {
                  await _executeWarpCommand('dns', ['log', 'toggle']);
                  if (mounted) Navigator.of(context).pop();
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: localizations?.setFallbackDomain ?? 'Set Fallback Domain'),
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
  final localizations = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(localizations?.proxySettings ?? 'Proxy Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: localizations?.setProxyPort ?? 'Set Proxy Port'),
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
              child: Text(localizations?.setPort ?? 'Set Port'),
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
      final localizations = AppLocalizations.of(context);
      return TrustedNetworksDialog(
        executeWarpCommand: _executeWarpCommand,
        showTrustedSsidsDialog: _showTrustedSsidsDialog,
      );
    },
  );
}

void _showStatsDialog() async {
  final localizations = AppLocalizations.of(context);
  final result = await _executeWarpCommand('stats');
  if (mounted) {
    _showResultDialog(localizations?.showStatistics ?? 'Show Statistics', result);
  }
}

void _showDebugMenuDialog() {
  final localizations = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(localizations?.debugMenu ?? 'Debug Menu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(localizations?.showNetworkInfo ?? 'Show Network Info'),
                onTap: () async {
                  final result = await _executeWarpCommand('debug', ['network']);
                  if (mounted) Navigator.of(context).pop();
                  _showResultDialog(localizations?.networkInfo ?? 'Network Info', result);
                },
              ),
              ListTile(
                title: Text(localizations?.showPostureInfo ?? 'Show Posture Info'),
                onTap: () async {
                  final result = await _executeWarpCommand('debug', ['posture']);
                  if (mounted) Navigator.of(context).pop();
                  _showResultDialog(localizations?.postureInfo ?? 'Posture Info', result);
                },
              ),
              ListTile(
                title: Text(localizations?.showDexData ?? 'Show DEX data'),
                onTap: () async {
                  final result = await _executeWarpCommand('debug', ['dex']);
                  if (mounted) Navigator.of(context).pop();
                  _showResultDialog(localizations?.dexData ?? 'DEX Data', result);
                },
              ),
              ListTile(
                title: Text(localizations?.toggleConnectivityCheck ?? 'Toggle connectivity check'),
                onTap: () async {
                  final result = await _executeWarpCommand('debug', ['connectivity-check', 'toggle']);
                  if (mounted) Navigator.of(context).pop();
                  _showResultDialog(localizations?.connectivityCheck ?? 'Connectivity Check', result);
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
  final localizations = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(localizations?.tunnelSettings ?? 'Tunnel Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(localizations?.tunnelStats ?? 'Tunnel Stats'),
              onTap: () async {
                final result = await _executeWarpCommand('tunnel', ['stats']);
                if (mounted) Navigator.of(context).pop();
                _showResultDialog(localizations?.tunnelStats ?? 'Tunnel Stats', result);
              },
            ),
            ListTile(
              title: Text(localizations?.rotateTunnelKeys ?? 'Rotate Tunnel Keys'),
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
  final localizations = AppLocalizations.of(context);
  final currentVnet = await _executeWarpCommand('vnet');
  String? newVnet;
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(localizations?.virtualNetwork ?? 'Virtual Network (VNet)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localizations?.currentVnet(currentVnet) ?? 'Current Vnet: $currentVnet'),
            TextField(
              decoration: InputDecoration(labelText: localizations?.setNewVnet ?? 'Set New Vnet'),
              onChanged: (value) => newVnet = value,
            ),
            ElevatedButton(
              onPressed: () async {
                if (newVnet != null && newVnet!.isNotEmpty) {
                  await _executeWarpCommand('vnet', [newVnet!]);
                  if (mounted) Navigator.of(context).pop();
                  _showResultDialog(localizations?.vnetSet ?? 'VNet Set', localizations?.newVnetSet(newVnet!) ?? 'New VNet has been set to $newVnet');
                }
              },
              child: Text(localizations?.setVnet ?? 'Set VNet'),
            ),
          ],
        ),
      );
    },
  );
}
  
void _showLogoutConfirmationDialog(BuildContext context) {
  final localizations = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(localizations?.confirmLogout ?? 'Are you sure you want to logout from Cloudflare Zero Trust?'),
        content: Text(
          localizations?.logoutDescription ?? 'After the logout, you will be disassociated from Cloudflare Zero Trust.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              localizations?.cancel ?? 'Cancel',
              style: const TextStyle(color: Colors.grey),
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
            child: Text(localizations?.confirmLogoutButton ?? 'Confirm logout'),
          ),
        ],
      );
    },
  );
}

void _showEnvironmentDialog() {
  String? newEnvironment;
  final localizations = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(localizations?.environmentSettings ?? 'Environment Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: localizations?.setNewEnvironment ?? 'Set new environment'),
              onChanged: (value) => newEnvironment = value,
            ),
            ElevatedButton(
              onPressed: () async {
                if (newEnvironment != null && newEnvironment!.isNotEmpty) {
                  final result = await _executeWarpCommand('environment', ['set', newEnvironment!]);
                  if (mounted) Navigator.of(context).pop();
                  _showResultDialog(localizations?.environmentStatus ?? 'Environment Status', result);
                }
              },
              child: Text(localizations?.setButton ?? 'Set'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await _executeWarpCommand('environment', ['reset']);
                if (mounted) Navigator.of(context).pop();
                _showResultDialog(localizations?.environmentStatus ?? 'Environment Status', result);
              },
              child: Text(localizations?.resetButton ?? 'Reset'),
            ),
          ],
        ),
      );
    },
  );
}

void _showMdmDialog() {
  final localizations = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(localizations?.mdmConfigs ?? 'MDM Configurations'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(localizations?.getMdmConfigs ?? 'Get MDM configs'),
              onTap: () async {
                final result = await _executeWarpCommand('mdm', ['get-configs']);
                if (mounted) Navigator.of(context).pop();
                _showResultDialog(localizations?.mdmConfigs ?? 'MDM Configs', result);
              },
            ),
          ],
        ),
      );
    },
  );
}

void _showOverrideDialog() {
  final localizations = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(localizations?.overrideSettings ?? 'Override Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(localizations?.showOverrides ?? 'Show overrides'),
              onTap: () async {
                final result = await _executeWarpCommand('override', ['show']);
                if (mounted) Navigator.of(context).pop();
                _showResultDialog(localizations?.overrideStatus ?? 'Override Status', result);
              },
            ),
            ListTile(
              title: Text(localizations?.unlockPolicies ?? 'Unlock policies'),
              onTap: () async {
                final result = await _executeWarpCommand('override', ['unlock']);
                if (mounted) Navigator.of(context).pop();
                _showResultDialog(localizations?.overrideStatus ?? 'Override Status', result);
              },
            ),
            ListTile(
              title: Text(localizations?.localNetworkOverride ?? 'Local Network Override'),
              onTap: () {
                if (mounted) Navigator.of(context).pop();
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
  final localizations = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(localizations?.targets ?? 'Targets'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(localizations?.listAllTargets ?? 'List all targets'),
                onTap: () async {
                  final result = await _executeWarpCommand('target', ['list']);
                  if (mounted) Navigator.of(context).pop();
                  _showResultDialog(localizations?.targets ?? 'Targets', result);
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
  final localizations = AppLocalizations.of(context);
  final result = await _executeWarpCommand('certs');
  if (mounted) {
    _showResultDialog(localizations?.accountCertificates ?? 'Account Certificates', result);
  }
}

void _showLocalNetworkOverrideDialog() {
  final localizations = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(localizations?.localNetworkOverride ?? 'Local Network Override'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(localizations?.allowAccess ?? 'Allow access'),
              onTap: () async {
                final result = await _executeWarpCommand('override', ['local-network', 'allow']);
                if (mounted) Navigator.of(context).pop();
                _showResultDialog(localizations?.localNetworkStatus ?? 'Local Network Status', result);
              },
            ),
            ListTile(
              title: Text(localizations?.showAccess ?? 'Show access'),
              onTap: () async {
                final result = await _executeWarpCommand('override', ['local-network', 'show']);
                if (mounted) Navigator.of(context).pop();
                _showResultDialog(localizations?.localNetworkStatus ?? 'Local Network Status', result);
              },
            ),
            ListTile(
              title: Text(localizations?.stopAccess ?? 'Stop access'),
              onTap: () async {
                final result = await _executeWarpCommand('override', ['local-network', 'stop']);
                if (mounted) Navigator.of(context).pop();
                _showResultDialog(localizations?.localNetworkStatus ?? 'Local Network Status', result);
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
  final localizations = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(localizations?.trustedSsids ?? 'Trusted SSIDs'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(localizations?.listSsids ?? 'List SSIDs'),
              onTap: () async {
                final result = await _executeWarpCommand('trusted', ['ssid', 'list']);
                if (mounted) Navigator.of(context).pop();
                _showResultDialog(localizations?.trustedSsids ?? 'Trusted SSIDs', result);
              },
            ),
            ListTile(
              title: Text(localizations?.addSsid ?? 'Add SSID'),
              onTap: () {
                if (mounted) Navigator.of(context).pop();
                _showAddSsidsDialog();
              },
            ),
            ListTile(
              title: Text(localizations?.removeSsid ?? 'Remove SSID'),
              onTap: () {
                if (mounted) Navigator.of(context).pop();
                _showRemoveSsidsDialog();
              },
            ),
            ListTile(
              title: Text(localizations?.resetSsids ?? 'Reset SSIDs'),
              onTap: () async {
                final result = await _executeWarpCommand('trusted', ['ssid', 'reset']);
                if (mounted) Navigator.of(context).pop();
                _showResultDialog(localizations?.resetSsids ?? 'Reset SSIDs', result);
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
  final localizations = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(localizations?.addSsid ?? 'Add SSID'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: localizations?.enterSsidName ?? 'Enter SSID Name'),
              onChanged: (value) => ssidName = value,
            ),
            ElevatedButton(
              onPressed: () async {
                if (ssidName != null && ssidName!.isNotEmpty) {
                  await _executeWarpCommand('trusted', ['ssid', 'add', ssidName!]);
                  if (mounted) Navigator.of(context).pop();
                }
              },
              child: Text(localizations?.addButton ?? 'Add'),
            ),
          ],
        ),
      );
    },
  );
}

void _showRemoveSsidsDialog() {
  String? ssidName;
  final localizations = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(localizations?.removeSsid ?? 'Remove SSID'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: localizations?.enterSsidName ?? 'Enter SSID Name'),
              onChanged: (value) => ssidName = value,
            ),
            ElevatedButton(
              onPressed: () async {
                if (ssidName != null && ssidName!.isNotEmpty) {
                  await _executeWarpCommand('trusted', ['ssid', 'remove', ssidName!]);
                  if (mounted) Navigator.of(context).pop();
                }
              },
              child: Text(localizations?.removeButton ?? 'Remove'),
            ),
          ],
        ),
      );
    },
  );
}


void _showSettingsMenu() {
  final localizations = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(
          localizations?.settings ?? 'Settings',
          style: const TextStyle(
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
                    title: Text(localizations?.doh ?? 'DoH'),
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
                    title: Text(localizations?.warp ?? 'WARP'),
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
                    title: Text(localizations?.warpDoh ?? 'WARP + DoH'),
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
                    title: Text(localizations?.dot ?? 'DoT'),
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
                    title: Text(localizations?.warpDot ?? 'WARP + DoT'),
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
                    title: Text(localizations?.proxy ?? 'Proxy'),
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
                    title: Text(localizations?.tunnelOnly ?? 'Tunnel Only'),
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
                    title: Text(localizations?.dnsSettings ?? 'DNS Settings'),
                    onTap: () {
                      if (mounted) Navigator.of(context).pop();
                      _showDnsSettingsDialog();
                    },
                  ),
                  ListTile(
                    title: Text(localizations?.proxySettings ?? 'Proxy Settings'),
                    onTap: () {
                      if (mounted) Navigator.of(context).pop();
                      _showProxySettingsDialog();
                    },
                  ),
                  ListTile(
                    title: Text(localizations?.trustedNetworks ?? 'Trusted Networks'),
                    onTap: () {
                      if (mounted) Navigator.of(context).pop();
                      _showTrustedNetworksDialog();
                    },
                  ),
                  ListTile(
                    title: Text(localizations?.showStatistics ?? 'Show Statistics'),
                    onTap: () {
                      if (mounted) Navigator.of(context).pop();
                      _showStatsDialog();
                    },
                  ),
                  ListTile(
                    title: Text(localizations?.tunnelSettings ?? 'Tunnel Settings'),
                    onTap: () {
                      if (mounted) Navigator.of(context).pop();
                      _showTunnelSettingsDialog();
                    },
                  ),
                  ListTile(
                    title: Text(localizations?.vnetSettings ?? 'VNet Settings'),
                    onTap: () {
                      if (mounted) Navigator.of(context).pop();
                      _showVnetDialog();
                    },
                  ),
                  ListTile(
                    title: Text(localizations?.debugMenu ?? 'Debug Menu'),
                    onTap: () {
                      if (mounted) Navigator.of(context).pop();
                      _showDebugMenuDialog();
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: Text(localizations?.environmentSettings ?? 'Environment Settings'),
                    onTap: () {
                      if (mounted) Navigator.of(context).pop();
                      _showEnvironmentDialog();
                    },
                  ),
                  ListTile(
                    title: Text(localizations?.mdmConfigs ?? 'MDM Configurations'),
                    onTap: () {
                      if (mounted) Navigator.of(context).pop();
                      _showMdmDialog();
                    },
                  ),
                  ListTile(
                    title: Text(localizations?.overrideSettings ?? 'Override Settings'),
                    onTap: () {
                      if (mounted) Navigator.of(context).pop();
                      _showOverrideDialog();
                    },
                  ),
                  ListTile(
                    title: Text(localizations?.targetList ?? 'Target List'),
                    onTap: () {
                      if (mounted) Navigator.of(context).pop();
                      _showTargetDialog();
                    },
                  ),
                  ListTile(
                    title: Text(localizations?.showCertificates ?? 'Show Certificates'),
                    onTap: () {
                      if (mounted) Navigator.of(context).pop();
                      _showCertsDialog();
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: Text(localizations?.logoutFromZeroTrust ?? 'Logout from Zero Trust'),
                    onTap: () {
                      _showLogoutConfirmationDialog(context);
                    },
                  ),
                  ListTile(
                    title: Text(localizations?.reauthenticateSession ?? 'Re-authenticate session'),
                    onTap: () async {
                      await _executeWarpCommand('debug', ['access-reauth']);
                      _checkWarpStatus();
                      if (mounted) Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: Text(localizations?.registrationSettings ?? 'Registration Settings'),
                    onTap: () {
                      if (mounted) Navigator.of(context).pop();
                      _showRegistrationSettingsDialog();
                    },
                  ),
                  ListTile(
                    title: Text(localizations?.zeroTrustLogin ?? 'Zero Trust Login'),
                    onTap: () {
                      if (mounted) Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ZeroTrustLoginScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: Text(localizations?.aboutZeroTrust ?? 'About Zero Trust'),
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
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
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
                          Text(
                            localizations?.warpControlScreenText ?? 'CLOUDFLARE WARP',
                            style: const TextStyle(
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
          Positioned(
            right: 8,
            top: 8,
            child: LanguageSelector(onChanged: (newLocale) {
              if (newLocale != null) {
                MyApp.setLocale(context, newLocale);
              }
            }),
          ),
        ],
      ),
    );
  }
}

