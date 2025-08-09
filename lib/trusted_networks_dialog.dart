// trusted_networks_dialog.dart

import 'package:flutter/material.dart';

// Definição do tipo de função para o comando WARP CLI
typedef ExecuteWarpCommand = Future<String> Function(String, [List<String>]);

// Definição do tipo de função para o diálogo de SSIDs
typedef ShowTrustedSsidsDialog = void Function();

class TrustedNetworksDialog extends StatefulWidget {
  final ExecuteWarpCommand executeWarpCommand;
  final ShowTrustedSsidsDialog showTrustedSsidsDialog;

  const TrustedNetworksDialog({
    super.key,
    required this.executeWarpCommand,
    required this.showTrustedSsidsDialog,
  });

  @override
  State<TrustedNetworksDialog> createState() => _TrustedNetworksDialogState();
}

class _TrustedNetworksDialogState extends State<TrustedNetworksDialog> {
  bool _isTrustedEthernetEnabled = false;
  bool _isTrustedWifiEnabled = false;

  @override
  void initState() {
    super.initState();
    _getTrustedNetworkStatus();
  }
  
  Future<void> _getTrustedNetworkStatus() async {
    try {
      final ethernetStatus = await widget.executeWarpCommand('trusted', ['ethernet']);
      final wifiStatus = await widget.executeWarpCommand('trusted', ['wifi']);
      if (mounted) {
        setState(() {
          _isTrustedEthernetEnabled = ethernetStatus.contains('enabled');
          _isTrustedWifiEnabled = wifiStatus.contains('enabled');
        });
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Trusted Networks'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Manage trusted SSIDs'),
            onTap: () {
              Navigator.of(context).pop();
              widget.showTrustedSsidsDialog();
            },
          ),
          SwitchListTile(
            title: const Text('Toggle trusted Ethernet'),
            value: _isTrustedEthernetEnabled,
            onChanged: (bool value) async {
              final command = value ? 'enable' : 'disable';
              await widget.executeWarpCommand('trusted', ['ethernet', command]);
              if (mounted) {
                setState(() {
                  _isTrustedEthernetEnabled = value;
                });
              }
            },
          ),
          SwitchListTile(
            title: const Text('Toggle trusted Wi-Fi'),
            value: _isTrustedWifiEnabled,
            onChanged: (bool value) async {
              final command = value ? 'enable' : 'disable';
              await widget.executeWarpCommand('trusted', ['wifi', command]);
              if (mounted) {
                setState(() {
                  _isTrustedWifiEnabled = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
