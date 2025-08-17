// network_speed_widget.dart

import 'package:flutter/material.dart';
import 'speed_details_content.dart';
import 'l10n/app_localizations.dart';

class NetworkSpeedWidget extends StatelessWidget {
  final bool isConnected;

  const NetworkSpeedWidget({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return IconButton(
      icon: const Icon(Icons.speed, color: Colors.grey),
      iconSize: 22,
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              title: Text(
                localizations.dataUsage,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SpeedDetailsContent(isConnected: isConnected),
              actions: [
                TextButton(
                  onPressed: () {
                    // O botão OK apenas fecha o diálogo.
                    Navigator.of(context).pop();
                  },
                  child: Text(localizations.ok, style: const TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

